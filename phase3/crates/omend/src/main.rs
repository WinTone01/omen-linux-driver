//! `omend` — OMEN 16-ap0xxx fan egrisi servisi.
//!
//! Neden bir daemon gerekiyor: Faz 1 §6.4'te saptandi ki HP'nin "Auto" fan
//! egrisi EC'de degil, Windows uygulamasinda kosuyor - OGH periyodik olarak
//! WMI 0x2E setpoint'i yaziyor. Yani `hp-wmi` tek basina "otomatik fan"
//! vermiyor; egriyi isleten bir sey lazim. Bu o sey.
//!
//! EC'nin kendi bir otomatigi VAR ve fena degil (Faz 2: 45C'de fan-stop,
//! 58C'de 2400 RPM). Bu yuzden egrinin alt bolgesinde kontrolu ona
//! birakiyoruz; yalnizca daha fazlasini istedigimizde devraliyoruz.

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
omend - OMEN 16-ap0xxx fan egrisi servisi

KULLANIM:
    omend [SECENEKLER]

SECENEKLER:
    -c, --config <YOL>   Yapilandirma dosyasi (varsayilan: /etc/omen/omend.toml)
        --dry-run        Hicbir sey yazma, ne yapacagini yaz
        --once           Tek tur calis ve cik (tanilama icin)
        --restore-auto   Fani otomatige alip cik (systemd ExecStopPost icin)
    -h, --help           Bu metni goster

ORNEK:
    omend --dry-run --once        # guvenli: hicbir sey degistirmez
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
            "-c" | "--config" => {
                args.config = it.next().context("--config bir yol bekliyor")?.into()
            }
            "--dry-run" => args.dry_run = true,
            "--once" => args.once = true,
            "--restore-auto" => args.restore_auto = true,
            other => anyhow::bail!("bilinmeyen secenek: {other}\n\n{USAGE}"),
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
    // Guvenlik kurali 1, ucuncu kapi: SIGKILL'de Drop calismaz. systemd
    // ExecStopPost bunu cagirir; daemon nasil oldugunden bagimsiz olarak
    // fan otomatige doner. Yapilandirmaya bakmaz - bozuk bir dosya yuzunden
    // kurtarma adiminin basarisiz olmasi kabul edilemez.
    if args.restore_auto {
        let fan = Fan::discover(
            omen_core::fan::DEFAULT_MIN_RPM,
            omen_core::fan::DEFAULT_MAX_RPM,
        )
        .context("fan bulunamadi")?;
        fan.restore_auto().context("otomatige alinamadi")?;
        info!("fan otomatige alindi (pwm1_enable=2)");
        return Ok(());
    }

    let cfg = Config::load(&args.config)
        .with_context(|| format!("yapilandirma okunamadi: {}", args.config.display()))?;

    let thermal = Thermal::discover().context("sicaklik kaynagi bulunamadi")?;
    let fan =
        Fan::discover(cfg.fan.min_rpm, cfg.fan.max_rpm).context("fan kontrolu hazirlanamadi")?;

    info!(
        "hwmon: {}  fan araligi: {}-{} RPM  adim: {} RPM  olcum: {}s",
        fan.hwmon_path().display(),
        fan.min_rpm(),
        fan.max_rpm(),
        cfg.fan.step_rpm,
        cfg.fan.interval_secs
    );
    info!(
        "sicaklik kaynaklari: {}",
        thermal
            .sensors
            .iter()
            .map(|s| s.label.as_str())
            .collect::<Vec<_>>()
            .join(", ")
    );

    // Profil isleyicisi listesinde hp-wmi yoksa 8D24 yamasi tutmamis
    // demektir. Fan yine calisiyor olabilir ama durumu bilmek isteriz.
    if !PlatformProfile::hp_wmi_active() {
        warn!("platform profil isleyicileri arasinda hp-wmi yok - 8D24 yamasi eksik olabilir");
    }

    let read_only = args.dry_run || !cfg.fan.enabled;
    if !cfg.fan.enabled {
        warn!("fan.enabled = false - egri isletilmiyor, yalnizca izleniyor");
    }
    if args.dry_run {
        warn!("--dry-run: hicbir sey yazilmayacak");
    }

    let mut rt = Runtime::new(fan.clone(), thermal, cfg, read_only)?;
    rt.log_curve();

    let mut keeper = AutoRestore::new(fan);
    if read_only {
        keeper.disarm();
    }

    let shared = Shared::new();
    // Tek turluk tanilama kosusu socket acmaz. dry-run acar: modu
    // degistirip ne olacagini gormek tam da dry-run'in isi. Cakismayi
    // onlemek icin OMEND_SOCKET ile ayri bir yol verilebilir.
    if !args.once {
        server::spawn(shared.clone())?;
    }

    let stop = Arc::new(AtomicBool::new(false));
    for sig in [signal_hook::consts::SIGTERM, signal_hook::consts::SIGINT] {
        signal_hook::flag::register(sig, Arc::clone(&stop))
            .with_context(|| format!("sinyal {sig} yakalanamadi"))?;
    }

    loop {
        rt.tick(&shared, &args.config);

        if args.once || stop.load(Ordering::Relaxed) {
            break;
        }
        // Bir sonraki olcume kadar bekle. Istek gelirse erken uyanir;
        // dilimleme sinyal bayragina bakabilmek icin (SIGTERM'i condvar
        // ile haber veremiyoruz).
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

    info!("kapaniyor");
    let _ = std::fs::remove_file(omen_core::ipc::socket_path());
    // `keeper` burada dusuyor ve fani otomatige aliyor.
    Ok(())
}

#[derive(Debug, PartialEq)]
enum SafetyState {
    Normal,
    /// Egri birakildi, kontrol EC'de. Sebep loglandi.
    Fallback,
}

/// Fana en son ne yazdik? Ayni degeri tekrar yazmamak icin.
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
            "egri: {}",
            self.governor
                .curve()
                .points()
                .iter()
                .map(|p| if p.rpm == 0 {
                    format!("{:.0}C:oto", p.temp_c)
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
                // Guvenlik kurali 3: sicaklik okunamiyorsa egriyi isletme.
                if self.state != SafetyState::Fallback {
                    error!("sicaklik okunamadi ({e}) - otomatige dusuluyor");
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
                        info!("yapilandirma yeniden okundu");
                        self.log_curve();
                    }
                    Err(e) => error!("yeni egri gecersiz, eskisi korunuyor: {e}"),
                },
                Err(e) => error!("yapilandirma okunamadi, eskisi korunuyor: {e}"),
            }
        }

        if let Some(mode) = shared.take_request() {
            if mode != self.mode {
                info!("mod: {} -> {mode}", self.mode);
                self.mode = mode;
                // Yeni modda sifirdan karar verilsin.
                self.governor.reset();
                self.applied = Applied::Unknown;
            }
        }
    }

    /// Kritik sigorta. HER modda gecerli - kullanicinin manuel istegi
    /// termal korumayi devre disi birakmaz.
    ///
    /// `true` -> normal surus devam edebilir.
    fn check_safety(&mut self, label: &str, temp: f32) -> bool {
        match self.state {
            SafetyState::Normal if temp >= self.cfg.safety.critical_c => {
                error!(
                    "{label} {temp:.1}C >= kritik {:.1}C - kontrol EC'ye birakildi",
                    self.cfg.safety.critical_c
                );
                self.fall_back();
                false
            }
            SafetyState::Fallback => {
                let recover_at = self.cfg.safety.critical_c - self.cfg.safety.recover_delta_c;
                if temp > recover_at {
                    debug!("guvenlik modunda, {label} {temp:.1}C > {recover_at:.1}C");
                    return false;
                }
                info!("{label} {temp:.1}C <= {recover_at:.1}C - kontrol geri alindi");
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
                    debug!("{label} {temp:.1}C - degisiklik yok");
                    return;
                };
                match target {
                    None => self.apply(Applied::Auto, &format!("{label} {temp:.1}C")),
                    Some(rpm) => self.apply(Applied::Rpm(rpm), &format!("{label} {temp:.1}C")),
                }
            }
            ControlMode::Manual { rpm } => self.apply(Applied::Rpm(rpm), "manuel"),
            ControlMode::Auto => self.apply(Applied::Auto, "manuel"),
            ControlMode::Max => self.apply(Applied::Max, "manuel"),
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
                            debug!("{rpm} RPM istendi, {actual} RPM'e kelepcelendi");
                        }
                        self.applied = Applied::Rpm(actual);
                    }
                    Err(e) => {
                        // Yazma basarisizsa setpoint bilinmeyen bir durumda
                        // kalir. En guvenlisi kontrolu geri vermek.
                        error!("setpoint yazilamadi ({e}) - otomatige dusuluyor");
                        self.fall_back();
                    }
                }
            }
            Applied::Auto => {
                info!("{why} -> otomatik (kontrol EC'de)");
                if !self.read_only {
                    if let Err(e) = self.fan.restore_auto() {
                        error!("otomatige alinamadi: {e}");
                        return;
                    }
                }
                self.applied = want;
            }
            Applied::Max => {
                warn!("{why} -> FAN TAM GUC");
                if !self.read_only {
                    if let Err(e) = self.fan.set_mode(omen_core::fan::PwmMode::Max) {
                        error!("tam guce alinamadi: {e}");
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
        // Histerezis eski karara takilmasin; cikista sifirdan karar verilsin.
        self.governor.reset();
        self.applied = Applied::Unknown;
        if self.read_only {
            return;
        }
        if let Err(e) = self.fan.restore_auto() {
            error!("KRITIK: otomatige alinamadi: {e}");
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
