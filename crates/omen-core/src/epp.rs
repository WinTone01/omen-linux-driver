//! The CPU's energy-performance preference, kept in step with the profile.
//!
//! On Windows the Hub switches the power plan with every mode
//! (`PowerOptionBg`, `IsWin11PowerModeSyncSupport`). The Linux equivalent is
//! the EPP hint `amd_pstate` and `intel_pstate` take in active mode: the
//! platform profile moves the firmware's limits, EPP moves how eagerly the
//! cores clock up inside them. A performance profile with the default
//! `balance_performance` hint leaves some of what the profile allows unused.
//!
//! power-profiles-daemon and tuned already do exactly this when they drive
//! the profile, so this steps aside whenever either is running: two things
//! writing the same hint is how a setting ends up flickering.

use std::path::PathBuf;

use crate::error::{Error, Result};
use crate::sysfs;

const CPUS: &str = "/sys/devices/system/cpu";

/// The hint for a profile, as power-profiles-daemon maps them.
pub fn for_profile(profile: &str) -> Option<&'static str> {
    match profile {
        "low-power" | "quiet" | "cool" => Some("power"),
        "balanced" => Some("balance_performance"),
        "performance" | crate::limits::UNLEASHED => Some("performance"),
        _ => None,
    }
}

/// Every CPU's EPP file. Empty when the driver is not in active mode, or is
/// not one that takes a hint.
pub fn files() -> Vec<PathBuf> {
    let Ok(entries) = std::fs::read_dir(CPUS) else {
        return Vec::new();
    };
    let mut files: Vec<PathBuf> = entries
        .flatten()
        .filter(|e| {
            let name = e.file_name();
            let name = name.to_string_lossy();
            name.strip_prefix("cpu")
                .is_some_and(|n| !n.is_empty() && n.bytes().all(|b| b.is_ascii_digit()))
        })
        .map(|e| e.path().join("cpufreq/energy_performance_preference"))
        .filter(|p| p.exists())
        .collect();
    files.sort();
    files
}

/// The hint in force, when every CPU agrees on one.
pub fn current() -> Option<String> {
    let mut seen: Option<String> = None;
    for file in files() {
        let value = sysfs::read_string(&file).ok()?;
        match &seen {
            None => seen = Some(value),
            Some(v) if *v == value => {}
            Some(_) => return Some("mixed".into()),
        }
    }
    seen
}

/// Writes the hint to every CPU. The `performance` governor accepts only
/// the `performance` hint and refuses the rest, which is reported rather than
/// worked around: changing someone's governor is not ours to do.
pub fn set(value: &str) -> Result<()> {
    let files = files();
    if files.is_empty() {
        return Err(Error::Curve(
            "no energy_performance_preference - the CPU frequency driver is not in active mode"
                .into(),
        ));
    }
    for file in files {
        std::fs::write(&file, value).map_err(|source| Error::Write { path: file, source })?;
    }
    Ok(())
}

/// The daemons that already keep EPP in step, by process name.
const OWNERS: &[&str] = &[
    "power-profiles-daemon",
    "tuned",
    "tuned-ppd",
    "auto-cpufreq",
];

/// Which of them is running, if one is.
pub fn owner() -> Option<&'static str> {
    let entries = std::fs::read_dir("/proc").ok()?;
    for entry in entries.flatten() {
        let Ok(comm) = std::fs::read_to_string(entry.path().join("comm")) else {
            continue;
        };
        if let Some(owner) = OWNERS.iter().find(|o| is_comm_of(comm.trim(), o)) {
            return Some(owner);
        }
    }
    None
}

/// Whether `comm` is what the kernel shows for a program called `name`.
/// The kernel keeps 15 characters: power-profiles-daemon is
/// `power-profiles-` in /proc, and an exact comparison never finds it.
fn is_comm_of(comm: &str, name: &str) -> bool {
    const COMM_MAX: usize = 15;
    comm == &name[..name.len().min(COMM_MAX)]
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn every_profile_has_a_hint_and_more_is_never_less() {
        let rank = |p: &str| match for_profile(p).unwrap() {
            "power" => 0,
            "balance_power" => 1,
            "balance_performance" => 2,
            "performance" => 3,
            other => panic!("{other}"),
        };
        assert!(rank("low-power") < rank("balanced"));
        assert!(rank("balanced") < rank("performance"));
        assert_eq!(rank("performance"), rank("unleashed"));
        assert_eq!(for_profile("custom"), None);
    }

    #[test]
    fn a_truncated_name_is_still_recognised() {
        assert!(is_comm_of("power-profiles-", "power-profiles-daemon"));
        assert!(is_comm_of("tuned", "tuned"));
        assert!(!is_comm_of("tuned", "tuned-ppd"));
    }

    #[test]
    fn what_is_found_is_an_epp_file() {
        for f in files() {
            assert!(
                f.ends_with("energy_performance_preference"),
                "{}",
                f.display()
            );
        }
    }
}
