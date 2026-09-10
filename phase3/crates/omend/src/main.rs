//! `omend` - fan curve service for the OMEN 16-ap0xxx.
//!
//! Why a daemon is needed: Phase 1 §6.4 established that HP's "Auto" fan curve
//! does not live in the EC but runs in the Windows application - OGH writes
//! the WMI 0x2E setpoint periodically. So `hp-wmi` on its own does not give
//! you automatic fan control; something has to run the curve. This is that.
//!
//! The EC *does* have an automatic mode of its own and it is not bad (Phase 2:
//! fan-stop at 45 C, 2400 RPM at 58 C). So we leave the lower part of the
//! curve to it and only take over when we want more.

mod guard;
mod server;
mod shared;

use std::process::ExitCode;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::time::{Duration, Instant};

use anyhow::{Context, Result};
use log::{debug, error, info, warn};

use omen_core::config::Config;
use omen_core::curve::Governor;
use omen_core::fan::Fan;
use omen_core::ipc::{ControlMode, Snapshot};
use omen_core::profile::PlatformProfile;
use omen_core::thermal::Thermal;

use crate::guard::AutoRestore;
use crate::shared::Shared;

const USAGE: &str = "\
omend - fan curve service for the OMEN 16-ap0xxx

USAGE:
    omend [OPTIONS]

OPTIONS:
    -c, --config <PATH>  Configuration file (default: /etc/omen/omend.toml)
        --dry-run        Write nothing; log what would be done
        --once           Run a single iteration and exit (for diagnostics)
        --restore-auto   Return the fan to automatic and exit (systemd ExecStopPost)
    -h, --help           Show this text

EXAMPLE:
    omend --dry-run --once        # safe: changes nothing
";

struct Args {
    config: std::path::PathBuf,
    dry_run: bool,
    once: bool,
    restore_auto: bool,
}

fn parse_args() -> Result<Option<Args>> {
    let mut args = Args {
        config: Config::default_path(),
        dry_run: false,
        once: false,
        restore_auto: false,
    };
    let mut it = std::env::args().skip(1);
    while let Some(arg) = it.next() {
        match arg.as_str() {
            "-h" | "--help" => {
                print!("{USAGE}");
                return Ok(None);
            }
            "-c" | "--config" => args.config = it.next().context("--config expects a path")?.into(),
            "--dry-run" => args.dry_run = true,
            "--once" => args.once = true,
            "--restore-auto" => args.restore_auto = true,
            other => anyhow::bail!("unknown option: {other}\n\n{USAGE}"),
        }
    }
    Ok(Some(args))
}

fn main() -> ExitCode {
    env_logger::Builder::from_env(env_logger::Env::default().default_filter_or("info"))
        .format_timestamp_secs()
        .init();

    let args = match parse_args() {
        Ok(Some(a)) => a,
        Ok(None) => return ExitCode::SUCCESS,
        Err(e) => {
            eprintln!("{e}");
            return ExitCode::from(2);
        }
    };

    match run(args) {
        Ok(()) => ExitCode::SUCCESS,
        Err(e) => {
            error!("{e:#}");
            ExitCode::FAILURE
        }
    }
}

fn run(args: Args) -> Result<()> {
    // Safety rule 1, third door: on SIGKILL `Drop` does not run. systemd
    // ExecStopPost calls this, so the fan returns to automatic no matter how
    // the daemon died. It deliberately ignores the configuration - a broken
    // file must not make the recovery step fail.
    if args.restore_auto {
        let fan = Fan::discover(
            omen_core::fan::DEFAULT_MIN_RPM,
            omen_core::fan::DEFAULT_MAX_RPM,
        )
        .context("fan not found")?;
        // Same decision as the in-process exit path, and the same code, so
        // the two cannot drift apart. Defaults rather than the config file:
        // a broken config must not make the recovery step fail.
        guard::park(
            &fan,
            Thermal::discover().ok().as_ref(),
            omen_core::config::SafetyConfig::default().stall_temp_c,
        );
        return Ok(());
    }

    let cfg = Config::load(&args.config).with_context(|| {
        format!(
            "could not read the configuration: {}",
            args.config.display()
        )
    })?;

    let thermal = Thermal::discover().context("no temperature source found")?;
    let fan =
        Fan::discover(cfg.fan.min_rpm, cfg.fan.max_rpm).context("could not set up fan control")?;

    info!(
        "hwmon: {}  fan range: {}-{} RPM  step: {} RPM  interval: {}s",
        fan.hwmon_path().display(),
        fan.min_rpm(),
        fan.max_rpm(),
        cfg.fan.step_rpm,
        cfg.fan.interval_secs
    );
    info!(
        "temperature sources: {}",
        thermal
            .sensors
            .iter()
            .map(|s| s.label.as_str())
            .collect::<Vec<_>>()
            .join(", ")
    );

    // If hp-wmi is not among the profile handlers the 8D24 patch did not take
    // effect. The fan may still work, but we want to know.
    if !PlatformProfile::hp_wmi_active() {
        warn!("hp-wmi is not among the platform profile handlers - the 8D24 patch may be missing");
    }

    let read_only = args.dry_run || !cfg.fan.enabled;
    if !cfg.fan.enabled {
        warn!("fan.enabled = false - the curve is not being run, only observed");
    }
    if args.dry_run {
        warn!("--dry-run: nothing will be written");
    }

    let hot_above_c = cfg.safety.stall_temp_c;
    let mut rt = Runtime::new(fan.clone(), thermal, cfg, read_only)?;
    rt.log_curve();

    let mut keeper = AutoRestore::new(
        fan,
        Thermal::discover().context("no temperature source found")?,
        hot_above_c,
    );
    if read_only {
        keeper.disarm();
    }

    let shared = Shared::new();
    // A single diagnostic iteration does not open a socket. --dry-run does:
    // changing the mode and watching what would happen is exactly what
    // dry-run is for. Use OMEND_SOCKET to avoid clashing with a real daemon.
    if !args.once {
        server::spawn(shared.clone())?;
    }

    let stop = Arc::new(AtomicBool::new(false));
    for sig in [signal_hook::consts::SIGTERM, signal_hook::consts::SIGINT] {
        signal_hook::flag::register(sig, Arc::clone(&stop))
            .with_context(|| format!("could not install a handler for signal {sig}"))?;
    }

    loop {
        rt.tick(&shared, &args.config);

        if args.once || stop.load(Ordering::Relaxed) {
            break;
        }
        // Wait until the next sample. A request wakes us early; the slicing is
        // there so we can check the signal flag (SIGTERM cannot be delivered
        // through the condvar).
        let deadline = Instant::now() + rt.cfg.interval();
        while Instant::now() < deadline && !stop.load(Ordering::Relaxed) {
            shared.wait_until(deadline, Duration::from_millis(200));
            if shared.has_pending() {
                break;
            }
        }
        if stop.load(Ordering::Relaxed) {
            break;
        }
    }

    info!("shutting down");
    let _ = std::fs::remove_file(omen_core::ipc::socket_path());
    // `keeper` drops here and returns the fan to automatic.
    Ok(())
}

/// An active safety override: the fans have been forced to full power and
/// normal driving is suspended until the temperature comes back down.
///
/// This used to hand control to the EC instead. That was wrong, and the
/// machine demonstrated it: with `pwm1_enable = 2` the fans sat at 0 RPM
/// while the CPU climbed 78 -> 85 C in twelve seconds under load, and the
/// cutout - whose only action was to hand control to the EC - fired at 98 C
/// and changed nothing, because the fan was already there. A safety net
/// whose action is "give the problem back to whatever caused it" is not a
/// safety net. At these temperatures the only defensible action is full
/// power.
#[derive(Debug)]
struct Emergency {
    reason: String,
    /// Normal driving resumes once the temperature falls below this. `None`
    /// when the trigger was not a temperature threshold, so waiting for a big
    /// drop would make no sense.
    recover_below: Option<f32>,
    /// Full power is held at least this long, so the machine cannot flap
    /// between the override and whatever tripped it.
    hold_until: Instant,
}

/// What did we last write to the fan? Used to avoid rewriting the same value.
#[derive(Debug, Clone, Copy, PartialEq)]
enum Applied {
    Unknown,
    Auto,
    Rpm(u32),
    Max,
}

struct Runtime {
    fan: Fan,
    thermal: Thermal,
    cfg: Config,
    governor: Governor,
    emergency: Option<Emergency>,
    /// When the fans were first seen stopped while hot. `None` means they are
    /// either moving or the machine is cool.
    stall_since: Option<Instant>,
    mode: ControlMode,
    applied: Applied,
    read_only: bool,
    started: Instant,
}

impl Runtime {
    fn new(fan: Fan, thermal: Thermal, cfg: Config, read_only: bool) -> Result<Self> {
        let governor = Governor::new(
            cfg.curve()?,
            cfg.fan.hysteresis_c,
            cfg.min_dwell(),
            cfg.fan.step_rpm,
        );
        Ok(Self {
            fan,
            thermal,
            cfg,
            governor,
            emergency: None,
            stall_since: None,
            mode: ControlMode::Curve,
            applied: Applied::Unknown,
            read_only,
            started: Instant::now(),
        })
    }

    fn log_curve(&self) {
        info!(
            "curve: {}",
            self.governor
                .curve()
                .points()
                .iter()
                .map(|p| if p.rpm == 0 {
                    format!("{:.0}C:auto", p.temp_c)
                } else {
                    format!("{:.0}C:{}", p.temp_c, p.rpm)
                })
                .collect::<Vec<_>>()
                .join(" -> ")
        );
    }

    fn tick(&mut self, shared: &Shared, config_path: &std::path::Path) {
        self.handle_requests(shared, config_path);

        let temp = match self.thermal.hottest() {
            Ok(v) => Some(v),
            Err(e) => {
                // Safety rule 3: if the temperature cannot be read we are
                // flying blind. Full power is the only state we can be sure
                // about; the EC cannot be trusted to take over (see
                // Emergency).
                if self.emergency.is_none() {
                    // Nothing to compare against, so resume as soon as a
                    // reading comes back.
                    self.declare_emergency(
                        format!("no temperature could be read ({e})"),
                        None,
                        Duration::from_secs(0),
                    );
                }
                None
            }
        };

        if let Some((label, celsius)) = &temp {
            if self.guard(label, *celsius) {
                self.drive(label, *celsius);
            }
        }

        shared.publish(self.snapshot(temp));
        shared.finish_tick();
    }

    fn handle_requests(&mut self, shared: &Shared, config_path: &std::path::Path) {
        if shared.take_reload() {
            match Config::load(config_path) {
                Ok(cfg) => match cfg.curve() {
                    Ok(curve) => {
                        self.governor = Governor::new(
                            curve,
                            cfg.fan.hysteresis_c,
                            cfg.min_dwell(),
                            cfg.fan.step_rpm,
                        );
                        self.cfg = cfg;
                        self.applied = Applied::Unknown;
                        info!("configuration re-read");
                        self.log_curve();
                    }
                    Err(e) => error!("the new curve is invalid, keeping the old one: {e}"),
                },
                Err(e) => error!("could not read the configuration, keeping the old one: {e}"),
            }
        }

        if let Some(mode) = shared.take_request() {
            if mode != self.mode {
                info!("mode: {} -> {mode}", self.mode);
                self.mode = mode;
                // Decide from scratch in the new mode.
                self.governor.reset();
                self.applied = Applied::Unknown;
            }
        }
    }

    /// Everything that can override normal driving, in order of severity.
    ///
    /// Returns `true` when normal driving may continue.
    fn guard(&mut self, label: &str, temp: f32) -> bool {
        // Already in an emergency: hold full power until it is properly cool
        // again. Leaving early just re-enters it a few seconds later.
        if let Some(e) = &self.emergency {
            let still_hot = e.recover_below.is_some_and(|limit| temp > limit);
            if Instant::now() < e.hold_until || still_hot {
                debug!("emergency hold ({}), {label} {temp:.1}C", e.reason);
                self.apply(Applied::Max, "emergency");
                return false;
            }
            info!("{label} {temp:.1}C - leaving emergency ({})", e.reason);
            self.emergency = None;
            self.stall_since = None;
            self.applied = Applied::Unknown;
            return true;
        }

        // The critical cutout. Applies in EVERY mode - a manual request from
        // the user does not disable thermal protection.
        if temp >= self.cfg.safety.critical_c {
            // A temperature threshold tripped this, so a temperature drop is
            // the right thing to wait for.
            self.declare_emergency(
                format!(
                    "{label} {temp:.1}C >= critical {:.1}C",
                    self.cfg.safety.critical_c
                ),
                Some(self.cfg.safety.critical_c - self.cfg.safety.recover_delta_c),
                Duration::from_secs(10),
            );
            return false;
        }

        // Cooling failure: hot, and the fans are not turning.
        //
        // This is the check that would have caught the incident. It is
        // deliberately about BEHAVIOUR rather than about a particular mode -
        // whatever the reason the fans are stopped, stopped fans at this
        // temperature are wrong.
        let stopped = matches!((self.fan.rpm(1), self.fan.rpm(2)), (Ok(0), Ok(0)));
        if stopped && temp >= self.cfg.safety.stall_temp_c {
            let since = *self.stall_since.get_or_insert_with(Instant::now);
            if since.elapsed() >= self.cfg.stall_grace() {
                // Deliberately NOT waiting for a big temperature drop here.
                // The condition was "fans stopped", and forcing full power
                // ends it immediately - the fans are turning. Under a
                // sustained load the machine never reaches a low temperature,
                // so a temperature-based recovery would pin it at full power
                // for as long as the load lasts. A fixed hold is enough: if
                // the cause is still there, the detector fires again.
                self.declare_emergency(
                    format!(
                        "{label} {temp:.1}C with both fans stopped for {}s",
                        since.elapsed().as_secs()
                    ),
                    None,
                    Duration::from_secs(20),
                );
                // Auto is the mode that produces this on purpose, by handing
                // the fans to an EC that does not take them. Staying in it
                // would oscillate between full power and no cooling, so we
                // take the machine back to the curve and say so.
                if self.mode == ControlMode::Auto {
                    warn!("auto mode is not cooling this machine - switching to the curve");
                    self.mode = ControlMode::Curve;
                    self.governor.reset();
                }
                return false;
            }
            debug!("{label} {temp:.1}C, fans stopped for {:?}", since.elapsed());
        } else {
            self.stall_since = None;
        }

        true
    }

    fn declare_emergency(&mut self, reason: String, recover_below: Option<f32>, hold: Duration) {
        error!("EMERGENCY: {reason} - forcing the fans to full power");
        self.emergency = Some(Emergency {
            reason,
            recover_below,
            hold_until: Instant::now() + hold,
        });
        self.governor.reset();
        self.applied = Applied::Unknown;
        self.apply(Applied::Max, "emergency");
    }

    fn drive(&mut self, label: &str, temp: f32) {
        match self.mode {
            ControlMode::Curve => {
                let Some(target) = self.governor.decide(temp, Instant::now()) else {
                    debug!("{label} {temp:.1}C - no change");
                    return;
                };
                match target {
                    None => self.apply(Applied::Auto, &format!("{label} {temp:.1}C")),
                    Some(rpm) => self.apply(Applied::Rpm(rpm), &format!("{label} {temp:.1}C")),
                }
            }
            ControlMode::Manual { rpm } => self.apply(Applied::Rpm(rpm), "manual"),
            ControlMode::Auto => self.apply(Applied::Auto, "manual"),
            ControlMode::Max => self.apply(Applied::Max, "manual"),
        }
    }

    fn apply(&mut self, want: Applied, why: &str) {
        if want == self.applied {
            return;
        }
        match want {
            Applied::Rpm(rpm) => {
                info!("{why} -> {rpm} RPM (pwm {})", self.fan.rpm_to_pwm(rpm));
                if self.read_only {
                    self.applied = want;
                    return;
                }
                match self.fan.set_target_rpm(rpm) {
                    Ok(actual) => {
                        if actual != rpm {
                            debug!("{rpm} RPM requested, clamped to {actual} RPM");
                        }
                        self.applied = Applied::Rpm(actual);
                    }
                    Err(e) => {
                        // A failed write leaves the setpoint in an unknown
                        // state, and the EC will not pick the curve up on its
                        // own. Full power is the state we can be sure about.
                        let reason = format!("could not write the setpoint ({e})");
                        self.declare_emergency(reason, None, Duration::from_secs(20));
                    }
                }
            }
            Applied::Auto => {
                info!("{why} -> automatic (control with the EC)");
                if !self.read_only {
                    if let Err(e) = self.fan.restore_auto() {
                        error!("could not switch to automatic: {e}");
                        return;
                    }
                }
                self.applied = want;
            }
            Applied::Max => {
                warn!("{why} -> FANS AT FULL POWER");
                if !self.read_only {
                    if let Err(e) = self.fan.set_mode(omen_core::fan::PwmMode::Max) {
                        error!("could not switch to full power: {e}");
                        return;
                    }
                }
                self.applied = want;
            }
            Applied::Unknown => {}
        }
    }

    fn snapshot(&self, driver: Option<(String, f32)>) -> Snapshot {
        Snapshot {
            mode: Some(self.mode),
            hw_mode: self.fan.mode().ok().map(|m| m.to_string()),
            driver_label: driver.as_ref().map(|(l, _)| l.clone()),
            driver_temp_c: driver.as_ref().map(|(_, c)| *c),
            target_rpm: match self.applied {
                Applied::Rpm(rpm) => Some(rpm),
                _ => None,
            },
            fan1_rpm: self.fan.rpm(1).ok(),
            fan2_rpm: self.fan.rpm(2).ok(),
            pwm: self.fan.pwm().ok(),
            profile: PlatformProfile::discover().and_then(|p| p.get().ok()),
            safety_fallback: self.emergency.is_some(),
            safety_reason: self.emergency.as_ref().map(|e| e.reason.clone()),
            temps: self
                .thermal
                .read_all()
                .into_iter()
                .filter_map(|(l, v)| v.ok().map(|c| (l, c)))
                .collect(),
            uptime_secs: self.started.elapsed().as_secs(),
        }
    }
}
