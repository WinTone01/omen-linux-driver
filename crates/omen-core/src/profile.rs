//! Platform power/thermal profile.
//!
//! This machine has TWO handlers (established in Phase 2): `amd-pmf` and -
//! after the 8D24 patch - `hp-wmi`. Writing the legacy sysfs file drives both;
//! hp-wmi does its part by writing EC 0x95 (HPCM). That is why we write the
//! legacy file rather than an individual handler.
//!
//! **Unleashed** is the fourth mode OMEN Gaming Hub offers (HPCM `0x04`), and
//! platform_profile has no name for it. It is offered here anyway, under its
//! own name, through omen-kbd-rgb's `unleashed` switch - so every caller that
//! lists, reads or selects a profile (the CLI, the window, the OMEN key, the
//! rules) gets it without knowing it is not the kernel's. Selecting it goes
//! through performance first: that is the mode it sits above, and what
//! amd-pmf and the rest of the desktop should see while it runs.

use std::path::{Path, PathBuf};

use crate::error::Result;
use crate::limits::{self, UNLEASHED};
use crate::sysfs;

const LEGACY: &str = "/sys/firmware/acpi/platform_profile";
const LEGACY_CHOICES: &str = "/sys/firmware/acpi/platform_profile_choices";
const CLASS_DIR: &str = "/sys/class/platform-profile";

#[derive(Debug, Clone)]
pub struct Handler {
    pub name: String,
    pub profile: String,
}

#[derive(Debug, Clone)]
pub struct PlatformProfile {
    path: PathBuf,
}

impl PlatformProfile {
    pub fn discover() -> Option<Self> {
        let path = Path::new(LEGACY);
        path.exists().then(|| Self {
            path: path.to_owned(),
        })
    }

    /// The profile in force. Unleashed is asked of the module first: hp-wmi
    /// maps HPCM to a name and `0x04` is not one of its values, so what the
    /// legacy file says meanwhile is not something to rely on.
    pub fn get(&self) -> Result<String> {
        if limits::unleashed() == Some(true) {
            return Ok(UNLEASHED.to_owned());
        }
        sysfs::read_string(&self.path)
    }

    /// The firmware's profiles, quiet to loud, then Unleashed where there is
    /// one - so stepping through them with the OMEN key ends at the top.
    pub fn choices(&self) -> Vec<String> {
        let mut choices: Vec<String> = sysfs::read_string(Path::new(LEGACY_CHOICES))
            .map(|s| s.split_whitespace().map(str::to_owned).collect())
            .unwrap_or_default();
        if limits::has_unleashed() && choices.iter().any(|c| c == "performance") {
            choices.push(UNLEASHED.to_owned());
        }
        choices
    }

    pub fn set(&self, profile: &str) -> Result<()> {
        if profile == UNLEASHED {
            self.write("performance")?;
            return limits::set_unleashed(true);
        }
        // Writing the legacy file makes hp-wmi write HPCM, which ends
        // Unleashed by itself. Said explicitly as well, because whether the
        // kernel calls the handler for a profile it believes is already set
        // depends on its version.
        if limits::unleashed() == Some(true) {
            limits::set_unleashed(false)?;
        }
        self.write(profile)
    }

    fn write(&self, profile: &str) -> Result<()> {
        std::fs::write(&self.path, profile).map_err(|source| crate::error::Error::Write {
            path: self.path.clone(),
            source,
        })
    }

    /// Registered handlers. `hp-wmi` showing up here is the most direct
    /// evidence that the 8D24 patch took effect (Phase 2).
    pub fn handlers() -> Vec<Handler> {
        let Ok(entries) = std::fs::read_dir(CLASS_DIR) else {
            return Vec::new();
        };
        entries
            .flatten()
            .filter_map(|e| {
                let p = e.path();
                Some(Handler {
                    name: sysfs::read_string(&p.join("name")).ok()?,
                    profile: sysfs::read_string(&p.join("profile")).unwrap_or_default(),
                })
            })
            .collect()
    }

    pub fn hp_wmi_active() -> bool {
        Self::handlers()
            .iter()
            .any(|h| h.name == "hp-wmi" || h.name == "hp_wmi")
    }
}
