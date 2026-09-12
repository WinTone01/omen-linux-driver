//! What this particular machine can actually be asked to do.
//!
//! Everything in this project was measured on one board, and the honest
//! position on any other is "unverified". That is not the same as "refuse to
//! run", and the difference matters: the fan and profile protocol here is
//! shared across OMEN and Victus models, the lighting is not, and the graphics
//! mux exists on some of them. A machine that can do two of the three should
//! get two of the three rather than nothing.
//!
//! So instead of one yes/no question about the board, this asks a separate
//! question of each interface - is it there, can it be driven - and reports a
//! level made of the answers. Everything above this (the daemon, the CLI, the
//! window) then offers exactly what is present and says why the rest is
//! missing.
//!
//! Nothing here writes. A capability is detected by the presence of the
//! kernel interface that provides it, never by trying it and seeing what
//! breaks - on this hardware "try it and see" is how you wedge an EC.

use serde::{Deserialize, Serialize};

/// How much of this project is usable on the machine it is running on.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum Level {
    /// The fan can be driven and the profile can be set: everything works.
    Full,
    /// The platform profile works but the fan setpoint does not. Common on an
    /// OMEN whose board is not in hp-wmi's DMI table - profiles come from
    /// ACPI, `pwm1` does not appear.
    ProfileOnly,
    /// Sensors can be read and nothing can be driven. Still worth running for
    /// the graph and the diagnosis, and it is the state the doctor needs to
    /// be able to describe.
    TelemetryOnly,
    /// Nothing recognisable. A non-HP machine, or a kernel with no hp-wmi.
    Unsupported,
}

impl Level {
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Full => "full",
            Self::ProfileOnly => "profile-only",
            Self::TelemetryOnly => "telemetry-only",
            Self::Unsupported => "unsupported",
        }
    }

    /// One sentence, for the top of a window or the first line of a status.
    pub fn describe(self) -> &'static str {
        match self {
            Self::Full => "fan control and performance profiles are both available",
            Self::ProfileOnly => {
                "performance profiles work, but the fan setpoint cannot be driven here"
            }
            Self::TelemetryOnly => "this machine can be watched but not driven",
            Self::Unsupported => "no supported interface was found on this machine",
        }
    }
}

impl std::fmt::Display for Level {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(self.as_str())
    }
}

/// The board this project was built and verified on.
pub const VERIFIED_BOARD: &str = "8D24";

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Caps {
    pub vendor: Option<String>,
    pub model: Option<String>,
    pub board: Option<String>,

    /// The board everything here was measured on.
    pub verified_board: bool,
    /// An OMEN or a Victus, by model name. The fan and profile protocol is
    /// shared across the family, which is what makes a partial answer on an
    /// unverified board better than a refusal.
    pub omen_family: bool,

    /// `pwm1` exists, so a setpoint can be driven.
    pub fan_setpoint: bool,
    /// There are tachometers to read.
    pub fan_tacho: bool,
    /// `platform_profile` exists.
    pub profile: bool,
    /// ...and hp-wmi is one of the drivers behind it. On this hardware
    /// amd-pmf also registers, and only hp-wmi carries the OMEN modes.
    pub hp_wmi_profile: bool,
    /// A temperature can be read from somewhere.
    pub temps: bool,
    /// The four-zone keyboard is present.
    pub leds: bool,
    /// The firmware reports a graphics mux.
    pub mux: bool,
    /// The kernel exposes a battery charge threshold.
    pub charge_limit: bool,
}

/// Whether a fan setpoint can be driven at all, without asking every other
/// question. Two small reads, so it is cheap enough to check on each control
/// request rather than caching an answer that a module reload can invalidate.
pub fn fan_setpoint_present() -> bool {
    crate::sysfs::Hwmon::find_any(&["hp", "hp_wmi"]).is_some_and(|h| h.has("pwm1"))
}

impl Caps {
    /// Asks the machine, once. Cheap - a handful of small reads - but not
    /// free, so callers that need it repeatedly should keep the answer.
    pub fn detect() -> Self {
        let dmi = |file: &str| {
            std::fs::read_to_string(format!("/sys/class/dmi/id/{file}"))
                .ok()
                .map(|s| s.trim().to_owned())
                .filter(|s| !s.is_empty())
        };

        let board = dmi("board_name");
        let model = dmi("product_name");
        let vendor = dmi("sys_vendor");

        let family = model.as_deref().unwrap_or("").to_ascii_lowercase();
        let omen_family = family.contains("omen") || family.contains("victus");

        let hwmon = crate::sysfs::Hwmon::find_any(&["hp", "hp_wmi"]);
        let fan_setpoint = fan_setpoint_present();
        let fan_tacho = hwmon.as_ref().is_some_and(|h| h.has("fan1_input"));

        let profile = crate::profile::PlatformProfile::discover().is_some();

        Self {
            verified_board: board.as_deref() == Some(VERIFIED_BOARD),
            omen_family,
            fan_setpoint,
            fan_tacho,
            profile,
            hp_wmi_profile: crate::profile::PlatformProfile::hp_wmi_active(),
            temps: crate::thermal::Thermal::discover().is_ok(),
            leds: crate::leds::Leds::discover().is_ok(),
            mux: crate::gpu::mux::discover().is_some_and(|m| !m.supported.is_empty()),
            charge_limit: crate::battery::supported(),
            vendor,
            model,
            board,
        }
    }

    pub fn level(&self) -> Level {
        // The fan is the thing this project exists for, so it decides the top
        // level. A profile without it is still useful - that is the whole
        // point of having a level below "full" rather than a boolean.
        match (
            self.fan_setpoint,
            self.profile,
            self.temps || self.fan_tacho,
        ) {
            (true, true, _) => Level::Full,
            // A setpoint with no profile is unusual enough to be worth not
            // claiming "full", but it is still fan control.
            (true, false, _) => Level::Full,
            (false, true, _) => Level::ProfileOnly,
            (false, false, true) => Level::TelemetryOnly,
            (false, false, false) => Level::Unsupported,
        }
    }

    /// Why the level is what it is, as lines to print. Every capability
    /// appears, present or not: "what does this machine have" is the question,
    /// and a list that silently omits what is missing does not answer it.
    pub fn lines(&self) -> Vec<(&'static str, bool, String)> {
        vec![
            (
                "fan setpoint",
                self.fan_setpoint,
                if self.fan_setpoint {
                    "pwm1 is exposed by hp-wmi".into()
                } else {
                    "no pwm1 - this board is not in hp-wmi's DMI table".into()
                },
            ),
            (
                "fan tachometers",
                self.fan_tacho,
                if self.fan_tacho {
                    "fan1_input is readable".into()
                } else {
                    "no fan1_input, so fan speed cannot be read back".into()
                },
            ),
            (
                "performance profiles",
                self.profile,
                match (self.profile, self.hp_wmi_profile) {
                    (true, true) => "platform_profile, handled by hp-wmi".into(),
                    (true, false) => {
                        "platform_profile, but not from hp-wmi - the OMEN modes may be absent"
                            .into()
                    }
                    _ => "no platform_profile".into(),
                },
            ),
            (
                "temperatures",
                self.temps,
                if self.temps {
                    "a sensor was found".into()
                } else {
                    "no k10temp / amdgpu / acpitz sensor".into()
                },
            ),
            (
                "keyboard lighting",
                self.leds,
                if self.leds {
                    "the four-zone LED class is present".into()
                } else {
                    "no LED class - omen-kbd-rgb is not loaded, or this board has none".into()
                },
            ),
            (
                "graphics mux",
                self.mux,
                if self.mux {
                    "the firmware reports one".into()
                } else {
                    "none reported".into()
                },
            ),
            (
                "battery charge limit",
                self.charge_limit,
                if self.charge_limit {
                    "the kernel exposes a threshold".into()
                } else {
                    "no kernel threshold (HP usually keeps this in BIOS setup)".into()
                },
            ),
        ]
    }

    /// How much this machine resembles the one everything was measured on.
    pub fn confidence(&self) -> String {
        match (self.verified_board, self.omen_family) {
            (true, _) => format!("board {VERIFIED_BOARD} - the one this was built and verified on"),
            (false, true) => format!(
                "board {}, an OMEN or Victus but not the verified {VERIFIED_BOARD} - \
                 the fan and profile protocol is shared across the family, the rest is not",
                self.board.as_deref().unwrap_or("unknown")
            ),
            (false, false) => format!(
                "{} - not an OMEN or Victus at all; nothing here was measured on it",
                self.model.as_deref().unwrap_or("unknown model")
            ),
        }
    }

    /// What to do about a level below Full, when there is something to do.
    pub fn remedy(&self) -> Option<String> {
        match self.level() {
            Level::Full => None,
            // The verified board with no pwm1 is a different problem from an
            // unverified one: the entry exists, so either the patched module
            // is not installed or the running one predates the upgrade.
            Level::ProfileOnly if self.verified_board => Some(format!(
                "This IS board {VERIFIED_BOARD}, so hp-wmi should be exposing pwm1. Either the \
                 patched module is not installed or the one loaded predates it - a module \
                 keeps running until it is reloaded. Check with kernel/hp-wmi-8d24/verify.sh, \
                 and 'omenctl version' says whether what is loaded is what is installed."
            )),
            Level::ProfileOnly if self.omen_family => Some(format!(
                "hp-wmi has no entry for board {}. The 8D24 patch in kernel/hp-wmi-8d24/ \
                 is one line in a DMI table; adding this board to it is the same change, \
                 and the fan protocol is shared across the family. Nothing else here \
                 needs to change.",
                self.board.as_deref().unwrap_or("unknown")
            )),
            Level::ProfileOnly => Some(
                "No pwm1. On a non-OMEN machine that is expected: this project drives \
                 HP's fan interface and nothing else."
                    .into(),
            ),
            Level::TelemetryOnly | Level::Unsupported => Some(
                "Is hp-wmi loaded? modprobe hp_wmi, then 'omenctl doctor'. On a machine \
                 that is not an HP laptop there is nothing here to use."
                    .into(),
            ),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn caps() -> Caps {
        Caps {
            vendor: Some("HP".into()),
            model: Some("OMEN Gaming Laptop 16-ap0xxx".into()),
            board: Some(VERIFIED_BOARD.into()),
            verified_board: true,
            omen_family: true,
            fan_setpoint: true,
            fan_tacho: true,
            profile: true,
            hp_wmi_profile: true,
            temps: true,
            leds: true,
            mux: true,
            charge_limit: false,
        }
    }

    #[test]
    fn everything_present_is_full_control() {
        assert_eq!(caps().level(), Level::Full);
        assert!(caps().remedy().is_none());
    }

    #[test]
    fn a_board_without_pwm_still_gets_its_profiles() {
        let mut c = caps();
        c.fan_setpoint = false;
        c.verified_board = false;
        c.board = Some("8BCA".into());
        assert_eq!(c.level(), Level::ProfileOnly);
        // And the remedy names the actual fix rather than shrugging.
        let remedy = c.remedy().unwrap();
        assert!(remedy.contains("DMI"), "{remedy}");
    }

    #[test]
    fn sensors_alone_are_still_worth_running_for() {
        let mut c = caps();
        c.fan_setpoint = false;
        c.profile = false;
        assert_eq!(c.level(), Level::TelemetryOnly);
    }

    #[test]
    fn a_machine_with_nothing_says_so() {
        let mut c = caps();
        c.fan_setpoint = false;
        c.fan_tacho = false;
        c.profile = false;
        c.temps = false;
        c.omen_family = false;
        c.verified_board = false;
        assert_eq!(c.level(), Level::Unsupported);
        assert!(c.confidence().contains("not an OMEN"));
    }

    #[test]
    fn every_capability_is_listed_either_way() {
        let mut c = caps();
        c.leds = false;
        let lines = c.lines();
        assert!(lines
            .iter()
            .any(|(name, ok, _)| *name == "keyboard lighting" && !ok));
        assert_eq!(lines.len(), 7);
    }

    #[test]
    fn detecting_on_the_real_machine_does_not_panic() {
        let c = Caps::detect();
        // Whatever this machine is, the answer has to be one of the four.
        let _ = c.level();
        let _ = c.confidence();
    }
}
