//! Mains or battery, and what the machine should do about it.
//!
//! The rule is deliberately shaped like an application profile: a platform
//! profile, a fan mode, or both. What differs is when it applies - a power
//! source is a state the machine is in, not a program that comes and goes, so
//! there is nothing to "restore" when it ends. Unplugging applies the battery
//! rule; that is the whole model.
//!
//! Application profiles win over these. A game asking for performance is a
//! more specific statement than "this machine is on battery", and the person
//! who configured both meant the specific one.

use std::path::{Path, PathBuf};

use serde::{Deserialize, Serialize};

use crate::ipc::ControlMode;

const SUPPLY_DIR: &str = "/sys/class/power_supply";

#[derive(Debug, Clone, Default, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct PowerRule {
    /// Platform profile to select: balanced / performance / low-power.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub profile: Option<String>,

    /// How the fan should be driven.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub fan: Option<ControlMode>,
}

impl PowerRule {
    pub fn is_empty(&self) -> bool {
        self.profile.is_none() && self.fan.is_none()
    }

    pub fn summary(&self) -> String {
        let mut parts = Vec::new();
        if let Some(p) = &self.profile {
            parts.push(p.clone());
        }
        if let Some(f) = &self.fan {
            parts.push(format!("fan {f}"));
        }
        if parts.is_empty() {
            "nothing to apply".into()
        } else {
            parts.join(", ")
        }
    }
}

/// Whether the machine is on mains power.
///
/// `None` means it could not be determined, which is not the same as "on
/// battery" - a desktop, or a kernel that names the supply something we did
/// not expect. Nothing is applied in that case, because guessing wrong here
/// means changing the machine's behaviour for no reason.
pub fn on_ac() -> Option<bool> {
    let entries = std::fs::read_dir(SUPPLY_DIR).ok()?;

    for entry in entries.flatten() {
        let dir = entry.path();
        // Match on the type rather than the name: ACAD, ADP1, AC0 and
        // "ucsi-source-psy-..." are all the same thing to the kernel, and a
        // USB-C charger is a mains supply too.
        let kind = read(&dir.join("type"))?;
        if kind != "Mains" && kind != "USB" {
            continue;
        }
        if let Some(online) = read(&dir.join("online")) {
            if online == "1" {
                return Some(true);
            }
        }
    }

    // No mains supply is online. That is only meaningful if there was one to
    // check; a machine with no AC adapter at all tells us nothing.
    has_mains().then_some(false)
}

fn has_mains() -> bool {
    let Ok(entries) = std::fs::read_dir(SUPPLY_DIR) else {
        return false;
    };
    entries.flatten().any(|e| {
        read(&e.path().join("type")).is_some_and(|k| k == "Mains" || k == "USB")
            && e.path().join("online").exists()
    })
}

fn read(path: &Path) -> Option<String> {
    std::fs::read_to_string(path)
        .ok()
        .map(|s| s.trim().to_owned())
}

/// Where the battery's own charge sits, for reporting. `None` when there is
/// no battery.
pub fn battery_percent() -> Option<u8> {
    let entries = std::fs::read_dir(SUPPLY_DIR).ok()?;
    for entry in entries.flatten() {
        let dir: PathBuf = entry.path();
        if read(&dir.join("type")).as_deref() != Some("Battery") {
            continue;
        }
        if let Some(capacity) = read(&dir.join("capacity")).and_then(|c| c.parse().ok()) {
            return Some(capacity);
        }
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn an_empty_rule_is_recognised_as_empty() {
        assert!(PowerRule::default().is_empty());
        assert!(!PowerRule {
            profile: Some("balanced".into()),
            fan: None,
        }
        .is_empty());
    }

    #[test]
    fn the_summary_names_both_halves() {
        let rule = PowerRule {
            profile: Some("performance".into()),
            fan: Some(ControlMode::Max),
        };
        assert_eq!(rule.summary(), "performance, fan max");
    }

    #[test]
    fn reading_the_power_source_does_not_panic() {
        // Whatever machine this runs on: a laptop answers true or false, a
        // container answers None. All three are fine; crashing is not.
        let _ = on_ac();
        let _ = battery_percent();
    }
}
