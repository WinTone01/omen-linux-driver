//! OMEN Gaming Hub's own fan algorithm, as it runs on this board.
//!
//! The curve in curve.rs is the Hub's *custom curve* table - the starting
//! point it offers someone who turns custom curves on. What the Hub runs
//! otherwise is this, read out of the platform configuration it ships for the
//! chassis (docs/research/hub-gap.md):
//!
//! * **Three sources, three tables.** CPU, discrete GPU and the palm rest
//!   (the "IR" sensor) each have their own table, and the fans follow
//!   whichever asks for the most.
//! * **Steps with two edges.** Each step has a temperature to go up at and a
//!   lower one to come down at, so the tables carry their own hysteresis, and
//!   a source moves at most one step per cycle.
//! * **The CPU is smoothed first.** An exponential average that rises slowly
//!   and falls quickly: a compile that spikes Tctl for two seconds does not
//!   spin the fans up, a sustained load does. The GPU and the palm rest are
//!   slow by nature and are used as they are.
//! * **One table set per mode.** Balanced (and low-power) share the default
//!   set, which keeps the fans stopped until the smoothed CPU reaches 68 °C;
//!   performance and Unleashed start earlier and go higher.
//!
//! Speeds are in hundreds of RPM, as the EC takes them. 0 is "fans off", the
//! same setpoint-of-zero the curve uses at its bottom.

use std::time::{Duration, Instant};

use crate::curve::Target;

/// One source's table: go up a step at `up[n]`, down a step at `down[n]`.
#[derive(Debug, Clone, Copy)]
pub struct Table {
    pub up: &'static [u8],
    /// Empty for a table with no separate down edges (the palm rest in every
    /// set): such a table is read as a plain lookup.
    pub down: &'static [u8],
    pub speed: &'static [u8],
}

/// One mode's tables, and how its CPU average moves.
#[derive(Debug, Clone, Copy)]
pub struct TableSet {
    pub name: &'static str,
    pub cpu: Table,
    pub gpu: Table,
    pub surface: Table,
    /// The average's weight on a new reading, per second, when the CPU is
    /// warmer than the average and when it is cooler.
    pub rise: f32,
    pub fall: f32,
}

/// `SwFanControlCustomDefault`: eco, balanced and low-power.
pub const DEFAULT: TableSet = TableSet {
    name: "default",
    cpu: Table {
        up: &[68, 71, 74, 77, 80, 83, 90, 94, 97],
        down: &[0, 62, 65, 68, 71, 74, 77, 83, 88],
        speed: &[0, 18, 21, 24, 26, 28, 29, 33, 33],
    },
    gpu: Table {
        up: &[54, 56, 58, 62, 66, 68, 70, 72, 87],
        down: &[43, 49, 51, 55, 59, 61, 63, 65, 69],
        speed: &[0, 18, 21, 24, 26, 28, 29, 33, 33],
    },
    surface: Table {
        up: &[35, 36, 37, 38, 39, 44],
        down: &[],
        speed: &[0, 18, 21, 24, 26, 28],
    },
    rise: 0.05,
    fall: 0.7,
};

/// `SwFanControlCustomPerformance`.
pub const PERFORMANCE: TableSet = TableSet {
    name: "performance",
    cpu: Table {
        up: &[51, 57, 63, 69, 72, 75, 95, 97, 100],
        down: &[0, 45, 52, 59, 64, 67, 71, 89, 95],
        speed: &[18, 21, 24, 26, 29, 33, 36, 42, 42],
    },
    gpu: Table {
        up: &[58, 62, 66, 69, 70, 72, 74, 84, 87],
        down: &[49, 56, 58, 61, 63, 65, 67, 69, 76],
        speed: &[18, 21, 24, 26, 29, 33, 36, 42, 42],
    },
    surface: Table {
        up: &[32, 36, 37, 38, 42, 45],
        down: &[],
        speed: &[18, 21, 24, 26, 29, 33],
    },
    rise: 0.07,
    fall: 0.5,
};

/// `SwFanControlCustomUnleashed`: the performance tables, run to full speed.
pub const UNLEASHED: TableSet = TableSet {
    name: "unleashed",
    cpu: Table {
        up: &[60, 66, 71, 74, 77, 80, 83, 97, 100],
        down: &[0, 53, 59, 64, 67, 70, 73, 78, 90],
        speed: &[18, 21, 24, 26, 29, 33, 36, 42, 48],
    },
    gpu: Table {
        up: &[58, 62, 66, 69, 70, 72, 74, 81, 87],
        down: &[49, 56, 58, 61, 63, 65, 67, 69, 76],
        speed: &[18, 21, 24, 26, 29, 33, 36, 42, 48],
    },
    surface: Table {
        up: &[32, 36, 37, 38, 42, 45],
        down: &[],
        speed: &[18, 21, 24, 26, 29, 33],
    },
    rise: 0.07,
    fall: 0.5,
};

/// The set the Hub uses for a profile.
pub fn for_profile(profile: Option<&str>) -> &'static TableSet {
    match profile {
        Some("performance") => &PERFORMANCE,
        Some(crate::limits::UNLEASHED) => &UNLEASHED,
        _ => &DEFAULT,
    }
}

/// How often a source may move a step. The Hub's cycle.
pub const STEP_EVERY: Duration = Duration::from_secs(5);

/// A table with down edges, and the step it is on.
#[derive(Debug, Clone, Copy, Default)]
struct Stepper {
    step: Option<usize>,
}

impl Stepper {
    /// Where to start: the step above the band the temperature is in.
    fn place(table: &Table, t: f32) -> usize {
        let last = table.speed.len() - 1;
        if t < table.up[0] as f32 {
            return 0;
        }
        if t >= table.up[last] as f32 {
            return last;
        }
        (0..last)
            .find(|&i| t >= table.up[i] as f32 && t < table.up[i + 1] as f32)
            .map_or(0, |i| i + 1)
    }

    /// One step at most, up or down.
    fn advance(&mut self, table: &Table, t: f32) -> u8 {
        let last = table.speed.len() - 1;
        let step = match self.step {
            None => Self::place(table, t),
            Some(n) if n != 0 && t <= table.down[n] as f32 => n - 1,
            Some(n) if n != last && t >= table.up[n] as f32 => n + 1,
            Some(n) => n,
        };
        self.step = Some(step);
        table.speed[step]
    }
}

/// A table without down edges: the band the temperature is in.
fn lookup(table: &Table, t: f32) -> u8 {
    let last = table.speed.len() - 1;
    if t <= table.up[0] as f32 {
        return table.speed[0];
    }
    if t >= table.up[last] as f32 {
        return table.speed[last];
    }
    (0..last)
        .find(|&i| t >= table.up[i] as f32 && t < table.up[i + 1] as f32)
        .map_or(table.speed[0], |i| table.speed[i])
}

/// The readings one decision is made from. `None` for a source this machine
/// does not report, which then asks for nothing.
#[derive(Debug, Clone, Copy, Default)]
pub struct Readings {
    pub cpu: Option<f32>,
    pub gpu: Option<f32>,
    pub surface: Option<f32>,
}

/// What was decided, and which source asked for it - for the decision log.
#[derive(Debug, Clone, PartialEq)]
pub struct Decision {
    pub target: Target,
    pub why: String,
}

#[derive(Debug, Clone)]
pub struct HubFan {
    set: &'static TableSet,
    average: Option<(f32, Instant)>,
    cpu: Stepper,
    gpu: Stepper,
    last_step: Option<Instant>,
    /// What each source last asked for, held between steps.
    held: (u8, u8, u8),
}

impl HubFan {
    pub fn new(set: &'static TableSet) -> Self {
        Self {
            set,
            average: None,
            cpu: Stepper::default(),
            gpu: Stepper::default(),
            last_step: None,
            held: (0, 0, 0),
        }
    }

    pub fn set(&self) -> &'static TableSet {
        self.set
    }

    /// The CPU average as it stands, for showing.
    pub fn cpu_average(&self) -> Option<f32> {
        self.average.map(|(v, _)| v)
    }

    /// Updates the average and, once a cycle, moves each source a step.
    ///
    /// `floor_above_c`: at or above this, on the CPU's raw reading or the
    /// GPU's, the fans are never left stopped. The smoothing is the Hub's
    /// choice and a good one for noise, but this project's stall detector
    /// treats stopped fans on a hot machine as a failure - correctly - and
    /// the two must not be able to disagree.
    pub fn decide(&mut self, r: Readings, now: Instant, floor_above_c: f32) -> Decision {
        if let Some(t) = r.cpu {
            let next = match self.average {
                None => t,
                Some((v, at)) => {
                    let per_second = if t >= v { self.set.rise } else { self.set.fall };
                    // The Hub updates once a second; this is called at the
                    // daemon's interval, so the weight is compounded to match.
                    let secs = now.duration_since(at).as_secs_f32().clamp(0.0, 30.0);
                    let w = 1.0 - (1.0 - per_second).powf(secs);
                    v + w * (t - v)
                }
            };
            self.average = Some((next, now));
        }

        let due = self
            .last_step
            .is_none_or(|at| now.duration_since(at) >= STEP_EVERY);
        if due {
            self.last_step = Some(now);
            let set = self.set;
            let cpu = match self.average {
                Some((v, _)) => self.cpu.advance(&set.cpu, v),
                None => 0,
            };
            let gpu = r.gpu.map_or(0, |t| self.gpu.advance(&set.gpu, t));
            let surface = r.surface.map_or(0, |t| lookup(&set.surface, t));
            self.held = (cpu, gpu, surface);
        }

        let (cpu, gpu, surface) = self.held;
        let mut speed = cpu.max(gpu).max(surface);
        let mut why = if speed == 0 {
            "all sources below their first step".to_string()
        } else if speed == cpu {
            format!("cpu avg {:.1}C", self.cpu_average().unwrap_or_default())
        } else if speed == gpu {
            format!("gpu {:.0}C", r.gpu.unwrap_or_default())
        } else {
            format!("surface {:.0}C", r.surface.unwrap_or_default())
        };

        let raw_hot = r.cpu.into_iter().chain(r.gpu).any(|t| t >= floor_above_c);
        if speed == 0 && raw_hot {
            speed = self
                .set
                .cpu
                .speed
                .iter()
                .copied()
                .find(|s| *s > 0)
                .unwrap_or(18);
            why = format!("hot ({floor_above_c:.0}C) while the average is low - not stopping");
        }

        Decision {
            target: (speed > 0).then(|| speed as u32 * crate::curve::EC_STEP_RPM),
            why: format!("{} tables: {why}", self.set.name),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const FLOOR: f32 = 75.0;

    fn readings(cpu: f32, gpu: f32, surface: f32) -> Readings {
        Readings {
            cpu: Some(cpu),
            gpu: Some(gpu),
            surface: Some(surface),
        }
    }

    fn every_table() -> Vec<(&'static str, Table)> {
        [&DEFAULT, &PERFORMANCE, &UNLEASHED]
            .iter()
            .flat_map(|s| [(s.name, s.cpu), (s.name, s.gpu), (s.name, s.surface)])
            .collect()
    }

    #[test]
    fn the_tables_are_well_formed() {
        for (name, t) in every_table() {
            assert_eq!(t.up.len(), t.speed.len(), "{name}");
            assert!(t.down.is_empty() || t.down.len() == t.up.len(), "{name}");
            assert!(t.up.windows(2).all(|w| w[0] < w[1]), "{name} up");
            assert!(t.speed.windows(2).all(|w| w[0] <= w[1]), "{name} speed");
            // A step is left downwards below the temperature it was entered
            // at, or there is no hysteresis.
            for (i, d) in t.down.iter().enumerate().skip(1) {
                assert!(*d < t.up[i - 1], "{name} step {i}");
            }
            // 48 is the EC's ceiling (Phase 1 §3.2).
            assert!(t.speed.iter().all(|s| *s <= 48), "{name}");
        }
    }

    #[test]
    fn balanced_at_idle_is_silent() {
        let mut f = HubFan::new(&DEFAULT);
        let d = f.decide(readings(55.0, 45.0, 33.0), Instant::now(), FLOOR);
        assert_eq!(d.target, None, "{}", d.why);
    }

    #[test]
    fn performance_never_stops_the_fans() {
        let mut f = HubFan::new(&PERFORMANCE);
        let d = f.decide(readings(40.0, 40.0, 30.0), Instant::now(), FLOOR);
        assert_eq!(d.target, Some(1800));
    }

    #[test]
    fn the_hottest_source_wins() {
        let mut f = HubFan::new(&DEFAULT);
        // CPU cool, GPU at 70 C: placed on the step above its band, 3300.
        let d = f.decide(readings(50.0, 70.0, 30.0), Instant::now(), FLOOR);
        assert_eq!(d.target, Some(3300));
        assert!(d.why.contains("gpu"), "{}", d.why);
    }

    #[test]
    fn a_cpu_spike_does_not_move_the_fans_but_a_sustained_load_does() {
        // The stall floor is the other half of the story and has its own
        // test; this is the averaging alone.
        const FLOOR: f32 = 200.0;
        let t0 = Instant::now();
        let mut f = HubFan::new(&DEFAULT);
        f.decide(readings(50.0, 40.0, 30.0), t0, FLOOR);
        // Six seconds at 90 C: the average barely moves.
        let d = f.decide(
            readings(90.0, 40.0, 30.0),
            t0 + Duration::from_secs(6),
            FLOOR,
        );
        assert_eq!(d.target, None, "{}", d.why);
        // A minute of it: it does.
        let mut last = d;
        for s in (12..=72).step_by(6) {
            last = f.decide(
                readings(90.0, 40.0, 30.0),
                t0 + Duration::from_secs(s),
                FLOOR,
            );
        }
        assert!(last.target.is_some(), "{}", last.why);
    }

    #[test]
    fn one_step_per_cycle() {
        let t0 = Instant::now();
        let mut f = HubFan::new(&DEFAULT);
        f.decide(readings(50.0, 55.0, 30.0), t0, FLOOR); // GPU step 1
                                                         // GPU jumps to 80: placement is over, so it climbs one step a cycle.
        let a = f.decide(readings(50.0, 80.0, 30.0), t0 + STEP_EVERY, FLOOR);
        let b = f.decide(readings(50.0, 80.0, 30.0), t0 + STEP_EVERY * 2, FLOOR);
        assert_eq!(a.target, Some(2100));
        assert_eq!(b.target, Some(2400));
        // Between cycles nothing moves.
        let c = f.decide(
            readings(50.0, 80.0, 30.0),
            t0 + STEP_EVERY * 2 + Duration::from_secs(1),
            FLOOR,
        );
        assert_eq!(c.target, b.target);
    }

    #[test]
    fn coming_down_needs_the_lower_edge() {
        let t0 = Instant::now();
        let mut f = HubFan::new(&DEFAULT);
        // GPU placed at step 1 (54-56 C band).
        assert_eq!(
            f.decide(readings(50.0, 55.0, 30.0), t0, FLOOR).target,
            Some(1800)
        );
        // 50 C is under the up edge (54) but above the down edge (49): hold.
        let d = f.decide(readings(50.0, 50.0, 30.0), t0 + STEP_EVERY, FLOOR);
        assert_eq!(d.target, Some(1800));
        // 49 reaches it.
        let d = f.decide(readings(50.0, 49.0, 30.0), t0 + STEP_EVERY * 2, FLOOR);
        assert_eq!(d.target, None);
    }

    #[test]
    fn the_palm_rest_has_a_say() {
        let mut f = HubFan::new(&DEFAULT);
        let d = f.decide(readings(50.0, 40.0, 39.0), Instant::now(), FLOOR);
        assert_eq!(d.target, Some(2600));
        assert!(d.why.contains("surface"), "{}", d.why);
    }

    #[test]
    fn a_hot_machine_never_reads_as_idle() {
        let t0 = Instant::now();
        let mut f = HubFan::new(&DEFAULT);
        f.decide(readings(45.0, 40.0, 30.0), t0, FLOOR);
        // Tctl leaps past the stall threshold; the average has not caught up.
        let d = f.decide(
            readings(80.0, 40.0, 30.0),
            t0 + Duration::from_secs(2),
            FLOOR,
        );
        assert_eq!(d.target, Some(1800), "{}", d.why);
    }

    #[test]
    fn a_missing_source_asks_for_nothing() {
        let mut f = HubFan::new(&DEFAULT);
        let d = f.decide(
            Readings {
                cpu: Some(50.0),
                gpu: None,
                surface: None,
            },
            Instant::now(),
            FLOOR,
        );
        assert_eq!(d.target, None);
    }

    #[test]
    fn profiles_choose_their_set() {
        assert_eq!(for_profile(Some("balanced")).name, "default");
        assert_eq!(for_profile(Some("low-power")).name, "default");
        assert_eq!(for_profile(None).name, "default");
        assert_eq!(for_profile(Some("performance")).name, "performance");
        assert_eq!(for_profile(Some("unleashed")).name, "unleashed");
    }
}
