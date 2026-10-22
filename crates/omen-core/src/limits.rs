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
    /// The lowest PL1 the surface limit takes Unleashed to. Not the slider's
    /// 25: the Hub's floor in Unleashed is the balanced entry of
    /// `NbPL1LowerBound` (30 on this platform), or the configured PL1 when
    /// that is lower (`AdaptivePowerControlV1.SetNbPL1LowerBound`).
    pub const SURFACE_PL1_FLOOR_W: u8 = 30;
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

    /// The GPU slowdown temperature the Hub sends with every profile
    /// (`GpsMaxTemperature`), and the one it drops to while the palm rest is
    /// too hot in balanced (`GpsMinTemperature`).
    pub const GPU_SLOWDOWN_C: u8 = 87;
    pub const GPU_SLOWDOWN_HOT_C: u8 = 75;

    /// Below this charge, on mains, a battery that is still discharging takes
    /// PL1 down a watt a second (`BatteryLowerBound`, `BatteryLifeThreshold`
    /// and the 3 % `BatteryDrainBuffer` above it, in which PL1 is held).
    pub const DRAIN_PL1_FLOOR_W: u8 = 35;
    pub const DRAIN_THRESHOLD: u8 = 90;
    pub const DRAIN_BUFFER: u8 = 3;
    /// Watts a second PL1 loses while the battery drains, and gets back
    /// afterwards (the Hub's `Increase`).
    pub const DRAIN_STEP_DOWN_W: f32 = 1.0;
    pub const DRAIN_STEP_UP_W: f32 = 5.0;
}

/// How the GPU is held back while the palm rest is over its limit.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SurfaceGpu {
    /// Dynamic Boost off; cTGP stays. Performance and Unleashed
    /// (`PpabOffWhenIrOverheat`).
    BoostOff,
    /// cTGP and Dynamic Boost off, and the GPU's slowdown temperature down to
    /// [`platform::GPU_SLOWDOWN_HOT_C`]. Balanced and low-power.
    Throttle,
}

/// The palm-rest limits OMEN Gaming Hub applies in a profile, on mains.
///
/// From the platform configuration for this chassis: `IrOverheatThreshold`,
/// `IrPl1Threshold` and `IrReleaseThreshold` are eight-entry arrays indexed by
/// the Hub's mode, and `NbPL1LowerBound` the same. Balanced and Eco are index
/// 2, performance index 7; Unleashed uses its own surface setting for all
/// three, released five degrees below.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct SurfaceLimits {
    /// At or above: PL1 loses a step each cycle, and the GPU is held back.
    pub overheat_c: u8,
    /// At or above, while rising: PL1 loses a step per degree risen (at most
    /// three). Equal to `overheat_c` in Unleashed.
    pub pl1_c: u8,
    /// At or below: the limit lets go, and PL1 and the GPU come back.
    pub release_c: u8,
    /// The lowest PL1 the loop goes to.
    pub floor_w: u8,
    /// The PL1 the profile runs at, which the loop never exceeds.
    pub max_w: u8,
    pub gpu: SurfaceGpu,
}

impl SurfaceLimits {
    /// The Hub's limits for `profile`, with Unleashed's from `cfg`. `None`
    /// for a profile it does not watch the palm rest in.
    pub fn for_profile(profile: &str, cfg: &PowerConfig) -> Option<Self> {
        use platform::*;
        match profile {
            "low-power" | "balanced" | "quiet" | "cool" => Some(Self {
                overheat_c: 52,
                pl1_c: 49,
                release_c: 43,
                floor_w: 30,
                max_w: 55,
                gpu: SurfaceGpu::Throttle,
            }),
            "performance" => Some(Self {
                overheat_c: 54,
                pl1_c: 50,
                release_c: 44,
                floor_w: 35,
                max_w: 60,
                gpu: SurfaceGpu::BoostOff,
            }),
            UNLEASHED => Some(Self {
                overheat_c: cfg.unleashed_surface_c,
                pl1_c: cfg.unleashed_surface_c,
                release_c: cfg.unleashed_surface_c.saturating_sub(SURFACE_RELEASE_C),
                floor_w: SURFACE_PL1_FLOOR_W.min(cfg.unleashed_pl1_w),
                max_w: cfg.unleashed_pl1_w,
                gpu: SurfaceGpu::BoostOff,
            }),
            _ => None,
        }
    }

    /// The charge below which a draining battery takes PL1 down: what the
    /// Hub derives from the minimum-battery settings in performance and
    /// Unleashed (100 minus them), and its platform default elsewhere.
    pub fn drain_threshold(profile: &str, cfg: &PowerConfig) -> u8 {
        match profile {
            UNLEASHED => 100u8.saturating_sub(cfg.min_battery_unleashed),
            "performance" => 100u8.saturating_sub(cfg.min_battery_performance),
            _ => platform::DRAIN_THRESHOLD,
        }
    }
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

/// The palm-rest limit: the Hub's loop (`CheckIfHandledByIrSensorV1`), one
/// cycle at a time.
///
/// Every [`platform::SURFACE_CYCLE_SECS`] the palm rest is read against the
/// profile's [`SurfaceLimits`]:
///
/// * at or above the PL1 threshold the surface is *handled*, until it falls
///   back to the release point;
/// * at or above the overheat threshold PL1 loses
///   [`platform::SURFACE_PL1_STEP_W`] and the GPU is held back;
/// * below that, still rising past the PL1 threshold, PL1 loses a step per
///   degree risen, three at most;
/// * below that, no longer rising, above the release point, PL1 creeps back,
///   more the faster it falls;
/// * at the release point the limit lets go, and the profile's PL1 comes back
///   at once - the Hub's Unleashed branch writes the configured value on its
///   next one-second pass, and its general algorithm climbs back to the
///   profile's bound within seconds under load.
#[derive(Debug, Clone)]
pub struct SurfaceGuard {
    limits: SurfaceLimits,
    pl1: u8,
    last_c: Option<u8>,
    handled: bool,
    hot: bool,
}

/// What one cycle decided.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct SurfaceStep {
    /// The PL1 to hold now.
    pub pl1: u8,
    /// Whether the GPU is held back: from the first overheat until release.
    pub hot: bool,
}

impl SurfaceGuard {
    pub fn new(limits: SurfaceLimits) -> Self {
        Self {
            limits,
            pl1: limits.max_w,
            last_c: None,
            handled: false,
            hot: false,
        }
    }

    pub fn limits(&self) -> &SurfaceLimits {
        &self.limits
    }

    pub fn pl1(&self) -> u8 {
        self.pl1
    }

    pub fn is_hot(&self) -> bool {
        self.hot
    }

    pub fn cycle(&mut self, surface_c: u8) -> SurfaceStep {
        use platform::*;
        let l = self.limits;
        let gap = self.last_c.map_or(0, |last| surface_c as i16 - last as i16);
        self.last_c = Some(surface_c);

        if surface_c >= l.pl1_c {
            self.handled = true;
        }
        let mut pl1 = self.pl1 as i16;
        if surface_c >= l.overheat_c {
            self.hot = true;
            pl1 -= SURFACE_PL1_STEP_W as i16;
        } else if gap > 0 && surface_c >= l.pl1_c {
            pl1 -= gap.min(3) * SURFACE_PL1_STEP_W as i16;
        } else if gap <= 0 && surface_c > l.release_c {
            pl1 += 1 - gap * 2;
        }
        if self.handled && surface_c <= l.release_c {
            self.handled = false;
            self.hot = false;
        }
        if !self.handled {
            pl1 = l.max_w as i16;
        }
        self.pl1 = pl1.clamp(l.floor_w as i16, l.max_w as i16) as u8;
        SurfaceStep {
            pl1: self.pl1,
            hot: self.hot,
        }
    }
}

/// PL1 while the battery drains on mains: the Hub's `ProcessBatteryDrain`.
///
/// An adapter that cannot keep up shows as a battery discharging with the
/// charger in. Below the threshold the Hub takes PL1 down a watt a second, to
/// [`platform::DRAIN_PL1_FLOOR_W`]; in the few percent above it, PL1 is held;
/// once the battery stops draining, PL1 climbs back to the profile's.
#[derive(Debug, Clone)]
pub struct DrainGuard {
    cap: f32,
    max_w: u8,
    floor_w: u8,
}

impl DrainGuard {
    pub fn new(max_w: u8) -> Self {
        Self {
            cap: max_w as f32,
            max_w,
            floor_w: platform::DRAIN_PL1_FLOOR_W.min(max_w),
        }
    }

    /// The most PL1 may be now.
    pub fn cap(&self) -> u8 {
        self.cap.round() as u8
    }

    /// Whether PL1 is being held under the profile's for the battery.
    pub fn limiting(&self) -> bool {
        self.cap() < self.max_w
    }

    /// `draining` is a battery discharging while on mains; `secs` the time
    /// since the last call.
    pub fn step(&mut self, draining: bool, percent: u8, threshold: u8, secs: f32) -> u8 {
        use platform::*;
        let secs = secs.clamp(0.0, 30.0);
        if draining && percent < threshold {
            self.cap -= DRAIN_STEP_DOWN_W * secs;
        } else if draining && percent < threshold.saturating_add(DRAIN_BUFFER) {
            // Held where it is.
        } else {
            self.cap += DRAIN_STEP_UP_W * secs;
        }
        self.cap = self.cap.clamp(self.floor_w as f32, self.max_w as f32);
        self.cap()
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
        let mut g = SurfaceGuard::new(unleashed(54, 71));
        assert_eq!(g.cycle(50).pl1, 71);
        let step = g.cycle(54);
        assert_eq!(step.pl1, 66);
        assert!(step.hot);
        assert_eq!(g.cycle(56).pl1, 61);
    }

    #[test]
    fn pl1_never_leaves_hps_range() {
        let mut g = SurfaceGuard::new(unleashed(44, 71));
        for _ in 0..30 {
            g.cycle(60);
        }
        assert_eq!(g.pl1(), platform::SURFACE_PL1_FLOOR_W);
        g.cycle(30);
        assert_eq!(
            g.pl1(),
            71,
            "given back at once, but not past the configured value"
        );
    }

    #[test]
    fn a_configured_pl1_under_the_floor_is_the_floor() {
        let mut g = SurfaceGuard::new(unleashed(44, 25));
        for _ in 0..5 {
            g.cycle(60);
        }
        assert_eq!(g.pl1(), 25);
    }

    #[test]
    fn rising_but_under_the_limit_holds() {
        let mut g = SurfaceGuard::new(unleashed(54, 71));
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
        let mut g = SurfaceGuard::new(unleashed(54, 71));
        assert!(g.cycle(54).hot);
        assert!(g.cycle(52).hot, "warm but under the limit: still held off");
        assert!(!g.cycle(45).hot);
    }

    fn unleashed(surface_c: u8, pl1_w: u8) -> SurfaceLimits {
        let cfg = PowerConfig {
            unleashed_surface_c: surface_c,
            unleashed_pl1_w: pl1_w,
            ..PowerConfig::default()
        };
        SurfaceLimits::for_profile(UNLEASHED, &cfg).unwrap()
    }

    fn limits(profile: &str) -> SurfaceLimits {
        SurfaceLimits::for_profile(profile, &PowerConfig::default()).unwrap()
    }

    #[test]
    fn every_profile_has_the_hubs_limits() {
        let b = limits("balanced");
        assert_eq!((b.overheat_c, b.pl1_c, b.release_c), (52, 49, 43));
        assert_eq!((b.floor_w, b.max_w, b.gpu), (30, 55, SurfaceGpu::Throttle));
        assert_eq!(limits("low-power"), b, "Eco is the balanced entry");
        let p = limits("performance");
        assert_eq!((p.overheat_c, p.pl1_c, p.release_c), (54, 50, 44));
        assert_eq!((p.floor_w, p.max_w, p.gpu), (35, 60, SurfaceGpu::BoostOff));
        let u = limits(UNLEASHED);
        assert_eq!((u.overheat_c, u.pl1_c, u.release_c), (54, 54, 49));
        assert_eq!((u.floor_w, u.max_w), (30, 71));
        for l in [b, p, u] {
            assert!(l.release_c < l.pl1_c && l.pl1_c <= l.overheat_c, "{l:?}");
            assert_eq!(platform::profile_pl1("performance"), Some(p.max_w));
        }
        assert_eq!(
            SurfaceLimits::for_profile("custom", &PowerConfig::default()),
            None
        );
    }

    #[test]
    fn a_cool_palm_rest_leaves_the_profile_alone() {
        let mut g = SurfaceGuard::new(limits("balanced"));
        for c in [35, 40, 45, 48, 44] {
            let step = g.cycle(c);
            assert_eq!((step.pl1, step.hot), (55, false), "{c} C");
        }
    }

    #[test]
    fn a_rising_palm_rest_costs_a_step_per_degree() {
        let mut g = SurfaceGuard::new(limits("performance"));
        g.cycle(48);
        // 50 is the PL1 threshold: two degrees risen, two steps.
        assert_eq!(g.cycle(50).pl1, 50);
        // Four more: three steps at most.
        assert_eq!(g.cycle(54 - 1).pl1, 35, "three steps, and the floor");
        assert!(!g.is_hot(), "under the overheat threshold the GPU is left");
    }

    #[test]
    fn balanced_overheat_throttles_the_gpu_until_release() {
        let mut g = SurfaceGuard::new(limits("balanced"));
        assert!(g.cycle(52).hot);
        assert_eq!(g.pl1(), 50);
        // Falling, still above the release point: PL1 creeps back, held off.
        let step = g.cycle(47);
        assert!(step.hot);
        assert_eq!(step.pl1, 55, "50 + 1 + 2 x 5, at the profile's bound");
        let step = g.cycle(46);
        assert!(step.hot);
        // 43 releases it.
        assert_eq!(
            g.cycle(43),
            SurfaceStep {
                pl1: 55,
                hot: false
            }
        );
    }

    #[test]
    fn a_draining_battery_takes_pl1_down_a_watt_a_second() {
        let mut d = DrainGuard::new(60);
        assert_eq!(d.step(true, 95, 90, 2.0), 60, "above the threshold");
        assert_eq!(d.step(true, 92, 90, 2.0), 60, "in the buffer: held");
        assert_eq!(d.step(true, 89, 90, 2.0), 58);
        assert!(d.limiting());
        for _ in 0..30 {
            d.step(true, 80, 90, 2.0);
        }
        assert_eq!(d.cap(), platform::DRAIN_PL1_FLOOR_W);
        // In the buffer after a drain: held, not given back.
        assert_eq!(d.step(true, 91, 90, 2.0), 35);
        // Charging again: back, five watts a second.
        assert_eq!(d.step(false, 80, 90, 2.0), 45);
        d.step(false, 80, 90, 10.0);
        assert!(!d.limiting());
    }

    #[test]
    fn the_drain_threshold_follows_the_battery_floors() {
        let cfg = PowerConfig::default();
        assert_eq!(SurfaceLimits::drain_threshold(UNLEASHED, &cfg), 60);
        assert_eq!(SurfaceLimits::drain_threshold("performance", &cfg), 90);
        assert_eq!(SurfaceLimits::drain_threshold("balanced", &cfg), 90);
    }
}
