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
    /// The shared limit the firmware held before anything here wrote it, put
    /// back when the profile no longer asks for a raised one.
    tpp_base: Option<u8>,
    /// The shared limit as last written or read, so the status does not cost
    /// an SMI every tick.
    tpp_now: Option<u8>,
    /// Whether the shared limit is ours rather than the firmware's.
    tpp_raised: bool,
    run: Option<Run>,
    /// When Unleashed was entered, and whether it has been put back once
    /// already - see on_profile.
    unleashed_at: Option<Instant>,
    unleashed_reasserted: bool,
    /// Who owns EPP when it is not us, as last checked.
    epp_owner: Option<&'static str>,
}

/// How soon after Unleashed is entered a drop back to performance is taken
/// for power-profiles-daemon echoing the profile write, rather than a person.
const ECHO_WINDOW: Duration = Duration::from_secs(15);

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
        // power-profiles-daemon watches platform_profile. Selecting Unleashed
        // writes "performance" there first, and when that is a change, PPD
        // can write "performance" back a moment later - which makes hp-wmi
        // rewrite HPCM and ends Unleashed (seen 2026-10-09: the first
        // `omenctl profile unleashed` from another profile did not stick, the
        // second did). A drop to performance this soon after entering is
        // taken for that echo, and Unleashed is put back once.
        if from == Some(UNLEASHED)
            && to == "performance"
            && !self.unleashed_reasserted
            && self
                .unleashed_at
                .is_some_and(|at| at.elapsed() < ECHO_WINDOW)
        {
            self.unleashed_reasserted = true;
            match limits::set_unleashed(true) {
                Ok(()) => {
                    info!(
                        "the profile went back to performance within {}s of Unleashed - \
                         taken for power-profiles-daemon echoing the change; Unleashed put back",
                        ECHO_WINDOW.as_secs()
                    );
                    // Still Unleashed: nothing else changes.
                    self.applied_for = Some((UNLEASHED.to_owned(), ctx.on_ac));
                    return;
                }
                Err(e) => out
                    .problems
                    .push(format!("could not put Unleashed back: {e}")),
            }
        }

        if to != UNLEASHED {
            self.end_run(out);
            self.unleashed_at = None;
            // The firmware does not reset PL1 with the profile, so after
            // Unleashed - or anything else that wrote it - every firmware
            // profile gets its own value back.
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
        if from == Some(UNLEASHED) && self.tpp_base.is_none() {
            // Started inside Unleashed: the base can be read now.
            self.tpp_base = limits::tpp();
        }

        if to == UNLEASHED && (from != Some(UNLEASHED) || self.run.is_none()) {
            if from != Some(UNLEASHED) {
                self.unleashed_at = Some(Instant::now());
                self.unleashed_reasserted = false;
            }
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

    /// The shared CPU+GPU limit. In performance and Unleashed, on mains, it is
    /// HP's base plus the configured offset - what the Hub's SetConcurrentTdp
    /// writes. Anywhere else the firmware's own value goes back, if it was
    /// ever changed here.
    fn apply_tpp(&mut self, ctx: &Ctx<'_>, profile: &str, out: &mut Outcome) {
        if limits::tpp().is_none() && self.tpp_now.is_none() {
            return; // no shared limit on this machine
        }
        let raised = match (profile, ctx.on_ac) {
            (UNLEASHED, Some(true)) => Some(ctx.cfg.unleashed_tpp_offset_w),
            ("performance", Some(true)) => Some(ctx.cfg.performance_tpp_offset_w),
            _ => None,
        }
        .map(|offset| {
            platform::TPP_MIN_W
                .saturating_add(offset.min(platform::TPP_MAX_OFFSET_W))
                .min(platform::TPP_MAX_W)
        });

        let want = match (raised, self.tpp_raised, self.tpp_base) {
            (Some(w), _, _) => w,
            (None, true, Some(base)) => base,
            _ => return, // never touched: the firmware's value stands
        };
        if self.tpp_now == Some(want) && self.tpp_raised == raised.is_some() {
            return;
        }
        match limits::set_tpp(want) {
            Ok(()) => {
                info!("{profile}: shared CPU+GPU limit {want} W");
                self.tpp_now = Some(want);
                self.tpp_raised = raised.is_some();
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
