//! Platform power/thermal profile.
//!
//! This machine has TWO handlers (established in Phase 2): `amd-pmf` and -
//! after the 8D24 patch - `hp-wmi`. Writing the legacy sysfs file drives both;
//! hp-wmi does its part by writing EC 0x95 (HPCM). That is why we write the
//! legacy file rather than an individual handler.

use std::path::{Path, PathBuf};

use crate::error::Result;
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

    pub fn get(&self) -> Result<String> {
        sysfs::read_string(&self.path)
    }

    pub fn choices(&self) -> Vec<String> {
        sysfs::read_string(Path::new(LEGACY_CHOICES))
            .map(|s| s.split_whitespace().map(str::to_owned).collect())
            .unwrap_or_default()
    }

    pub fn set(&self, profile: &str) -> Result<()> {
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
