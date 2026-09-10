//! Fan curve, plus a governor that prevents hunting.
//!
//! Three design decisions live here:
//!
//! 1. **`rpm = 0` does not mean "stop the fans", it means "hand control to
//!    the EC".** Measured in Phase 2: the EC's own automatic mode stops the
//!    fans completely at 45 C (fan-stop). Taking manual control at the bottom
//!    of the curve and forcing 1800 RPM would make the machine LOUDER than it
//!    is from the factory. So we give control back down there.
//!
//! 2. **Setpoints are rounded to the hardware's resolution.** Phase 1 §3.2:
//!    the EC's fan target (`SRP1`/`SRP2`) is in hundreds of RPM, so the real
//!    step is 100 RPM. `pwm1` being 0-255 makes it look finer, but the kernel
//!    reduces it with `pwm_to_rpm`: pwm 99 and 100 both land on EC value 18.
//!    Without rounding we would issue WMI calls that change nothing for every
//!    0.1 C of drift.
//!
//! 3. **Going up is free, coming down is delayed.** More cooling is always the
//!    safe direction and applies immediately. Reducing it requires both a
//!    temperature drop of at least the hysteresis and a minimum dwell time -
//!    otherwise the fan oscillates around a threshold.

use std::time::{Duration, Instant};

use serde::{Deserialize, Serialize};

use crate::error::{Error, Result};

/// A single point on the curve. `rpm = 0` -> hand control to the EC.
#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub struct Point {
    pub temp_c: f32,
    pub rpm: u32,
}

/// The desired fan state. `None` = control is with the EC.
pub type Target = Option<u32>;

/// The EC's fan target is in hundreds of RPM (Phase 1 §3.2), so this is the
/// real step size.
pub const EC_STEP_RPM: u32 = 100;

/// Ordering by "how much cooling", for comparisons. The automatic region sits
/// at the bottom of the curve, so it ranks lowest.
fn cooling_rank(t: Target) -> u32 {
    t.unwrap_or(0)
}

#[derive(Debug, Clone)]
pub struct Curve {
    points: Vec<Point>,
}

impl Curve {
    pub fn new(mut points: Vec<Point>) -> Result<Self> {
        if points.len() < 2 {
            return Err(Error::Curve("at least two points are required".into()));
        }
        points.sort_by(|a, b| a.temp_c.total_cmp(&b.temp_c));

        for w in points.windows(2) {
            if w[0].temp_c == w[1].temp_c {
                return Err(Error::Curve(format!(
                    "two points at the same temperature: {} C",
                    w[0].temp_c
                )));
            }
            // The fan cannot slow down as the temperature rises.
            if w[1].rpm != 0 && w[0].rpm > w[1].rpm {
                return Err(Error::Curve(format!(
                    "RPM decreases between {} C and {} C ({} -> {})",
                    w[0].temp_c, w[1].temp_c, w[0].rpm, w[1].rpm
                )));
            }
            // The automatic region may only sit at the bottom of the curve;
            // a 0 in the middle would imply everything above it is automatic
            // too, which is not what happens.
            if w[0].rpm != 0 && w[1].rpm == 0 {
                return Err(Error::Curve(format!(
                    "the automatic region (rpm=0) may only be at the bottom of the curve, found one at {} C",
                    w[1].temp_c
                )));
            }
        }
        Ok(Self { points })
    }

    pub fn points(&self) -> &[Point] {
        &self.points
    }

    /// The target for a given temperature. Linear interpolation between
    /// points; below the first point the first point applies, above the last
    /// the last one does.
    pub fn target(&self, temp_c: f32) -> Target {
        let first = self.points[0];
        let last = self.points[self.points.len() - 1];

        if temp_c <= first.temp_c {
            return (first.rpm != 0).then_some(first.rpm);
        }
        if temp_c >= last.temp_c {
            return (last.rpm != 0).then_some(last.rpm);
        }

        for w in self.points.windows(2) {
            let (a, b) = (w[0], w[1]);
            if temp_c >= a.temp_c && temp_c <= b.temp_c {
                // Interpolating out of the automatic region into the first
                // real point is meaningless - 0 is a mode, not an RPM value.
                if a.rpm == 0 {
                    return (b.rpm != 0).then_some(b.rpm);
                }
                let ratio = (temp_c - a.temp_c) / (b.temp_c - a.temp_c);
                let rpm = a.rpm as f32 + ratio * (b.rpm as f32 - a.rpm as f32);
                return Some(rpm.round() as u32);
            }
        }
        None
    }
}

#[derive(Debug, Clone, Copy)]
struct Applied {
    temp_c: f32,
    target: Target,
    at: Instant,
}

/// Runs the curve with hysteresis.
#[derive(Debug)]
pub struct Governor {
    curve: Curve,
    down_delta_c: f32,
    min_dwell: Duration,
    step_rpm: u32,
    applied: Option<Applied>,
}

impl Governor {
    pub fn new(curve: Curve, down_delta_c: f32, min_dwell: Duration, step_rpm: u32) -> Self {
        Self {
            curve,
            down_delta_c: down_delta_c.max(0.0),
            min_dwell,
            step_rpm: step_rpm.max(1),
            applied: None,
        }
    }

    /// Rounds the target to the hardware step. Rounds UP deliberately, so
    /// rounding error always lands on the side of more cooling.
    fn quantize(&self, target: Target) -> Target {
        target.map(|rpm| rpm.div_ceil(self.step_rpm) * self.step_rpm)
    }

    pub fn curve(&self) -> &Curve {
        &self.curve
    }

    pub fn current(&self) -> Option<Target> {
        self.applied.map(|a| a.target)
    }

    /// What should happen at this temperature?
    ///
    /// `None` -> no change (keep the current setpoint).
    /// `Some(target)` -> apply it.
    pub fn decide(&mut self, temp_c: f32, now: Instant) -> Option<Target> {
        let want = self.quantize(self.curve.target(temp_c));

        let Some(applied) = self.applied else {
            return Some(self.commit(temp_c, want, now));
        };

        if want == applied.target {
            return None;
        }

        // More cooling: immediately.
        if cooling_rank(want) > cooling_rank(applied.target) {
            return Some(self.commit(temp_c, want, now));
        }

        // Less cooling: both conditions must hold.
        let cooled_enough = temp_c <= applied.temp_c - self.down_delta_c;
        let waited_enough = now.duration_since(applied.at) >= self.min_dwell;
        if cooled_enough && waited_enough {
            return Some(self.commit(temp_c, want, now));
        }
        None
    }

    fn commit(&mut self, temp_c: f32, target: Target, now: Instant) -> Target {
        self.applied = Some(Applied {
            temp_c,
            target,
            at: now,
        });
        target
    }

    /// Called when falling back to safe mode, so the next decision starts
    /// fresh instead of being held back by hysteresis against a stale state.
    pub fn reset(&mut self) {
        self.applied = None;
    }
}

/// The curve taken from OGH's `profiles.json` in Phase 1 §6.3. The lower
/// region is left to the EC so its fan-stop behaviour is preserved.
pub fn default_curve() -> Curve {
    Curve::new(vec![
        Point {
            temp_c: 60.0,
            rpm: 0,
        },
        Point {
            temp_c: 70.0,
            rpm: 1800,
        },
        Point {
            temp_c: 80.0,
            rpm: 2400,
        },
        Point {
            temp_c: 90.0,
            rpm: 3300,
        },
        Point {
            temp_c: 95.0,
            rpm: 4800,
        },
    ])
    .expect("the built-in default curve must be valid")
}

#[cfg(test)]
mod tests {
    use super::*;

    fn c() -> Curve {
        default_curve()
    }

    #[test]
    fn lower_region_is_automatic() {
        assert_eq!(c().target(30.0), None);
        assert_eq!(c().target(59.9), None);
    }

    #[test]
    fn above_the_top_holds_the_last_point() {
        assert_eq!(c().target(95.0), Some(4800));
        assert_eq!(c().target(120.0), Some(4800));
    }

    #[test]
    fn interpolation_is_linear() {
        assert_eq!(c().target(75.0), Some(2100));
        assert_eq!(c().target(85.0), Some(2850));
    }

    #[test]
    fn leaving_the_automatic_region_does_not_interpolate() {
        // 60-70: the lower end is automatic, the upper end is 1800. Every
        // value in between is 1800.
        assert_eq!(c().target(65.0), Some(1800));
    }

    #[test]
    fn decreasing_rpm_is_rejected() {
        let bad = Curve::new(vec![
            Point {
                temp_c: 60.0,
                rpm: 3000,
            },
            Point {
                temp_c: 70.0,
                rpm: 2000,
            },
        ]);
        assert!(bad.is_err());
    }

    #[test]
    fn automatic_region_in_the_middle_is_rejected() {
        let bad = Curve::new(vec![
            Point {
                temp_c: 60.0,
                rpm: 1800,
            },
            Point {
                temp_c: 70.0,
                rpm: 0,
            },
        ]);
        assert!(bad.is_err());
    }

    #[test]
    fn heating_applies_immediately() {
        let mut g = Governor::new(c(), 5.0, Duration::from_secs(30), EC_STEP_RPM);
        let t0 = Instant::now();
        assert_eq!(g.decide(50.0, t0), Some(None));
        // Suddenly hot: step up without waiting.
        assert_eq!(g.decide(80.0, t0), Some(Some(2400)));
    }

    #[test]
    fn cooling_needs_both_hysteresis_and_dwell() {
        let mut g = Governor::new(c(), 5.0, Duration::from_secs(30), EC_STEP_RPM);
        let t0 = Instant::now();
        g.decide(80.0, t0);

        // Dropped 2 C, not enough hysteresis -> no change.
        assert_eq!(g.decide(78.0, t0 + Duration::from_secs(60)), None);
        // Dropped 6 C but the dwell has not elapsed -> still nothing.
        assert_eq!(g.decide(74.0, t0 + Duration::from_secs(5)), None);
        // Both satisfied -> step down. The raw target at 74 C is 2040, which
        // rounds up to 2100.
        assert_eq!(
            g.decide(74.0, t0 + Duration::from_secs(60)),
            Some(Some(2100))
        );
    }

    #[test]
    fn small_heating_produces_no_writes() {
        // Slow warm-up must not write a new setpoint every 0.1 C: the EC's
        // step is 100 RPM and the values in between land in the same place.
        let mut g = Governor::new(c(), 5.0, Duration::from_secs(30), EC_STEP_RPM);
        let t0 = Instant::now();
        g.decide(70.0, t0);

        let mut writes = 0;
        // 70.0 -> 74.9 over 50 samples; the raw target goes 1800 -> 2094.
        for i in 0..50 {
            let temp = 70.0 + i as f32 * 0.1;
            if g.decide(temp, t0 + Duration::from_secs(i * 2)).is_some() {
                writes += 1;
            }
        }
        // 1800 -> 1900 -> 2000 -> 2100: at most 3 real changes.
        assert!(writes <= 3, "produced {writes} writes, expected <= 3");
    }

    #[test]
    fn quantization_rounds_up() {
        let g = Governor::new(c(), 5.0, Duration::from_secs(30), EC_STEP_RPM);
        assert_eq!(g.quantize(Some(1801)), Some(1900));
        assert_eq!(g.quantize(Some(1800)), Some(1800));
        assert_eq!(g.quantize(None), None);
    }

    #[test]
    fn no_hunting() {
        // A temperature oscillating around a threshold must not change the
        // setpoint on every tick.
        let mut g = Governor::new(c(), 5.0, Duration::from_secs(30), EC_STEP_RPM);
        let t0 = Instant::now();
        g.decide(70.0, t0);

        let mut changes = 0;
        for i in 0..100 {
            let temp = if i % 2 == 0 { 69.5 } else { 70.5 };
            if g.decide(temp, t0 + Duration::from_secs(i * 10)).is_some() {
                changes += 1;
            }
        }
        assert!(changes <= 2, "changed {changes} times around the threshold");
    }
}
