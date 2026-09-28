//! Settings that belong to the person, not to the machine.
//!
//! The daemon's configuration is root-owned and machine-wide: curves, safety
//! thresholds, application profiles. None of that belongs here. What is here
//! is how this window behaves for this user - how often it polls, whether it
//! starts with the session, whether a thermal override should raise a
//! notification - so it lives in the user's own config directory and needs no
//! privileges at all.

use std::path::PathBuf;

use serde::{Deserialize, Serialize};

const DIR: &str = "omen-control";
const FILE: &str = "settings.json";
/// Named after the app id, the same as the system-wide entry, so the desktop
/// treats them as the same application.
const AUTOSTART_FILE: &str = "dev.wintone.omen-control.desktop";

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default)]
pub struct Settings {
    /// How often the window asks the daemon for a new reading, in
    /// milliseconds.
    pub poll_ms: u32,
    /// Raise a desktop notification when the fans are forced to full power,
    /// when the service refuses a hardware command, or when it goes away.
    /// when the service refuses a hardware command, or when it goes away.
    pub alerts: bool,
    /// Start with the session.
    pub autostart: bool,
    /// Start hidden in the tray. Only honoured when there is a tray.
    pub start_hidden: bool,
    /// UI language: "en", "tr", or absent to follow the desktop's own.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub lang: Option<String>,
}

impl Default for Settings {
    fn default() -> Self {
        Self {
            poll_ms: 2000,
            alerts: true,
            autostart: false,
            start_hidden: false,
            lang: None,
        }
    }
}

fn config_dir() -> PathBuf {
    // XDG_CONFIG_HOME when set, ~/.config otherwise. Written out rather than
    // pulling in a crate for two lines.
    std::env::var_os("XDG_CONFIG_HOME")
        .map(PathBuf::from)
        .or_else(|| std::env::var_os("HOME").map(|h| PathBuf::from(h).join(".config")))
        .unwrap_or_else(|| PathBuf::from("."))
        .join(DIR)
}

fn autostart_path() -> PathBuf {
    config_dir()
        .parent()
        .unwrap_or_else(|| std::path::Path::new("."))
        .join("autostart")
        .join(AUTOSTART_FILE)
}

impl Settings {
    /// Defaults when there is no file or it is unreadable. A broken settings
    /// file must not stop the window opening - unlike the daemon's config,
    /// nothing here is safety-relevant.
    pub fn load() -> Self {
        std::fs::read_to_string(config_dir().join(FILE))
            .ok()
            .and_then(|raw| serde_json::from_str(&raw).ok())
            .unwrap_or_default()
    }

    pub fn save(&self) -> Result<(), String> {
        let dir = config_dir();
        std::fs::create_dir_all(&dir).map_err(|e| format!("{}: {e}", dir.display()))?;
        let json = serde_json::to_string_pretty(self).map_err(|e| e.to_string())?;
        let path = dir.join(FILE);
        std::fs::write(&path, json).map_err(|e| format!("{}: {e}", path.display()))?;
        self.apply_autostart()
    }

    /// Autostart is a file, not a setting: the desktop looks for a .desktop
    /// entry in ~/.config/autostart, so writing the JSON is not enough.
    fn apply_autostart(&self) -> Result<(), String> {
        let path = autostart_path();
        if !self.autostart {
            match std::fs::remove_file(&path) {
                Ok(()) => return Ok(()),
                // Already absent is the state we wanted.
                Err(e) if e.kind() == std::io::ErrorKind::NotFound => return Ok(()),
                Err(e) => return Err(format!("{}: {e}", path.display())),
            }
        }

        let dir = path.parent().unwrap();
        std::fs::create_dir_all(dir).map_err(|e| format!("{}: {e}", dir.display()))?;

        // Written rather than copied from /usr/share/applications: the copy
        // needs an extra key the installed one must not have, and a stale
        // copy of a file we also ship is a thing to go wrong later.
        let entry = "[Desktop Entry]\n\
             Type=Application\n\
             Name=OMEN Control\n\
             Comment=Fan curve, thermal profile and RGB keyboard control\n\
             Exec=omen-ui\n\
             Icon=omen-control\n\
             Terminal=false\n\
             X-GNOME-Autostart-enabled=true\n\
             StartupWMClass=dev.wintone.omen-control\n";
        std::fs::write(&path, entry).map_err(|e| format!("{}: {e}", path.display()))
    }
}
