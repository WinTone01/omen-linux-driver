//! What is wrong with this machine, as a list of named checks.
//!
//! There is already a shell script that does this (kernel/hp-wmi-8d24/verify.sh)
//! and it is where most of the knowledge below came from. What it cannot do
//! is be read by anything other than a person: every consumer - the CLI, the
//! window, a bug report - would have to re-derive the same conclusions from
//! the same prose.
//!
//! So the checks live here and produce a structure. Three consequences worth
//! having:
//!
//! * The GUI page and the copyable report are rendered from the SAME checks,
//!   so they cannot disagree about what was found.
//! * A check that fails says what to do about it. A diagnostic that reports
//!   "pwm1: missing" and stops has done the easy half.
//! * Nothing here writes, loads a module or needs root. Anything that would
//!   is reported as something for the user to run.

use serde::{Deserialize, Serialize};

use crate::about;
use crate::fan::Fan;
use crate::gpu;
use crate::ipc::{client, Request, Response};
use crate::leds::Leds;
use crate::profile::PlatformProfile;
use crate::sysfs;
use crate::thermal::Thermal;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Verdict {
    /// Working, or not a problem.
    Ok,
    /// Works, but something about it will bite later.
    Warn,
    /// Broken: the thing this check is about does not work.
    Fail,
    /// Could not be checked from here - usually because it needs root, or
    /// the hardware is absent. Deliberately not a failure: a check that
    /// cries wolf when run as a normal user teaches people to ignore it.
    Skip,
}

impl Verdict {
    pub fn label(self) -> &'static str {
        match self {
            Self::Ok => "OK",
            Self::Warn => "WARN",
            Self::Fail => "FAIL",
            Self::Skip => "—",
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Check {
    /// Stable identifier, so the UI can style or link a specific check
    /// without matching on its wording.
    pub id: String,
    pub title: String,
    pub verdict: Verdict,
    /// What was actually found. Always filled in, including when the answer
    /// is good - "OK" alone is not evidence.
    pub detail: String,
    /// What to do about it. Only present when there is something to do.
    pub fix: Option<String>,
}

impl Check {
    fn new(id: &str, title: &str, verdict: Verdict, detail: impl Into<String>) -> Self {
        Self {
            id: id.into(),
            title: title.into(),
            verdict,
            detail: detail.into(),
            fix: None,
        }
    }

    fn with_fix(mut self, fix: impl Into<String>) -> Self {
        self.fix = Some(fix.into());
        self
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Section {
    pub title: String,
    pub checks: Vec<Check>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Report {
    pub sections: Vec<Section>,
}

impl Report {
    pub fn checks(&self) -> impl Iterator<Item = &Check> {
        self.sections.iter().flat_map(|s| s.checks.iter())
    }

    pub fn count(&self, verdict: Verdict) -> usize {
        self.checks().filter(|c| c.verdict == verdict).count()
    }

    /// One line: what a person wants to know before reading the rest.
    pub fn summary(&self) -> String {
        let fail = self.count(Verdict::Fail);
        let warn = self.count(Verdict::Warn);
        match (fail, warn) {
            (0, 0) => "everything checked is working".into(),
            (0, w) => format!("{w} thing{} worth knowing about", plural(w)),
            (f, 0) => format!("{f} thing{} broken", plural(f)),
            (f, w) => format!("{f} thing{} broken, {w} worth knowing about", plural(f)),
        }
    }

    /// The report as text, for pasting into a bug report.
    ///
    /// Generated from the same checks the page renders, so the two can never
    /// describe the machine differently.
    pub fn to_text(&self) -> String {
        use std::fmt::Write;
        let mut out = String::new();

        let _ = writeln!(
            out,
            "omen-control {} - {}\n",
            about::VERSION,
            self.summary()
        );
        for section in &self.sections {
            let _ = writeln!(out, "== {} ==", section.title);
            for c in &section.checks {
                let _ = writeln!(out, "  {:<4} {}: {}", c.verdict.label(), c.title, c.detail);
                if let Some(fix) = &c.fix {
                    let _ = writeln!(out, "       -> {fix}");
                }
            }
            out.push('\n');
        }
        out
    }
}

fn plural(n: usize) -> &'static str {
    if n == 1 {
        ""
    } else {
        "s"
    }
}

fn read(path: &str) -> Option<String> {
    sysfs::read_string(std::path::Path::new(path)).ok()
}

/// Runs everything. Read-only, and safe to run as a normal user.
///
/// The daemon's view is fetched once and handed to the checks that need it.
/// It is not a convenience: the daemon runs as root and can read things this
/// process cannot - the EC among them - so asking it is the difference
/// between "the GPU temperature is not being watched" and "I cannot see it
/// from here", which are different problems with different remedies.
pub fn run() -> Report {
    let snapshot = match client::send(&Request::Status) {
        Ok(Response::Ok(snap)) => Ok(*snap),
        Ok(_) => Err("the daemon answered, but not with a status".to_string()),
        Err(e) => Err(e.to_string()),
    };

    Report {
        sections: vec![
            hardware(),
            fan(),
            thermal(&snapshot),
            service(&snapshot),
            lighting(),
            graphics(),
            conflicts(),
        ],
    }
}

type DaemonView = Result<crate::ipc::Snapshot, String>;

fn hardware() -> Section {
    let mut checks = Vec::new();

    // First, because it frames everything below it: on a board that is not
    // the verified one, half these checks are expected to fail and the
    // difference between "broken" and "not applicable here" is the whole
    // point.
    let caps = crate::caps::Caps::detect();
    checks.push(match caps.level() {
        crate::caps::Level::Full => Check::new(
            "caps",
            "What this machine can do",
            Verdict::Ok,
            caps.level().describe(),
        ),
        level => {
            let check = Check::new(
                "caps",
                "What this machine can do",
                // Not a failure: a machine that cannot drive its fan is
                // working exactly as its firmware allows, and calling that
                // broken teaches people to ignore the report.
                Verdict::Warn,
                level.describe(),
            );
            match caps.remedy() {
                Some(remedy) => check.with_fix(remedy),
                None => check,
            }
        }
    });

    let board = read("/sys/class/dmi/id/board_name").unwrap_or_else(|| "unknown".into());
    checks.push(if board == "8D24" {
        Check::new(
            "board",
            "Board",
            Verdict::Ok,
            format!("{board}, the one this is built for"),
        )
    } else {
        Check::new(
            "board",
            "Board",
            Verdict::Warn,
            format!("{board}, but this build targets 8D24"),
        )
        .with_fix(
            "Everything here was measured on an OMEN 16-ap0xxx. On another board the \
             fan and lighting protocols may differ; treat what follows as unverified.",
        )
    });

    checks.push(Check::new(
        "product",
        "Model",
        Verdict::Ok,
        read("/sys/class/dmi/id/product_name").unwrap_or_else(|| "unknown".into()),
    ));

    checks.push(Check::new(
        "kernel",
        "Kernel",
        Verdict::Ok,
        read("/proc/sys/kernel/osrelease").unwrap_or_else(|| "unknown".into()),
    ));

    checks.push(Check::new(
        "bios",
        "Firmware version",
        Verdict::Ok,
        format!(
            "{} ({})",
            read("/sys/class/dmi/id/bios_version").unwrap_or_else(|| "unknown".into()),
            read("/sys/class/dmi/id/bios_date").unwrap_or_else(|| "date unknown".into())
        ),
    ));

    // Not a fault either way. It is here because "can this machine stop
    // charging at 80%?" is a question with a real answer that is hard to find
    // out, and the answer on this board - no, it is a BIOS setting - is
    // exactly the kind of thing people assume is a missing feature.
    checks.push(match crate::battery::Battery::discover() {
        None => Check::new(
            "charge_limit",
            "Battery charge limit",
            Verdict::Skip,
            "no battery",
        ),
        Some(b) if b.supports_limit() => Check::new(
            "charge_limit",
            "Battery charge limit",
            Verdict::Ok,
            match b.limit() {
                Some(100) | None => "available, not limiting".to_string(),
                Some(p) => format!("charging stops at {p}%"),
            },
        ),
        Some(b) => Check::new(
            "charge_limit",
            "Battery charge limit",
            Verdict::Skip,
            "the kernel exposes no threshold for this battery",
        )
        .with_fix(b.unsupported_reason()),
    });

    Section {
        title: "Hardware".into(),
        checks,
    }
}

fn fan() -> Section {
    let mut checks = Vec::new();

    let hp_wmi = about::module_status("hp_wmi");
    checks.push(if hp_wmi.loaded {
        Check::new("hp_wmi", "hp-wmi module", Verdict::Ok, "loaded")
    } else {
        Check::new("hp_wmi", "hp-wmi module", Verdict::Fail, "not loaded")
            .with_fix("sudo modprobe hp_wmi")
    });

    // The profile existing does not mean hp-wmi is driving it: on Strix Point
    // amd-pmf registers a handler too, and if it is the one in charge then
    // the firmware's own thermal profile is never written.
    let handlers = PlatformProfile::handlers();
    checks.push(if PlatformProfile::hp_wmi_active() {
        Check::new(
            "profile_handler",
            "Firmware thermal profile",
            Verdict::Ok,
            format!(
                "hp-wmi is a platform_profile handler ({})",
                handlers
                    .iter()
                    .map(|h| h.name.clone())
                    .collect::<Vec<_>>()
                    .join(", ")
            ),
        )
    } else if handlers.is_empty() {
        Check::new(
            "profile_handler",
            "Firmware thermal profile",
            Verdict::Warn,
            "no platform_profile handlers are listed (kernel older than 6.14?)",
        )
        .with_fix("Check that hp-wmi has the 8D24 board entry: omenctl status")
    } else {
        Check::new(
            "profile_handler",
            "Firmware thermal profile",
            Verdict::Fail,
            format!(
                "hp-wmi is NOT driving it - {} is",
                handlers
                    .iter()
                    .map(|h| h.name.clone())
                    .collect::<Vec<_>>()
                    .join(", ")
            ),
        )
        .with_fix(
            "The 8D24 board entry is missing from hp-wmi, so the firmware profile \
             (and with it the EC's fan behaviour) is never written. Rebuild the \
             patched module: kernel/hp-wmi-8d24/build-module.sh --install",
        )
    });

    match Fan::discover(crate::fan::DEFAULT_MIN_RPM, crate::fan::DEFAULT_MAX_RPM) {
        Ok(f) => {
            checks.push(Check::new(
                "pwm",
                "Fan control",
                Verdict::Ok,
                format!("pwm1 at {}", f.hwmon_path().display()),
            ));

            let rpms: Vec<String> = (1..=2u8)
                .filter_map(|i| f.rpm(i).ok().map(|r| format!("fan{i} {r} RPM")))
                .collect();
            checks.push(if rpms.is_empty() {
                Check::new(
                    "tacho",
                    "Fan tachometers",
                    Verdict::Fail,
                    "no fan speeds can be read",
                )
                .with_fix("Without a tachometer the stall detector cannot tell a stopped fan from a slow one.")
            } else {
                Check::new("tacho", "Fan tachometers", Verdict::Ok, rpms.join(", "))
            });
        }
        Err(e) => checks.push(
            Check::new("pwm", "Fan control", Verdict::Fail, e.to_string()).with_fix(
                "pwm1 appears only when hp-wmi knows this board. Build the patched \
                 module: kernel/hp-wmi-8d24/build-module.sh --install",
            ),
        ),
    }

    Section {
        title: "Fan".into(),
        checks,
    }
}

fn thermal(snapshot: &DaemonView) -> Section {
    let mut checks = Vec::new();

    match Thermal::discover() {
        Ok(t) => {
            let labels: Vec<String> = t.sensors.iter().map(|s| s.label.clone()).collect();
            checks.push(Check::new(
                "sensors",
                "Temperature sensors",
                Verdict::Ok,
                labels.join(", "),
            ));

            // Asked of the daemon first. The GPU's temperature comes from
            // the EC, which only root can read - so a user running this would
            // otherwise be told the curve is blind when it is not.
            let daemon_sees_dgpu = snapshot
                .as_ref()
                .ok()
                .map(|s| s.temps.iter().any(|(label, _)| label.starts_with("dgpu")));

            checks.push(match (daemon_sees_dgpu, t.has_dgpu()) {
                (Some(true), _) | (None, true) => Check::new(
                    "dgpu_temp",
                    "Discrete GPU temperature",
                    Verdict::Ok,
                    "being watched",
                ),
                (Some(false), _) => Check::new(
                    "dgpu_temp",
                    "Discrete GPU temperature",
                    Verdict::Warn,
                    "the service is not watching it - the curve only follows the CPU",
                )
                .with_fix(
                    "The GPU's temperature is read from the EC, which needs the ec_sys \
                     module: sudo modprobe ec_sys  (read-only; do NOT pass \
                     write_support=1 on this board). Then: sudo systemctl restart omend",
                ),
                (None, false) => Check::new(
                    "dgpu_temp",
                    "Discrete GPU temperature",
                    Verdict::Skip,
                    "cannot be read from here - it comes from the EC, which needs root",
                ),
            });
        }
        Err(e) => checks.push(
            Check::new(
                "sensors",
                "Temperature sensors",
                Verdict::Fail,
                e.to_string(),
            )
            .with_fix("Without a temperature there is nothing to run a curve against."),
        ),
    }

    // Writable EC access is the one thing on this machine that can wedge the
    // firmware hard enough to need a power cycle. omen-space blocks direct EC
    // writes on this board for exactly that reason.
    checks.push(match read("/sys/module/ec_sys/parameters/write_support") {
        None => Check::new(
            "ec_write",
            "EC write access",
            Verdict::Ok,
            "ec_sys is not loaded, or is read-only",
        ),
        Some(v) if v == "N" => Check::new(
            "ec_write",
            "EC write access",
            Verdict::Ok,
            "ec_sys is loaded read-only, which is what this project expects",
        ),
        Some(v) => Check::new(
            "ec_write",
            "EC write access",
            Verdict::Warn,
            format!("ec_sys allows writes (write_support={v})"),
        )
        .with_fix(
            "Nothing here writes to the EC, but with writes enabled another tool can. \
             On this board a bad EC write locks the keyboard controller until a power \
             cycle. Load it read-only instead: write_support=0",
        ),
    });

    Section {
        title: "Thermal".into(),
        checks,
    }
}

fn service(snapshot: &DaemonView) -> Section {
    let mut checks = Vec::new();

    match snapshot {
        Ok(snap) => {
            checks.push(Check::new(
                "omend",
                "Service",
                Verdict::Ok,
                format!(
                    "running, driving the fan in {} mode",
                    snap.mode.map(|m| m.to_string()).unwrap_or_default()
                ),
            ));

            checks.push(match snap.version.as_deref() {
                Some(v) if v == about::VERSION => Check::new(
                    "omend_version",
                    "Service version",
                    Verdict::Ok,
                    format!("{v}, the same as this tool"),
                ),
                Some(v) => Check::new(
                    "omend_version",
                    "Service version",
                    Verdict::Warn,
                    format!("{v} is running, but {} is installed", about::VERSION),
                )
                .with_fix("sudo systemctl restart omend"),
                None => Check::new(
                    "omend_version",
                    "Service version",
                    Verdict::Warn,
                    "running, but too old to report a version",
                )
                .with_fix("sudo systemctl restart omend"),
            });

            checks.push(if snap.safety_fallback {
                Check::new(
                    "safety",
                    "Safety override",
                    Verdict::Warn,
                    snap.safety_reason
                        .clone()
                        .unwrap_or_else(|| "the fans are forced to full power".into()),
                )
                .with_fix(
                    "Normal control resumes on its own once the machine cools. If it \
                     keeps happening, the curve is not keeping up: omenctl curve",
                )
            } else {
                Check::new("safety", "Safety override", Verdict::Ok, "not active")
            });

            if let Some(path) = &snap.config_path {
                checks.push(
                    match crate::config::Config::load(std::path::Path::new(path)) {
                        Ok(_) => Check::new("config", "Configuration", Verdict::Ok, path.clone()),
                        Err(e) => Check::new(
                            "config",
                            "Configuration",
                            Verdict::Fail,
                            format!("{path}: {e}"),
                        )
                        .with_fix(
                            "The daemon is running on its previous configuration; the file \
                             on disk would not load. Fix it and run: omenctl reload",
                        ),
                    },
                );
            }
        }
        Err(e) => {
            let message = e.clone();
            // Told apart because the remedies are completely different: one
            // is a stopped service, the other is a group membership that has
            // not taken effect in this session yet.
            let denied = message.contains("Permission denied");
            checks.push(if denied {
                Check::new(
                    "omend",
                    "Service",
                    Verdict::Warn,
                    "running, but this user cannot talk to it",
                )
                .with_fix(
                    "The socket is owned by the 'omen' group. Join it and start a new \
                     login session: sudo usermod -aG omen $USER",
                )
            } else {
                Check::new("omend", "Service", Verdict::Fail, message)
                    .with_fix("sudo systemctl start omend  (and: systemctl status omend)")
            });
        }
    }

    Section {
        title: "Service".into(),
        checks,
    }
}

fn lighting() -> Section {
    let mut checks = Vec::new();

    let module = about::module_status("omen_kbd_rgb");
    checks.push(if module.loaded {
        let detail = match &module.version {
            Some(v) => format!("loaded, version {v}"),
            None => "loaded".into(),
        };
        if module.stale() {
            Check::new(
                "rgb_module",
                "RGB module",
                Verdict::Warn,
                format!("{detail} - a different build is installed"),
            )
            .with_fix("sudo modprobe -r omen-kbd-rgb && sudo modprobe omen-kbd-rgb")
        } else {
            Check::new("rgb_module", "RGB module", Verdict::Ok, detail)
        }
    } else {
        Check::new("rgb_module", "RGB module", Verdict::Warn, "not loaded")
            .with_fix("sudo modprobe omen-kbd-rgb  (install omen-kbd-rgb-dkms if it is missing)")
    });

    match Leds::discover() {
        Ok(leds) => {
            let state = leds.state();
            checks.push(if leds.writable() {
                Check::new(
                    "leds_write",
                    "LED access",
                    Verdict::Ok,
                    "writable by this user",
                )
            } else {
                Check::new(
                    "leds_write",
                    "LED access",
                    Verdict::Warn,
                    "read-only for this user",
                )
                .with_fix(
                    "Install the udev rule (packaging/99-omen-leds.rules) and join the \
                     'omen' group; a new group membership only applies in a new login \
                     session.",
                )
            });

            checks.push(if state.backlight_off {
                Check::new(
                    "backlight",
                    "Keyboard backlight",
                    Verdict::Warn,
                    "off - colours can be set but nothing will be visible",
                )
                .with_fix("Turn it on with the keyboard's own backlight key (Fn+F4).")
            } else {
                Check::new(
                    "backlight",
                    "Keyboard backlight",
                    Verdict::Ok,
                    format!("on at {}%", state.brightness.unwrap_or(0)),
                )
            });
        }
        Err(e) => checks.push(Check::new(
            "leds",
            "LED class",
            Verdict::Skip,
            format!("no keyboard LEDs ({e})"),
        )),
    }

    Section {
        title: "Lighting".into(),
        checks,
    }
}

fn graphics() -> Section {
    let mut checks = Vec::new();

    match gpu::discover() {
        None => checks.push(Check::new(
            "dgpu",
            "Discrete GPU",
            Verdict::Skip,
            "none found",
        )),
        Some(g) => {
            checks.push(Check::new(
                "dgpu",
                "Discrete GPU",
                Verdict::Ok,
                format!("{} ({})", g.address, g.status),
            ));

            checks.push(if g.control != "auto" {
                Check::new(
                    "dgpu_pm",
                    "GPU runtime power",
                    Verdict::Warn,
                    format!("power/control is '{}' - it cannot suspend", g.control),
                )
                .with_fix("omenctl gpu auto")
            } else if g.awake_despite_pm() {
                let who = if g.holders.is_empty() {
                    "nothing is holding it open, which is unusual".to_string()
                } else {
                    g.holders
                        .iter()
                        .map(|h| format!("{} ({})", h.name, h.pid))
                        .collect::<Vec<_>>()
                        .join(", ")
                };
                Check::new(
                    "dgpu_pm",
                    "GPU runtime power",
                    Verdict::Warn,
                    format!("allowed to suspend but never has - held open by {who}"),
                )
                .with_fix(
                    "Each program holding a /dev/nvidia* handle keeps the GPU awake and \
                     costs battery. Closing them, or configuring them not to use the \
                     discrete GPU, is what lets it sleep.",
                )
            } else {
                Check::new(
                    "dgpu_pm",
                    "GPU runtime power",
                    Verdict::Ok,
                    format!(
                        "may suspend; {} minutes asleep so far",
                        g.suspended_ms / 60_000
                    ),
                )
            });
        }
    }

    // The mux is reported by omen-kbd-rgb, which asks the firmware. Absence
    // is not a fault - but it is only an ANSWER when the module that would
    // have reported it is the installed one. A module from before the mux
    // support was added cannot say the firmware has none; it can only say it
    // did not look.
    let rgb = about::module_status("omen_kbd_rgb");
    checks.push(match crate::gpu::mux::discover() {
        Some(mux) => Check::new(
            "mux",
            "Graphics switcher",
            Verdict::Ok,
            format!(
                "{} (supports {})",
                mux.current.clone().unwrap_or_else(|| "?".into()),
                mux.supported.join(", ")
            ),
        ),
        None if rgb.stale() => Check::new(
            "mux",
            "Graphics switcher",
            Verdict::Skip,
            "unknown - the loaded omen-kbd-rgb is an older build than the installed one",
        )
        .with_fix("sudo modprobe -r omen-kbd-rgb && sudo modprobe omen-kbd-rgb"),
        None if rgb.loaded => Check::new(
            "mux",
            "Graphics switcher",
            Verdict::Skip,
            "this machine's firmware does not offer one",
        ),
        None => Check::new(
            "mux",
            "Graphics switcher",
            Verdict::Skip,
            "unknown - omen-kbd-rgb is what asks the firmware, and it is not loaded",
        ),
    });

    Section {
        title: "Graphics".into(),
        checks,
    }
}

/// Other software that drives the same knobs.
///
/// Two things are deliberately NOT in the list. power-profiles-daemon watches
/// platform_profile rather than owning it, so it coexists - it was tested.
/// And a desktop's own power settings only ever set the same profile through
/// the same interface.
const KNOWN_CONFLICTS: &[(&str, &str)] = &[
    (
        "thermald",
        "Intel thermal daemon - writes thermal limits of its own",
    ),
    (
        "nbfc",
        "NoteBook FanControl - drives the fan directly, via the EC",
    ),
    (
        "fancontrol",
        "lm_sensors' fancontrol - writes pwm1, the same file omend does",
    ),
    (
        "tuned",
        "tuned - applies its own power and thermal policies",
    ),
    (
        "auto-cpufreq",
        "auto-cpufreq - changes governors and limits underneath",
    ),
    ("ryzenadj", "ryzenadj - writes SMU power limits directly"),
    (
        "system76-power",
        "system76-power - another laptop power daemon",
    ),
];

fn conflicts() -> Section {
    let running = crate::apps::running_processes();
    let found: Vec<String> = KNOWN_CONFLICTS
        .iter()
        .filter(|(name, _)| running.iter().any(|p| p == name))
        .map(|(name, why)| format!("{name} ({why})"))
        .collect();

    let mut checks = vec![if found.is_empty() {
        Check::new(
            "conflicts",
            "Other thermal software",
            Verdict::Ok,
            "nothing else is driving the fans or power limits",
        )
    } else {
        Check::new(
            "conflicts",
            "Other thermal software",
            Verdict::Warn,
            found.join("; "),
        )
        .with_fix(
            "Two programs writing the same setpoint will fight, and the loser is \
             whichever wrote first. Stop the other one, or stop omend.",
        )
    }];

    // A second omend is worth calling out separately: the socket refuses to
    // start twice, so a duplicate means one of them is running with
    // OMEND_SOCKET set and is writing the fan without anyone watching it.
    let omend_count = running.iter().filter(|p| *p == "omend").count();
    if omend_count > 1 {
        checks.push(
            Check::new(
                "omend_dup",
                "Duplicate service",
                Verdict::Fail,
                format!("{omend_count} omend processes are running"),
            )
            .with_fix(
                "Only one may drive the fan. The extra one was probably started by hand \
                 with OMEND_SOCKET set: pkill -f 'omend --config'",
            ),
        );
    }

    checks.push(Check::new(
        "ppd",
        "power-profiles-daemon",
        if running.iter().any(|p| p == "power-profiles-") {
            Verdict::Ok
        } else {
            Verdict::Skip
        },
        "watches platform_profile rather than owning it; it coexists with omend",
    ));

    Section {
        title: "Coexistence".into(),
        checks,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn check(verdict: Verdict) -> Check {
        Check::new("x", "X", verdict, "detail")
    }

    fn report(verdicts: &[Verdict]) -> Report {
        Report {
            sections: vec![Section {
                title: "S".into(),
                checks: verdicts.iter().copied().map(check).collect(),
            }],
        }
    }

    #[test]
    fn a_clean_report_says_so() {
        let r = report(&[Verdict::Ok, Verdict::Ok, Verdict::Skip]);
        assert_eq!(r.summary(), "everything checked is working");
    }

    #[test]
    fn skipped_checks_are_not_failures() {
        // A check that could not run must not read as a broken machine.
        let r = report(&[Verdict::Skip, Verdict::Skip]);
        assert_eq!(r.count(Verdict::Fail), 0);
        assert_eq!(r.summary(), "everything checked is working");
    }

    #[test]
    fn failures_and_warnings_are_counted_separately() {
        let r = report(&[Verdict::Fail, Verdict::Warn, Verdict::Warn, Verdict::Ok]);
        assert_eq!(r.count(Verdict::Fail), 1);
        assert_eq!(r.count(Verdict::Warn), 2);
        assert_eq!(r.summary(), "1 thing broken, 2 worth knowing about");
    }

    #[test]
    fn the_text_report_carries_the_fixes() {
        let mut r = report(&[Verdict::Fail]);
        r.sections[0].checks[0].fix = Some("do the thing".into());
        let text = r.to_text();
        assert!(text.contains("FAIL"));
        assert!(text.contains("do the thing"));
    }

    #[test]
    fn running_the_real_checks_produces_every_section() {
        // Runs against whatever machine the tests are on: the point is that
        // nothing panics and no section is silently dropped when hardware is
        // missing.
        let r = run();
        assert_eq!(r.sections.len(), 7);
        assert!(r.checks().count() > 10);
    }
}
