//! Fan curve, plus a governor that prevents hunting.
//!
//! Three design decisions live here:
//!
//! 1. **`rpm = 0` means "fans off, setpoint still ours".** The machine is
//!    silent at idle from the factory - the EC stops the fans completely at
//!    45 C - and forcing 1800 RPM down there would make it LOUDER than
//!    stock. But "off" must not be spelled by handing control to the EC:
//!    once this driver has been in manual mode the EC does not take its own
//!    curve back, and the fans then stay stopped while the machine heats up.
//!    So the bottom of the curve is manual mode at pwm 0, which the next
//!    sample can undo.
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

/// A single point on the curve. `rpm = 0` -> fans off (still our setpoint).
#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub struct Point {
    pub temp_c: f32,
    pub rpm: u32,
}

/// The desired fan state. `None` = fans off.
pub type Target = Option<u32>;

/// How a value between two points is worked out.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Interpolation {
    /// Hold each point's value until the next one is reached.
    ///
    /// The default, because this is what OMEN Gaming Hub does: the curve it
    /// ships in `profiles.json` is a lookup table at 5 C granularity, not a
    /// continuous curve (Phase 1 §6.3). At 75 C its table says 2400 RPM;
    /// interpolating between the 70 C and 80 C entries would say 2100 and be
    /// quieter than stock.
    #[default]
    Step,
    /// Straight line between the two neighbouring points.
    Linear,
}

/// The EC's fan target is in hundreds of RPM (Phase 1 §3.2), so this is the
/// real step size.
pub const EC_STEP_RPM: u32 = 100;

/// Ordering by "how much cooling", for comparisons. The idle region sits at
/// the bottom of the curve, so it ranks lowest.
fn cooling_rank(t: Target) -> u32 {
    t.unwrap_or(0)
}

#[derive(Debug, Clone)]
pub struct Curve {
    points: Vec<Point>,
    interpolation: Interpolation,
}

impl Curve {
    pub fn new(points: Vec<Point>) -> Result<Self> {
        Self::with_interpolation(points, Interpolation::default())
    }

    pub fn with_interpolation(
        mut points: Vec<Point>,
        interpolation: Interpolation,
    ) -> Result<Self> {
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
            // The idle region may only sit at the bottom of the curve; a 0
            // in the middle would mean the fans stop again as the machine
            // gets hotter, which is not a curve anyone means to draw.
            if w[0].rpm != 0 && w[1].rpm == 0 {
                return Err(Error::Curve(format!(
                    "fans off (rpm=0) is only allowed at the bottom of the curve, found one at {} C",
                    w[1].temp_c
                )));
            }
        }
        Ok(Self {
            points,
            interpolation,
        })
    }

    pub fn points(&self) -> &[Point] {
        &self.points
    }

    pub fn interpolation(&self) -> Interpolation {
        self.interpolation
    }

    /// The target for a given temperature.
    ///
    /// Below the first point the first point applies; above the last, the
    /// last one does. In between it depends on [`Interpolation`].
    pub fn target(&self, temp_c: f32) -> Target {
        let first = self.points[0];
        let last = self.points[self.points.len() - 1];

        if temp_c <= first.temp_c {
            return (first.rpm != 0).then_some(first.rpm);
        }
        if temp_c >= last.temp_c {
            return (last.rpm != 0).then_some(last.rpm);
        }

        if self.interpolation == Interpolation::Step {
            // The last point at or below this temperature. Searching from the
            // end matters: at a point's exact temperature that point wins, not
            // the one below it, so 70.0 C reads 2400 and not 1800.
            let p = self
                .points
                .iter()
                .rev()
                .find(|p| temp_c >= p.temp_c)
                .unwrap_or(&first);
            return (p.rpm != 0).then_some(p.rpm);
        }

        for w in self.points.windows(2) {
            let (a, b) = (w[0], w[1]);
            if temp_c >= a.temp_c && temp_c <= b.temp_c {
                // Interpolating out of the idle region into the first real
                // point is meaningless - off is a state, not an RPM value.
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

/// OMEN Gaming Hub's own fan curve, captured in Phase 1 §6.3 from the
/// `profiles.json` it ships.
///
/// A lookup table at 5 C granularity rather than a continuous curve, so it is
/// reproduced point for point and read with [`Interpolation::Step`]. The
/// duplicate values are deliberate: this is the table as measured, not a
/// simplification of it.
///
/// | CPU C | 50 | 55 | 60 | 65 | 70 | 75 | 80 | 85 | 90 |
/// |---|---|---|---|---|---|---|---|---|---|
/// | hundreds of RPM | 18 | 18 | 18 | 18 | 24 | 24 | 24 | 24 | 33 |
///
/// Two things are ours rather than HP's, because the table does not cover
/// them:
///
/// * **Below 50 C** the table says nothing, so the fans are left alone. The
///   machine is silent at idle, which is what it does from the factory
///   (measured in Phase 2: 0 RPM at 45 C).
/// * **Above 90 C** the table stops, so 3300 RPM is held. HP lets the CPU
///   throttle rather than spinning faster; the critical cutout at 97 C is
///   what catches a genuine runaway.
pub fn default_curve() -> Curve {
    let p = |temp_c: f32, rpm: u32| Point { temp_c, rpm };
    Curve::with_interpolation(
        vec![
            p(45.0, 0),
            p(50.0, 1800),
            p(55.0, 1800),
            p(60.0, 1800),
            p(65.0, 1800),
            p(70.0, 2400),
            p(75.0, 2400),
            p(80.0, 2400),
            p(85.0, 2400),
            p(90.0, 3300),
        ],
        Interpolation::Step,
    )
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
        // OGH's table starts at 50 C; below that the fans are left alone.
        assert_eq!(c().target(30.0), None);
        assert_eq!(c().target(44.9), None);
        assert_eq!(c().target(47.0), None);
    }

    #[test]
    fn above_the_top_holds_the_last_point() {
        // HP's table stops at 90 C / 3300 RPM. Above that it lets the CPU
        // throttle; the critical cutout is what catches a real runaway.
        assert_eq!(c().target(90.0), Some(3300));
        assert_eq!(c().target(120.0), Some(3300));
    }

    #[test]
    fn the_default_matches_ogh_point_for_point() {
        // Phase 1 §6.3, from the profiles.json OMEN Gaming Hub ships.
        for (temp, rpm) in [
            (50.0, 1800),
            (55.0, 1800),
            (60.0, 1800),
            (65.0, 1800),
            (70.0, 2400),
            (75.0, 2400),
            (80.0, 2400),
            (85.0, 2400),
            (90.0, 3300),
        ] {
            assert_eq!(c().target(temp), Some(rpm), "at {temp} C");
        }
    }

    #[test]
    fn step_holds_until_the_next_point() {
        // The value is held, not ramped: at 69.9 C OGH still says 1800, and
        // interpolating would have said 2100 - quieter than stock, which is
        // the opposite of matching it.
        assert_eq!(c().target(69.9), Some(1800));
        assert_eq!(c().target(70.0), Some(2400));
        assert_eq!(c().target(89.9), Some(2400));
    }

    #[test]
    fn linear_still_interpolates_when_asked() {
        let curve = Curve::with_interpolation(
            vec![
                Point {
                    temp_c: 70.0,
                    rpm: 1800,
                },
                Point {
                    temp_c: 80.0,
                    rpm: 2400,
                },
            ],
            Interpolation::Linear,
        )
        .unwrap();
        assert_eq!(curve.target(75.0), Some(2100));
    }

    #[test]
    fn leaving_the_automatic_region_does_not_interpolate() {
        // Linear mode cannot interpolate out of the idle region - 0 is a
        // mode, not an RPM value - so the upper point applies throughout.
        let curve = Curve::with_interpolation(
            vec![
                Point {
                    temp_c: 60.0,
                    rpm: 0,
                },
                Point {
                    temp_c: 70.0,
                    rpm: 1800,
                },
            ],
            Interpolation::Linear,
        )
        .unwrap();
        assert_eq!(curve.target(65.0), Some(1800));
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
        assert_eq!(g.decide(40.0, t0), Some(None));
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
        // Dropped 12 C but the dwell has not elapsed -> still nothing.
        assert_eq!(g.decide(68.0, t0 + Duration::from_secs(5)), None);
        // Both satisfied -> step down to the 65 C entry.
        assert_eq!(
            g.decide(68.0, t0 + Duration::from_secs(60)),
            Some(Some(1800))
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
        // 70.0 -> 74.9 over 50 samples, all inside the same table entry.
        for i in 0..50 {
            let temp = 70.0 + i as f32 * 0.1;
            if g.decide(temp, t0 + Duration::from_secs(i * 2)).is_some() {
                writes += 1;
            }
        }
        // A step curve holds one value across the whole entry, so a slow
        // warm-up inside it should produce nothing at all.
        assert_eq!(writes, 0, "produced {writes} writes inside one entry");
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
