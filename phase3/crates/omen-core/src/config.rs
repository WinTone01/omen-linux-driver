//! Configuration. TOML, `/etc/omen/omend.toml`.
//!
//! If the file is absent the built-in defaults are used, so the daemon runs
//! without an install step. If it is present but invalid we do NOT silently
//! fall back to defaults - we error. Where a fan curve is concerned, what
//! matters is what the user wrote, not what we guess they meant.

use std::path::{Path, PathBuf};
use std::time::Duration;

use serde::{Deserialize, Serialize};

use crate::curve::{self, Curve, Point};
use crate::error::{Error, Result};
use crate::fan::{DEFAULT_MAX_RPM, DEFAULT_MIN_RPM};

pub const DEFAULT_PATH: &str = "/etc/omen/omend.toml";

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
#[serde(deny_unknown_fields)]
pub struct Config {
    #[serde(default)]
    pub fan: FanConfig,
    #[serde(default)]
    pub safety: SafetyConfig,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct FanConfig {
    /// Disables running the curve entirely; the daemon only observes.
    #[serde(default = "yes")]
    pub enabled: bool,

    /// Sampling interval, in seconds.
    #[serde(default = "default_interval")]
    pub interval_secs: u64,

    /// How far the temperature must fall before the setpoint is lowered.
    #[serde(default = "default_down_delta")]
    pub hysteresis_c: f32,

    /// Minimum time between two setpoint changes, in seconds.
    #[serde(default = "default_dwell")]
    pub min_dwell_secs: u64,

    #[serde(default = "default_min_rpm")]
    pub min_rpm: u32,

    #[serde(default = "default_max_rpm")]
    pub max_rpm: u32,

    /// Setpoints are rounded to this step. 100 by default, because the EC's
    /// fan target is in hundreds of RPM (Phase 1 §3.2) - writing finer just
    /// produces WMI calls that land on the same EC value.
    #[serde(default = "default_step_rpm")]
    pub step_rpm: u32,

    /// `rpm = 0` -> hand control to the EC at that temperature.
    #[serde(default)]
    pub curve: Vec<Point>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct SafetyConfig {
    /// Above this temperature the curve is abandoned and control returns to
    /// the EC. If a software bug is holding the fans low, let the hardware
    /// take its own curve back.
    #[serde(default = "default_critical")]
    pub critical_c: f32,

    /// How far the temperature must fall to leave the safety fallback.
    #[serde(default = "default_recover")]
    pub recover_delta_c: f32,

    /// Above this temperature, fans reading 0 RPM means cooling has failed.
    ///
    /// Measured on this machine (2026-09-11): with `pwm1_enable = 2` the fans
    /// stayed at 0 RPM while the CPU climbed 78 -> 85 C in twelve seconds
    /// under load. The EC does NOT take the curve back the way upstream's
    /// `HP_FAN_SPEED_AUTOMATIC` comment implies, at least once the driver has
    /// been in manual mode. So "hand control to the EC" cannot be treated as
    /// a safe resting state, and something has to notice when it is not
    /// working.
    ///
    /// Kept well above any legitimate fan-stop (the EC idles the fans in the
    /// 40s) and well below the critical cutout.
    #[serde(default = "default_stall_temp")]
    pub stall_temp_c: f32,

    /// How long the fans may read 0 RPM above `stall_temp_c` before we force
    /// them to full power. A few seconds of grace covers a fan spinning up
    /// and the tachometer lagging.
    #[serde(default = "default_stall_grace")]
    pub stall_grace_secs: u64,
}

fn yes() -> bool {
    true
}
fn default_interval() -> u64 {
    2
}
fn default_down_delta() -> f32 {
    5.0
}
fn default_dwell() -> u64 {
    20
}
fn default_min_rpm() -> u32 {
    DEFAULT_MIN_RPM
}
fn default_max_rpm() -> u32 {
    DEFAULT_MAX_RPM
}
fn default_step_rpm() -> u32 {
    crate::curve::EC_STEP_RPM
}
fn default_critical() -> f32 {
    // Strix Point's Tjmax is around 100 C. The cutout must sit ABOVE the top
    // of the curve (95 C), otherwise the curve's most aggressive region can
    // never be used - the cutout fires first. See validate().
    97.0
}
fn default_recover() -> f32 {
    10.0
}
fn default_stall_temp() -> f32 {
    75.0
}
fn default_stall_grace() -> u64 {
    6
}

impl Default for FanConfig {
    fn default() -> Self {
        Self {
            enabled: yes(),
            interval_secs: default_interval(),
            hysteresis_c: default_down_delta(),
            min_dwell_secs: default_dwell(),
            min_rpm: default_min_rpm(),
            max_rpm: default_max_rpm(),
            step_rpm: default_step_rpm(),
            curve: Vec::new(),
        }
    }
}

impl Default for SafetyConfig {
    fn default() -> Self {
        Self {
            critical_c: default_critical(),
            recover_delta_c: default_recover(),
            stall_temp_c: default_stall_temp(),
            stall_grace_secs: default_stall_grace(),
        }
    }
}

impl Config {
    /// Defaults when the file is absent; parsed when present; an ERROR when
    /// it is present and broken.
    pub fn load(path: &Path) -> Result<Self> {
        if !path.exists() {
            return Ok(Self::default());
        }
        let raw = crate::sysfs::read_string(path)?;
        let cfg: Self = toml::from_str(&raw).map_err(|e| Error::Curve(format!("{path:?}: {e}")))?;
        cfg.validate()?;
        Ok(cfg)
    }

    pub fn default_path() -> PathBuf {
        PathBuf::from(DEFAULT_PATH)
    }

    fn validate(&self) -> Result<()> {
        if self.fan.interval_secs == 0 {
            return Err(Error::Curve("interval_secs cannot be 0".into()));
        }
        if self.fan.step_rpm == 0 {
            return Err(Error::Curve("step_rpm cannot be 0".into()));
        }
        if self.fan.min_rpm >= self.fan.max_rpm {
            return Err(Error::Curve(format!(
                "min_rpm ({}) >= max_rpm ({})",
                self.fan.min_rpm, self.fan.max_rpm
            )));
        }
        if self.safety.recover_delta_c <= 0.0 {
            return Err(Error::Curve("recover_delta_c must be positive".into()));
        }
        if self.safety.stall_temp_c >= self.safety.critical_c {
            return Err(Error::Curve(format!(
                "stall_temp_c ({:.0} C) must be below critical_c ({:.0} C)",
                self.safety.stall_temp_c, self.safety.critical_c
            )));
        }

        // Curve validity is checked in Curve::new.
        let curve = self.curve()?;

        // If the cutout fires before the top of the curve is reached, the
        // curve's most aggressive region becomes dead code: control moves to
        // the EC before the temperature ever gets there. Say so rather than
        // accepting it silently.
        let top = curve.points().last().map(|p| p.temp_c).unwrap_or_default();
        if self.safety.critical_c <= top {
            return Err(Error::Curve(format!(
                "critical_c ({:.0} C) must be above the top of the curve ({top:.0} C), \
                 otherwise the top of the curve is never used",
                self.safety.critical_c
            )));
        }
        Ok(())
    }

    /// The configured curve, or the built-in default when none is given.
    pub fn curve(&self) -> Result<Curve> {
        if self.fan.curve.is_empty() {
            Ok(curve::default_curve())
        } else {
            Curve::new(self.fan.curve.clone())
        }
    }

    pub fn interval(&self) -> Duration {
        Duration::from_secs(self.fan.interval_secs)
    }

    pub fn min_dwell(&self) -> Duration {
        Duration::from_secs(self.fan.min_dwell_secs)
    }

    pub fn stall_grace(&self) -> Duration {
        Duration::from_secs(self.safety.stall_grace_secs)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn empty_config_falls_back_to_defaults() {
        let cfg: Config = toml::from_str("").unwrap();
        assert!(cfg.fan.enabled);
        assert_eq!(cfg.safety.critical_c, 97.0);
        cfg.validate().unwrap();
        assert_eq!(cfg.curve().unwrap().points().len(), 5);
    }

    #[test]
    fn unknown_keys_are_rejected() {
        // A silently swallowed typo means the user thinks their setting is in
        // effect when it is not - dangerous for a fan curve.
        let r: std::result::Result<Config, _> = toml::from_str("[fan]\nenabld = true\n");
        assert!(r.is_err());
    }

    #[test]
    fn a_broken_curve_fails_the_config() {
        let cfg: Config = toml::from_str(
            r#"
            [fan]
            curve = [
              { temp_c = 60.0, rpm = 3000 },
              { temp_c = 70.0, rpm = 2000 },
            ]
            "#,
        )
        .unwrap();
        assert!(cfg.validate().is_err());
    }

    #[test]
    fn the_cutout_must_be_above_the_curve() {
        // The curve runs to 95 C but the cutout is at 90 C, so the top of the
        // curve can never be used. That is a contradiction, not a preference.
        let cfg: Config = toml::from_str("[safety]\ncritical_c = 90.0\n").unwrap();
        let err = cfg.validate().unwrap_err().to_string();
        assert!(err.contains("critical_c"), "{err}");
    }

    #[test]
    fn a_custom_curve_is_read() {
        let cfg: Config = toml::from_str(
            r#"
            [fan]
            interval_secs = 5
            curve = [
              { temp_c = 50.0, rpm = 0 },
              { temp_c = 80.0, rpm = 4000 },
            ]

            [safety]
            critical_c = 95.0
            "#,
        )
        .unwrap();
        cfg.validate().unwrap();
        assert_eq!(cfg.interval(), Duration::from_secs(5));
        assert_eq!(cfg.curve().unwrap().target(80.0), Some(4000));
    }
}
