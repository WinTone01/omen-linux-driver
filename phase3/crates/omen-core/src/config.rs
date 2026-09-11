//! Configuration. TOML, `/etc/omen/omend.toml`.
//!
//! If the file is absent the built-in defaults are used, so the daemon runs
//! without an install step. If it is present but invalid we do NOT silently
//! fall back to defaults - we error. Where a fan curve is concerned, what
//! matters is what the user wrote, not what we guess they meant.

use std::path::{Path, PathBuf};
use std::time::Duration;

use serde::{Deserialize, Serialize};

use crate::anim::{Effect, EffectSpec};
use crate::apps::AppProfile;
use crate::curve::{self, Curve, Interpolation, Point};
use crate::error::{Error, Result};
use crate::fan::{DEFAULT_MAX_RPM, DEFAULT_MIN_RPM};
use crate::gpu::DgpuPower;

pub const DEFAULT_PATH: &str = "/etc/omen/omend.toml";

/// Written at the top of a saved file, because the first question on finding
/// your comments gone is "what did that".
const SAVED_HEADER: &str = "\
# Written by omend. Hand edits are fine - run 'omenctl reload' afterwards -
# but saving a curve from omenctl or the GUI rewrites this file and drops any
# comments you add.

";

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
#[serde(deny_unknown_fields)]
pub struct Config {
    #[serde(default)]
    pub fan: FanConfig,
    #[serde(default)]
    pub safety: SafetyConfig,
    #[serde(default)]
    pub lighting: LightingConfig,

    /// Per-application profiles, in priority order: the first entry whose
    /// process is running wins.
    #[serde(default, rename = "app")]
    pub apps: Vec<AppProfile>,

    #[serde(default)]
    pub automation: AutomationConfig,

    #[serde(default)]
    pub graphics: GraphicsConfig,
}

/// Discrete GPU power. Not a graphics switch - this board has no mux; see
/// gpu::DgpuPower.
#[derive(Debug, Clone, Copy, PartialEq, Default, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct GraphicsConfig {
    #[serde(default)]
    pub dgpu_power: DgpuPower,
}

/// Settings for the things omend does on its own.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct AutomationConfig {
    /// Platform profile to select when the daemon starts.
    ///
    /// The firmware remembers the last profile across a reboot, which is
    /// usually what you want and occasionally not: a machine that was left on
    /// performance for one evening stays there. Naming one here makes the
    /// starting point explicit.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub startup_profile: Option<String>,

    /// How often the process list is checked, in seconds.
    ///
    /// Every check walks /proc. Five seconds is quick enough that a game is
    /// on its loading screen when the profile lands, and slow enough that the
    /// walk is nothing.
    #[serde(default = "default_app_scan")]
    pub app_scan_secs: u64,
}

impl Default for AutomationConfig {
    fn default() -> Self {
        Self {
            startup_profile: None,
            app_scan_secs: default_app_scan(),
        }
    }
}

fn default_app_scan() -> u64 {
    5
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

    /// How values between two curve points are worked out.
    ///
    /// `step` by default, because OMEN Gaming Hub's curve is a lookup table
    /// at 5 C granularity rather than a continuous curve (Phase 1 §6.3).
    /// `linear` ramps between the points instead.
    #[serde(default)]
    pub interpolation: Interpolation,

    /// `rpm = 0` -> fans off at that temperature, with the setpoint still
    /// ours. NOT the same as handing control to the EC; see fan::set_idle.
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

/// Keyboard lighting.
///
/// Colours are NOT kept here: they live in the LED class, where the kernel
/// already remembers them and where anything else on the system can set them
/// too (see leds.rs). Only the animation belongs to us, because an animation
/// is a thing that has to keep running.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct LightingConfig {
    /// none / breathing / wave / spectrum.
    #[serde(default)]
    pub effect: Effect,

    /// 1 (slowest) to 10 (fastest).
    #[serde(default = "default_speed")]
    pub speed: u8,

    /// Base colour for the effects that take one, as `[r, g, b]`.
    #[serde(default = "default_effect_color")]
    pub color: [u8; 3],

    /// Frames per second while an effect runs.
    ///
    /// Each frame writes four zones, and each zone write is a WMI call. Ten
    /// is smooth enough for four zones spread across a keyboard and leaves
    /// the firmware alone the rest of the time; there is no point paying for
    /// sixty.
    #[serde(default = "default_fps")]
    pub fps: u8,
}

impl Default for LightingConfig {
    fn default() -> Self {
        let spec = EffectSpec::default();
        Self {
            effect: spec.effect,
            speed: spec.speed,
            color: default_effect_color(),
            fps: default_fps(),
        }
    }
}

impl LightingConfig {
    pub fn spec(&self) -> EffectSpec {
        EffectSpec {
            effect: self.effect,
            speed: self.speed,
            color: crate::leds::Rgb {
                r: self.color[0],
                g: self.color[1],
                b: self.color[2],
            },
        }
    }

    pub fn set_spec(&mut self, spec: EffectSpec) {
        self.effect = spec.effect;
        self.speed = spec.speed;
        self.color = [spec.color.r, spec.color.g, spec.color.b];
    }

    pub fn frame_interval(&self) -> Duration {
        Duration::from_secs_f32(1.0 / self.fps.clamp(1, 60) as f32)
    }
}

fn default_fps() -> u8 {
    10
}

fn default_speed() -> u8 {
    EffectSpec::default().speed
}

fn default_effect_color() -> [u8; 3] {
    let c = EffectSpec::default().color;
    [c.r, c.g, c.b]
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
            interpolation: Interpolation::default(),
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

    pub fn validate(&self) -> Result<()> {
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
        for app in &self.apps {
            if app.process.trim().is_empty() {
                return Err(Error::Curve(
                    "an application profile has an empty process name".into(),
                ));
            }
        }
        if self.automation.app_scan_secs == 0 {
            return Err(Error::Curve("app_scan_secs cannot be 0".into()));
        }
        if self.lighting.fps == 0 || self.lighting.fps > 60 {
            return Err(Error::Curve(format!(
                "lighting fps must be between 1 and 60, got {}",
                self.lighting.fps
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
            Curve::with_interpolation(self.fan.curve.clone(), self.fan.interpolation)
        }
    }

    /// Writes the configuration back out.
    ///
    /// Via a temporary file in the same directory and a rename, so a crash or
    /// a full disk halfway through leaves the previous configuration intact
    /// rather than a truncated one the daemon would refuse to start with.
    ///
    /// Comments in the file are lost - this serialises the parsed struct, it
    /// does not edit the text. That is the price of letting a GUI own the
    /// curve, and the reason the shipped file says so at the top.
    pub fn save(&self, path: &Path) -> Result<()> {
        self.validate()?;

        let body = toml::to_string_pretty(self)
            .map_err(|e| Error::Curve(format!("could not serialise the configuration: {e}")))?;
        let text = format!("{SAVED_HEADER}{body}");

        let dir = path.parent().unwrap_or_else(|| Path::new("."));
        std::fs::create_dir_all(dir).map_err(|source| Error::Write {
            path: dir.to_owned(),
            source,
        })?;

        let tmp = path.with_extension("toml.tmp");
        std::fs::write(&tmp, text.as_bytes()).map_err(|source| Error::Write {
            path: tmp.clone(),
            source,
        })?;
        std::fs::rename(&tmp, path).map_err(|source| Error::Write {
            path: path.to_owned(),
            source,
        })?;
        Ok(())
    }

    pub fn interval(&self) -> Duration {
        Duration::from_secs(self.fan.interval_secs)
    }

    pub fn min_dwell(&self) -> Duration {
        Duration::from_secs(self.fan.min_dwell_secs)
    }

    pub fn app_scan_interval(&self) -> Duration {
        Duration::from_secs(self.automation.app_scan_secs)
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
        assert_eq!(cfg.curve().unwrap().points().len(), 10);
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
