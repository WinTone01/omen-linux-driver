//! `omenctl` — durum ve tanilama araci.
//!
//! M1'de SALT OKUNUR. Yazma yetkisi bilerek yalnizca daemon'da
//! (phase3-plan §4, guvenlik kurali 5): fan setpoint'ini tek bir yerden
//! surmek, iki surecin birbirinin uzerine yazmasindan iyidir. Kontrol
//! komutlari M1b'de unix socket uzerinden daemon'a gidecek.

use std::process::ExitCode;

use anyhow::Result;
use omen_core::config::Config;
use omen_core::fan::Fan;
use omen_core::profile::PlatformProfile;
use omen_core::sysfs;
use omen_core::thermal::Thermal;

const USAGE: &str = "\
omenctl - OMEN 16-ap0xxx fan ve termal durum araci

KULLANIM:
    omenctl status              Mevcut durumu goster
    omenctl curve [-c YOL]      Etkin fan egrisini goster
    omenctl --help

NOT: Bu arac salt okunurdur. Fan kontrolu omend uzerinden yapilir.
";

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let cmd = args.first().map(String::as_str).unwrap_or("status");

    let result = match cmd {
        "status" => status(),
        "curve" => curve(&args),
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

fn field(name: &str, value: impl std::fmt::Display) {
    println!("  {name:<16} {value}");
}

fn status() -> Result<()> {
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
