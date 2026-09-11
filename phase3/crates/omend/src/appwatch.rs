//! Applies a profile while a particular program is running.
//!
//! The state machine is small but the corners are where the behaviour lives:
//!
//! * A profile is applied once, when the process appears. Not every tick -
//!   that would make the settings un-overridable while a game is open, which
//!   is not automation, it is a lock.
//! * What is restored on exit is what was there before, captured at the
//!   moment of takeover.
//! * Nothing is restored if the state no longer matches what we applied. If
//!   the user changed the profile with the game still running, that is a more
//!   recent decision than ours.

use log::{info, warn};

use omen_core::apps::{self, AppProfile};
use omen_core::ipc::ControlMode;
use omen_core::profile::PlatformProfile;

/// What the machine looked like before an application profile took over.
#[derive(Debug, Clone)]
struct Previous {
    mode: ControlMode,
    profile: Option<String>,
}

/// What we changed it to, so we can tell whether anyone has since disagreed.
#[derive(Debug, Clone)]
struct Applied {
    mode: Option<ControlMode>,
    profile: Option<String>,
}

#[derive(Debug, Default)]
pub struct AppWatch {
    active: Option<(String, Previous, Applied)>,
}

/// What the watcher wants done. The daemon owns the fan mode, so the watcher
/// asks rather than writes - the same rule every other client follows.
///
/// Which application is in force is not in here: the daemon reads that from
/// `active()` when it builds a snapshot, and one source for it beats two that
/// can disagree.
#[derive(Debug, Default)]
pub struct Actions {
    pub mode: Option<ControlMode>,
}

impl AppWatch {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn active(&self) -> Option<&str> {
        self.active.as_ref().map(|(name, _, _)| name.as_str())
    }

    /// One scan. `mode` is the daemon's current fan mode.
    pub fn poll(&mut self, profiles: &[AppProfile], mode: ControlMode) -> Actions {
        let running = apps::running_processes();
        let matched = apps::active(profiles, &running).cloned();

        match (&self.active, matched) {
            // Nothing before, nothing now.
            (None, None) => Actions::default(),

            // A program we know about has started.
            (None, Some(profile)) => self.take_over(profile, mode),

            // The program is still running - leave everything alone, so the
            // user can still override it while it is open.
            (Some((name, _, _)), Some(profile)) if profile.matches(name) => Actions::default(),

            // A different program's profile now applies. Restore first, so
            // what the second one captures as "before" is the real before.
            (Some(_), Some(profile)) => {
                let restore = self.restore(mode);
                let mut actions = self.take_over(profile, restore.mode.unwrap_or(mode));
                // The restore's mode is superseded by the new profile's, if
                // it has one; otherwise it still applies.
                if actions.mode.is_none() {
                    actions.mode = restore.mode;
                }
                actions
            }

            // It exited.
            (Some(_), None) => self.restore(mode),
        }
    }

    fn take_over(&mut self, profile: AppProfile, mode: ControlMode) -> Actions {
        let previous = Previous {
            mode,
            profile: PlatformProfile::discover().and_then(|p| p.get().ok()),
        };

        let mut applied = Applied {
            mode: None,
            profile: None,
        };

        if let Some(want) = &profile.profile {
            match PlatformProfile::discover() {
                Some(pp) if pp.choices().iter().any(|c| c == want) => match pp.set(want) {
                    Ok(()) => applied.profile = Some(want.clone()),
                    Err(e) => warn!("{}: could not set profile {want}: {e}", profile.process),
                },
                Some(pp) => warn!(
                    "{}: profile {want:?} is not one of {}",
                    profile.process,
                    pp.choices().join(" ")
                ),
                None => warn!("{}: no platform_profile to set", profile.process),
            }
        }
        applied.mode = profile.fan;

        info!(
            "{} is running -> {} (was {}{})",
            profile.process,
            profile.summary(),
            previous.mode,
            previous
                .profile
                .as_ref()
                .map(|p| format!(", {p}"))
                .unwrap_or_default()
        );

        let name = profile.process.clone();
        self.active = Some((name, previous, applied.clone()));
        Actions { mode: applied.mode }
    }

    fn restore(&mut self, mode: ControlMode) -> Actions {
        let Some((name, previous, applied)) = self.active.take() else {
            return Actions::default();
        };

        // Did anyone disagree with us while it was running? If the fan mode
        // is no longer what we set, or the platform profile is not, then the
        // user has made a newer decision and it stands.
        let fan_ours = applied.mode.is_none_or(|m| m == mode);
        let current_profile = PlatformProfile::discover().and_then(|p| p.get().ok());
        let profile_ours = applied
            .profile
            .as_ref()
            .is_none_or(|p| current_profile.as_ref() == Some(p));

        if !fan_ours || !profile_ours {
            info!("{name} exited; leaving the settings alone - they were changed since");
            return Actions::default();
        }

        if applied.profile.is_some() {
            if let (Some(pp), Some(want)) = (PlatformProfile::discover(), &previous.profile) {
                if let Err(e) = pp.set(want) {
                    warn!("could not restore the {want} profile: {e}");
                }
            }
        }

        info!("{name} exited -> back to {}", previous.mode);
        Actions {
            mode: applied.mode.map(|_| previous.mode),
        }
    }
}
