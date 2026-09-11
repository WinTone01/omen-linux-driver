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

mod appwatch;
mod guard;
mod hotkey;
mod lighting;
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
use omen_core::gpu;
use omen_core::ipc::{ControlMode, CurveSpec, Snapshot};
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

    // Without the dGPU the curve is blind to most of the heat a game makes,
    // and the only symptom is fans that stay quiet while the machine cooks.
    // Worth saying out loud rather than leaving to be discovered.
    if !thermal.has_dgpu() {
        warn!(
            "the discrete GPU is not being watched - load 'ec_sys' so it can be read \
             (modprobe ec_sys write_support=0); without it the curve only follows the CPU"
        );
    }

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
    let mut rt = Runtime::new(fan.clone(), thermal, cfg, read_only, &args.config)?;
    rt.log_curve();
    rt.apply_startup_profile();

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
        server::spawn(shared.clone(), args.config.clone())?;
    }

    // Effects are a long-running thing, so a single diagnostic pass does not
    // start one. --dry-run does not either: the flag means "write nothing".
    let lights = (!args.once && !args.dry_run)
        .then(|| lighting::Lighting::start(rt.cfg.lighting.clone()))
        .flatten();

    // The OMEN key cycles the performance profile. Not for --once, which is
    // a single diagnostic pass, and not for --dry-run, which promises to
    // write nothing.
    if !args.once && !args.dry_run {
        hotkey::spawn();
    }

    // What the backlight rule last asked for, so it is only asked again when
    // the answer changes.
    let mut backlight_state: Option<bool> = None;

    let stop = Arc::new(AtomicBool::new(false));
    for sig in [signal_hook::consts::SIGTERM, signal_hook::consts::SIGINT] {
        signal_hook::flag::register(sig, Arc::clone(&stop))
            .with_context(|| format!("could not install a handler for signal {sig}"))?;
    }

    loop {
        rt.tick(&shared, &args.config);
        if let (Some(lights), Some(cfg)) = (lights.as_ref(), rt.take_lighting_change()) {
            lights.update(cfg);
        }

        // The keyboard follows the power source, when asked to. Edge-driven
        // like the rest of the power rule: someone who turns the backlight
        // back on while on battery should be able to keep it on.
        let want_backlight = rt.backlight_wanted();
        if want_backlight != backlight_state {
            if let (Some(lights), Some(on)) = (lights.as_ref(), want_backlight) {
                lights.backlight(on);
            }
            backlight_state = want_backlight;
        }

        rt.remember_zones(lights.as_ref(), &args.config);

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

/// How often the keyboard's colours are compared with the remembered ones.
const ZONE_REMEMBER_EVERY: Duration = Duration::from_secs(60);

/// How many decisions are kept for the UI. At one change every few seconds
/// under a varying load, this is roughly the last hour of interesting
/// behaviour; the journal has the rest.
const HISTORY_MAX: usize = 200;

/// How often a setpoint we already hold is written again. See apply().
const SETPOINT_KEEPALIVE: Duration = Duration::from_secs(10);

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
    /// Fans off, still under our setpoint. The bottom of the curve.
    Idle,
    /// Control handed to the EC. Only ever a deliberate user request now -
    /// the curve does not go here, because the EC does not take its curve
    /// back and the fans stay stopped while the machine heats up.
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
    /// Set when a reload brought a new lighting configuration, so the main
    /// loop can hand it to the lighting thread. The thread is not reachable
    /// from here, and it should not be - it is not part of fan control.
    lighting_changed: bool,
    apps: appwatch::AppWatch,
    /// Last known power source, so a rule is applied on the change rather
    /// than on every tick - otherwise it could not be overridden.
    on_ac: Option<bool>,
    /// A dust-clearing run: full power until this passes, then back to the
    /// mode that was in force when it started.
    cleaning: Option<(Instant, ControlMode)>,
    /// When the keyboard colours were last compared with the remembered set.
    zones_checked: Instant,
    /// Set when the hardware disagrees with our last setpoint, with the
    /// details. Reported rather than only logged - see check_drift.
    drift: Option<String>,
    /// The last few setpoint decisions, for the UI. Bounded: this is a
    /// daemon that runs for weeks.
    history: std::collections::VecDeque<omen_core::ipc::Decision>,
    /// The most recent sensor reading, so a decision can record what drove
    /// it without the temperature being passed through four call sites.
    last_reading: Option<(String, f32)>,
    /// When the disagreement was first seen.
    drift_since: Option<Instant>,
    config_path: std::path::PathBuf,
    /// When the process list was last scanned.
    apps_scanned: Instant,
    /// When the current setpoint was last written, for the keep-alive.
    applied_at: Instant,
    gpu: gpu::Watch,
    started: Instant,
}

impl Runtime {
    fn new(
        fan: Fan,
        thermal: Thermal,
        cfg: Config,
        read_only: bool,
        config_path: &std::path::Path,
    ) -> Result<Self> {
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
            lighting_changed: false,
            apps: appwatch::AppWatch::new(),
            on_ac: None,
            cleaning: None,
            zones_checked: Instant::now(),
            drift: None,
            history: std::collections::VecDeque::new(),
            last_reading: None,
            drift_since: None,
            config_path: config_path.to_owned(),
            // Scan on the first tick rather than one interval in: a daemon
            // starting while a game is already open should notice it.
            apps_scanned: Instant::now() - Duration::from_secs(3600),
            applied_at: Instant::now(),
            gpu: gpu::Watch::new(),
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
        self.check_drift();

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

        self.apply_power_rule();
        self.scan_apps();
        self.apply_gpu_power();

        self.last_reading = temp.clone();

        if let Some((label, celsius)) = &temp {
            if self.guard(label, *celsius) {
                self.drive(label, *celsius);
            }
        }

        shared.publish(self.snapshot(temp));
        shared.publish_history(self.history(HISTORY_MAX));
        shared.finish_tick();
    }

    /// Adds a decision to the log kept for the UI.
    ///
    /// Only on a change: the keep-alive rewrites the same setpoint every ten
    /// seconds, and a log of "still 2400 RPM" six times a minute would bury
    /// the moments that matter.
    fn record(&mut self, want: Applied, why: &str) {
        let (label, temp_c) = self
            .last_reading
            .clone()
            .unwrap_or_else(|| ("?".to_string(), f32::NAN));

        self.history.push_back(omen_core::ipc::Decision {
            uptime_secs: self.started.elapsed().as_secs(),
            label,
            temp_c,
            target_rpm: match want {
                Applied::Rpm(rpm) => Some(rpm),
                Applied::Idle => Some(0),
                Applied::Max => Some(self.cfg.fan.max_rpm),
                Applied::Auto | Applied::Unknown => None,
            },
            reason: why.to_owned(),
        });
        while self.history.len() > HISTORY_MAX {
            self.history.pop_front();
        }
    }

    /// Looks for the hwmon again, for when the one we had went away.
    ///
    /// hp-wmi's hwmon is numbered by registration order, so rebuilding and
    /// reloading the module - which this project does every time it is
    /// upgraded - moves it. The cached path then points at nothing, every
    /// write fails, and the old behaviour was to treat that as a cooling
    /// failure and force the fans to full. Looking again first is strictly
    /// better: if it worked, nothing was ever wrong.
    ///
    /// Returns true when a usable fan was found at a NEW path.
    ///
    /// Note that the restore-on-exit guard keeps its own handle, taken at
    /// startup. If the module is reloaded, its path is stale too and the
    /// restore it performs on exit will fail and be logged. That is benign:
    /// the fans are left at the last setpoint, which a module reload has
    /// already reset anyway.
    fn rediscover_fan(&mut self) -> bool {
        let Ok(found) = Fan::discover(self.cfg.fan.min_rpm, self.cfg.fan.max_rpm) else {
            return false;
        };
        if found.hwmon_path() == self.fan.hwmon_path() {
            return false;
        }
        warn!(
            "the fan moved from {} to {} - the module was probably reloaded",
            self.fan.hwmon_path().display(),
            found.hwmon_path().display()
        );
        self.fan = found;
        self.applied = Applied::Unknown;
        true
    }

    /// Compares what the hardware reports with what we last wrote.
    ///
    /// Everything else in this daemon assumes a write that returned Ok stayed
    /// written, and the history of this project says that is optimistic: the
    /// EC has a watchdog on manual control, another tool can write pwm1, and
    /// a suspend or a module reload re-initialises the controller. The
    /// setpoint is re-asserted every ten seconds anyway; this notices when it
    /// had to be, which is the difference between "under control" and
    /// "believed to be under control".
    ///
    /// Two ticks before it counts. One is a race: the read can land between
    /// our write and the firmware applying it.
    fn check_drift(&mut self) {
        // Nothing was written, so there is nothing to have stuck. In
        // read-only mode the daemon keeps a model of what it WOULD have set,
        // and comparing that against hardware someone else is driving
        // reports a disagreement on every tick.
        if self.read_only {
            return;
        }
        let want = match self.applied {
            Applied::Rpm(rpm) => Some(self.fan.rpm_to_pwm(rpm)),
            Applied::Idle => Some(0),
            // Max and Auto are modes rather than setpoints; pwm1 is not
            // meaningful in them.
            _ => None,
        };
        let Some(want) = want else {
            self.drift_since = None;
            self.drift = None;
            return;
        };

        let hw = match (self.fan.pwm(), self.fan.mode()) {
            (Ok(pwm), Ok(mode)) => Some((pwm, mode)),
            _ => None,
        };
        let Some((pwm, mode)) = hw else { return };

        let agrees = pwm == want && mode == omen_core::fan::PwmMode::Manual;
        if agrees {
            if self.drift.is_some() {
                info!("the setpoint is being honoured again");
            }
            self.drift_since = None;
            self.drift = None;
            return;
        }

        match self.drift_since {
            None => self.drift_since = Some(Instant::now()),
            Some(since) if since.elapsed() >= self.cfg.interval() => {
                let message =
                    format!("wrote pwm {want} in manual, hardware reports pwm {pwm} in {mode}");
                if self.drift.as_deref() != Some(message.as_str()) {
                    warn!("the fan setpoint did not stick: {message}");
                }
                self.drift = Some(message);
                // Write it again from scratch. The keep-alive would get there
                // within ten seconds; there is no reason to wait once we know.
                self.applied = Applied::Unknown;
            }
            Some(_) => {}
        }
    }

    /// Starts a dust-clearing run.
    ///
    /// Bounded at both ends: a couple of seconds does nothing useful, and a
    /// run long enough to be forgotten about is a laptop screaming on a desk
    /// while its owner is in another room.
    fn start_cleaning(&mut self, seconds: u64) -> u64 {
        let seconds = seconds.clamp(5, 120);
        let previous = self.cleaning.map(|(_, before)| before).unwrap_or(self.mode);
        self.cleaning = Some((Instant::now() + Duration::from_secs(seconds), previous));
        info!("clearing dust for {seconds}s, then back to {previous}");
        seconds
    }

    /// Remembers the zone colours, so they can be put back after a reboot.
    ///
    /// Polled rather than hooked: the colours can be changed by anything with
    /// write access to the LED class - this window, brightnessctl, a script -
    /// and there is no notification for it. Once a minute is often enough for
    /// something that is only read at startup, and the config is only written
    /// when they have actually changed.
    fn remember_zones(
        &mut self,
        lights: Option<&lighting::Lighting>,
        config_path: &std::path::Path,
    ) {
        if !self.cfg.lighting.restore_on_start
            || self.cfg.lighting.effect != omen_core::anim::Effect::None
            || self.zones_checked.elapsed() < ZONE_REMEMBER_EVERY
        {
            return;
        }
        self.zones_checked = Instant::now();

        let Some(lights) = lights else { return };
        let Some(zones) = lights.zones() else { return };
        let as_arrays: Vec<[u8; 3]> = zones.iter().map(|c| [c.r, c.g, c.b]).collect();
        if as_arrays == self.cfg.lighting.zones {
            return;
        }

        // Written through a freshly loaded config so a hand edit made since
        // the daemon started is not thrown away by this.
        match Config::load(config_path) {
            Ok(mut on_disk) => {
                on_disk.lighting.zones = as_arrays.clone();
                if let Err(e) = on_disk.save(config_path) {
                    debug!("could not remember the keyboard colours: {e}");
                    return;
                }
                self.cfg.lighting.zones = as_arrays;
                debug!("keyboard colours remembered");
            }
            Err(e) => debug!("could not re-read the configuration to remember colours: {e}"),
        }
    }

    /// Applies the mains/battery rule when the power source changes.
    ///
    /// On the change, not on every tick: a rule that re-applied continuously
    /// could not be overridden, which would make the profile buttons in the
    /// UI stop working while plugged in. And application profiles win - a
    /// game asking for performance is a more specific statement than "this
    /// machine is on battery".
    fn apply_power_rule(&mut self) {
        let now = omen_core::power::on_ac();
        if now == self.on_ac || now.is_none() {
            return;
        }
        let first = self.on_ac.is_none();
        self.on_ac = now;
        let on_ac = now.unwrap();

        let rule = if on_ac {
            self.cfg.automation.on_ac.clone()
        } else {
            self.cfg.automation.on_battery.clone()
        };
        if rule.is_empty() {
            return;
        }
        // At startup the startup_profile has just been applied; letting a
        // power rule immediately overwrite it would make that setting look
        // broken. The rule takes over from the first change onwards.
        if first && self.cfg.automation.startup_profile.is_some() {
            return;
        }
        if self.apps.active().is_some() {
            debug!("power source changed, but an application profile is in force");
            return;
        }

        info!(
            "{} -> {}",
            if on_ac { "on mains" } else { "on battery" },
            rule.summary()
        );

        if let Some(want) = &rule.profile {
            match PlatformProfile::discover() {
                Some(pp) if pp.choices().contains(want) => {
                    if let Err(e) = pp.set(want) {
                        warn!("could not set the {want} profile: {e}");
                    }
                }
                Some(pp) => warn!("{want:?} is not one of {}", pp.choices().join(" ")),
                None => warn!("no platform_profile to set"),
            }
        }
        if let Some(mode) = rule.fan {
            if mode != self.mode {
                self.mode = mode;
                self.governor.reset();
                self.applied = Applied::Unknown;
            }
        }
    }

    /// Whether the keyboard backlight should be on, given the power source.
    /// `None` when the setting is off and nothing should be done either way.
    fn backlight_wanted(&self) -> Option<bool> {
        self.cfg
            .lighting
            .off_on_battery
            .then(|| self.on_ac.unwrap_or(true))
    }

    /// Looks for a configured application, and applies or restores its
    /// profile. The watcher asks for a fan mode; the loop is still the only
    /// thing that sets one.
    /// Selects the configured starting profile, once, at startup.
    ///
    /// Only at startup: doing it on every reload would fight the user every
    /// time the configuration is re-read, and fight the application profiles
    /// every time one of them ends.
    fn apply_startup_profile(&self) {
        let Some(want) = self.cfg.automation.startup_profile.clone() else {
            return;
        };
        if self.read_only {
            return;
        }
        match PlatformProfile::discover() {
            Some(pp) if pp.choices().contains(&want) => match pp.set(&want) {
                Ok(()) => info!("startup profile: {want}"),
                Err(e) => warn!("could not select the {want} profile at startup: {e}"),
            },
            Some(pp) => warn!(
                "startup_profile {want:?} is not one of {}",
                pp.choices().join(" ")
            ),
            None => warn!("startup_profile is set but there is no platform_profile"),
        }
    }

    /// Keeps the dGPU's power policy where the configuration says.
    ///
    /// Re-asserted rather than set once: udev rules, driver reloads and
    /// resume can all put it back, and a setting that silently stops applying
    /// is worse than one that was never offered.
    fn apply_gpu_power(&mut self) {
        if self.read_only {
            return;
        }
        let want = self.cfg.graphics.dgpu_power;
        let Some(gpu) = self.gpu.get() else {
            return;
        };
        if gpu.control == want.as_str() {
            return;
        }
        match omen_core::gpu::set_power(want) {
            Ok(()) => info!("dGPU runtime power: {} -> {want}", gpu.control),
            Err(e) => warn!("could not set the dGPU power policy to {want}: {e}"),
        }
        self.gpu.invalidate();
    }

    fn scan_apps(&mut self) {
        if self.cfg.apps.is_empty() || self.apps_scanned.elapsed() < self.cfg.app_scan_interval() {
            return;
        }
        self.apps_scanned = Instant::now();

        let actions = self.apps.poll(&self.cfg.apps, self.mode);
        if let Some(mode) = actions.mode {
            if mode != self.mode {
                self.mode = mode;
                self.governor.reset();
                self.applied = Applied::Unknown;
            }
        }
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
                        if cfg.lighting != self.cfg.lighting {
                            self.lighting_changed = true;
                        }
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

        if let Some(seconds) = shared.take_clean() {
            self.start_cleaning(seconds);
            self.applied = Applied::Unknown;
        }

        if let Some(mode) = shared.take_request() {
            // Asking for a mode ends a dust run: it is an explicit
            // instruction about the fans, which is what a cleaning run is
            // too, and the newer one wins.
            if self.cleaning.take().is_some() {
                info!("dust clearing cancelled");
            }
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
        // A dust run is a user request for full power with an end time. It
        // sits here rather than in guard() on purpose: guard() is for the
        // safety overrides, and a cleaning run must not be able to mask one -
        // if the machine overheats during it, the emergency still takes over
        // and this ends when its timer does.
        if let Some((until, previous)) = self.cleaning {
            if Instant::now() < until {
                self.apply(Applied::Max, "clearing dust");
                return;
            }
            info!("dust clearing finished, back to {previous}");
            self.cleaning = None;
            self.mode = previous;
            self.governor.reset();
            self.applied = Applied::Unknown;
        }

        match self.mode {
            ControlMode::Curve => {
                let Some(target) = self.governor.decide(temp, Instant::now()) else {
                    debug!("{label} {temp:.1}C - no change");
                    return;
                };
                match target {
                    None => self.apply(Applied::Idle, &format!("{label} {temp:.1}C")),
                    Some(rpm) => self.apply(Applied::Rpm(rpm), &format!("{label} {temp:.1}C")),
                }
            }
            ControlMode::Manual { rpm } => self.apply(Applied::Rpm(rpm), "manual"),
            ControlMode::Auto => self.apply(Applied::Auto, "manual"),
            ControlMode::Max => self.apply(Applied::Max, "manual"),
        }
    }

    fn apply(&mut self, want: Applied, why: &str) {
        // Re-assert a setpoint we already hold, from time to time.
        //
        // We are not the only thing that can change it: the EC has a watchdog
        // on manual fan control (Phase 1 3.3, EC 0x63), another tool may write
        // pwm1, and a suspend/resume cycle re-initialises the controller.
        // Whatever the cause, the state it falls back to is the one that is
        // dangerous here - fans stopped, nobody driving - so it is worth one
        // WMI call every ten seconds to know we still mean it. omen-space
        // rewrites its duty on the same interval, for the same reason.
        let repeat = want == self.applied;
        if !repeat {
            self.record(want, why);
        }
        if repeat {
            let refresh = matches!(want, Applied::Rpm(_) | Applied::Idle)
                && self.applied_at.elapsed() >= SETPOINT_KEEPALIVE;
            if !refresh {
                return;
            }
        }
        self.applied_at = Instant::now();
        match want {
            Applied::Rpm(rpm) => {
                if repeat {
                    debug!("{why} -> {rpm} RPM (re-asserted)");
                } else {
                    info!("{why} -> {rpm} RPM (pwm {})", self.fan.rpm_to_pwm(rpm));
                }
                if self.read_only {
                    self.applied = want;
                    return;
                }
                let mut result = self.fan.set_target_rpm(rpm);
                if result.is_err() && self.rediscover_fan() {
                    result = self.fan.set_target_rpm(rpm);
                }
                match result {
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
            Applied::Idle => {
                if repeat {
                    debug!("{why} -> fans off (re-asserted)");
                } else {
                    info!("{why} -> fans off (setpoint 0, still ours)");
                }
                if !self.read_only {
                    if self.fan.set_idle().is_err() {
                        self.rediscover_fan();
                    }
                    if let Err(e) = self.fan.set_idle() {
                        // Same reasoning as a failed setpoint write: we no
                        // longer know what the fan is doing, and the EC will
                        // not pick it up for us.
                        let reason = format!("could not stop the fans ({e})");
                        self.declare_emergency(reason, None, Duration::from_secs(20));
                        return;
                    }
                }
                self.applied = want;
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

    pub fn history(&self, limit: usize) -> Vec<omen_core::ipc::Decision> {
        self.history
            .iter()
            .rev()
            .take(limit)
            .rev()
            .cloned()
            .collect()
    }

    fn take_lighting_change(&mut self) -> Option<omen_core::config::LightingConfig> {
        std::mem::take(&mut self.lighting_changed).then(|| self.cfg.lighting.clone())
    }

    fn snapshot(&self, driver: Option<(String, f32)>) -> Snapshot {
        Snapshot {
            mode: Some(self.mode),
            hw_mode: self.fan.mode().ok().map(|m| m.to_string()),
            driver_label: driver.as_ref().map(|(l, _)| l.clone()),
            driver_temp_c: driver.as_ref().map(|(_, c)| *c),
            target_rpm: match self.applied {
                Applied::Rpm(rpm) => Some(rpm),
                // Zero is a real setpoint we are holding, and saying so is
                // the difference between "quiet" and "nobody is driving".
                Applied::Idle => Some(0),
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
            curve: Some(CurveSpec {
                points: self.governor.curve().points().to_vec(),
                interpolation: self.governor.curve().interpolation(),
            }),
            version: Some(omen_core::about::VERSION.to_owned()),
            config_path: self.config_path.to_str().map(str::to_owned),
            cleaning_secs_left: self.cleaning.as_ref().map(|(until, _)| {
                until
                    .saturating_duration_since(Instant::now())
                    .as_secs()
                    // Round up, so a run of five seconds does not show four
                    // for most of its life.
                    .max(1)
            }),
            drift: self.drift.clone(),
            on_ac: self.on_ac,
            battery_percent: omen_core::power::battery_percent(),
            power_ac: self.cfg.automation.on_ac.clone(),
            power_battery: self.cfg.automation.on_battery.clone(),
            startup_profile: self.cfg.automation.startup_profile.clone(),
            apps: self.cfg.apps.clone(),
            active_app: self.apps.active().map(str::to_owned),
            lighting_restore: self.cfg.lighting.restore_on_start,
            lighting_off_on_battery: self.cfg.lighting.off_on_battery,
            effect: Some(self.cfg.lighting.spec()),
            gpu: self.gpu.get(),
            uptime_secs: self.started.elapsed().as_secs(),
        }
    }
}
