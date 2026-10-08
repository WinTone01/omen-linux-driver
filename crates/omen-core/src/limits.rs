//! Unleashed, PL1 and the shared CPU+GPU limit.
//!
//! What OMEN Gaming Hub does beyond the three thermal profiles, on the board
//! it was read from. The protocol and every number below are in
//! docs/research/hub-gap.md: the WMI commands came out of the Hub's logs and
//! the DSDT, the limits out of the platform configuration the Hub ships for
//! this chassis (`Khalilah_STX_N22X4X6`).
//!
//! omen-kbd-rgb 0.3.0 does the firmware calls and exposes plain watts; this
//! is the policy on top - the ranges HP allows, the defaults it uses, and the
//! loop that holds the palm rest under a temperature in Unleashed.

use std::path::{Path, PathBuf};

use serde::{Deserialize, Serialize};

use crate::error::{Error, Result};

const DIR: &str = "/sys/devices/platform/omen-kbd-rgb";

/// The profile name Unleashed is offered under, next to the firmware's own.
pub const UNLEASHED: &str = "unleashed";

/// HP's numbers for this platform. Ranges are what the Hub lets a user pick;
/// the rest is what it sets by itself.
pub mod platform {
    /// PL1 in Unleashed: the Hub's slider, and where it starts.
    pub const UNLEASHED_PL1_MIN_W: u8 = 25;
    pub const UNLEASHED_PL1_MAX_W: u8 = 71;
    /// The surface temperature Unleashed holds the palm rest under.
    pub const SURFACE_MIN_C: u8 = 44;
    pub const SURFACE_MAX_C: u8 = 54;
    /// How far below the limit the surface must fall before PL1 is given
    /// back - the Hub's `UnleashedModeIrReleaseThresholdOffset`.
    pub const SURFACE_RELEASE_C: u8 = 5;
    /// PL1 taken away per cycle at the limit, and how often the loop runs.
    pub const SURFACE_PL1_STEP_W: u8 = 5;
    pub const SURFACE_CYCLE_SECS: u64 = 30;
    /// The shared CPU+GPU limit can be raised this far above the firmware's
    /// own value (45 W here, read at startup): `TppMaxValue` is 65 W.
    pub const TPP_MAX_OFFSET_W: u8 = 20;
    /// The battery charge below which the Hub will not stay in a mode.
    pub const PERFORMANCE_MIN_BATTERY: u8 = 10;
    pub const UNLEASHED_MIN_BATTERY: u8 = 40;

    /// The PL1 the firmware's own profiles use. Put back on every change to
    /// one of them, so a raised limit does not outlive the mode that raised
    /// it: the firmware does not reset PL1 with the profile (measured
    /// 2026-10-09 - after Unleashed, balanced and performance both drew 71 W).
    ///
    /// Low-power is 55 like balanced because it is the same firmware profile:
    /// hp-wmi writes HPCM 0x30 for both, and the low-power cap comes from
    /// amd-pmf, not from PL1. The numbers are HP's (`PL1DefaultValue`,
    /// `NbPL1UpperBoundPerformance`) and the ones `omenctl profile measure`
    /// found before anything here wrote PL1 (profile-power.md).
    pub fn profile_pl1(profile: &str) -> Option<u8> {
        match profile {
            "low-power" | "balanced" | "quiet" | "cool" => Some(55),
            "performance" => Some(60),
            _ => None,
        }
    }

    /// The shared CPU+GPU limit the Hub works from on this platform (its
    /// `DefaultConcurrentTdp`, logged as `SetConcurrentTdp - value=45`) and
    /// the most it allows (`TppMaxValue`). Fixed rather than read: what the
    /// firmware reports follows the profile - 30 W was read on Linux while
    /// the Hub saw 45 - and an offset added to a moving base is not the
    /// setting someone chose.
    pub const TPP_MIN_W: u8 = 45;
    pub const TPP_MAX_W: u8 = 65;
}

fn path(file: &str) -> PathBuf {
    Path::new(DIR).join(file)
}

fn read_u8(file: &str) -> Option<u8> {
    std::fs::read_to_string(path(file))
        .ok()
        .and_then(|s| s.trim().parse().ok())
}

fn write(file: &str, value: impl std::fmt::Display) -> Result<()> {
    let p = path(file);
    std::fs::write(&p, value.to_string()).map_err(|source| Error::Write { path: p, source })
}

/// Whether this machine has Unleashed (omen-kbd-rgb 0.3.0 on 8D24).
pub fn has_unleashed() -> bool {
    path("unleashed").exists()
}

/// Whether HPCM reads Unleashed. `None` when there is no such mode here.
pub fn unleashed() -> Option<bool> {
    read_u8("unleashed").map(|v| v == 1)
}

pub fn set_unleashed(on: bool) -> Result<()> {
    write("unleashed", u8::from(on))
}

/// PL1 as the EC holds it, in watts.
pub fn pl1() -> Option<u8> {
    read_u8("cpu_pl1")
}

pub fn set_pl1(watts: u8) -> Result<()> {
    write("cpu_pl1", watts)
}

/// The shared CPU+GPU limit in force, in watts.
pub fn tpp() -> Option<u8> {
    read_u8("gpu_tpp").filter(|w| *w > 0)
}

pub fn set_tpp(watts: u8) -> Result<()> {
    write("gpu_tpp", watts)
}

/// What the configuration asks of Unleashed and of the performance profile.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct PowerConfig {
    /// PL1 in Unleashed, watts. 25-71; the Hub starts at 71.
    #[serde(default = "default_pl1")]
    pub unleashed_pl1_w: u8,
    /// The surface temperature Unleashed keeps under, °C. 44-54.
    #[serde(default = "default_surface")]
    pub unleashed_surface_c: u8,
    /// Watts added to the shared CPU+GPU limit in Unleashed. 0-20.
    #[serde(default = "default_unleashed_tpp")]
    pub unleashed_tpp_offset_w: u8,
    /// The same, in the performance profile. The Hub's default is none.
    #[serde(default)]
    pub performance_tpp_offset_w: u8,
    /// On battery, below this charge the performance profile gives way to
    /// balanced. 0 turns the floor off.
    #[serde(default = "default_min_performance")]
    pub min_battery_performance: u8,
    /// On battery, below this charge Unleashed gives way to performance.
    #[serde(default = "default_min_unleashed")]
    pub min_battery_unleashed: u8,
    /// The CPU's energy-performance preference follows the profile, when
    /// nothing else (power-profiles-daemon, tuned) is already doing it.
    #[serde(default = "yes")]
    pub epp_follows_profile: bool,
}

fn default_pl1() -> u8 {
    platform::UNLEASHED_PL1_MAX_W
}
fn default_surface() -> u8 {
    platform::SURFACE_MAX_C
}
fn default_unleashed_tpp() -> u8 {
    platform::TPP_MAX_OFFSET_W
}
fn default_min_performance() -> u8 {
    platform::PERFORMANCE_MIN_BATTERY
}
fn default_min_unleashed() -> u8 {
    platform::UNLEASHED_MIN_BATTERY
}
fn yes() -> bool {
    true
}

impl Default for PowerConfig {
    fn default() -> Self {
        Self {
            unleashed_pl1_w: default_pl1(),
            unleashed_surface_c: default_surface(),
            unleashed_tpp_offset_w: default_unleashed_tpp(),
            performance_tpp_offset_w: 0,
            min_battery_performance: default_min_performance(),
            min_battery_unleashed: default_min_unleashed(),
            epp_follows_profile: true,
        }
    }
}

impl PowerConfig {
    /// HP's ranges. Not ours to widen: past them is a machine nobody has
    /// measured.
    pub fn check(&self) -> std::result::Result<(), String> {
        use platform::*;
        let within = |what: &str, v: u8, lo: u8, hi: u8| {
            if (lo..=hi).contains(&v) {
                Ok(())
            } else {
                Err(format!("{what} must be between {lo} and {hi}, got {v}"))
            }
        };
        within(
            "unleashed_pl1_w",
            self.unleashed_pl1_w,
            UNLEASHED_PL1_MIN_W,
            UNLEASHED_PL1_MAX_W,
        )?;
        within(
            "unleashed_surface_c",
            self.unleashed_surface_c,
            SURFACE_MIN_C,
            SURFACE_MAX_C,
        )?;
        within(
            "unleashed_tpp_offset_w",
            self.unleashed_tpp_offset_w,
            0,
            TPP_MAX_OFFSET_W,
        )?;
        within(
            "performance_tpp_offset_w",
            self.performance_tpp_offset_w,
            0,
            TPP_MAX_OFFSET_W,
        )?;
        within(
            "min_battery_performance",
            self.min_battery_performance,
            0,
            100,
        )?;
        within("min_battery_unleashed", self.min_battery_unleashed, 0, 100)?;
        Ok(())
    }

    /// The lowest charge `profile` may run at on battery; 0 for none.
    pub fn battery_floor(&self, profile: &str) -> u8 {
        match profile {
            UNLEASHED => self.min_battery_unleashed,
            "performance" => self.min_battery_performance,
            _ => 0,
        }
    }
}

/// The profile to fall back to when the battery is below `profile`'s floor,
/// stepping down until one fits. `None` when `profile` may stay.
pub fn battery_fallback(cfg: &PowerConfig, profile: &str, percent: u8) -> Option<&'static str> {
    if percent >= cfg.battery_floor(profile) {
        return None;
    }
    if profile == UNLEASHED && percent >= cfg.battery_floor("performance") {
        return Some("performance");
    }
    Some("balanced")
}

/// Unleashed's surface limit: the Hub's loop, one cycle at a time.
///
/// Every [`platform::SURFACE_CYCLE_SECS`] the palm rest is read against the
/// limit. At or above it PL1 loses [`platform::SURFACE_PL1_STEP_W`] and
/// Dynamic Boost is switched off; between the release point and the limit,
/// with the surface no longer rising, PL1 creeps back. Below the release
/// point the Hub leaves PL1 where it is and lets its general algorithm raise
/// it; there is no general algorithm here, so it is raised a step at a time
/// back to the configured value instead.
#[derive(Debug, Clone)]
pub struct SurfaceGuard {
    limit_c: u8,
    max_pl1: u8,
    pl1: u8,
    last_c: Option<u8>,
    hot: bool,
}

/// What one cycle decided.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct SurfaceStep {
    /// The PL1 to hold now.
    pub pl1: u8,
    /// Whether the surface is at the limit - Dynamic Boost off while it is.
    pub hot: bool,
}

impl SurfaceGuard {
    pub fn new(limit_c: u8, pl1: u8) -> Self {
        Self {
            limit_c,
            max_pl1: pl1,
            pl1,
            last_c: None,
            hot: false,
        }
    }

    pub fn pl1(&self) -> u8 {
        self.pl1
    }

    pub fn is_hot(&self) -> bool {
        self.hot
    }

    pub fn cycle(&mut self, surface_c: u8) -> SurfaceStep {
        use platform::*;
        let gap = self.last_c.map_or(0, |last| surface_c as i16 - last as i16);
        self.last_c = Some(surface_c);
        let release = self.limit_c.saturating_sub(SURFACE_RELEASE_C);
        let floor = UNLEASHED_PL1_MIN_W;

        let pl1 = self.pl1 as i16;
        let next = if surface_c >= self.limit_c {
            self.hot = true;
            pl1 - SURFACE_PL1_STEP_W as i16
        } else if surface_c > release {
            // Still warm. Falling or flat: give a little back, more the
            // faster it falls. Rising: hold.
            if gap <= 0 {
                pl1 + 1 - gap * 2
            } else {
                pl1
            }
        } else {
            self.hot = false;
            pl1 + SURFACE_PL1_STEP_W as i16
        };
        self.pl1 = next.clamp(floor as i16, self.max_pl1 as i16) as u8;
        SurfaceStep {
            pl1: self.pl1,
            hot: self.hot,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn the_defaults_are_hps_and_pass_hps_ranges() {
        let cfg = PowerConfig::default();
        assert_eq!(cfg.unleashed_pl1_w, 71);
        assert_eq!(cfg.unleashed_surface_c, 54);
        cfg.check().unwrap();
    }

    #[test]
    fn every_firmware_profile_gets_its_pl1_back() {
        // Measured: after Unleashed, low-power then balanced then performance
        // all held its 71 W, because only the direct exit restored anything
        // and low-power had no value to restore.
        for p in ["low-power", "balanced", "performance"] {
            let w = platform::profile_pl1(p).unwrap_or_else(|| panic!("{p} has no PL1"));
            assert!(w < platform::UNLEASHED_PL1_MAX_W, "{p}");
        }
        assert_eq!(platform::profile_pl1(UNLEASHED), None);
        assert_eq!(
            platform::TPP_MIN_W + platform::TPP_MAX_OFFSET_W,
            platform::TPP_MAX_W,
            "HP's base plus the largest offset is HP's maximum"
        );
    }

    #[test]
    fn a_pl1_beyond_hps_range_is_refused() {
        let cfg = PowerConfig {
            unleashed_pl1_w: 80,
            ..PowerConfig::default()
        };
        assert!(cfg.check().unwrap_err().contains("unleashed_pl1_w"));
    }

    #[test]
    fn the_battery_floor_steps_down_one_mode_at_a_time() {
        let cfg = PowerConfig::default();
        assert_eq!(battery_fallback(&cfg, UNLEASHED, 80), None);
        assert_eq!(battery_fallback(&cfg, UNLEASHED, 30), Some("performance"));
        assert_eq!(battery_fallback(&cfg, UNLEASHED, 5), Some("balanced"));
        assert_eq!(battery_fallback(&cfg, "performance", 9), Some("balanced"));
        assert_eq!(battery_fallback(&cfg, "balanced", 1), None);
    }

    #[test]
    fn a_floor_of_zero_is_off() {
        let cfg = PowerConfig {
            min_battery_unleashed: 0,
            min_battery_performance: 0,
            ..PowerConfig::default()
        };
        assert_eq!(battery_fallback(&cfg, UNLEASHED, 1), None);
    }

    #[test]
    fn at_the_limit_pl1_comes_down_and_boost_goes_off() {
        let mut g = SurfaceGuard::new(54, 71);
        assert_eq!(g.cycle(50).pl1, 71);
        let step = g.cycle(54);
        assert_eq!(step.pl1, 66);
        assert!(step.hot);
        assert_eq!(g.cycle(56).pl1, 61);
    }

    #[test]
    fn pl1_never_leaves_hps_range() {
        let mut g = SurfaceGuard::new(44, 71);
        for _ in 0..30 {
            g.cycle(60);
        }
        assert_eq!(g.pl1(), platform::UNLEASHED_PL1_MIN_W);
        for _ in 0..30 {
            g.cycle(30);
        }
        assert_eq!(g.pl1(), 71, "given back, but not past the configured value");
    }

    #[test]
    fn rising_but_under_the_limit_holds() {
        let mut g = SurfaceGuard::new(54, 71);
        g.cycle(55);
        g.cycle(55);
        let held = g.pl1();
        // 49 is the release point: cool enough for a step back.
        g.cycle(49);
        assert!(g.pl1() > held);
        // Then warming again, still under the limit: nothing more is given
        // back while it climbs.
        let before = g.pl1();
        g.cycle(51);
        assert_eq!(g.pl1(), before, "rising: hold");
    }

    #[test]
    fn cool_again_ends_the_hot_state() {
        let mut g = SurfaceGuard::new(54, 71);
        assert!(g.cycle(54).hot);
        assert!(g.cycle(52).hot, "warm but under the limit: still held off");
        assert!(!g.cycle(45).hot);
    }
}
