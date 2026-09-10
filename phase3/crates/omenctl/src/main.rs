//! `omenctl` — durum araci ve daemon istemcisi.
//!
//! Fan'a DOGRUDAN yazmaz. Kontrol komutlari unix socket uzerinden omend'e
//! gider (phase3-plan §4, guvenlik kurali 5): setpoint'i tek bir yerden
//! surmek, iki surecin birbirinin uzerine yazmasindan iyidir. Boylece
//! kelepceleme, kritik sigorta ve cikista otomatige donme her yol icin
//! tek bir yerde garanti altinda.
//!
//! `status` daemon calismiyorken de ise yarasin diye sysfs'ten dogrudan
//! okumaya duser - tanilama araci olarak degeri buradan geliyor.

mod client;

use std::process::ExitCode;

use anyhow::{bail, Result};
use omen_core::config::Config;
use omen_core::fan::Fan;
use omen_core::ipc::{ControlMode, Request, Response};
use omen_core::profile::PlatformProfile;
use omen_core::sysfs;
use omen_core::thermal::Thermal;

const USAGE: &str = "\
omenctl - OMEN 16-ap0xxx fan ve termal kontrol araci

KULLANIM:
    omenctl status                 Mevcut durum (daemon yoksa sysfs'ten okur)
    omenctl curve [-c YOL]         Etkin fan egrisini goster

    omenctl set curve              Fani egri sursun (varsayilan)
    omenctl set auto               Kontrolu EC'ye birak
    omenctl set manual <RPM>       Sabit hedef
    omenctl set max                Fan tam guc

    omenctl profile <AD>           balanced / performance / low-power
    omenctl reload                 Yapilandirmayi yeniden okut

Kontrol komutlari omend'e socket uzerinden gider; fan'a yazan tek sey
daemon'dir. Izin hatasi alirsan sudo ile calistir.
";

fn main() -> ExitCode {
    restore_sigpipe();
    let args: Vec<String> = std::env::args().skip(1).collect();
    let cmd = args.first().map(String::as_str).unwrap_or("status");

    let result = match cmd {
        "status" => status(),
        "curve" => curve(&args),
        "set" => set_mode(&args),
        "profile" => set_profile(&args),
        "reload" => client::send(&Request::Reload).and_then(client::report),
        "-h" | "--help" | "help" => {
            print!("{USAGE}");
            return ExitCode::SUCCESS;
        }
        other => {
            eprintln!("bilinmeyen komut: {other}\n\n{USAGE}");
            return ExitCode::from(2);
        }
    };

    match result {
        Ok(()) => ExitCode::SUCCESS,
        Err(e) => {
            eprintln!("hata: {e:#}");
            ExitCode::FAILURE
        }
    }
}

/// Rust SIGPIPE'i baslangicta yok sayiyor; bu yuzden `omenctl status | head`
/// gibi bir boruda okuyan taraf kapaninca yazma hata veriyor ve panic
/// ciktisi bastiriyor. Bir CLI icin dogru davranis, her filtre programinin
/// yaptigi gibi sessizce sonlanmak.
fn restore_sigpipe() {
    // SAFETY: tek is parcacikliyiz ve yalnizca varsayilan davranisi
    // geri koyuyoruz.
    unsafe {
        libc::signal(libc::SIGPIPE, libc::SIG_DFL);
    }
}

fn field(name: &str, value: impl std::fmt::Display) {
    println!("  {name:<16} {value}");
}

fn set_mode(args: &[String]) -> Result<()> {
    let mode = match args.get(1).map(String::as_str) {
        Some("curve") => ControlMode::Curve,
        Some("auto") => ControlMode::Auto,
        Some("max") => ControlMode::Max,
        Some("manual") => {
            let rpm: u32 = args
                .get(2)
                .ok_or_else(|| anyhow::anyhow!("manual bir RPM degeri bekliyor"))?
                .parse()
                .map_err(|_| anyhow::anyhow!("RPM sayi olmali"))?;
            ControlMode::Manual { rpm }
        }
        Some(other) => bail!("bilinmeyen mod: {other} (curve / auto / manual <RPM> / max)"),
        None => bail!("mod bekleniyor: curve / auto / manual <RPM> / max"),
    };
    client::report(client::send(&Request::SetMode(mode))?)
}

fn set_profile(args: &[String]) -> Result<()> {
    let profile = args
        .get(1)
        .ok_or_else(|| anyhow::anyhow!("profil adi bekleniyor"))?
        .clone();
    client::report(client::send(&Request::SetProfile { profile })?)
}

fn status() -> Result<()> {
    // Daemon calisiyorsa onun gorunumu daha zengin: surus modu, kritik
    // sigortanin durumu, hedef setpoint. Yoksa sysfs'ten okumaya duseriz.
    if let Ok(Response::Ok(snap)) = client::send(&Request::Status) {
        println!("omend");
        field("mod", snap.mode.map(|m| m.to_string()).unwrap_or_default());
        if snap.safety_fallback {
            println!("  ! kritik sigorta atti - kontrol EC'de");
        }
        if let (Some(l), Some(c)) = (&snap.driver_label, snap.driver_temp_c) {
            field("egriyi suren", format!("{l} {c:.1} C"));
        }
        // target_rpm yalnizca sabit bir setpoint varken dolu. Bos olmasi
        // "otomatik" demek DEGIL - max modunda da bos, ve orada fan tam
        // guctedir. Modu birlikte okumak gerekiyor.
        match (snap.mode, snap.target_rpm) {
            (_, Some(rpm)) => field("hedef", format!("{rpm} RPM")),
            (Some(ControlMode::Max), None) => field("hedef", "tam guc"),
            (_, None) => field("hedef", "otomatik (kontrol EC'de)"),
        }
        field("calisma suresi", format!("{} s", snap.uptime_secs));
        println!();
    }

    println!("donanim");
    let board = sysfs::read_string(std::path::Path::new("/sys/class/dmi/id/board_name"))
        .unwrap_or_else(|_| "?".into());
    field(
        "kart",
        format!(
            "{board}{}",
            if board == "8D24" {
                ""
            } else {
                "  (beklenen: 8D24)"
            }
        ),
    );
    field(
        "cekirdek",
        sysfs::read_string(std::path::Path::new("/proc/sys/kernel/osrelease"))
            .unwrap_or_else(|_| "?".into()),
    );

    println!("\nplatform profil");
    match PlatformProfile::discover() {
        Some(pp) => {
            field("aktif", pp.get().unwrap_or_else(|_| "?".into()));
            field("secenekler", pp.choices().join(" "));
            for h in PlatformProfile::handlers() {
                field("isleyici", format!("{} -> {}", h.name, h.profile));
            }
            if !PlatformProfile::hp_wmi_active() {
                println!("  ! hp-wmi isleyici olarak yok - 8D24 yamasi eksik olabilir");
            }
        }
        None => println!("  platform_profile yok"),
    }

    println!("\nfan");
    match Fan::discover(
        omen_core::fan::DEFAULT_MIN_RPM,
        omen_core::fan::DEFAULT_MAX_RPM,
    ) {
        Ok(fan) => {
            field("hwmon", fan.hwmon_path().display());
            field(
                "mod",
                fan.mode()
                    .map(|m| m.to_string())
                    .unwrap_or_else(|e| format!("? ({e})")),
            );
            for i in 1..=2u8 {
                if let Ok(rpm) = fan.rpm(i) {
                    field(
                        &format!("fan{i}"),
                        if rpm == 0 {
                            "0 RPM  (durmus)".to_string()
                        } else {
                            format!("{rpm} RPM")
                        },
                    );
                }
            }
            if let Ok(pwm) = fan.pwm() {
                field("pwm1", format!("{pwm}/255  (~{} RPM)", fan.pwm_to_rpm(pwm)));
            }
        }
        Err(e) => println!("  {e}"),
    }

    println!("\nsicakliklar");
    match Thermal::discover() {
        Ok(t) => {
            for (label, value) in t.read_all() {
                match value {
                    Ok(c) => field(&label, format!("{c:.1} C")),
                    Err(e) => field(&label, format!("okunamadi ({e})")),
                }
            }
            if let Ok((label, c)) = t.hottest() {
                println!("  -> egriyi suren: {label} {c:.1} C");
            }
        }
        Err(e) => println!("  {e}"),
    }

    Ok(())
}

fn curve(args: &[String]) -> Result<()> {
    let path = match args.iter().position(|a| a == "-c" || a == "--config") {
        Some(i) => args
            .get(i + 1)
            .map(std::path::PathBuf::from)
            .ok_or_else(|| anyhow::anyhow!("--config bir yol bekliyor"))?,
        None => Config::default_path(),
    };

    let cfg = Config::load(&path)?;
    let curve = cfg.curve()?;

    if path.exists() {
        println!("kaynak: {}", path.display());
    } else {
        println!("kaynak: gomulu varsayilan ({} yok)", path.display());
    }
    println!("\n  {:>8}  hedef", "sicaklik");
    for p in curve.points() {
        let target = if p.rpm == 0 {
            "otomatik (kontrol EC'de)".to_string()
        } else {
            format!("{} RPM", p.rpm)
        };
        println!("  {:>6.0} C  {target}", p.temp_c);
    }
    println!(
        "\n  histerezis {:.1} C, asgari bekleme {} s, olcum {} s",
        cfg.fan.hysteresis_c, cfg.fan.min_dwell_secs, cfg.fan.interval_secs
    );
    println!(
        "  kritik sigorta {:.0} C, {:.0} C'ye dusunce egri geri devreye girer",
        cfg.safety.critical_c,
        cfg.safety.critical_c - cfg.safety.recover_delta_c
    );
    Ok(())
}
