//! Applying settings while something holds, and putting them back after.
//!
//! Two things need this and they need it identically: an application profile
//! ("while this program is running") and a trigger ("while the machine is in
//! this state"). The mechanics are the interesting part and they are all
//! corner cases, so there is one copy of them here rather than two that drift:
//!
//! * Settings are applied once, when the condition starts. Not every tick -
//!   that would make them un-overridable while it holds, which is not
//!   automation, it is a lock.
//! * What is restored is what was there before, captured at the moment of
//!   takeover. Restoring to a fixed "balanced" would quietly rewrite a choice
//!   the user made an hour ago.
//! * Nothing is restored if the state no longer matches what we applied. If
//!   the user changed things while it held, that is the more recent decision
//!   and it stands.
//!
//! The daemon owns every write to the fan, so this asks rather than writes -
//! the platform profile is the one thing it sets directly, because that is a
//! single sysfs write with no arbitration to do.

use log::{info, warn};

use omen_core::ipc::ControlMode;
use omen_core::profile::PlatformProfile;

/// The three things a rule can ask for. The same set for applications,
/// triggers and power rules, because they are answering the same question
/// about the same machine.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct Want {
    pub profile: Option<String>,
    pub fan: Option<ControlMode>,
    pub curve: Option<String>,
}

/// What the caller should do about the fan. See the module note: the loop is
/// still the only thing that drives it.
#[derive(Debug, Default)]
pub struct Actions {
    pub mode: Option<ControlMode>,
    /// A named curve to run, or - when a rule ends and we had set one -
    /// `Some(None)` meaning "put the configured curve back".
    pub curve: Option<Option<String>>,
}

/// How the logs read. The events are the same, the English is not: a program
/// starts and exits, a condition simply holds or stops holding.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Voice {
    App,
    Trigger,
}

impl Voice {
    fn engaged(self, name: &str) -> String {
        match self {
            Self::App => format!("{name} is running"),
            Self::Trigger => name.to_owned(),
        }
    }

    fn released(self, name: &str) -> String {
        match self {
            Self::App => format!("{name} exited"),
            Self::Trigger => format!("no longer {name}"),
        }
    }
}

/// What the machine looked like before a rule took over.
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
    curve: Option<String>,
}

#[derive(Debug)]
pub struct Takeover {
    voice: Voice,
    active: Option<(String, Previous, Applied)>,
}

impl Takeover {
    pub fn new(voice: Voice) -> Self {
        Self {
            voice,
            active: None,
        }
    }

    /// The rule in force, by name.
    pub fn active(&self) -> Option<&str> {
        self.active.as_ref().map(|(name, _, _)| name.as_str())
    }

    /// One evaluation. `holding` is the rule that should be in force now -
    /// its name and what it wants - or `None` when nothing should be.
    ///
    /// `mode` is the daemon's current fan mode, which is both what gets
    /// remembered as "before" and what tells us whether our own setting is
    /// still in place.
    pub fn poll(&mut self, holding: Option<(String, Want)>, mode: ControlMode) -> Actions {
        match (self.active.as_ref().map(|(n, _, _)| n.clone()), holding) {
            (None, None) => Actions::default(),

            (None, Some((name, want))) => self.take_over(name, want, mode),

            // The same rule as last time: leave everything alone, so the user
            // can still override it while it holds.
            (Some(current), Some((name, _))) if current == name => Actions::default(),

            // A different rule applies now. Restore first, so what the second
            // one captures as "before" is the real before.
            (Some(_), Some((name, want))) => {
                let restore = self.restore(mode);
                let mut actions = self.take_over(name, want, restore.mode.unwrap_or(mode));
                if actions.mode.is_none() {
                    actions.mode = restore.mode;
                }
                actions
            }

            (Some(_), None) => self.restore(mode),
        }
    }

    fn take_over(&mut self, name: String, want: Want, mode: ControlMode) -> Actions {
        let previous = Previous {
            mode,
            profile: PlatformProfile::discover().and_then(|p| p.get().ok()),
        };

        let mut applied = Applied {
            mode: want.fan,
            profile: None,
            curve: want.curve.clone(),
        };

        if let Some(target) = &want.profile {
            match PlatformProfile::discover() {
                Some(pp) if pp.choices().iter().any(|c| c == target) => match pp.set(target) {
                    Ok(()) => applied.profile = Some(target.clone()),
                    Err(e) => warn!("{name}: could not set profile {target}: {e}"),
                },
                Some(pp) => warn!(
                    "{name}: profile {target:?} is not one of {}",
                    pp.choices().join(" ")
                ),
                None => warn!("{name}: no platform_profile to set"),
            }
        }

        info!(
            "{} -> {} (was {}{})",
            self.voice.engaged(&name),
            summary(&want),
            previous.mode,
            previous
                .profile
                .as_ref()
                .map(|p| format!(", {p}"))
                .unwrap_or_default()
        );

        self.active = Some((name, previous, applied.clone()));
        Actions {
            mode: applied.mode,
            curve: applied.curve.map(Some),
        }
    }

    fn restore(&mut self, mode: ControlMode) -> Actions {
        let Some((name, previous, applied)) = self.active.take() else {
            return Actions::default();
        };

        // Did anyone disagree with us while it held? If the fan mode is no
        // longer what we set, or the platform profile is not, then the user
        // has made a newer decision and it stands.
        let fan_ours = applied.mode.is_none_or(|m| m == mode);
        let current_profile = PlatformProfile::discover().and_then(|p| p.get().ok());
        let profile_ours = applied
            .profile
            .as_ref()
            .is_none_or(|p| current_profile.as_ref() == Some(p));

        if !fan_ours || !profile_ours {
            info!(
                "{}; leaving the settings alone - they were changed since",
                self.voice.released(&name)
            );
            return Actions::default();
        }

        if applied.profile.is_some() {
            if let (Some(pp), Some(want)) = (PlatformProfile::discover(), &previous.profile) {
                if let Err(e) = pp.set(want) {
                    warn!("could not restore the {want} profile: {e}");
                }
            }
        }

        info!(
            "{} -> back to {}",
            self.voice.released(&name),
            previous.mode
        );
        Actions {
            mode: applied.mode.map(|_| previous.mode),
            // Only put the curve back if we were the ones who changed it.
            curve: applied.curve.map(|_| None),
        }
    }
}

/// What a rule does, in words. The wording is shared with the CLI's own
/// summaries deliberately: a log line and the list in `omenctl app` should
/// describe the same rule the same way.
fn summary(want: &Want) -> String {
    let mut parts = Vec::new();
    if let Some(p) = &want.profile {
        parts.push(p.clone());
    }
    if let Some(c) = &want.curve {
        parts.push(format!("{c} curve"));
    } else if let Some(f) = &want.fan {
        parts.push(format!("fan {f}"));
    }
    if parts.is_empty() {
        "nothing to apply".into()
    } else {
        parts.join(", ")
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn want(profile: &str) -> Want {
        Want {
            profile: Some(profile.into()),
            fan: Some(ControlMode::Max),
            curve: None,
        }
    }

    #[test]
    fn taking_over_asks_for_the_fan_mode_and_remembers_the_old_one() {
        let mut t = Takeover::new(Voice::App);
        let actions = t.poll(Some(("cs2".into(), want("performance"))), ControlMode::Curve);
        assert_eq!(actions.mode, Some(ControlMode::Max));
        assert_eq!(t.active(), Some("cs2"));

        // Still holding: nothing is re-applied, so a manual change sticks.
        let actions = t.poll(Some(("cs2".into(), want("performance"))), ControlMode::Max);
        assert_eq!(actions.mode, None);

        // Released while our setting is still in place -> put the old one back.
        let actions = t.poll(None, ControlMode::Max);
        assert_eq!(actions.mode, Some(ControlMode::Curve));
        assert_eq!(t.active(), None);
    }

    #[test]
    fn a_mode_changed_by_hand_is_not_undone() {
        let mut t = Takeover::new(Voice::Trigger);
        t.poll(Some(("above 85 C".into(), want("performance"))), ControlMode::Curve);
        // The user asked for something else while it held.
        let actions = t.poll(None, ControlMode::Auto);
        assert_eq!(actions.mode, None, "their choice is newer than ours");
    }

    #[test]
    fn a_curve_is_only_put_back_if_we_set_one() {
        let mut t = Takeover::new(Voice::App);
        let no_curve = Want {
            profile: None,
            fan: None,
            curve: None,
        };
        t.poll(Some(("steam".into(), no_curve)), ControlMode::Curve);
        assert!(t.poll(None, ControlMode::Curve).curve.is_none());

        let with_curve = Want {
            profile: None,
            fan: None,
            curve: Some("quiet".into()),
        };
        let actions = t.poll(Some(("steam".into(), with_curve)), ControlMode::Curve);
        assert_eq!(actions.curve, Some(Some("quiet".into())));
        assert_eq!(t.poll(None, ControlMode::Curve).curve, Some(None));
    }

    #[test]
    fn one_rule_replacing_another_restores_before_it_takes_over() {
        let mut t = Takeover::new(Voice::Trigger);
        t.poll(Some(("the lid is shut".into(), want("low-power"))), ControlMode::Curve);
        let actions = t.poll(Some(("above 85 C".into(), want("performance"))), ControlMode::Max);
        assert_eq!(t.active(), Some("above 85 C"));
        assert_eq!(actions.mode, Some(ControlMode::Max));
    }
}
