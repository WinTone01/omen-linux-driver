//! Which versions of this project are actually in play.
//!
//! This exists because of how the project is installed. The daemon, the CLI,
//! the GUI and two kernel modules are built together and upgraded together -
//! and then keep running whatever was loaded before the upgrade. The usual
//! symptom is a bug that was fixed hours ago, reported against a binary on
//! disk that no longer contains it.
//!
//! So: compare what is running against what is installed, and say where they
//! differ rather than printing a version number and hoping.

use std::path::Path;

use serde::{Deserialize, Serialize};

/// The version every crate in this workspace is built with.
pub const VERSION: &str = env!("CARGO_PKG_VERSION");

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModuleStatus {
    pub name: String,
    /// Loaded at all?
    pub loaded: bool,
    /// MODULE_VERSION of the loaded module, when it declares one.
    pub version: Option<String>,
    /// srcversion identifies the BUILD, not the release: it changes whenever
    /// the compiled module changes, which is what makes it useful for
    /// spotting a module that was upgraded on disk but never reloaded.
    pub loaded_srcversion: Option<String>,
    /// The same field, read from the module file currently installed.
    pub installed_srcversion: Option<String>,
}

impl ModuleStatus {
    /// True when a different build of this module is installed than the one
    /// running. Unknown values mean "no reason to think so" - this must not
    /// cry wolf on a machine where modinfo is unavailable.
    pub fn stale(&self) -> bool {
        match (&self.loaded_srcversion, &self.installed_srcversion) {
            (Some(loaded), Some(installed)) => loaded != installed,
            _ => false,
        }
    }
}

/// Reads a module's state from /sys and, for the installed copy, modinfo.
///
/// `name` is the module name as the kernel spells it, with underscores:
/// "omen_kbd_rgb".
pub fn module_status(name: &str) -> ModuleStatus {
    let dir = Path::new("/sys/module").join(name);
    let read = |file: &str| {
        std::fs::read_to_string(dir.join(file))
            .ok()
            .map(|s| s.trim().to_owned())
            .filter(|s| !s.is_empty())
    };

    ModuleStatus {
        loaded: dir.exists(),
        version: read("version"),
        loaded_srcversion: read("srcversion"),
        installed_srcversion: installed_srcversion(name),
        name: name.to_owned(),
    }
}

/// srcversion of the module file on disk, via modinfo.
///
/// Shelling out is fine here: this is asked for when someone opens a settings
/// page or runs `omenctl version`, not on a timer. Finding and parsing the
/// .ko ourselves would mean reimplementing module search paths, compression
/// and modules.dep for no gain.
fn installed_srcversion(name: &str) -> Option<String> {
    let out = std::process::Command::new("modinfo")
        .args(["-F", "srcversion", name])
        .output()
        .ok()?;
    if !out.status.success() {
        return None;
    }
    let text = String::from_utf8(out.stdout).ok()?;
    text.lines().next().map(str::trim).and_then(|s| {
        if s.is_empty() {
            None
        } else {
            Some(s.to_owned())
        }
    })
}

/// The modules this project cares about: ours, and the patched hp-wmi the fan
/// side depends on.
pub fn modules() -> Vec<ModuleStatus> {
    ["omen_kbd_rgb", "hp_wmi"]
        .iter()
        .map(|n| module_status(n))
        .collect()
}
