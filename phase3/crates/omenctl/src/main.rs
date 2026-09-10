//! `omenctl` - status tool and daemon client.
//!
//! It never writes to the fan directly. Control commands go to omend over a
//! unix socket (phase3-plan §4, safety rule 5): driving the setpoint from one
//! place beats two processes overwriting each other. That keeps clamping, the
//! critical cutout and restore-on-exit guaranteed in a single place.
//!
//! `status` falls back to reading sysfs directly so it stays useful while the
//! daemon is not running - that is where its value as a diagnostic lies.

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
omenctl - fan and thermal control tool for the OMEN 16-ap0xxx

USAGE:
    omenctl status                 Current state (reads sysfs if no daemon)
    omenctl curve [-c PATH]        Show the active fan curve

    omenctl set curve              Automatic: the curve drives the fan (default)
    omenctl set manual <RPM>       Fixed target
    omenctl set max                Fans at full power
    omenctl set auto               Advanced: hand the fans to the EC and stop
                                   managing them. On this machine the EC does
                                   not take them - for comparing against stock
                                   behaviour, not for daily use.

    omenctl profile <NAME>         balanced / performance / low-power
    omenctl reload                 Make the daemon re-read its configuration

Control commands go to omend over a socket; the daemon is the only thing that
writes to the fan. Run with sudo if you get a permission error.
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
            eprintln!("unknown command: {other}\n\n{USAGE}");
            return ExitCode::from(2);
        }
    };

    match result {
        Ok(()) => ExitCode::SUCCESS,
        Err(e) => {
            eprintln!("error: {e:#}");
            ExitCode::FAILURE
        }
    }
}

/// Rust ignores SIGPIPE at startup, so in a pipeline like
/// `omenctl status | head` the write fails once the reader closes and a panic
/// message is printed. The right behaviour for a CLI is to die quietly, the
/// way every filter program does.
fn restore_sigpipe() {
    // SAFETY: single-threaded here, and we are only restoring the default
    // disposition.
    unsafe {
        libc::signal(libc::SIGPIPE, libc::SIG_DFL);
    }
}

fn set_mode(args: &[String]) -> Result<()> {
    let mode = match args.get(1).map(String::as_str) {
        Some("curve") => ControlMode::Curve,
        Some("auto") => ControlMode::Auto,
        Some("max") => ControlMode::Max,
        Some("manual") => {
            let rpm: u32 = args
                .get(2)
                .ok_or_else(|| anyhow::anyhow!("manual expects an RPM value"))?
                .parse()
                .map_err(|_| anyhow::anyhow!("the RPM value must be a number"))?;
            ControlMode::Manual { rpm }
        }
        Some(other) => bail!("unknown mode: {other} (curve / auto / manual <RPM> / max)"),
        None => bail!("a mode is required: curve / auto / manual <RPM> / max"),
    };
    client::report(client::send(&Request::SetMode(mode))?)
}

fn set_profile(args: &[String]) -> Result<()> {
    let profile = args
        .get(1)
        .ok_or_else(|| anyhow::anyhow!("a profile name is required"))?
        .clone();
    client::report(client::send(&Request::SetProfile { profile })?)
}

fn field(name: &str, value: impl std::fmt::Display) {
    println!("  {name:<16} {value}");
}

fn status() -> Result<()> {
    // When the daemon is running its view is richer: drive mode, whether the
    // critical cutout has tripped, the target setpoint. Otherwise we fall
    // back to reading sysfs.
    if let Ok(Response::Ok(snap)) = client::send(&Request::Status) {
        println!("omend");
        field("mode", snap.mode.map(|m| m.to_string()).unwrap_or_default());
        if snap.safety_fallback {
            println!("  ! the critical cutout has tripped - control is with the EC");
        }
        if let (Some(l), Some(c)) = (&snap.driver_label, snap.driver_temp_c) {
            field("driving sensor", format!("{l} {c:.1} C"));
        }
        // target_rpm is only set when there is a fixed setpoint. It being
        // empty does NOT mean "automatic" - it is empty in max mode too, and
        // there the fans are at full power. The mode has to be read with it.
        match (snap.mode, snap.target_rpm) {
            (_, Some(rpm)) => field("target", format!("{rpm} RPM")),
            (Some(ControlMode::Max), None) => field("target", "full power"),
            (_, None) => field("target", "automatic (control with the EC)"),
        }
        field("uptime", format!("{} s", snap.uptime_secs));
        println!();
    }

    println!("hardware");
    let board = sysfs::read_string(std::path::Path::new("/sys/class/dmi/id/board_name"))
        .unwrap_or_else(|_| "?".into());
    field(
        "board",
        format!(
            "{board}{}",
            if board == "8D24" {
                ""
            } else {
                "  (expected: 8D24)"
            }
        ),
    );
    field(
        "kernel",
        sysfs::read_string(std::path::Path::new("/proc/sys/kernel/osrelease"))
            .unwrap_or_else(|_| "?".into()),
    );

    println!("\nplatform profile");
    match PlatformProfile::discover() {
        Some(pp) => {
            field("active", pp.get().unwrap_or_else(|_| "?".into()));
            field("choices", pp.choices().join(" "));
            for h in PlatformProfile::handlers() {
                field("handler", format!("{} -> {}", h.name, h.profile));
            }
            if !PlatformProfile::hp_wmi_active() {
                println!("  ! hp-wmi is not a handler - the 8D24 patch may be missing");
            }
        }
        None => println!("  no platform_profile"),
    }

    println!("\nfan");
    match Fan::discover(
        omen_core::fan::DEFAULT_MIN_RPM,
        omen_core::fan::DEFAULT_MAX_RPM,
    ) {
        Ok(fan) => {
            field("hwmon", fan.hwmon_path().display());
            field(
                "mode",
                fan.mode()
                    .map(|m| m.to_string())
                    .unwrap_or_else(|e| format!("? ({e})")),
            );
            for i in 1..=2u8 {
                if let Ok(rpm) = fan.rpm(i) {
                    field(
                        &format!("fan{i}"),
                        if rpm == 0 {
                            "0 RPM  (stopped)".to_string()
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

    println!("\ntemperatures");
    match Thermal::discover() {
        Ok(t) => {
            for (label, value) in t.read_all() {
                match value {
                    Ok(c) => field(&label, format!("{c:.1} C")),
                    Err(e) => field(&label, format!("unreadable ({e})")),
                }
            }
            if let Ok((label, c)) = t.hottest() {
                println!("  -> driving the curve: {label} {c:.1} C");
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
            .ok_or_else(|| anyhow::anyhow!("--config expects a path"))?,
        None => Config::default_path(),
    };

    let cfg = Config::load(&path)?;
    let curve = cfg.curve()?;

    if path.exists() {
        println!("source: {}", path.display());
    } else {
        println!(
            "source: built-in default ({} does not exist)",
            path.display()
        );
    }
    println!("\n  {:>11}  target", "temperature");
    for p in curve.points() {
        let target = if p.rpm == 0 {
            "automatic (control with the EC)".to_string()
        } else {
            format!("{} RPM", p.rpm)
        };
        println!("  {:>9.0} C  {target}", p.temp_c);
    }
    println!(
        "\n  hysteresis {:.1} C, minimum dwell {} s, sampling every {} s",
        cfg.fan.hysteresis_c, cfg.fan.min_dwell_secs, cfg.fan.interval_secs
    );
    println!(
        "  critical cutout {:.0} C, the curve re-engages below {:.0} C",
        cfg.safety.critical_c,
        cfg.safety.critical_c - cfg.safety.recover_delta_c
    );
    Ok(())
}
