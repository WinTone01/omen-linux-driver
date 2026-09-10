//! Platform guc/termal profili.
//!
//! Bu makinede IKI isleyici var (Faz 2'de saptandi): `amd-pmf` ve - 8D24
//! yamasindan sonra - `hp-wmi`. Eski (legacy) sysfs dosyasina yazmak ikisini
//! birden surer; hp-wmi kendi payina EC 0x95'e (HPCM) yazar. O yuzden tek tek
//! isleyicilere degil, legacy dosyaya yaziyoruz.

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

    /// Kayitli isleyiciler. `hp-wmi`nin burada gorunmesi 8D24 yamasinin
    /// tuttugunun en dogrudan kanitidir (Faz 2).
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
