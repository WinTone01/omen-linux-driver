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

/// What the daemon can ask the lighting thread to do.
#[derive(Debug, Clone)]
pub enum Ask {
    /// A new configuration - effect, speed, colour, and the settings below.
    Configure(Box<LightingConfig>),
    /// Turn the backlight off, or put it back to the brightness it had.
    /// Used for "off on battery"; the brightness to restore is remembered
    /// here rather than in the config, because it is a runtime fact.
    Backlight(bool),
}

/// Handle to the lighting thread. Dropping it stops the thread and restores
/// the colours the keyboard had before the effect started.
pub struct Lighting {
    tx: Sender<Ask>,
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

        let (tx, rx) = mpsc::channel::<Ask>();
        std::thread::Builder::new()
            .name("omend-lighting".into())
            .spawn(move || {
                let mut cfg = initial;
                let mut painter = Painter::new(leds);
                painter.restore_saved(&cfg);
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
                        Ok(Ask::Configure(next)) => {
                            painter.reconfigure(&cfg, &next);
                            cfg = *next;
                        }
                        Ok(Ask::Backlight(on)) => painter.set_backlight(on),
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
        let _ = self.tx.send(Ask::Configure(Box::new(cfg)));
    }

    /// Turns the backlight off or back on, for the battery rule.
    pub fn backlight(&self, on: bool) {
        let _ = self.tx.send(Ask::Backlight(on));
    }

    /// Whether the keyboard is dark. `None` when there is no keyboard.
    pub fn is_dark(&self) -> Option<bool> {
        Leds::discover().ok()?.brightness().map(|b| b == 0)
    }

    /// The keyboard's brightness, for remembering it. `None` while it is dark
    /// or absent: zero is not a level to come back to.
    pub fn brightness(&self) -> Option<u8> {
        Leds::discover().ok()?.brightness().filter(|b| *b > 0)
    }

    /// The colours the keyboard is showing, for remembering them. `None`
    /// while an effect is running - what is on screen then is a frame, not a
    /// choice.
    pub fn zones(&self) -> Option<Vec<Rgb>> {
        let leds = Leds::discover().ok()?;
        Some(
            (0..ZONE_COUNT)
                .map(|i| leds.zone(i).unwrap_or(Rgb { r: 0, g: 0, b: 0 }))
                .collect(),
        )
    }
}

struct Painter {
    leds: Leds,
    started: Instant,
    /// The colours the zones had before an effect took over, so stopping one
    /// puts the keyboard back rather than leaving it on whatever frame it
    /// happened to stop on.
    saved: Option<Vec<Rgb>>,
    /// What we painted last, so unchanged zones are not rewritten. The driver
    /// folds a frame's zones into one WMI call, but a frame with nothing new
    /// in it is still a call; a breathing effect at its dimmest can hold the
    /// same 8-bit value for several frames.
    last: Option<[Rgb; ZONE_COUNT]>,
    /// Brightness before the backlight was switched off, so turning it back
    /// on returns to what it was rather than to an arbitrary full.
    saved_brightness: Option<u8>,
}

impl Painter {
    fn new(leds: Leds) -> Self {
        Self {
            leds,
            started: Instant::now(),
            saved: None,
            last: None,
            saved_brightness: None,
        }
    }

    /// Writes the remembered colours, once, at startup.
    ///
    /// Before any effect starts, so an effect's own first frame still wins -
    /// and so the "before" colours it saves are the ones the user chose
    /// rather than whatever the firmware happened to leave.
    fn restore_saved(&mut self, cfg: &LightingConfig) {
        if !cfg.restore_on_start || cfg.zones.is_empty() {
            return;
        }
        for (i, rgb) in cfg.zones.iter().enumerate().take(ZONE_COUNT) {
            let colour = Rgb {
                r: rgb[0],
                g: rgb[1],
                b: rgb[2],
            };
            if let Err(e) = self.leds.set_zone(i, colour) {
                debug!("could not restore zone {i}: {e}");
                return;
            }
        }
        // After the colours: the driver scales what it holds, so the level
        // applies to the colours just written. Only if the keyboard is lit -
        // setting a level switches it on, and a keyboard someone turned off
        // should stay off.
        // Off if it was switched off: the firmware may well light the
        // keyboard at boot whatever it was left as.
        if cfg.backlight_off {
            if let Err(e) = self.leds.set_brightness(0) {
                debug!("could not switch the backlight back off: {e}");
            }
            info!("keyboard colours restored, backlight left off as it was");
            return;
        }
        let lit = self.leds.brightness().is_some_and(|b| b > 0);
        if let Some(level) = cfg.brightness.filter(|b| *b > 0 && lit) {
            if let Err(e) = self.leds.set_brightness(level) {
                debug!("could not restore the brightness: {e}");
            }
        }
        info!("keyboard colours restored");
    }

    /// The backlight switch. Writing 0 turns it off; anything else turns it
    /// on at that level (the hardware switch is on/off, and the levels are
    /// produced by scaling the colours - see the driver).
    fn set_backlight(&mut self, on: bool) {
        if on {
            let level = self.saved_brightness.take().unwrap_or(100);
            if let Err(e) = self.leds.set_brightness(level) {
                debug!("could not turn the backlight on: {e}");
            }
            return;
        }
        if self.saved_brightness.is_none() {
            self.saved_brightness = self.leds.brightness().filter(|b| *b > 0);
        }
        if let Err(e) = self.leds.set_brightness(0) {
            debug!("could not turn the backlight off: {e}");
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
