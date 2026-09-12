//! The battery's charge limit, where the kernel offers one.
//!
//! A laptop that lives on its charger spends its life at 100%, which is the
//! one state a lithium cell ages fastest in. The fix is to stop charging
//! short of full, and the kernel has a standard place for it:
//! `charge_control_end_threshold` under the battery's power supply. Nothing
//! here is HP-specific - the same file is what GNOME's own battery
//! preservation switch writes.
//!
//! **This board does not have it.** `BAT0` on the 16-ap0xxx exposes no
//! threshold file, because HP keeps the setting in the firmware (BIOS setup,
//! "Battery Health Manager") rather than handing it to the OS. That is worth
//! implementing anyway rather than skipping: the same code is right on every
//! OMEN and Victus whose driver does expose it, and on the boards that do not
//! the honest answer - "the kernel offers no control here, it is a BIOS
//! setting" - is more useful than silence, because the alternative is a user
//! assuming the feature is missing from this project.
//!
//! We never fabricate the control. If the file is not there, nothing is
//! written anywhere else to simulate it.

use std::path::{Path, PathBuf};

use crate::error::{Error, Result};

const SUPPLY_DIR: &str = "/sys/class/power_supply";
const END: &str = "charge_control_end_threshold";
const START: &str = "charge_control_start_threshold";

/// HP's BIOS-settings driver. Where a machine's firmware publishes its setup
/// options, a charge limit would appear under here rather than in the power
/// supply - so its presence is worth reporting when the usual file is absent.
const BIOSCFG_DIR: &str = "/sys/class/firmware-attributes/hp-bioscfg";

/// How far below the end threshold charging is allowed to resume, on drivers
/// that also expose a start threshold and insist the two differ. Five points
/// is what HP's own firmware uses, and it keeps the charger from cycling on
/// and off at the limit.
const START_BELOW_END: u8 = 5;

/// The lowest limit worth accepting. Below this a "charge limit" is closer to
/// a discharge instruction, and some firmware refuses it anyway.
pub const MIN_LIMIT: u8 = 50;

/// A battery that can have its charging stopped short of full.
#[derive(Debug, Clone)]
pub struct Battery {
    dir: PathBuf,
}

impl Battery {
    /// The first battery in `/sys/class/power_supply`.
    ///
    /// Found by `type`, not by name: BAT0 and BAT1 are conventions, not
    /// guarantees, and a machine with two batteries has the same answer for
    /// the first one either way.
    pub fn discover() -> Option<Self> {
        let mut found: Vec<PathBuf> = std::fs::read_dir(SUPPLY_DIR)
            .ok()?
            .flatten()
            .map(|e| e.path())
            .filter(|dir| {
                std::fs::read_to_string(dir.join("type"))
                    .map(|t| t.trim() == "Battery")
                    .unwrap_or(false)
            })
            .collect();
        // Sorted so a two-battery machine picks the same one every boot;
        // read_dir order is whatever the filesystem felt like.
        found.sort();
        found.into_iter().next().map(|dir| Self { dir })
    }

    pub fn path(&self) -> &Path {
        &self.dir
    }

    /// Whether this kernel exposes a charge limit for this battery.
    pub fn supports_limit(&self) -> bool {
        self.dir.join(END).exists()
    }

    /// The limit in force, as a percentage. `None` when there is no control,
    /// and `Some(100)` when there is one but it is not limiting anything.
    pub fn limit(&self) -> Option<u8> {
        let raw = std::fs::read_to_string(self.dir.join(END)).ok()?;
        raw.trim().parse().ok()
    }

    /// Sets the limit, or clears it when given `None`.
    ///
    /// Clearing is a write of 100 rather than an erase: the file is a number,
    /// and "charge all the way" is what 100 means. Values are clamped rather
    /// than rejected, except that a limit below [`MIN_LIMIT`] is refused -
    /// somebody typing 5 meant something else.
    pub fn set_limit(&self, percent: Option<u8>) -> Result<()> {
        let end = percent.unwrap_or(100).min(100);
        if end < MIN_LIMIT {
            return Err(Error::Curve(format!(
                "a charge limit of {end}% is too low; {MIN_LIMIT}% is the lowest accepted"
            )));
        }
        if !self.supports_limit() {
            return Err(Error::Curve(self.unsupported_reason()));
        }

        // Order matters on drivers that validate the pair: lower the start
        // threshold first when the new end would cross it, otherwise the
        // write of `end` is rejected for being below `start`.
        let start_path = self.dir.join(START);
        if start_path.exists() {
            let start: u8 = std::fs::read_to_string(&start_path)
                .ok()
                .and_then(|s| s.trim().parse().ok())
                .unwrap_or(0);
            if start >= end {
                let want = end.saturating_sub(START_BELOW_END);
                crate::sysfs::write_i64(&start_path, want as i64)?;
            }
        }

        crate::sysfs::write_i64(&self.dir.join(END), end as i64)
    }

    /// Why there is no control here, in a sentence that says what to do
    /// instead. HP is the common case on this hardware and it has a real
    /// answer, so it gets named rather than left as "unsupported".
    pub fn unsupported_reason(&self) -> String {
        let name = self
            .dir
            .file_name()
            .map(|n| n.to_string_lossy().into_owned())
            .unwrap_or_else(|| "the battery".into());

        // The other place it could have come from, and the one somebody who
        // knows their BIOS has the setting will ask about. hp-bioscfg
        // publishes a machine's BIOS options as sysfs attributes, so whether
        // this one is among them is a question with an answer rather than an
        // assumption - and on this firmware it is not.
        let bioscfg = std::path::Path::new(BIOSCFG_DIR).exists();

        format!(
            "this kernel exposes no charge threshold for {name} - on HP laptops the setting \
             usually lives in BIOS setup instead (Battery Health Manager, F10 at boot).{}",
            if bioscfg {
                " hp-bioscfg is loaded, but this firmware does not publish the setting through \
                 it either, so there is nothing for the OS to write."
            } else {
                ""
            }
        )
    }
}

/// The limit in force on this machine, if any. Convenience for the status
/// paths, which do not care which battery it was.
pub fn limit() -> Option<u8> {
    Battery::discover()?.limit()
}

/// Whether HP's BIOS-settings driver is present.
///
/// Reported separately from the reason text so the window can say it in the
/// window's own language - the daemon's sentences stay English because they
/// end up in bug reports, and this one belongs on a settings card.
pub fn bioscfg_present() -> bool {
    std::path::Path::new(BIOSCFG_DIR).exists()
}

/// Whether this machine offers the control at all.
pub fn supported() -> bool {
    Battery::discover().is_some_and(|b| b.supports_limit())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn discovery_does_not_panic_anywhere() {
        // A laptop finds a battery, a container or a desktop finds none.
        // Both are fine; crashing while probing is not.
        let _ = Battery::discover();
        let _ = limit();
        let _ = supported();
    }

    #[test]
    fn a_silly_limit_is_refused_before_anything_is_written() {
        let battery = Battery {
            dir: PathBuf::from("/nonexistent/BAT0"),
        };
        let err = battery.set_limit(Some(5)).unwrap_err().to_string();
        assert!(err.contains("too low"), "{err}");
    }

    #[test]
    fn an_unsupported_battery_says_where_the_setting_lives() {
        let battery = Battery {
            dir: PathBuf::from("/nonexistent/BAT0"),
        };
        let err = battery.set_limit(Some(80)).unwrap_err().to_string();
        assert!(err.contains("BIOS"), "{err}");
        assert!(err.contains("BAT0"), "{err}");
    }
}
