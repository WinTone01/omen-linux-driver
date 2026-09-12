//! One file that answers "what is this machine doing", for a bug report.
//!
//! `omenctl doctor` already says what is wrong. This is the other half: the
//! raw state the conclusions were drawn from, so somebody reading a report
//! can check them rather than ask twenty questions. It is the single most
//! useful thing a project like this can have, because almost every report
//! that arrives without one turns into a week of "run this and paste the
//! output".
//!
//! Two rules about what goes in:
//!
//! * **Only what is needed to debug this project.** Fan, thermal, lighting,
//!   graphics, the modules, the configuration and the daemon's own log. Not
//!   the process list, not the network, not the user's files.
//! * **Nothing that identifies the machine or its owner.** The DMI serial
//!   numbers are root-only and are not read even when we could; board and
//!   model names are, because the whole project is board-specific and a
//!   report without the board is useless.
//!
//! It is plain text on purpose. It gets pasted into issues and chat windows
//! by people who should not have to be told how to open an archive.

use std::fmt::Write as _;
use std::path::Path;

use crate::about;
use crate::diagnose;
use crate::ipc::{client, Request, Response, Snapshot};

/// How many setpoint decisions to include. Enough to cover the last hour of
/// interesting behaviour without the file becoming a log dump.
const DECISIONS: usize = 60;

/// How many lines of the daemon's journal to include.
const JOURNAL_LINES: usize = 120;

/// Builds the report.
///
/// Read-only, and safe to run as a normal user - which is also the state most
/// people will run it in. Anything that cannot be read from here says so
/// rather than being left out, because "not readable without root" is itself
/// a useful line in a bug report.
pub fn report() -> String {
    let mut out = String::new();

    let snapshot = match client::send(&Request::Status) {
        Ok(Response::Ok(snap)) => Some(*snap),
        _ => None,
    };

    header(&mut out, snapshot.as_ref());
    section(&mut out, "DIAGNOSIS", diagnose::run().to_text());
    section(&mut out, "MACHINE", machine());
    section(&mut out, "MODULES", modules());
    section(&mut out, "DAEMON", daemon(snapshot.as_ref()));
    section(&mut out, "CONFIGURATION", configuration(snapshot.as_ref()));
    section(&mut out, "FAN AND THERMAL", fan_and_thermal());
    section(&mut out, "LIGHTING", lighting());
    section(&mut out, "GRAPHICS", graphics());
    section(&mut out, "RECENT DECISIONS", decisions());
    section(&mut out, "JOURNAL", journal());

    out
}

fn header(out: &mut String, snapshot: Option<&Snapshot>) {
    let _ = writeln!(out, "omen-control {} diagnostic report", about::VERSION);
    let _ = writeln!(
        out,
        "generated {}",
        std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map(|d| format!("at unix time {}", d.as_secs()))
            .unwrap_or_else(|_| "at an unknown time".into())
    );
    let _ = writeln!(
        out,
        "daemon: {}",
        match snapshot {
            Some(s) => format!(
                "running, {} for {}s",
                s.mode
                    .map(|m| m.to_string())
                    .unwrap_or_else(|| "idle".into()),
                s.uptime_secs
            ),
            None => "not reachable from here".into(),
        }
    );
    let _ = writeln!(
        out,
        "running as: {}",
        if is_root() {
            "root"
        } else {
            "a normal user - some files below may be unreadable"
        }
    );
}

fn section(out: &mut String, title: &str, body: String) {
    let _ = writeln!(out, "\n\n=== {title} ===\n");
    if body.trim().is_empty() {
        let _ = writeln!(out, "(nothing to report)");
    } else {
        let _ = writeln!(out, "{}", body.trim_end());
    }
}

fn machine() -> String {
    let mut out = String::new();
    for (label, path) in [
        ("board", "/sys/class/dmi/id/board_name"),
        ("board version", "/sys/class/dmi/id/board_version"),
        ("model", "/sys/class/dmi/id/product_name"),
        ("vendor", "/sys/class/dmi/id/sys_vendor"),
        ("bios", "/sys/class/dmi/id/bios_version"),
        ("bios date", "/sys/class/dmi/id/bios_date"),
        ("kernel", "/proc/sys/kernel/osrelease"),
    ] {
        let _ = writeln!(out, "{label:<16} {}", read(path).unwrap_or_else(missing));
    }

    // The distribution matters more than it looks: kernel packaging is what
    // decides whether the 8D24 patch survives an update.
    let distro = std::fs::read_to_string("/etc/os-release")
        .ok()
        .and_then(|text| {
            text.lines()
                .find_map(|l| l.strip_prefix("PRETTY_NAME=").map(|v| v.trim_matches('"').to_owned()))
        });
    let _ = writeln!(out, "{:<16} {}", "distribution", distro.unwrap_or_else(missing));
    let _ = writeln!(
        out,
        "{:<16} {}",
        "cpu",
        std::fs::read_to_string("/proc/cpuinfo")
            .ok()
            .and_then(|text| text
                .lines()
                .find_map(|l| l
                    .strip_prefix("model name")
                    .and_then(|v| v.split_once(':'))
                    .map(|(_, name)| name.trim().to_owned())))
            .unwrap_or_else(missing)
    );
    out
}

fn modules() -> String {
    let mut out = String::new();
    for m in about::modules() {
        let _ = writeln!(
            out,
            "{:<16} {}",
            m.name,
            if !m.loaded {
                "not loaded".to_string()
            } else {
                format!(
                    "{}{}",
                    m.version.clone().unwrap_or_else(|| "loaded".into()),
                    if m.stale() {
                        "  (a DIFFERENT build is installed - not reloaded since the upgrade)"
                    } else {
                        ""
                    }
                )
            }
        );
    }
    // Other things that drive the same hardware. A conflict here explains
    // more reports than anything else in this file.
    // hp_wmi is already listed above as one of ours; this list is the other
    // things that can drive the same hardware behind our back.
    for other in ["ec_sys", "acpi_call", "nbfc", "hp_accel", "ideapad_laptop"] {
        if Path::new("/sys/module").join(other).exists() {
            let params = std::fs::read_dir(Path::new("/sys/module").join(other).join("parameters"))
                .map(|dir| {
                    dir.flatten()
                        .filter_map(|e| {
                            let name = e.file_name().to_string_lossy().into_owned();
                            let value = std::fs::read_to_string(e.path()).ok()?;
                            Some(format!("{name}={}", value.trim()))
                        })
                        .collect::<Vec<_>>()
                        .join(" ")
                })
                .unwrap_or_default();
            let _ = writeln!(out, "{:<16} loaded {params}", format!("also: {other}"));
        }
    }
    out
}

fn daemon(snapshot: Option<&Snapshot>) -> String {
    match snapshot {
        // Pretty-printed rather than one line: this gets read by people.
        Some(snap) => serde_json::to_string_pretty(snap)
            .unwrap_or_else(|e| format!("the snapshot could not be serialised: {e}")),
        None => "omend did not answer. Is it running? systemctl status omend\n\
                 (a permission error here means the socket is root-owned and this \
                 was not run with sudo or as a member of the 'omen' group)"
            .into(),
    }
}

fn configuration(snapshot: Option<&Snapshot>) -> String {
    let path = snapshot
        .and_then(|s| s.config_path.clone())
        .unwrap_or_else(|| crate::config::DEFAULT_PATH.to_owned());
    match std::fs::read_to_string(&path) {
        Ok(text) => format!("{path}:\n\n{text}"),
        Err(e) => format!("{path}: {e}\n(the built-in defaults are in use when there is no file)"),
    }
}

fn fan_and_thermal() -> String {
    let mut out = String::new();

    match crate::fan::Fan::discover(
        crate::fan::DEFAULT_MIN_RPM,
        crate::fan::DEFAULT_MAX_RPM,
    ) {
        Ok(fan) => {
            let dir = fan.hwmon_path().to_owned();
            let _ = writeln!(out, "hwmon: {}", dir.display());
            dump_dir(&mut out, &dir);
        }
        Err(e) => {
            let _ = writeln!(out, "no fan control: {e}");
            // Say what IS there. "hp-wmi has no hwmon" and "there is no
            // hp-wmi at all" need different answers.
            for h in crate::sysfs::Hwmon::all() {
                let _ = writeln!(out, "  hwmon present: {:<12} {}", h.name, h.path.display());
            }
        }
    }

    let _ = writeln!(out);
    for (label, path) in [
        ("platform_profile", "/sys/firmware/acpi/platform_profile"),
        (
            "choices",
            "/sys/firmware/acpi/platform_profile_choices",
        ),
    ] {
        let _ = writeln!(out, "{label:<18} {}", read(path).unwrap_or_else(missing));
    }
    // Which driver is actually handling the profile. Two handlers on this
    // hardware (amd-pmf and hp-wmi) and only one of them does what we need.
    let _ = writeln!(
        out,
        "{:<18} {}",
        "handlers",
        read("/sys/firmware/acpi/platform_profile_handlers")
            .or_else(|| {
                // Newer kernels moved them under the class directory.
                std::fs::read_dir("/sys/class/platform-profile").ok().map(|d| {
                    d.flatten()
                        .filter_map(|e| read(e.path().join("name").to_str()?))
                        .collect::<Vec<_>>()
                        .join(" ")
                })
            })
            .unwrap_or_else(missing)
    );

    let _ = writeln!(out, "\ntemperatures:");
    match crate::thermal::Thermal::discover() {
        Ok(t) => {
            for (label, value) in t.read_all() {
                let _ = writeln!(
                    out,
                    "  {label:<16} {}",
                    match value {
                        Ok(c) => format!("{c:.1} C"),
                        Err(e) => e.to_string(),
                    }
                );
            }
        }
        Err(e) => {
            let _ = writeln!(out, "  none: {e}");
        }
    }
    out
}

fn lighting() -> String {
    let mut out = String::new();
    match crate::leds::Leds::discover() {
        Ok(leds) => {
            let state = leds.state();
            let _ = writeln!(
                out,
                "brightness  {}",
                state
                    .brightness
                    .map(|b| b.to_string())
                    .unwrap_or_else(|| "unknown".into())
            );
            let _ = writeln!(
                out,
                "backlight   {}",
                if state.backlight_off { "off" } else { "on" }
            );
            for (i, zone) in state.zones.iter().enumerate() {
                let _ = writeln!(
                    out,
                    "zone {i} ({:<6}) #{:02X}{:02X}{:02X}",
                    crate::leds::ZONE_LABELS.get(i).copied().unwrap_or("?"),
                    zone.r,
                    zone.g,
                    zone.b
                );
            }
        }
        Err(e) => {
            let _ = writeln!(out, "no LED class: {e}");
        }
    }
    out
}

fn graphics() -> String {
    let mut out = String::new();
    match crate::gpu::mux::discover() {
        Some(mux) => {
            let _ = writeln!(
                out,
                "mux           {} (supported: {})",
                mux.current.as_deref().unwrap_or("unknown"),
                mux.supported.join(" ")
            );
        }
        None => {
            let _ = writeln!(out, "mux           none reported by the driver");
        }
    }
    match crate::gpu::discover() {
        Some(gpu) => {
            let _ = writeln!(out, "dgpu          {}", gpu.address);
            let _ = writeln!(out, "runtime pm    {} ({})", gpu.control, gpu.status);
            let _ = writeln!(
                out,
                "dynamic pm    {}",
                crate::gpu::dynamic_power_management().unwrap_or_else(missing)
            );
        }
        None => {
            let _ = writeln!(out, "dgpu          none found");
        }
    }
    out
}

fn decisions() -> String {
    match client::send(&Request::History { limit: DECISIONS }) {
        Ok(Response::History { decisions }) if !decisions.is_empty() => decisions
            .iter()
            .map(|d| {
                format!(
                    "{:>7}s  {:<16} {:>6.1} C  -> {:<10} {}",
                    d.uptime_secs,
                    d.label,
                    d.temp_c,
                    match d.target_rpm {
                        Some(0) => "fans off".to_string(),
                        Some(rpm) => format!("{rpm} RPM"),
                        None => "EC".to_string(),
                    },
                    d.reason
                )
            })
            .collect::<Vec<_>>()
            .join("\n"),
        Ok(Response::History { .. }) => "the daemon has not changed the setpoint yet".into(),
        _ => "not available - the daemon did not answer".into(),
    }
}

/// The daemon's own log.
///
/// Shelling out to journalctl rather than reading the journal ourselves: the
/// format is binary, the reader is a library nobody should link for this, and
/// the command is on every machine that runs systemd. A machine without it
/// says so and the rest of the report is unaffected.
fn journal() -> String {
    let out = std::process::Command::new("journalctl")
        .args([
            "-u",
            "omend",
            "-n",
            &JOURNAL_LINES.to_string(),
            "--no-pager",
            "--output=short-iso",
        ])
        .output();

    match out {
        Ok(out) if out.status.success() => {
            let text = String::from_utf8_lossy(&out.stdout).trim().to_owned();
            if text.is_empty() {
                "the journal has nothing for omend".into()
            } else {
                text
            }
        }
        Ok(out) => format!(
            "journalctl said: {}",
            String::from_utf8_lossy(&out.stderr).trim()
        ),
        Err(e) => format!("journalctl could not be run: {e}"),
    }
}

/// Every readable attribute in a directory, one per line.
///
/// Deliberately everything rather than a chosen list: the attribute that
/// explains a problem is usually the one nobody thought to ask for.
fn dump_dir(out: &mut String, dir: &Path) {
    let Ok(entries) = std::fs::read_dir(dir) else {
        let _ = writeln!(out, "  (cannot be listed)");
        return;
    };
    let mut names: Vec<String> = entries
        .flatten()
        .map(|e| e.file_name().to_string_lossy().into_owned())
        .filter(|n| !matches!(n.as_str(), "device" | "subsystem" | "power" | "uevent"))
        .collect();
    names.sort();

    for name in names {
        let path = dir.join(&name);
        if path.is_dir() {
            continue;
        }
        match std::fs::read_to_string(&path) {
            Ok(v) => {
                let _ = writeln!(out, "  {name:<18} {}", v.trim());
            }
            // A write-only or root-only attribute is worth a line: its
            // absence from the list would read as "it is not there".
            Err(e) => {
                let _ = writeln!(out, "  {name:<18} <{}>", e.kind());
            }
        }
    }
}

fn read(path: &str) -> Option<String> {
    std::fs::read_to_string(path)
        .ok()
        .map(|s| s.trim().to_owned())
        .filter(|s| !s.is_empty())
}

fn missing() -> String {
    "not available".into()
}

fn is_root() -> bool {
    // No libc dependency for one number: the kernel already reports it.
    std::fs::read_to_string("/proc/self/status")
        .ok()
        .and_then(|s| {
            s.lines()
                .find_map(|l| l.strip_prefix("Uid:"))
                .and_then(|l| l.split_whitespace().next().map(|v| v == "0"))
        })
        .unwrap_or(false)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn a_report_can_be_produced_without_a_daemon_or_root() {
        // The whole point is that it works in the state a person filing a bug
        // report is in, which is usually neither.
        let text = report();
        for heading in [
            "=== DIAGNOSIS ===",
            "=== MACHINE ===",
            "=== MODULES ===",
            "=== DAEMON ===",
            "=== FAN AND THERMAL ===",
            "=== JOURNAL ===",
        ] {
            assert!(text.contains(heading), "missing {heading}");
        }
        assert!(text.starts_with("omen-control "));
    }

    #[test]
    fn nothing_identifying_is_collected() {
        // Serial numbers are root-only, so this would pass by accident when
        // run as a user. The check that matters is that we never ASK for one.
        let source = include_str!("bundle.rs");
        for forbidden in ["product_serial", "board_serial", "product_uuid"] {
            // The literal appears in this test's own list, so count the uses
            // outside it: any other occurrence is a read we should not do.
            let uses = source.matches(forbidden).count();
            assert_eq!(uses, 1, "{forbidden} is referenced outside this test");
        }
    }
}
