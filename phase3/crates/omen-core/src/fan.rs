//! Fan control through hp-wmi's hwmon interface.
//!
//! Verified in Phase 2: `pwm1` only appears when the 8D24 DMI entry matches.
//! The kernel-side contract (drivers/platform/x86/hp/hp-wmi.c):
//!
//!   * `pwm1_enable`  0 = MAX, 1 = MANUAL, 2 = AUTO
//!   * `pwm1`         0..255, mapped LINEARLY onto 0..max_rpm
//!   * writes to `pwm1` are only accepted in MANUAL mode (else -EINVAL)
//!   * the kernel additionally clamps the setpoint to min_rpm..max_rpm
//!
//! So clamping happens twice: here first, then in the kernel.

use crate::error::{Error, Result};
use crate::sysfs::Hwmon;

/// Names hp-wmi's hwmon may use in its `name` file. "hp" on 7.2; the second
/// catches a future rename.
const HWMON_NAMES: &[&str] = &["hp", "hp_wmi"];

/// Phase 1 §6.3: OGH's own `profiles.json` bounds are 18-48, i.e. 1800-4800 RPM.
pub const DEFAULT_MIN_RPM: u32 = 1800;
pub const DEFAULT_MAX_RPM: u32 = 4800;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PwmMode {
    /// Fans at full power. hp-wmi does this with WMI 0x27 (FFFS=1).
    Max,
    /// We drive the setpoint.
    Manual,
    /// Control belongs to the EC. Verified in Phase 2: in this mode EC
    /// 0x34/0x35 are written as 0, which means "revert to automatic"
    /// (HP_FAN_SPEED_AUTOMATIC), not "fans off".
    Auto,
}

impl PwmMode {
    fn from_raw(v: i64) -> Option<Self> {
        match v {
            0 => Some(Self::Max),
            1 => Some(Self::Manual),
            2 => Some(Self::Auto),
            _ => None,
        }
    }

    fn as_raw(self) -> i64 {
        match self {
            Self::Max => 0,
            Self::Manual => 1,
            Self::Auto => 2,
        }
    }
}

impl std::fmt::Display for PwmMode {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(match self {
            Self::Max => "max",
            Self::Manual => "manual",
            Self::Auto => "auto",
        })
    }
}

#[derive(Debug, Clone)]
pub struct Fan {
    hwmon: Hwmon,
    min_rpm: u32,
    max_rpm: u32,
}

impl Fan {
    /// Finds hp-wmi's hwmon and checks that `pwm1` is exposed.
    ///
    /// A missing `pwm1` almost always means the 8D24 patch was not applied -
    /// the error message says as much.
    pub fn discover(min_rpm: u32, max_rpm: u32) -> Result<Self> {
        let hwmon = Hwmon::find_any(HWMON_NAMES).ok_or(Error::HwmonNotFound)?;
        if !hwmon.has("pwm1") {
            return Err(Error::PwmUnsupported);
        }
        if max_rpm == 0 || min_rpm >= max_rpm {
            return Err(Error::Curve(format!(
                "invalid RPM range: {min_rpm}-{max_rpm}"
            )));
        }
        Ok(Self {
            hwmon,
            min_rpm,
            max_rpm,
        })
    }

    pub fn hwmon_path(&self) -> &std::path::Path {
        &self.hwmon.path
    }

    pub fn min_rpm(&self) -> u32 {
        self.min_rpm
    }

    pub fn max_rpm(&self) -> u32 {
        self.max_rpm
    }

    /// Tachometer. `index` is 1 or 2 (CPU / GPU fan).
    pub fn rpm(&self, index: u8) -> Result<u32> {
        Ok(self.hwmon.read(&format!("fan{index}_input"))?.max(0) as u32)
    }

    pub fn mode(&self) -> Result<PwmMode> {
        let raw = self.hwmon.read("pwm1_enable")?;
        PwmMode::from_raw(raw).ok_or_else(|| Error::Parse {
            path: self.hwmon.attr("pwm1_enable"),
            raw: raw.to_string(),
        })
    }

    pub fn set_mode(&self, mode: PwmMode) -> Result<()> {
        if self.mode()? == mode {
            return Ok(());
        }
        self.hwmon.write("pwm1_enable", mode.as_raw())
    }

    pub fn pwm(&self) -> Result<u8> {
        Ok(self.hwmon.read("pwm1")?.clamp(0, 255) as u8)
    }

    /// Writes the target speed in RPM.
    ///
    /// The mode is set first because the kernel rejects writes outside MANUAL.
    /// The value is clamped to the min/max range whatever the config says.
    pub fn set_target_rpm(&self, rpm: u32) -> Result<u32> {
        let clamped = rpm.clamp(self.min_rpm, self.max_rpm);
        self.set_mode(PwmMode::Manual)?;
        self.hwmon.write("pwm1", self.rpm_to_pwm(clamped) as i64)?;
        Ok(clamped)
    }

    /// Hands control back to the EC. Safety rule 1: called on every exit path.
    pub fn restore_auto(&self) -> Result<()> {
        self.set_mode(PwmMode::Auto)
    }

    /// RPM -> PWM. Rounds UP, so rounding error always lands on the side of
    /// MORE cooling, never less.
    pub fn rpm_to_pwm(&self, rpm: u32) -> u8 {
        let rpm = rpm.min(self.max_rpm);
        let scaled = (rpm as u64 * 255).div_ceil(self.max_rpm as u64);
        scaled.min(255) as u8
    }

    pub fn pwm_to_rpm(&self, pwm: u8) -> u32 {
        (pwm as u64 * self.max_rpm as u64 / 255) as u32
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn fan(min: u32, max: u32) -> Fan {
        Fan {
            hwmon: Hwmon {
                path: "/dev/null".into(),
                name: "hp".into(),
            },
            min_rpm: min,
            max_rpm: max,
        }
    }

    #[test]
    fn pwm_endpoints_are_right() {
        let f = fan(1800, 4800);
        assert_eq!(f.rpm_to_pwm(0), 0);
        assert_eq!(f.rpm_to_pwm(4800), 255);
        // A request above the ceiling saturates at 255 rather than wrapping.
        assert_eq!(f.rpm_to_pwm(9999), 255);
    }

    #[test]
    fn rounding_never_undershoots() {
        // For every RPM: converting back must not land below what was asked.
        let f = fan(1800, 4800);
        for rpm in (0..=4800).step_by(100) {
            let back = f.pwm_to_rpm(f.rpm_to_pwm(rpm));
            assert!(
                back + 100 >= rpm,
                "rpm={rpm} -> pwm={} -> {back}, dropped too far",
                f.rpm_to_pwm(rpm)
            );
        }
    }

    #[test]
    fn mode_conversion_is_symmetric() {
        for m in [PwmMode::Max, PwmMode::Manual, PwmMode::Auto] {
            assert_eq!(PwmMode::from_raw(m.as_raw()), Some(m));
        }
        assert_eq!(PwmMode::from_raw(3), None);
    }
}
