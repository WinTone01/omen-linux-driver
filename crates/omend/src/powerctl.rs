//! What follows the profile beyond the fans: Unleashed's limits, the shared
//! CPU+GPU limit, the battery floor, the CPU's EPP hint, and the two loops
//! OMEN Gaming Hub runs on mains.
//!
//! Everything but the loops is edge-driven, like the GPU boost next to it in
//! the main loop: settings are written when the profile (or the power source)
//! changes, not every tick. Two reasons. Most of these are firmware calls,
//! and reading the shared limit back costs an SMI. And a setting that was
//! re-asserted every two seconds could not be overridden by hand, which is a
//! lock rather than automation.
//!
//! The loops (`AdaptivePowerControlV1` in the Hub, docs/research/
//! hub-rea-review.md) run while a profile holds on mains, in every profile
//! the Hub runs them in:
//!
//! * the palm-rest limit, on the Hub's thirty-second cycle - PL1 down while
//!   the surface is too hot, and the GPU held back;
//! * the battery drain - PL1 down a watt a second while the battery
//!   discharges with the charger in, below a threshold.
//!
//! The PL1 written is the lower of the two.

use std::time::{Duration, Instant};

use log::{debug, info, warn};

use omen_core::gpu::boost;
use omen_core::limits::{
    self, platform, DrainGuard, PowerConfig, SurfaceGpu, SurfaceGuard, SurfaceLimits, UNLEASHED,
};
use omen_core::profile::PlatformProfile;

/// What the loop knows this tick.
pub struct Ctx<'a> {
    pub cfg: &'a PowerConfig,
    pub profile: Option<&'a str>,
    pub on_ac: Option<bool>,
    pub battery: Option<u8>,
    /// The battery is discharging. On mains: the adapter is not keeping up.
    pub discharging: Option<bool>,
    pub surface: Option<f32>,
    pub read_only: bool,
    /// A rule in force (an application, GameMode, a trigger) selected
    /// Unleashed, and nobody has asked for another profile through us since.
    pub hold_unleashed: bool,
}

/// What the caller has to do about it.
#[derive(Debug, Default)]
pub struct Outcome {
    /// Hardware commands that failed, for the problem list.
    pub problems: Vec<String>,
    /// The profile was changed here (the battery floor), so whatever watches
    /// for the firmware changing it should take the new one as given.
    pub changed_profile: bool,
    /// cTGP and Dynamic Boost were put back to what they were before the
    /// palm-rest limit held the GPU back - which, when the profile has just
    /// changed, is the old profile's. The caller sets the profile's again.
    pub reapply_boost: bool,
}

/// The loops, while a profile holds on mains.
#[derive(Debug)]
struct Run {
    profile: String,
    surface: SurfaceGuard,
    drain: DrainGuard,
    drain_threshold: u8,
    next_surface: Instant,
    last_tick: Instant,
    /// The PL1 as last written, by the profile change or by the loops.
    pl1: u8,
    /// cTGP and Dynamic Boost before the palm-rest limit held the GPU back.
    gpu_before: Option<(bool, bool)>,
    /// The slowdown temperature was lowered and has to go back.
    slowed: bool,
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
    /// When Unleashed was last put back for a rule that holds it, so a
    /// program that keeps writing performance is not fought every tick.
    unleashed_held_at: Option<Instant>,
    /// Who owns EPP when it is not us, as last checked.
    epp_owner: Option<&'static str>,
}

/// How soon after Unleashed is entered a drop back to performance is taken
/// for power-profiles-daemon echoing the profile write, rather than a person.
const ECHO_WINDOW: Duration = Duration::from_secs(15);

/// How often Unleashed is put back for a rule that holds it, at most.
const HOLD_EVERY: Duration = Duration::from_secs(10);

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
        self.run.as_ref().is_some_and(|r| r.surface.is_hot())
    }

    pub fn battery_drain(&self) -> bool {
        self.run.as_ref().is_some_and(|r| r.drain.limiting())
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

        self.run_cycle(&ctx, &mut out);
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
        //
        // While a rule holds Unleashed - a game's profile - the same drop is
        // put back whenever it happens, not only once: PPD can echo more than
        // once, and later than the window, and the rule is still in force.
        // A profile asked for through us clears the hold (ctx.hold_unleashed),
        // so a person can still leave it. Once every HOLD_EVERY at most.
        let echo = !self.unleashed_reasserted
            && self
                .unleashed_at
                .is_some_and(|at| at.elapsed() < ECHO_WINDOW);
        let dropped = from == Some(UNLEASHED) && to == "performance";
        let held_recently = self
            .unleashed_held_at
            .is_some_and(|at| at.elapsed() < HOLD_EVERY);
        if dropped && ctx.hold_unleashed && !echo && held_recently {
            // Put back moments ago and dropped again: wait out the interval
            // without taking the drop as the new state, so it is looked at
            // again on the next tick rather than accepted for good.
            self.applied_for = Some((UNLEASHED.to_owned(), ctx.on_ac));
            return;
        }
        let held = ctx.hold_unleashed && !held_recently;
        if dropped && (echo || held) {
            if echo {
                self.unleashed_reasserted = true;
            } else {
                self.unleashed_held_at = Some(Instant::now());
            }
            match limits::set_unleashed(true) {
                Ok(()) => {
                    if echo {
                        info!(
                            "the profile went back to performance within {}s of Unleashed - \
                             taken for power-profiles-daemon echoing the change; Unleashed put back",
                            ECHO_WINDOW.as_secs()
                        );
                    } else {
                        info!(
                            "the profile dropped to performance while a rule holds Unleashed, \
                             without being asked for here; Unleashed put back"
                        );
                    }
                    // Still Unleashed: nothing else changes.
                    self.applied_for = Some((UNLEASHED.to_owned(), ctx.on_ac));
                    return;
                }
                Err(e) => out
                    .problems
                    .push(format!("could not put Unleashed back: {e}")),
            }
        }

        self.end_run(out);

        if to != UNLEASHED {
            self.unleashed_at = None;
            // The firmware does not reset PL1 with the profile, so after
            // Unleashed - or anything else that wrote it - every firmware
            // profile gets its own value back.
            //
            // On a change of power source it is written even when the EC
            // already holds it, as the Hub does (NeedResetPL1): the firmware
            // applies a limit when it is written, and the power change may
            // have left the old one in force.
            let power_changed = from == Some(to);
            if let Some(watts) = platform::profile_pl1(to) {
                if limits::pl1().is_some_and(|now| now != watts || power_changed) {
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

        if to == UNLEASHED {
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
        }

        // The loops: on mains only, as in the Hub, and only where PL1 is
        // ours to move.
        if ctx.on_ac == Some(true) && limits::pl1().is_some() {
            if let Some(l) = SurfaceLimits::for_profile(to, ctx.cfg) {
                let now = Instant::now();
                self.run = Some(Run {
                    profile: to.to_owned(),
                    surface: SurfaceGuard::new(l),
                    drain: DrainGuard::new(l.max_w),
                    drain_threshold: SurfaceLimits::drain_threshold(to, ctx.cfg),
                    next_surface: now + Duration::from_secs(platform::SURFACE_CYCLE_SECS),
                    last_tick: now,
                    pl1: l.max_w,
                    gpu_before: None,
                    slowed: false,
                });
            }
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
            let base = limits::tpp_default().unwrap_or(platform::TPP_MIN_W);
            limits::tpp_raised(base, offset)
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

    /// One tick of the loops: the battery every tick, the palm rest when its
    /// cycle is due, and PL1 written when the lower of the two moves.
    fn run_cycle(&mut self, ctx: &Ctx<'_>, out: &mut Outcome) {
        let Some(run) = self.run.as_mut() else { return };
        let now = Instant::now();
        let secs = now.duration_since(run.last_tick).as_secs_f32();
        run.last_tick = now;

        let mut surface_moved = None;
        if let Some(surface) = ctx.surface {
            if now >= run.next_surface {
                run.next_surface = now + Duration::from_secs(platform::SURFACE_CYCLE_SECS);
                let before = run.surface.pl1();
                let step = run.surface.cycle(surface.round().clamp(0.0, 255.0) as u8);
                if step.pl1 != before {
                    surface_moved = Some(surface);
                }
            }
        }

        let was_limiting = run.drain.limiting();
        if let (Some(percent), Some(discharging)) = (ctx.battery, ctx.discharging) {
            run.drain
                .step(discharging, percent, run.drain_threshold, secs);
        }
        match (was_limiting, run.drain.limiting()) {
            (false, true) => info!(
                "the battery is draining on mains at {}% - PL1 coming down until the \
                 adapter keeps up",
                ctx.battery.unwrap_or_default()
            ),
            (true, false) => info!(
                "the adapter keeps up again - PL1 back to {} W",
                run.drain.cap()
            ),
            _ => {}
        }

        let want = run.surface.pl1().min(run.drain.cap());
        if want != run.pl1 {
            let l = run.surface.limits();
            if let Some(surface) = surface_moved {
                info!(
                    "{}: surface {surface:.0} C (limit {} C): PL1 {} -> {want} W",
                    run.profile, l.overheat_c, run.pl1
                );
            } else {
                debug!("{}: PL1 {} -> {want} W", run.profile, run.pl1);
            }
            match limits::set_pl1(want) {
                Ok(()) => run.pl1 = want,
                Err(e) => out
                    .problems
                    .push(format!("could not set PL1 to {want} W: {e}")),
            }
        }

        let hot = run.surface.is_hot();
        let gpu = run.surface.limits().gpu;
        let profile = run.profile.clone();
        match (hot, run.gpu_before.is_some()) {
            (true, false) => Self::hold_gpu(run, gpu, &profile, out),
            (false, true) => {
                info!("{profile}: surface cool again - the GPU's allowance back");
                Self::release_gpu(run, out);
            }
            _ => {}
        }
    }

    /// The Hub's GPU side of an overheating palm rest: Dynamic Boost off in
    /// performance and Unleashed; in balanced cTGP and Dynamic Boost off and
    /// the slowdown temperature lowered.
    fn hold_gpu(run: &mut Run, gpu: SurfaceGpu, profile: &str, out: &mut Outcome) {
        let Some(state) = boost::read_state() else {
            return;
        };
        run.gpu_before = Some(state);
        let (ctgp, ppab) = match gpu {
            SurfaceGpu::BoostOff => (state.0, false),
            SurfaceGpu::Throttle => (false, false),
        };
        info!("{profile}: surface at its limit - holding the GPU back until it cools");
        if (ctgp, ppab) != state {
            if let Err(e) = boost::set(ctgp, ppab) {
                out.problems
                    .push(format!("could not hold the GPU's allowance back: {e}"));
            }
        }
        if gpu == SurfaceGpu::Throttle && boost::slowdown().is_some() {
            match boost::set_slowdown(platform::GPU_SLOWDOWN_HOT_C) {
                Ok(()) => run.slowed = true,
                Err(e) => out.problems.push(format!(
                    "could not lower the GPU's slowdown temperature: {e}"
                )),
            }
        }
    }

    /// Puts back what hold_gpu changed. Returns whether anything was.
    fn release_gpu(run: &mut Run, out: &mut Outcome) -> bool {
        let mut changed = false;
        if let Some(state) = run.gpu_before.take() {
            if boost::read_state() != Some(state) {
                changed = true;
                if let Err(e) = boost::set(state.0, state.1) {
                    warn!("could not put the GPU's allowance back: {e}");
                    out.problems
                        .push(format!("could not put the GPU's allowance back: {e}"));
                }
            }
        }
        if std::mem::take(&mut run.slowed) {
            if let Err(e) = boost::set_slowdown(platform::GPU_SLOWDOWN_C) {
                out.problems.push(format!(
                    "could not put the GPU's slowdown temperature back: {e}"
                ));
            }
        }
        changed
    }

    fn end_run(&mut self, out: &mut Outcome) {
        let Some(mut run) = self.run.take() else {
            return;
        };
        if Self::release_gpu(&mut run, out) {
            out.reapply_boost = true;
        }
    }
}
