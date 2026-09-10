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
        fan.restore_auto()
            .context("could not return the fan to automatic")?;
        info!("fan returned to automatic (pwm1_enable=2)");
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

    let mut rt = Runtime::new(fan.clone(), thermal, cfg, read_only)?;
    rt.log_curve();

    let mut keeper = AutoRestore::new(fan);
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

#[derive(Debug, PartialEq)]
enum SafetyState {
    Normal,
    /// The curve has been abandoned, control is with the EC. The reason was
    /// logged.
    Fallback,
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
    state: SafetyState,
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
            state: SafetyState::Normal,
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
                // Safety rule 3: if the temperature cannot be read, do not run
                // the curve.
                if self.state != SafetyState::Fallback {
                    error!("could not read a temperature ({e}) - falling back to automatic");
                    self.fall_back();
                }
                None
            }
        };

        if let Some((label, celsius)) = &temp {
            if self.check_safety(label, *celsius) {
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

    /// The critical cutout. Applies in EVERY mode - a manual request from the
    /// user does not disable thermal protection.
    ///
    /// `true` -> normal driving may continue.
    fn check_safety(&mut self, label: &str, temp: f32) -> bool {
        match self.state {
            SafetyState::Normal if temp >= self.cfg.safety.critical_c => {
                error!(
                    "{label} {temp:.1}C >= critical {:.1}C - control handed to the EC",
                    self.cfg.safety.critical_c
                );
                self.fall_back();
                false
            }
            SafetyState::Fallback => {
                let recover_at = self.cfg.safety.critical_c - self.cfg.safety.recover_delta_c;
                if temp > recover_at {
                    debug!("in safety fallback, {label} {temp:.1}C > {recover_at:.1}C");
                    return false;
                }
                info!("{label} {temp:.1}C <= {recover_at:.1}C - taking control back");
                self.state = SafetyState::Normal;
                true
            }
            SafetyState::Normal => true,
        }
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
                        // state. Handing control back is the safest response.
                        error!("could not write the setpoint ({e}) - falling back to automatic");
                        self.fall_back();
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

    fn fall_back(&mut self) {
        self.state = SafetyState::Fallback;
        // Do not let hysteresis hold on to the old decision; decide fresh on
        // the way out.
        self.governor.reset();
        self.applied = Applied::Unknown;
        if self.read_only {
            return;
        }
        if let Err(e) = self.fan.restore_auto() {
            error!("CRITICAL: could not switch to automatic: {e}");
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
            safety_fallback: self.state == SafetyState::Fallback,
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
