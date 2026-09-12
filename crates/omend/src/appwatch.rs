//! Applies a profile while a particular program is running.
//!
//! The mechanics - apply once, remember what was there, do not undo a change
//! the user made since - live in [`crate::takeover`], because triggers need
//! exactly the same ones. What is left here is the only part that is about
//! applications: finding out whether one of them is running.

use omen_core::apps::{self, AppProfile};
use omen_core::ipc::ControlMode;

use crate::takeover::{Takeover, Voice, Want};

pub use crate::takeover::Actions;

#[derive(Debug)]
pub struct AppWatch {
    inner: Takeover,
}

impl Default for AppWatch {
    fn default() -> Self {
        Self::new()
    }
}

impl AppWatch {
    pub fn new() -> Self {
        Self {
            inner: Takeover::new(Voice::App),
        }
    }

    pub fn active(&self) -> Option<&str> {
        self.inner.active()
    }

    /// One scan. `mode` is the daemon's current fan mode.
    pub fn poll(&mut self, profiles: &[AppProfile], mode: ControlMode) -> Actions {
        let running = apps::running_processes();
        let matched = apps::active(profiles, &running).map(|p| {
            (
                p.process.clone(),
                Want {
                    profile: p.profile.clone(),
                    fan: p.fan,
                    curve: p.curve.clone(),
                },
            )
        });
        self.inner.poll(matched, mode)
    }
}
