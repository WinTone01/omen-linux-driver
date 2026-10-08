//! What follows the profile beyond the fans: Unleashed's limits, the shared
//! CPU+GPU limit, the battery floor and the CPU's EPP hint.
//!
//! Everything here is edge-driven, like the GPU boost next to it in the main
//! loop: settings are written when the profile (or the power source) changes,
//! not every tick. Two reasons. Most of these are firmware calls, and reading
//! the shared limit back costs an SMI. And a setting that was re-asserted
//! every two seconds could not be overridden by hand, which is a lock rather
//! than automation.
//!
//! The one loop is Unleashed's surface limit, which runs on the Hub's own
//! thirty-second cycle while the mode holds.

use std::time::{Duration, Instant};

use log::{info, warn};

use omen_core::gpu::boost;
use omen_core::limits::{self, platform, PowerConfig, SurfaceGuard, UNLEASHED};
use omen_core::profile::PlatformProfile;

/// What the loop knows this tick.
pub struct Ctx<'a> {
    pub cfg: &'a PowerConfig,
    pub profile: Option<&'a str>,
    pub on_ac: Option<bool>,
    pub battery: Option<u8>,
    pub surface: Option<f32>,
    pub read_only: bool,
}

/// What the caller has to do about it.
#[derive(Debug, Default)]
pub struct Outcome {
    /// Hardware commands that failed, for the problem list.
    pub problems: Vec<String>,
    /// The profile was changed here (the battery floor), so whatever watches
    /// for the firmware changing it should take the new one as given.
    pub changed_profile: bool,
}

/// Unleashed while it holds.
#[derive(Debug)]
struct Run {
    guard: SurfaceGuard,
    next: Instant,
    /// What Dynamic Boost was before the surface limit switched it off.
    boost_before: Option<(bool, bool)>,
}

#[derive(Debug, Default)]
pub struct PowerControl {
    /// The profile and power source the settings were last written for.
    applied_for: Option<(String, Option<bool>)>,
    /// The shared limit the firmware picked itself - what offsets add to.
    tpp_base: Option<u8>,
    /// The shared limit as last written or read, so the status does not cost
    /// an SMI every tick.
    tpp_now: Option<u8>,
    run: Option<Run>,
    /// Who owns EPP when it is not us, as last checked.
    epp_owner: Option<&'static str>,
}

impl PowerControl {
    pub fn new() -> Self {
        // Read the base outside Unleashed only: inside it the firmware holds
        // the raised value, which is ours, not its.
        let tpp_base = if limits::unleashed() == Some(true) {
            None
        } else {
            limits::tpp()
        };
        Self {
            tpp_base,
            tpp_now: tpp_base,
            ..Self::default()
        }
    }

    /// Forget what was applied, so a reload writes the new values.
    pub fn invalidate(&mut self) {
        self.applied_for = None;
    }

    pub fn tpp_now(&self) -> Option<u8> {
        self.tpp_now
    }

    pub fn tpp_base(&self) -> Option<u8> {
        self.tpp_base
    }

    pub fn surface_hot(&self) -> bool {
        self.run.as_ref().is_some_and(|r| r.guard.is_hot())
    }

    pub fn epp_owner(&self) -> Option<&'static str> {
        self.epp_owner
    }

    pub fn tick(&mut self, ctx: Ctx<'_>) -> Outcome {
        let mut out = Outcome::default();
        if ctx.read_only {
            return out;
        }
        let Some(profile) = ctx.profile else {
            return out;
        };

        if self.battery_floor(&ctx, profile, &mut out) {
            // The profile is changing; the rest happens for the new one next
            // tick.
            return out;
        }

        let key = (profile.to_owned(), ctx.on_ac);
        if self.applied_for.as_ref() != Some(&key) {
            let previous = self.applied_for.take().map(|(p, _)| p);
            self.on_profile(&ctx, previous.as_deref(), profile, &mut out);
            self.applied_for = Some(key);
        }

        self.surface_cycle(&ctx, &mut out);
        out
    }

    /// Below the configured charge on battery, a mode gives way to the next
    /// one down - what the Hub's minimum battery values do.
    fn battery_floor(&mut self, ctx: &Ctx<'_>, profile: &str, out: &mut Outcome) -> bool {
        let (Some(false), Some(percent)) = (ctx.on_ac, ctx.battery) else {
            return false;
        };
        let Some(fallback) = limits::battery_fallback(ctx.cfg, profile, percent) else {
            return false;
        };
        info!(
            "battery at {percent}% is below {profile}'s floor of {}% - switching to {fallback}",
            ctx.cfg.battery_floor(profile)
        );
        match PlatformProfile::discover().map(|pp| pp.set(fallback)) {
            Some(Ok(())) => {
                out.changed_profile = true;
                true
            }
            Some(Err(e)) => {
                out.problems.push(format!(
                    "could not switch to {fallback} for the battery: {e}"
                ));
                false
            }
            None => false,
        }
    }

    fn on_profile(&mut self, ctx: &Ctx<'_>, from: Option<&str>, to: &str, out: &mut Outcome) {
        let left_unleashed = from == Some(UNLEASHED) && to != UNLEASHED;
        let entered_unleashed = to == UNLEASHED && from != Some(UNLEASHED);

        if left_unleashed || (from.is_none() && to != UNLEASHED) {
            self.end_run(out);
            // Unleashed raised PL1; the firmware's own profile values go back
            // with it, rather than trusting that a profile write resets them.
            if let Some(watts) = platform::profile_pl1(to) {
                if limits::pl1().is_some_and(|now| now != watts) {
                    match limits::set_pl1(watts) {
                        Ok(()) => info!("{to}: PL1 back to {watts} W"),
                        Err(e) => out
                            .problems
                            .push(format!("could not put PL1 back to {watts} W: {e}")),
                    }
                }
            }
        }
        if left_unleashed && self.tpp_base.is_none() {
            // Started inside Unleashed: the base can be read now.
            self.tpp_base = limits::tpp();
        }

        if to == UNLEASHED && (entered_unleashed || self.run.is_none()) {
            let watts = ctx.cfg.unleashed_pl1_w;
            match limits::set_pl1(watts) {
                Ok(()) => info!(
                    "Unleashed: PL1 {watts} W, surface held under {} C",
                    ctx.cfg.unleashed_surface_c
                ),
                Err(e) => out
                    .problems
                    .push(format!("could not set PL1 to {watts} W: {e}")),
            }
            self.run = Some(Run {
                guard: SurfaceGuard::new(ctx.cfg.unleashed_surface_c, watts),
                next: Instant::now() + Duration::from_secs(platform::SURFACE_CYCLE_SECS),
                boost_before: None,
            });
        }

        self.apply_tpp(ctx, to, out);
        self.apply_epp(ctx, to, out);
    }

    /// The shared CPU+GPU limit: the firmware's own plus the offset the
    /// configuration gives this profile, on mains only - as the Hub does.
    fn apply_tpp(&mut self, ctx: &Ctx<'_>, profile: &str, out: &mut Outcome) {
        let Some(base) = self.tpp_base else { return };
        let offset = match (profile, ctx.on_ac) {
            (UNLEASHED, Some(true)) => ctx.cfg.unleashed_tpp_offset_w,
            ("performance", Some(true)) => ctx.cfg.performance_tpp_offset_w,
            _ => 0,
        };
        let want = base.saturating_add(offset.min(platform::TPP_MAX_OFFSET_W));
        if self.tpp_now == Some(want) {
            return;
        }
        match limits::set_tpp(want) {
            Ok(()) => {
                info!("{profile}: shared CPU+GPU limit {want} W");
                self.tpp_now = Some(want);
            }
            Err(e) => out.problems.push(format!(
                "could not set the shared CPU+GPU limit to {want} W: {e}"
            )),
        }
    }

    fn apply_epp(&mut self, ctx: &Ctx<'_>, profile: &str, out: &mut Outcome) {
        self.epp_owner = omen_core::epp::owner();
        if !ctx.cfg.epp_follows_profile {
            return;
        }
        if let Some(owner) = self.epp_owner {
            log::debug!("{owner} keeps EPP in step; leaving it");
            return;
        }
        let Some(hint) = omen_core::epp::for_profile(profile) else {
            return;
        };
        if omen_core::epp::files().is_empty() || omen_core::epp::current().as_deref() == Some(hint)
        {
            return;
        }
        match omen_core::epp::set(hint) {
            Ok(()) => info!("{profile}: EPP {hint}"),
            Err(e) => out
                .problems
                .push(format!("could not set EPP to {hint}: {e}")),
        }
    }

    /// One cycle of Unleashed's surface limit, when one is due.
    fn surface_cycle(&mut self, ctx: &Ctx<'_>, out: &mut Outcome) {
        let Some(run) = self.run.as_mut() else { return };
        let Some(surface) = ctx.surface else { return };
        if Instant::now() < run.next {
            return;
        }
        run.next = Instant::now() + Duration::from_secs(platform::SURFACE_CYCLE_SECS);

        let before = run.guard.pl1();
        let step = run.guard.cycle(surface.round().clamp(0.0, 255.0) as u8);
        if step.pl1 != before {
            info!(
                "surface {surface:.0} C (limit {} C): PL1 {before} -> {} W",
                ctx.cfg.unleashed_surface_c, step.pl1
            );
            if let Err(e) = limits::set_pl1(step.pl1) {
                out.problems
                    .push(format!("could not set PL1 to {} W: {e}", step.pl1));
            }
        }

        match (step.hot, run.boost_before) {
            (true, None) => {
                if let Some(state) = boost::read_state() {
                    if state.1 {
                        info!("surface at its limit - Dynamic Boost off until it cools");
                        if let Err(e) = boost::set(state.0, false) {
                            out.problems
                                .push(format!("could not switch Dynamic Boost off: {e}"));
                        }
                    }
                    run.boost_before = Some(state);
                }
            }
            (false, Some(state)) => {
                run.boost_before = None;
                if state.1 {
                    info!("surface cool again - Dynamic Boost back on");
                    if let Err(e) = boost::set(state.0, state.1) {
                        out.problems
                            .push(format!("could not switch Dynamic Boost back on: {e}"));
                    }
                }
            }
            _ => {}
        }
    }

    fn end_run(&mut self, out: &mut Outcome) {
        let Some(run) = self.run.take() else { return };
        if let Some(state) = run.boost_before {
            if let Err(e) = boost::set(state.0, state.1) {
                warn!("could not put Dynamic Boost back: {e}");
                out.problems
                    .push(format!("could not put Dynamic Boost back: {e}"));
            }
        }
    }
}
