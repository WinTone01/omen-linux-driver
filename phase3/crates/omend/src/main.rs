//! `omend` — OMEN 16-ap0xxx fan egrisi servisi.
//!
//! Neden bir daemon gerekiyor: Faz 1 §6.4'te saptandi ki HP'nin "Auto" fan
//! egrisi EC'de degil, Windows uygulamasinda kosuyor - OGH periyodik olarak
//! WMI 0x2E setpoint'i yaziyor. Yani `hp-wmi` tek basina "otomatik fan"
//! vermiyor; egriyi isleten bir sey lazim. Bu o sey.
//!
//! EC'nin kendi bir otomatigi VAR ve fena degil (Faz 2: 45C'de fan-stop,
//! 58C'de 2400 RPM). Bu yuzden egrinin alt bolgesinde kontrolu ona
//! biraikiyoruz; yalnizca daha fazlasini istedigimizde devraliyoruz.

mod guard;

use std::process::ExitCode;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::time::{Duration, Instant};

use anyhow::{Context, Result};
use log::{debug, error, info, warn};

use omen_core::config::Config;
use omen_core::curve::Governor;
use omen_core::fan::Fan;
use omen_core::profile::PlatformProfile;
use omen_core::thermal::Thermal;

use crate::guard::AutoRestore;

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
                args.config = it.next().context("--config bir yol bekliyor")?.into();
            }
            "--dry-run" => args.dry_run = true,
            "--restore-auto" => args.restore_auto = true,
            "--once" => args.once = true,
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
        "hwmon: {}  fan araligi: {}-{} RPM  olcum: {}s",
        fan.hwmon_path().display(),
        fan.min_rpm(),
        fan.max_rpm(),
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

    let curve = cfg.curve()?;
    info!(
        "egri: {}",
        curve
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

    if !cfg.fan.enabled {
        warn!("fan.enabled = false - egri isletilmiyor, yalnizca izleniyor");
    }
    if args.dry_run {
        warn!("--dry-run: hicbir sey yazilmayacak");
    }

    let mut governor = Governor::new(
        curve,
        cfg.fan.hysteresis_c,
        cfg.min_dwell(),
        cfg.fan.step_rpm,
    );

    let mut keeper = AutoRestore::new(fan.clone());
    if args.dry_run || !cfg.fan.enabled {
        keeper.disarm();
    }

    let stop = Arc::new(AtomicBool::new(false));
    for sig in [signal_hook::consts::SIGTERM, signal_hook::consts::SIGINT] {
        signal_hook::flag::register(sig, Arc::clone(&stop))
            .with_context(|| format!("sinyal {sig} yakalanamadi"))?;
    }

    let mut state = SafetyState::Normal;
    let interval = cfg.interval();

    loop {
        tick(
            &fan,
            &thermal,
            &mut governor,
            &mut state,
            &cfg,
            args.dry_run || !cfg.fan.enabled,
        );

        if args.once || stop.load(Ordering::Relaxed) {
            break;
        }
        // Sinyale hizli cevap verebilmek icin uykuyu dilimliyoruz.
        let deadline = Instant::now() + interval;
        while Instant::now() < deadline && !stop.load(Ordering::Relaxed) {
            std::thread::sleep(Duration::from_millis(200).min(deadline - Instant::now()));
        }
        if stop.load(Ordering::Relaxed) {
            break;
        }
    }

    info!("kapaniyor");
    // `keeper` burada dusuyor ve fani otomatige aliyor.
    Ok(())
}

#[derive(Debug, PartialEq)]
enum SafetyState {
    Normal,
    /// Egri birakildi, kontrol EC'de. Sebep loglandi.
    Fallback,
}

fn tick(
    fan: &Fan,
    thermal: &Thermal,
    governor: &mut Governor,
    state: &mut SafetyState,
    cfg: &Config,
    read_only: bool,
) {
    // --- Guvenlik kurali 3: sicaklik okunamiyorsa egriyi isletme. ---
    let (label, temp) = match thermal.hottest() {
        Ok(v) => v,
        Err(e) => {
            if *state != SafetyState::Fallback {
                error!("sicaklik okunamadi ({e}) - otomatige dusuluyor");
                fall_back(fan, governor, state, read_only);
            }
            return;
        }
    };

    // --- Guvenlik kurali 2: kritik sicaklik sigortasi. ---
    match state {
        SafetyState::Normal if temp >= cfg.safety.critical_c => {
            error!(
                "{label} {temp:.1}C >= kritik {:.1}C - egri birakildi, kontrol EC'de",
                cfg.safety.critical_c
            );
            fall_back(fan, governor, state, read_only);
            return;
        }
        SafetyState::Fallback => {
            let recover_at = cfg.safety.critical_c - cfg.safety.recover_delta_c;
            if temp > recover_at {
                debug!("guvenlik modunda, {label} {temp:.1}C > {recover_at:.1}C");
                return;
            }
            info!("{label} {temp:.1}C <= {recover_at:.1}C - egri yeniden isletiliyor");
            *state = SafetyState::Normal;
        }
        SafetyState::Normal => {}
    }

    let Some(target) = governor.decide(temp, Instant::now()) else {
        debug!("{label} {temp:.1}C - degisiklik yok");
        return;
    };

    match target {
        None => {
            info!("{label} {temp:.1}C -> otomatik (kontrol EC'de)");
            if !read_only {
                if let Err(e) = fan.restore_auto() {
                    error!("otomatige alinamadi: {e}");
                }
            }
        }
        Some(rpm) => {
            info!(
                "{label} {temp:.1}C -> {rpm} RPM (pwm {})",
                fan.rpm_to_pwm(rpm)
            );
            if !read_only {
                match fan.set_target_rpm(rpm) {
                    Ok(applied) if applied != rpm => {
                        debug!("{rpm} RPM istendi, {applied} RPM'e kelepcelendi")
                    }
                    Ok(_) => {}
                    Err(e) => {
                        // Yazma basarisizsa setpoint bilinmeyen bir durumda
                        // kalir. En guvenlisi kontrolu geri vermek.
                        error!("setpoint yazilamadi ({e}) - otomatige dusuluyor");
                        fall_back(fan, governor, state, read_only);
                    }
                }
            }
        }
    }
}

fn fall_back(fan: &Fan, governor: &mut Governor, state: &mut SafetyState, read_only: bool) {
    *state = SafetyState::Fallback;
    // Histerezis eski karara takilmasin; cikista sifirdan karar verilsin.
    governor.reset();
    if read_only {
        return;
    }
    if let Err(e) = fan.restore_auto() {
        error!("KRITIK: otomatige alinamadi: {e}");
    }
}
