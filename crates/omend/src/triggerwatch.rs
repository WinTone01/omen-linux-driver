//! Applies settings while the machine is in a described state.
//!
//! The state machine is [`crate::takeover`]; what is here is the sampling -
//! the lid, the charge, how long the machine has been doing nothing - and the
//! rule that an application profile outranks all of it.
//!
//! Why applications win: a trigger describes the machine, a profile names a
//! program. "Cyberpunk is open" is a more specific statement than "it is warm
//! in here", and somebody who configured both meant the specific one. The
//! daemon enforces that by not polling this at all while an application
//! profile is in force - and by releasing whatever a trigger had applied
//! first, so the profile captures the real "before".

use std::time::Instant;

use omen_core::ipc::ControlMode;
use omen_core::triggers::{self, Idle, Reading, Trigger};

use crate::takeover::{Actions, Takeover, Voice, Want};

#[derive(Debug)]
pub struct TriggerWatch {
    inner: Takeover,
    /// Which entry is engaged, so only that one gets the release margin.
    engaged: Option<usize>,
    idle: Idle,
    sampled: Instant,
    /// The lid as it was last seen, to notice it opening.
    lid: Option<bool>,
}

impl Default for TriggerWatch {
    fn default() -> Self {
        Self::new()
    }
}

impl TriggerWatch {
    pub fn new() -> Self {
        Self {
            inner: Takeover::new(Voice::Trigger),
            engaged: None,
            idle: Idle::new(),
            sampled: Instant::now(),
            lid: None,
        }
    }

    pub fn active(&self) -> Option<&str> {
        self.inner.active()
    }

    /// How long the machine has been idle, for the status output. Reported
    /// because "idle for 30 min" is a condition people will want to see the
    /// current value of before they trust a rule built on it.
    pub fn idle_secs(&self) -> u64 {
        self.idle.secs()
    }

    /// Everything a condition is evaluated against, sampled now.
    ///
    /// `temp_c` comes from the caller rather than being read again here: it
    /// must be the same number the curve was driven from this tick, or a
    /// trigger and the fan can disagree about how hot the machine is.
    pub fn sample(&mut self, temp_c: Option<f32>) -> Reading {
        let elapsed = self.sampled.elapsed();
        self.sampled = Instant::now();
        self.idle.sample(elapsed);

        let lid = triggers::lid_closed();
        // Opening the lid is somebody arriving, and /proc/stat may not show
        // it for another second or two. Start the idle count again.
        if self.lid == Some(true) && lid == Some(false) {
            self.idle.reset();
        }
        self.lid = lid;

        Reading {
            temp_c,
            battery_percent: omen_core::power::battery_percent(),
            idle_secs: self.idle.secs(),
            lid_closed: lid,
        }
    }

    /// One evaluation. Returns what the loop should do about the fan.
    pub fn poll(&mut self, list: &[Trigger], now: &Reading, mode: ControlMode) -> Actions {
        let index = triggers::active(list, now, self.engaged);
        self.engaged = index;

        let holding = index.map(|i| {
            let t = &list[i];
            (
                t.name(),
                Want {
                    profile: t.profile.clone(),
                    fan: t.fan,
                    curve: t.curve.clone(),
                },
            )
        });
        self.inner.poll(holding, mode)
    }

    /// Lets go of whatever is applied - used when an application profile
    /// takes over, which outranks every trigger.
    pub fn release(&mut self, mode: ControlMode) -> Actions {
        self.engaged = None;
        self.inner.poll(None, mode)
    }
}
