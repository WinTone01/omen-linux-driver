//! The thread that draws keyboard effects.
//!
//! Lighting is deliberately not arbitrated the way the fan is (see
//! omen-core/leds.rs): anyone with write access to the LED class may set a
//! colour, and that stays true here. This thread does not own the keyboard,
//! it just draws frames while an effect is configured. A colour someone else
//! writes mid-effect shows up and is then painted over on the next frame -
//! which is the honest behaviour, because an animation and a fixed colour are
//! a contradiction, not a conflict to resolve.
//!
//! Runs on its own thread rather than in the control loop: the loop samples
//! every two seconds and must not be paced by anything else, least of all
//! lighting.

use std::sync::mpsc::{self, RecvTimeoutError, Sender};
use std::time::{Duration, Instant};

use log::{debug, info, warn};

use omen_core::anim::{Effect, EffectSpec};
use omen_core::config::LightingConfig;
use omen_core::leds::{Leds, Rgb, ZONE_COUNT};

/// Handle to the lighting thread. Dropping it stops the thread and restores
/// the colours the keyboard had before the effect started.
pub struct Lighting {
    tx: Sender<LightingConfig>,
}

impl Lighting {
    /// Starts the thread. `None` when there is no keyboard to drive - the
    /// module not being loaded is not an error for the fan daemon.
    pub fn start(initial: LightingConfig) -> Option<Self> {
        let leds = match Leds::discover() {
            Ok(leds) if leds.writable() => leds,
            Ok(_) => {
                warn!("the keyboard LEDs are not writable - lighting effects are off");
                return None;
            }
            Err(e) => {
                debug!("no keyboard LEDs ({e}) - lighting effects are off");
                return None;
            }
        };

        let (tx, rx) = mpsc::channel::<LightingConfig>();
        std::thread::Builder::new()
            .name("omend-lighting".into())
            .spawn(move || {
                let mut cfg = initial;
                let mut painter = Painter::new(leds);
                painter.begin(&cfg);

                loop {
                    let spec = cfg.spec();
                    let wait = if spec.effect == Effect::None {
                        // Nothing to draw: block until the configuration
                        // changes rather than wake ten times a second to do
                        // nothing.
                        Duration::from_secs(3600)
                    } else {
                        painter.draw(&spec);
                        cfg.frame_interval()
                    };

                    match rx.recv_timeout(wait) {
                        Ok(next) => {
                            painter.reconfigure(&cfg, &next);
                            cfg = next;
                        }
                        Err(RecvTimeoutError::Timeout) => {}
                        // The daemon is going away.
                        Err(RecvTimeoutError::Disconnected) => {
                            painter.restore();
                            return;
                        }
                    }
                }
            })
            .ok()?;

        Some(Self { tx })
    }

    /// Applies a new lighting configuration. A closed channel means the
    /// thread is gone, which is not worth failing a config reload over.
    pub fn update(&self, cfg: LightingConfig) {
        let _ = self.tx.send(cfg);
    }
}

struct Painter {
    leds: Leds,
    started: Instant,
    /// The colours the zones had before an effect took over, so stopping one
    /// puts the keyboard back rather than leaving it on whatever frame it
    /// happened to stop on.
    saved: Option<Vec<Rgb>>,
    /// What we painted last, so unchanged zones are not rewritten. Every zone
    /// write is a WMI call; a breathing effect at its dimmest can hold the
    /// same 8-bit value for several frames.
    last: Option<[Rgb; ZONE_COUNT]>,
}

impl Painter {
    fn new(leds: Leds) -> Self {
        Self {
            leds,
            started: Instant::now(),
            saved: None,
            last: None,
        }
    }

    fn begin(&mut self, cfg: &LightingConfig) {
        if cfg.effect == Effect::None {
            return;
        }
        self.save();
        self.started = Instant::now();
        info!(
            "lighting: {} at speed {} ({} fps)",
            cfg.effect,
            cfg.spec().clamped_speed(),
            cfg.fps
        );
    }

    fn reconfigure(&mut self, old: &LightingConfig, new: &LightingConfig) {
        if old.effect == Effect::None && new.effect != Effect::None {
            self.begin(new);
        } else if new.effect == Effect::None && old.effect != Effect::None {
            self.restore();
            info!("lighting: effects off");
        } else if old.effect != new.effect {
            // Switching between two effects: restart the clock so the new one
            // begins at its own start rather than partway through.
            self.started = Instant::now();
            self.last = None;
            info!("lighting: {}", new.effect);
        }
    }

    fn save(&mut self) {
        if self.saved.is_some() {
            return;
        }
        let zones: Vec<Rgb> = (0..ZONE_COUNT)
            .map(|i| self.leds.zone(i).unwrap_or(Rgb { r: 0, g: 0, b: 0 }))
            .collect();
        self.saved = Some(zones);
    }

    fn restore(&mut self) {
        let Some(saved) = self.saved.take() else {
            return;
        };
        for (i, c) in saved.into_iter().enumerate() {
            if let Err(e) = self.leds.set_zone(i, c) {
                debug!("could not restore zone {i}: {e}");
            }
        }
        self.last = None;
    }

    fn draw(&mut self, spec: &EffectSpec) {
        let Some(frame) = spec.frame(self.started.elapsed().as_secs_f32()) else {
            return;
        };
        for (i, colour) in frame.iter().enumerate() {
            if self.last.map(|l| l[i]) == Some(*colour) {
                continue;
            }
            if let Err(e) = self.leds.set_zone(i, *colour) {
                // A keyboard that has gone away (module unloaded) should not
                // spin this thread logging once per frame.
                debug!("lighting: zone {i} write failed: {e}");
                return;
            }
        }
        self.last = Some(frame);
    }
}
