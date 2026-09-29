//! Keyboard lighting effects.
//!
//! Only the maths lives here: an effect is a pure function from "how long has
//! this been running" to "what colour is each zone". No sysfs, no timing, no
//! threads - which means the effects can be tested by asking them what they
//! look like at t = 0.7 s, and the daemon decides how often to ask.
//!
//! There are four zones in a row across the keyboard, so anything with a
//! spatial component has exactly four samples to work with. A wave across
//! four zones is a coarse thing; the frame rate cannot fix that, and pushing
//! frames faster only costs WMI calls. Hence the modest defaults.

use serde::{Deserialize, Serialize};

use crate::leds::{Rgb, ZONE_COUNT};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Effect {
    /// No animation: the zones keep whatever colour they were set to.
    #[default]
    None,
    /// One colour, fading in and out together.
    Breathing,
    /// A hue travelling along the four zones.
    Wave,
    /// Every zone on the same hue, cycling through the spectrum.
    Spectrum,
    /// One colour beating: a quick rise and a slower fall, then a rest.
    Pulse,
    /// A light running left to right across the zones, trailing off.
    Chase,
    /// A still blend from one colour on the left to another on the right.
    Gradient,
}

impl Effect {
    pub fn parse(s: &str) -> Option<Self> {
        match s.trim().to_ascii_lowercase().as_str() {
            "none" | "off" | "static" => Some(Self::None),
            "breathing" | "breathe" => Some(Self::Breathing),
            "wave" => Some(Self::Wave),
            "spectrum" | "rainbow" | "cycle" => Some(Self::Spectrum),
            "pulse" => Some(Self::Pulse),
            "chase" => Some(Self::Chase),
            "gradient" => Some(Self::Gradient),
            _ => None,
        }
    }

    pub fn as_str(self) -> &'static str {
        match self {
            Self::None => "none",
            Self::Breathing => "breathing",
            Self::Wave => "wave",
            Self::Spectrum => "spectrum",
            Self::Pulse => "pulse",
            Self::Chase => "chase",
            Self::Gradient => "gradient",
        }
    }

    /// Every effect, in the order a list of them should show.
    pub const ALL: [Effect; 7] = [
        Self::None,
        Self::Breathing,
        Self::Wave,
        Self::Spectrum,
        Self::Pulse,
        Self::Chase,
        Self::Gradient,
    ];

    /// Whether this effect uses the configured base colour. The two hue
    /// effects supply their own.
    pub fn uses_base_color(self) -> bool {
        matches!(
            self,
            Self::Breathing | Self::Pulse | Self::Chase | Self::Gradient
        )
    }

    /// Whether it also uses the second colour - the right-hand end of the
    /// gradient.
    pub fn uses_second_color(self) -> bool {
        self == Self::Gradient
    }

    /// Whether it moves. A gradient does not, so it has no speed.
    pub fn is_animated(self) -> bool {
        !matches!(self, Self::None | Self::Gradient)
    }
}

impl std::fmt::Display for Effect {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(self.as_str())
    }
}

/// A configured effect: what to draw, how fast, and in what colour.
#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub struct EffectSpec {
    #[serde(default)]
    pub effect: Effect,
    /// 1 (slowest) to 10 (fastest).
    #[serde(default = "default_speed")]
    pub speed: u8,
    /// Base colour, for the effects that take one.
    #[serde(default = "default_color")]
    pub color: Rgb,
    /// The second colour: where a gradient ends, on the right.
    #[serde(default = "default_color2")]
    pub color2: Rgb,
}

fn default_speed() -> u8 {
    5
}

fn default_color() -> Rgb {
    // OMEN red, the colour the machine ships with.
    Rgb {
        r: 232,
        g: 17,
        b: 35,
    }
}

fn default_color2() -> Rgb {
    // A cool blue, far enough round the wheel from OMEN red that a gradient
    // between them reads as one.
    Rgb {
        r: 0,
        g: 110,
        b: 255,
    }
}

impl Default for EffectSpec {
    fn default() -> Self {
        Self {
            effect: Effect::None,
            speed: default_speed(),
            color: default_color(),
            color2: default_color2(),
        }
    }
}

/// Slowest and fastest full cycle, in seconds. A breath that takes twelve
/// seconds is a lamp warming up; one that takes under a second is a strobe,
/// and nobody wants their keyboard to do that.
const SLOWEST_CYCLE_S: f32 = 12.0;
const FASTEST_CYCLE_S: f32 = 1.5;

impl EffectSpec {
    pub fn clamped_speed(&self) -> u8 {
        self.speed.clamp(1, 10)
    }

    /// How long one full cycle of the effect takes.
    pub fn cycle_secs(&self) -> f32 {
        let t = (self.clamped_speed() - 1) as f32 / 9.0;
        SLOWEST_CYCLE_S + (FASTEST_CYCLE_S - SLOWEST_CYCLE_S) * t
    }

    /// The colours for every zone at `elapsed_secs` into the effect.
    ///
    /// `None` means this effect draws nothing and the zones should be left
    /// alone - which is not the same as drawing them black.
    pub fn frame(&self, elapsed_secs: f32) -> Option<[Rgb; ZONE_COUNT]> {
        let phase = (elapsed_secs / self.cycle_secs()).rem_euclid(1.0);

        match self.effect {
            Effect::None => None,

            Effect::Breathing => {
                // A raised cosine rather than a triangle: the eye reads a
                // linear ramp as spending too long at the extremes.
                let perceived = 0.5 - 0.5 * (phase * std::f32::consts::TAU).cos();
                // The cosine is how bright it should *look*. LED output is
                // linear and the eye is not: driven linearly, the dim half of
                // the breath went by in a few coarse jumps and the bright
                // half barely seemed to move. Gamma 2.2 spends the steps
                // where the eye can see them.
                let linear = perceived.powf(2.2);
                // Never all the way to black. At zero the keyboard looks off
                // rather than dim, and "did it crash" is not the effect.
                let level = 0.04 + 0.96 * linear;
                Some([scale(self.color, level); ZONE_COUNT])
            }

            Effect::Spectrum => {
                let c = from_hue(phase);
                Some([c; ZONE_COUNT])
            }

            Effect::Pulse => {
                // A heartbeat, not a breath: up in the first tenth of the
                // cycle, then an exponential fall, which is how a pulse of
                // light looks when it decays. Same gamma as breathing.
                let perceived = if phase < 0.1 {
                    phase / 0.1
                } else {
                    (-(phase - 0.1) * 7.0).exp()
                };
                let level = 0.04 + 0.96 * perceived.powf(2.2);
                Some([scale(self.color, level); ZONE_COUNT])
            }

            Effect::Chase => {
                // A head moving left to right, one cycle to cross the
                // keyboard and wrap. Each zone lights by its distance behind
                // the head, so the light has a tail rather than jumping from
                // zone to zone - with four zones, a hard step is all there
                // would otherwise be.
                let head = phase * ZONE_COUNT as f32;
                let mut out = [Rgb { r: 0, g: 0, b: 0 }; ZONE_COUNT];
                let n = ZONE_COUNT as f32;
                for (i, zone) in out.iter_mut().enumerate() {
                    // How far the head is past this zone's centre, wrapped
                    // into -n/2..n/2: negative while it is still coming.
                    let past = (head - (i as f32 + 0.5) + n / 2.0).rem_euclid(n) - n / 2.0;
                    let perceived = if past < 0.0 {
                        // Arriving: a quick rise over half a zone.
                        (1.0 + past / 0.5).max(0.0)
                    } else {
                        // Gone past: the tail, over a zone and a half.
                        (1.0 - past / 1.5).max(0.0)
                    };
                    let level = 0.04 + 0.96 * perceived.powf(2.2);
                    *zone = scale(self.color, level);
                }
                Some(out)
            }

            Effect::Gradient => {
                // Blended in linear light, not in the byte values: a straight
                // mix of red and blue bytes goes through a muddy dark purple.
                let mut out = [Rgb { r: 0, g: 0, b: 0 }; ZONE_COUNT];
                for (i, zone) in out.iter_mut().enumerate() {
                    let t = i as f32 / (ZONE_COUNT - 1) as f32;
                    *zone = mix(self.color, self.color2, t);
                }
                Some(out)
            }

            Effect::Wave => {
                let mut out = [Rgb { r: 0, g: 0, b: 0 }; ZONE_COUNT];
                for (i, zone) in out.iter_mut().enumerate() {
                    // Spread a whole turn of hue across the keyboard, so the
                    // four zones are never the same colour at once.
                    let offset = i as f32 / ZONE_COUNT as f32;
                    *zone = from_hue((phase + offset).rem_euclid(1.0));
                }
                Some(out)
            }
        }
    }
}

fn scale(c: Rgb, factor: f32) -> Rgb {
    let f = factor.clamp(0.0, 1.0);
    Rgb {
        r: (c.r as f32 * f).round() as u8,
        g: (c.g as f32 * f).round() as u8,
        b: (c.b as f32 * f).round() as u8,
    }
}

/// A blend of two colours, `t` from 0 (all `a`) to 1 (all `b`), mixed in
/// linear light and brought back to the byte scale.
fn mix(a: Rgb, b: Rgb, t: f32) -> Rgb {
    let lin = |v: u8| (v as f32 / 255.0).powf(2.2);
    let back = |v: f32| (v.clamp(0.0, 1.0).powf(1.0 / 2.2) * 255.0).round() as u8;
    let ch = |x: u8, y: u8| back(lin(x) + (lin(y) - lin(x)) * t);
    Rgb {
        r: ch(a.r, b.r),
        g: ch(a.g, b.g),
        b: ch(a.b, b.b),
    }
}

/// Hue (0..1) at full saturation and value. Written out rather than pulled
/// from a colour crate - it is six lines and one dependency.
fn from_hue(h: f32) -> Rgb {
    let h6 = h.rem_euclid(1.0) * 6.0;
    let sector = h6.floor() as i32;
    let f = h6 - h6.floor();
    let up = (f * 255.0).round() as u8;
    let down = 255 - up;

    let (r, g, b) = match sector {
        0 => (255, up, 0),
        1 => (down, 255, 0),
        2 => (0, 255, up),
        3 => (0, down, 255),
        4 => (up, 0, 255),
        _ => (255, 0, down),
    };
    Rgb { r, g, b }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn none_draws_nothing() {
        assert!(EffectSpec::default().frame(1.0).is_none());
    }

    #[test]
    fn breathing_is_dimmest_at_the_start_and_brightest_halfway() {
        let spec = EffectSpec {
            effect: Effect::Breathing,
            speed: 5,
            color: Rgb {
                r: 255,
                g: 255,
                b: 255,
            },
            ..EffectSpec::default()
        };
        let cycle = spec.cycle_secs();
        let start = spec.frame(0.0).unwrap()[0];
        let middle = spec.frame(cycle / 2.0).unwrap()[0];
        assert!(start.r < middle.r);
        // Dimmest is dim, not off.
        assert!(start.r > 0);
        assert_eq!(middle.r, 255);
    }

    #[test]
    fn breathing_changes_gently_at_the_dim_end() {
        // What gamma buys: near the bottom of the breath, one frame at 30 fps
        // moves the output by only a few steps, instead of the jumps a linear
        // ramp made where the eye is most sensitive.
        let spec = EffectSpec {
            effect: Effect::Breathing,
            speed: 5,
            color: Rgb {
                r: 255,
                g: 255,
                b: 255,
            },
            ..EffectSpec::default()
        };
        let frame = 1.0 / 30.0;
        let mut t = 0.0;
        while t < spec.cycle_secs() / 4.0 {
            let a = spec.frame(t).unwrap()[0].r as i32;
            let b = spec.frame(t + frame).unwrap()[0].r as i32;
            if a < 40 {
                assert!((b - a).abs() <= 2, "{a} -> {b} at {t:.2}s");
            }
            t += frame;
        }
    }

    #[test]
    fn a_cycle_returns_to_where_it_started() {
        let spec = EffectSpec {
            effect: Effect::Spectrum,
            speed: 3,
            ..Default::default()
        };
        assert_eq!(spec.frame(0.0), spec.frame(spec.cycle_secs()));
    }

    #[test]
    fn the_wave_puts_a_different_hue_on_each_zone() {
        let spec = EffectSpec {
            effect: Effect::Wave,
            ..Default::default()
        };
        let frame = spec.frame(0.0).unwrap();
        for i in 1..ZONE_COUNT {
            assert_ne!(frame[0], frame[i], "zones 0 and {i} are the same colour");
        }
    }

    #[test]
    fn speed_maps_to_a_sensible_range() {
        let slow = EffectSpec {
            speed: 1,
            ..Default::default()
        };
        let fast = EffectSpec {
            speed: 10,
            ..Default::default()
        };
        assert!(slow.cycle_secs() > fast.cycle_secs());
        assert!(fast.cycle_secs() >= FASTEST_CYCLE_S);
        // Out of range must not produce a zero-length cycle and a divide by
        // zero in frame().
        let silly = EffectSpec {
            speed: 200,
            ..Default::default()
        };
        assert!(silly.cycle_secs() >= FASTEST_CYCLE_S);
    }

    fn spec(effect: Effect) -> EffectSpec {
        EffectSpec {
            effect,
            speed: 5,
            color: Rgb { r: 255, g: 0, b: 0 },
            color2: Rgb { r: 0, g: 0, b: 255 },
        }
    }

    #[test]
    fn a_pulse_rises_fast_and_falls_slowly() {
        let s = spec(Effect::Pulse);
        let c = s.cycle_secs();
        let at = |p: f32| s.frame(p * c).unwrap()[0].r;
        // Peak at a tenth of the way in, brighter than the start.
        assert!(at(0.1) > at(0.0));
        assert_eq!(at(0.1), 255);
        // Still well lit shortly after the peak, nearly dark by the end.
        assert!(at(0.2) > at(0.9));
        assert!(at(0.95) < 40);
    }

    #[test]
    fn the_chase_moves_left_to_right() {
        let s = spec(Effect::Chase);
        let c = s.cycle_secs();
        let brightest = |p: f32| {
            let f = s.frame(p * c).unwrap();
            (0..ZONE_COUNT).max_by_key(|&i| f[i].r).unwrap()
        };
        // Over one cycle the head crosses the zones in order.
        let seen: Vec<usize> = [0.125, 0.375, 0.625, 0.875]
            .iter()
            .map(|&p| brightest(p))
            .collect();
        assert_eq!(seen, vec![0, 1, 2, 3]);
        // And it has a tail: the zone behind the head is not dark.
        let f = s.frame(0.375 * c).unwrap();
        assert!(f[0].r > 0 && f[0].r < f[1].r);
    }

    #[test]
    fn a_gradient_runs_from_one_colour_to_the_other_and_holds_still() {
        let s = spec(Effect::Gradient);
        let f = s.frame(0.0).unwrap();
        assert_eq!(f[0], Rgb { r: 255, g: 0, b: 0 });
        assert_eq!(f[ZONE_COUNT - 1], Rgb { r: 0, g: 0, b: 255 });
        // Mixed in linear light, the middle stays bright rather than going
        // through a dark, muddy purple.
        assert!(f[1].r > 128 && f[2].b > 128);
        assert_eq!(s.frame(3.7).unwrap(), f);
        assert!(!Effect::Gradient.is_animated());
    }

    #[test]
    fn every_effect_round_trips_through_its_name() {
        for e in Effect::ALL {
            assert_eq!(Effect::parse(e.as_str()), Some(e));
        }
    }
}
