//! `omenctl` - status tool and daemon client.
//!
//! It never writes to the fan directly. Control commands go to omend over a
//! unix socket (phase3-plan §4, safety rule 5): driving the setpoint from one
//! place beats two processes overwriting each other. That keeps clamping, the
//! critical cutout and restore-on-exit guaranteed in a single place.
//!
//! `status` falls back to reading sysfs directly so it stays useful while the
//! daemon is not running - that is where its value as a diagnostic lies.

mod client;

use std::process::ExitCode;

use anyhow::{bail, Result};
use omen_core::anim::{Effect, EffectSpec};
use omen_core::config::Config;
use omen_core::fan::Fan;
use omen_core::ipc::{ControlMode, CurveSpec, Request, Response};
use omen_core::profile::PlatformProfile;
use omen_core::sysfs;
use omen_core::thermal::Thermal;

const USAGE: &str = "\
omenctl - fan and thermal control tool for the OMEN 16-ap0xxx

USAGE:
    omenctl status                 Current state (reads sysfs if no daemon)
    omenctl curve [-c PATH]        Show the active fan curve
    omenctl curve set <POINTS>     Replace it, e.g. 45:0,50:1800,70:2400,90:3300
                                   (temperature:RPM pairs; rpm 0 = fans off,
                                   only valid at the bottom)
    omenctl curve preset <NAME>    quiet / default / performance
    omenctl curve reset            Back to the built-in OMEN Gaming Hub table
    omenctl curve code             The curve as one line, to paste to somebody
    omenctl curve import <CODE>    Load a curve somebody pasted to you

    omenctl set curve              Automatic: the curve drives the fan (default)
    omenctl set manual <RPM>       Fixed target
    omenctl set max                Fans at full power
    omenctl set auto               Advanced: hand the fans to the EC and stop
                                   managing them. On this machine the EC does
                                   not take them - for comparing against stock
                                   behaviour, not for daily use.

    omenctl effect fps <1-60>        Frames a second for effects (default 30)
    omenctl effect <NAME> [SPEED] [#RRGGBB]
                                   Keyboard lighting: none / breathing / wave /
                                   spectrum. Speed is 1-10; the colour applies
                                   to breathing. Persists across reboots.

    omenctl app                    List the per-application profiles
    omenctl app add <PROCESS> [PROFILE] [FAN]
                                   e.g. omenctl app add cs2 performance 3000
                                   PROFILE is a platform profile, FAN is
                                   curve / max / auto / an RPM number, or
                                   curve:quiet / curve:performance to run a
                                   named curve while it is open
    omenctl app remove <PROCESS>   Drop one
    omenctl app running            What you are running now, by the name a
                                   profile has to match

    omenctl trigger                List the state triggers
    omenctl trigger add <WHEN> [ARGS] [PROFILE] [FAN]
                                   WHEN is temp-above / battery-below / idle /
                                   lid-closed / time-between / wifi-ssid. e.g.
                                     omenctl trigger add temp-above 88 performance
                                     omenctl trigger add idle 30 low-power curve:quiet
                                     omenctl trigger add lid-closed low-power
                                     omenctl trigger add time-between 23:00 07:00 low-power
                                     omenctl trigger add wifi-ssid Office balanced curve:quiet
    omenctl trigger remove <WHEN>  Drop one

    omenctl gpu mux [MODE]         Which GPU drives the screen from the next
                                   boot: hybrid / discrete / uma
    omenctl gpu boost [profile|leave]
                                   cTGP and Dynamic Boost: follow the profile
                                   as the vendor software does, or leave them
                                   to the firmware. Without an argument, shows
                                   what the firmware has now
    omenctl gpu [auto|on]          Discrete GPU: may it suspend when idle?
                                   Without an argument, shows what is holding
                                   it awake.

    omenctl power                  What happens on mains and on battery
    omenctl power ac|battery <PROFILE|none> [FAN]
                                   e.g. omenctl power battery low-power curve:quiet
                                   'none' clears that rule

    omenctl battery [PERCENT|off]  Stop charging at PERCENT, on a machine whose
                                   kernel offers the control. Without an
                                   argument, shows the charge and the limit.

    omenctl calibrate [--yes]      Measure what the fans actually do at each
                                   setpoint. Takes about a minute and is loud.

    omenctl clean [SECONDS]        Run the fans at full power to clear dust
                                   (default 20s, 5-120), then back to normal

    omenctl profile <NAME>         balanced / performance / low-power
    omenctl profile startup <NAME|none>
                                   Which profile to select when the daemon
                                   starts. 'none' leaves it to the firmware.
    omenctl profile measure        Load every core, and measure what each
                                   profile actually allows: CPU package power
                                   and clock, and the GPU's power limit.
                                   About a minute and a half; the profile is
                                   put back afterwards.
    omenctl key [ACTION]           What the OMEN key does: window / profile /
                                   both / none. Without an argument, says.
    omenctl keys check             Press the keys it names and it says which
                                   ones send the wrong key, and writes a rule
                                   for this board that fixes only those
    omenctl keys reset             Remove that rule
    omenctl reload                 Make the daemon re-read its configuration
    omenctl fix [WHAT]             The things here that need root - restarting
                                   the service, reloading a module, joining the
                                   'omen' group. Without an argument it lists
                                   what this machine needs; with one it runs it
                                   and asks for your password the way your
                                   desktop does.

    omenctl caps                   What this machine can be asked to do, and
                                   why anything missing is missing
    omenctl version                Versions, and whether anything running is
                                   older than what is installed
    omenctl report [PATH]          Write one file with everything a bug report
                                   needs: the diagnosis, the configuration,
                                   the sysfs state and the daemon's log.
                                   '-' writes it to stdout instead.
    omenctl doctor [--text]        Check the whole installation and say what
                                   to do about anything that is wrong

Control commands go to omend over a socket; the daemon is the only thing that
writes to the fan. Run with sudo if you get a permission error.
";

fn main() -> ExitCode {
    restore_sigpipe();
    let args: Vec<String> = std::env::args().skip(1).collect();
    let cmd = args.first().map(String::as_str).unwrap_or("status");

    let result = match cmd {
        "status" => status(),
        "curve" => curve(&args),
        "set" => set_mode(&args),
        "effect" => set_effect(&args),
        "app" => app_profiles(&args),
        "trigger" | "triggers" => triggers(&args),
        "gpu" => gpu_power(&args),
        "power" => power_rules(&args),
        "clean" => clean_fans(&args),
        "calibrate" => calibrate(&args),
        "battery" => battery(&args),
        "profile" => set_profile(&args),
        "key" => omen_key(&args),
        "keys" => keys(&args),
        "reload" => client::send(&Request::Reload).and_then(client::report),
        "caps" | "capabilities" => capabilities(),
        "fix" => fix(&args),
        "version" | "--version" | "-V" => versions(),
        "doctor" | "check" => doctor(&args),
        "report" => report(&args),
        "-h" | "--help" | "help" => {
            print!("{USAGE}");
            return ExitCode::SUCCESS;
        }
        other => {
            eprintln!("unknown command: {other}\n\n{USAGE}");
            return ExitCode::from(2);
        }
    };

    match result {
        Ok(()) => ExitCode::SUCCESS,
        Err(e) => {
            eprintln!("error: {e:#}");
            ExitCode::FAILURE
        }
    }
}

/// Rust ignores SIGPIPE at startup, so in a pipeline like
/// `omenctl status | head` the write fails once the reader closes and a panic
/// message is printed. The right behaviour for a CLI is to die quietly, the
/// way every filter program does.
fn restore_sigpipe() {
    // SAFETY: single-threaded here, and we are only restoring the default
    // disposition.
    unsafe {
        libc::signal(libc::SIGPIPE, libc::SIG_DFL);
    }
}

fn set_mode(args: &[String]) -> Result<()> {
    let mode = match args.get(1).map(String::as_str) {
        Some("curve") => ControlMode::Curve,
        Some("auto") => ControlMode::Auto,
        Some("max") => ControlMode::Max,
        Some("manual") => {
            let rpm: u32 = args
                .get(2)
                .ok_or_else(|| anyhow::anyhow!("manual expects an RPM value"))?
                .parse()
                .map_err(|_| anyhow::anyhow!("the RPM value must be a number"))?;
            ControlMode::Manual { rpm }
        }
        Some(other) => bail!("unknown mode: {other} (curve / auto / manual <RPM> / max)"),
        None => bail!("a mode is required: curve / auto / manual <RPM> / max"),
    };
    client::report(client::send(&Request::SetMode(mode))?)
}

/// The effect the daemon is running, if it is running and will say.
fn current_effect() -> Option<EffectSpec> {
    match client::send(&Request::Status) {
        Ok(Response::Ok(snap)) => snap.effect,
        _ => None,
    }
}

/// `#e81123` or `e81123`.
fn parse_hex(raw: &str) -> Result<omen_core::leds::Rgb> {
    let hex = raw.trim_start_matches('#');
    if hex.len() != 6 || !hex.chars().all(|c| c.is_ascii_hexdigit()) {
        bail!("{raw:?} is not a colour - expected something like #e81123");
    }
    let byte = |i: usize| u8::from_str_radix(&hex[i..i + 2], 16).unwrap();
    Ok(omen_core::leds::Rgb {
        r: byte(0),
        g: byte(2),
        b: byte(4),
    })
}

/// `curve:performance` -> the name. Anything else -> None.
fn parse_curve_arg(raw: &str) -> Result<Option<String>> {
    let Some(name) = raw.strip_prefix("curve:") else {
        return Ok(None);
    };
    if omen_core::curve::preset(name).is_none() {
        bail!(
            "unknown curve {name:?}; presets are {}",
            omen_core::curve::PRESETS
                .iter()
                .map(|(n, _)| *n)
                .collect::<Vec<_>>()
                .join(" / ")
        );
    }
    Ok(Some(name.to_owned()))
}

fn set_effect(args: &[String]) -> Result<()> {
    if args.get(1).map(String::as_str) == Some("fps") {
        let fps: u8 = args
            .get(2)
            .and_then(|v| v.parse().ok())
            .ok_or_else(|| anyhow::anyhow!("a frame rate is required: 1-60"))?;
        return client::report(client::send(&Request::SetLightingFps { fps })?);
    }

    let name = args.get(1).ok_or_else(|| {
        anyhow::anyhow!("an effect is required: none / breathing / wave / spectrum")
    })?;
    let effect = Effect::parse(name).ok_or_else(|| {
        anyhow::anyhow!("unknown effect: {name} (none / breathing / wave / spectrum)")
    })?;

    // Unspecified fields keep whatever the daemon is already using. Turning
    // effects off and back on should not quietly reset the colour you chose,
    // and `omenctl effect wave` should not reset the speed.
    let mut spec = EffectSpec {
        effect,
        ..current_effect().unwrap_or_default()
    };
    for arg in &args[2..] {
        if arg.starts_with('#') || arg.len() == 6 && arg.chars().all(|c| c.is_ascii_hexdigit()) {
            spec.color = parse_hex(arg)?;
        } else {
            let speed: u8 = arg
                .parse()
                .map_err(|_| anyhow::anyhow!("{arg:?} is neither a speed (1-10) nor a colour"))?;
            if !(1..=10).contains(&speed) {
                bail!("the speed must be between 1 and 10");
            }
            spec.speed = speed;
        }
    }

    client::report(client::send(&Request::SetEffect(spec))?)
}

/// What the OMEN key is bound to.
fn omen_key(args: &[String]) -> Result<()> {
    let Some(action) = args.get(1) else {
        let snap = app_snapshot()?;
        field(
            "OMEN key",
            snap.omen_key.clone().unwrap_or_else(|| "?".into()),
        );
        println!("\n  window   open the window, or raise it if it is already running");
        println!("  profile  step through the performance profiles");
        println!("  both     do both");
        println!("  none     nothing");
        return Ok(());
    };
    client::report(client::send(&Request::SetOmenKey {
        action: action.clone(),
    })?)
}

fn set_profile(args: &[String]) -> Result<()> {
    if args.get(1).map(String::as_str) == Some("measure") {
        return measure_profiles();
    }
    if args.get(1).map(String::as_str) == Some("startup") {
        let want = args
            .get(2)
            .ok_or_else(|| anyhow::anyhow!("a profile name is required, or 'none'"))?;
        let profile = (want != "none").then(|| want.clone());
        return client::report(client::send(&Request::SetStartupProfile { profile })?);
    }

    let profile = args
        .get(1)
        .ok_or_else(|| anyhow::anyhow!("a profile name is required"))?
        .clone();
    client::report(client::send(&Request::SetProfile { profile })?)
}

/// `omenctl keys check` / `reset`. See omen_core::keys.
fn keys(args: &[String]) -> Result<()> {
    use omen_core::keys::{self, Fix, Keyboard};
    use std::time::Duration;

    let is_root = std::fs::read_to_string("/proc/self/status")
        .ok()
        .and_then(|s| {
            s.lines()
                .find(|l| l.starts_with("Uid:"))
                .map(|l| l.split_whitespace().nth(1) == Some("0"))
        })
        .unwrap_or(false);

    match args.get(1).map(String::as_str) {
        Some("reset") => {
            if !is_root {
                println!("  This needs root:");
                println!("    sudo omenctl keys reset");
                return Ok(());
            }
            // Run whether or not the file is still there: a rule removed by
            // hand, or by an older version of this command, leaves its
            // mappings in the kernel until the keyboard is re-created.
            if std::path::Path::new(keys::HWDB_PATH).exists() {
                std::fs::remove_file(keys::HWDB_PATH)?;
                println!("  {} removed", keys::HWDB_PATH);
            }
            reload_hwdb()?;
            keys::reset_keymap()?;
            println!("  the keyboard's keymap is back to the defaults and systemd's own map");
            return Ok(());
        }
        Some("check") => {}
        _ => bail!("usage: omenctl keys check | omenctl keys reset"),
    }

    let Some(dev) = keys::keyboard_device() else {
        bail!("no built-in AT keyboard was found in /proc/bus/input/devices");
    };
    let mut kb = Keyboard::open(&dev).map_err(|e| {
        anyhow::anyhow!(
            "{} could not be opened ({e}). Reading it needs root or the 'input' group: \
             sudo omenctl keys check",
            dev.display()
        )
    })?;

    println!("  Press each key when asked. Wait 10 seconds to skip one this keyboard");
    println!("  does not have. The desktop sees the presses too, so PrtSc may take a");
    println!("  screenshot.\n");

    // The terminal would echo each key as an escape sequence (^[[24~ for
    // F12) into the middle of the report. Echo is put back on the way out,
    // including an early return.
    struct NoEcho;
    impl NoEcho {
        fn set(on: bool) {
            if let Ok(tty) = std::fs::File::open("/dev/tty") {
                let _ = std::process::Command::new("stty")
                    .arg(if on { "echo" } else { "-echo" })
                    .stdin(tty)
                    .status();
            }
        }
    }
    impl Drop for NoEcho {
        fn drop(&mut self) {
            NoEcho::set(true);
        }
    }
    NoEcho::set(false);
    let echo = NoEcho;

    let mut fixes = Vec::new();
    for want in keys::CHECKS {
        // A top-row key is asked for twice, on its own and with Fn: which of
        // the two gives F1 and which gives the action is a BIOS setting, and
        // the key is only broken if neither gives it.
        let ways: &[&str] = if want.top_row {
            &["on its own", "with Fn held"]
        } else {
            &[""]
        };
        let mut verdicts = Vec::new();
        for way in ways {
            let prompt = if way.is_empty() {
                want.label.to_string()
            } else {
                format!("{} {way}", want.label)
            };
            print!("  {prompt:<24} ");
            use std::io::Write as _;
            let _ = std::io::stdout().flush();
            kb.drain();
            let presses = kb.next_presses(Duration::from_secs(10));
            let verdict = keys::judge(want, &presses);
            match &verdict {
                keys::Verdict::Skipped => match keys::silent_hint(want) {
                    Some(hint) => println!("nothing sent - {hint}"),
                    None => println!("skipped"),
                },
                keys::Verdict::Right { with } if with.is_empty() => {
                    println!("ok - {}", keys::describe(&presses))
                }
                keys::Verdict::Right { .. } => println!(
                    "ok - {} (a combination the firmware sends)",
                    keys::describe(&presses)
                ),
                keys::Verdict::Wrong { .. } => {
                    println!("{} - not {}", keys::describe(&presses), want.name)
                }
            }
            verdicts.push(verdict);
        }

        let any_right = verdicts
            .iter()
            .any(|v| matches!(v, keys::Verdict::Right { .. }));
        let all_skipped = verdicts.iter().all(|v| *v == keys::Verdict::Skipped);
        if any_right || all_skipped {
            continue;
        }
        let fix = verdicts.iter().find_map(|v| match v {
            keys::Verdict::Wrong { fix: Some(s), .. } => Some(*s),
            _ => None,
        });
        match fix {
            Some(scancode) => fixes.push(Fix {
                scancode,
                name: want.name,
                label: want.label,
            }),
            None => println!(
                "    {} cannot be reached, but what came was a modifier, several keys or \
                 had no scancode - remapping that would break something else, so it is \
                 left alone",
                want.name
            ),
        }
    }
    drop(echo);

    if fixes.is_empty() {
        println!("\n  Every key that was pressed sends what it says. Nothing to fix.");
        return Ok(());
    }

    let board = sysfs::read_string(std::path::Path::new("/sys/class/dmi/id/board_name"))
        .unwrap_or_default();
    if board.is_empty() {
        bail!("the board name could not be read, so the rule cannot be limited to this board");
    }
    let rule = keys::hwdb_rule(&board, &fixes);
    println!("\n  The rule that fixes these, for board {board} only:\n");
    for line in rule.lines() {
        println!("    {line}");
    }

    if is_root {
        std::fs::create_dir_all("/etc/udev/hwdb.d")?;
        std::fs::write(keys::HWDB_PATH, &rule)?;
        reload_hwdb()?;
        // From clean defaults, so a mapping from an earlier rule that this
        // one no longer has does not linger.
        keys::reset_keymap()?;
        println!(
            "\n  Installed as {}. Undo with: sudo omenctl keys reset",
            keys::HWDB_PATH
        );
    } else {
        let staged = std::env::var_os("XDG_CONFIG_HOME")
            .map(std::path::PathBuf::from)
            .or_else(|| {
                std::env::var_os("HOME").map(|h| std::path::PathBuf::from(h).join(".config"))
            })
            .map(|c| c.join("omen-control/keyboard.hwdb"))
            .ok_or_else(|| anyhow::anyhow!("no home directory to save the rule in"))?;
        if let Some(dir) = staged.parent() {
            std::fs::create_dir_all(dir)?;
        }
        std::fs::write(&staged, &rule)?;
        println!(
            "\n  Saved to {}. Installing it needs root:",
            staged.display()
        );
        println!(
            "    sudo install -Dm644 {} {}",
            staged.display(),
            keys::HWDB_PATH
        );
        println!("    sudo systemd-hwdb update");
        println!("    sudo udevadm trigger -s input");
        println!("  or run this check again with sudo, which installs it itself.");
    }
    Ok(())
}

/// Rebuilds the hwdb and replays the input devices so a rule takes effect
/// without a reboot.
fn reload_hwdb() -> Result<()> {
    let ok = |cmd: &mut std::process::Command| cmd.status().map(|s| s.success()).unwrap_or(false);
    if !ok(std::process::Command::new("systemd-hwdb").arg("update")) {
        bail!("systemd-hwdb update failed");
    }
    if !ok(std::process::Command::new("udevadm").args(["trigger", "-s", "input"])) {
        bail!("udevadm trigger failed");
    }
    Ok(())
}

/// What each platform profile actually allows, measured.
///
/// A profile is a request to the firmware, and whether it does anything is a
/// question of fact: on a sibling of this board another project measured no
/// difference at all between modes until it took a different path. So this
/// puts every core under load, switches through the profiles, and reads what
/// the CPU package draws and how fast it runs once the firmware's limits have
/// settled - plus the power limit the NVIDIA driver is enforcing, which the
/// profile moves too.
///
/// Measured on 8D24 (2026-09-28): low-power 32 W, balanced 55 W,
/// performance 60 W; GPU limit 80 / 80 / 100 W. docs/research/profile-power.md.
fn measure_profiles() -> Result<()> {
    use std::sync::atomic::{AtomicBool, Ordering};
    use std::sync::Arc;
    use std::time::Duration;

    const SETTLE: Duration = Duration::from_secs(15);
    const WINDOW: Duration = Duration::from_secs(10);

    let Some(mut rapl) = omen_core::rapl::Package::discover() else {
        bail!("no RAPL package counter under /sys/class/powercap - nothing to measure with");
    };
    if let Err(e) = rapl.watts() {
        bail!(
            "{} is not readable ({e}). Some kernels keep it root-only: sudo omenctl profile measure",
            rapl.path().join("energy_uj").display()
        );
    }
    let Some(pp) = PlatformProfile::discover() else {
        bail!("there is no platform_profile to switch");
    };
    let before = pp.get()?;
    let choices = pp.choices();

    println!(
        "  Loading all {} threads. Each profile gets {}s to settle and {}s of measuring;",
        std::thread::available_parallelism().map_or(1, |n| n.get()),
        SETTLE.as_secs(),
        WINDOW.as_secs()
    );
    println!(
        "  the fans will spin up. Ctrl+C stops the load (the profile then stays where it is).\n"
    );

    let stop = Arc::new(AtomicBool::new(false));
    let workers: Vec<_> = (0..std::thread::available_parallelism().map_or(1, |n| n.get()))
        .map(|_| {
            let stop = stop.clone();
            std::thread::spawn(move || {
                // Floating point across a wide array, which the compiler turns
                // into vector code. A scalar integer loop is not enough: it
                // runs into the clock ceiling before it reaches the power
                // limit, and then every profile above low-power reads the
                // same - which says nothing about the limits.
                let mut a = [1.000_001_f64; 256];
                while !stop.load(Ordering::Relaxed) {
                    for _ in 0..2_000 {
                        for v in a.iter_mut() {
                            *v = *v * 0.999_999_9 + 1e-9;
                        }
                    }
                    std::hint::black_box(&mut a);
                }
            })
        })
        .collect();

    let mut rows = Vec::new();
    let mut failure = None;
    for profile in &choices {
        if let Err(e) = client::send(&Request::SetProfile {
            profile: profile.clone(),
        })
        .and_then(client::report)
        {
            failure = Some(e);
            break;
        }
        std::thread::sleep(SETTLE);
        let _ = rapl.watts();
        let mhz_before = mean_mhz();
        std::thread::sleep(WINDOW);
        let watts = rapl.watts().ok().flatten();
        let mhz = match (mhz_before, mean_mhz()) {
            (Some(a), Some(b)) => Some((a + b) / 2),
            (a, b) => a.or(b),
        };
        rows.push((profile.clone(), watts, mhz, gpu_power_limit()));
    }

    stop.store(true, Ordering::Relaxed);
    for w in workers {
        let _ = w.join();
    }
    let restored = client::send(&Request::SetProfile {
        profile: before.clone(),
    });

    println!(
        "\n  {:<14} {:>10} {:>10} {:>12}",
        "profile", "CPU", "clock", "GPU limit"
    );
    for (profile, watts, mhz, gpu) in &rows {
        println!(
            "  {:<14} {:>10} {:>10} {:>12}",
            profile,
            watts.map_or("?".into(), |w| format!("{w:.1} W")),
            mhz.map_or("?".into(), |m| format!("{m} MHz")),
            gpu.map_or("-".into(), |g| format!("{g:.0} W")),
        );
    }
    match restored {
        Ok(_) => println!("\n  profile put back to {before}"),
        Err(e) => println!("\n  could not put the profile back to {before}: {e}"),
    }
    if let Some(e) = failure {
        return Err(e);
    }
    Ok(())
}

/// The average current clock across all CPUs, from cpufreq.
fn mean_mhz() -> Option<u32> {
    let entries = std::fs::read_dir("/sys/devices/system/cpu").ok()?;
    let khz: Vec<u64> = entries
        .flatten()
        .filter(|e| {
            e.file_name()
                .to_str()
                .and_then(|n| n.strip_prefix("cpu"))
                .is_some_and(|n| !n.is_empty() && n.bytes().all(|b| b.is_ascii_digit()))
        })
        .filter_map(|e| sysfs::read_string(&e.path().join("cpufreq/scaling_cur_freq")).ok())
        .filter_map(|s| s.trim().parse().ok())
        .collect();
    (!khz.is_empty()).then(|| (khz.iter().sum::<u64>() / khz.len() as u64 / 1000) as u32)
}

/// The power limit the NVIDIA driver is enforcing, if there is one to ask.
/// This wakes the GPU for a moment, which is fine in a one-off test.
fn gpu_power_limit() -> Option<f32> {
    let out = std::process::Command::new("nvidia-smi")
        .args([
            "--query-gpu=enforced.power.limit",
            "--format=csv,noheader,nounits",
        ])
        .output()
        .ok()?;
    String::from_utf8_lossy(&out.stdout).trim().parse().ok()
}

/// The per-application profiles, as the daemon has them. Read from the daemon
/// rather than the file so the list shown is the list in force.
fn app_snapshot() -> Result<Box<omen_core::ipc::Snapshot>> {
    match client::send(&Request::Status)? {
        Response::Ok(snap) => Ok(snap),
        Response::Error { message } => bail!("{message}"),
        Response::Done { message } => bail!("unexpected reply: {message}"),
        Response::History { .. } | Response::Samples { .. } | Response::Presses { .. } => {
            bail!("unexpected reply: not a status")
        }
    }
}

/// `curve` / `max` / `auto` / a bare RPM number.
///
/// `curve:quiet` and friends are handled by the caller: they say WHICH curve
/// as well as that the curve should drive, so they produce two values.
fn parse_fan(raw: &str) -> Result<ControlMode> {
    Ok(match raw {
        "curve" => ControlMode::Curve,
        "max" => ControlMode::Max,
        "auto" => ControlMode::Auto,
        other => ControlMode::Manual {
            rpm: other.parse().map_err(|_| {
                anyhow::anyhow!("{other:?} is not a fan mode (curve / max / auto / an RPM number)")
            })?,
        },
    })
}

fn app_profiles(args: &[String]) -> Result<()> {
    let snap = app_snapshot()?;

    // Edits are built on the config FILE, not on the snapshot. The daemon
    // writes the file and re-reads it a moment later, so a snapshot taken
    // right after a previous edit can still be one change behind - and a
    // read-modify-write against a stale list silently resurrects an entry
    // that was just removed.
    let mut apps = match args.get(1).map(String::as_str) {
        Some("add") | Some("remove") => {
            // The daemon says which file it is reading; it is not always the
            // default one.
            let path = snap
                .config_path
                .as_deref()
                .map(std::path::PathBuf::from)
                .unwrap_or_else(Config::default_path);
            Config::load(&path)
                .map(|c| c.apps)
                .unwrap_or_else(|_| snap.apps.clone())
        }
        _ => snap.apps.clone(),
    };

    match args.get(1).map(String::as_str) {
        None | Some("list") => {
            if apps.is_empty() {
                println!("no application profiles");
                println!("  add one with: omenctl app add <process> [profile] [fan]");
                return Ok(());
            }
            println!("application profiles  (first running entry wins)\n");
            for app in &apps {
                let active = snap.active_app.as_deref() == Some(app.process.as_str());
                println!(
                    "  {}{:<24} {}",
                    if active { "* " } else { "  " },
                    app.process,
                    app.summary()
                );
            }
            if snap.active_app.is_none() {
                println!("\n  none of them are running");
            }
            Ok(())
        }

        Some("add") => {
            let process = args
                .get(2)
                .ok_or_else(|| anyhow::anyhow!("a process name is required"))?
                .clone();
            let mut entry = omen_core::apps::AppProfile {
                process: process.clone(),
                profile: None,
                fan: None,
                curve: None,
            };
            // Profile and fan are both optional and either may come first,
            // so they are told apart by shape - a fan mode is a number or one
            // of three words, everything else is a platform profile.
            for arg in &args[3..] {
                if let Some(name) = parse_curve_arg(arg)? {
                    entry.curve = Some(name);
                    entry.fan = Some(ControlMode::Curve);
                    continue;
                }
                match parse_fan(arg) {
                    Ok(mode) => entry.fan = Some(mode),
                    Err(_) => entry.profile = Some(arg.clone()),
                }
            }
            if entry.profile.is_none() && entry.fan.is_none() {
                bail!("give a profile, a fan mode, or both - otherwise there is nothing to apply");
            }

            apps.retain(|a| !a.process.eq_ignore_ascii_case(&process));
            apps.push(entry);
            client::report(client::send(&Request::SetAppProfiles { apps })?)
        }

        Some("remove") => {
            let process = args
                .get(2)
                .ok_or_else(|| anyhow::anyhow!("a process name is required"))?;
            let before = apps.len();
            apps.retain(|a| !a.process.eq_ignore_ascii_case(process));
            if apps.len() == before {
                bail!("no application profile for {process:?}");
            }
            client::report(client::send(&Request::SetAppProfiles { apps })?)
        }

        Some("running") => {
            // The same list the window offers as completions for the process
            // name. Here because "what is this game's process called" is the
            // one thing about application profiles that people get wrong, and
            // the answer is "start it, then look".
            let names = omen_core::apps::user_programs();
            if names.is_empty() {
                println!("nothing of yours is running that has a name to match");
                return Ok(());
            }
            println!("your running programs  ({} of them)\n", names.len());
            for name in &names {
                let known = apps.iter().any(|a| a.matches(name));
                println!("  {}{name}", if known { "* " } else { "  " });
            }
            println!("\n  * already has a profile");
            Ok(())
        }

        Some(other) => bail!("unknown subcommand: {other} (list / add / remove / running)"),
    }
}

/// The few things here that need root, and a way to ask for it.
///
/// This exists because the alternative was printing a command and hoping.
/// Everything that needs root is a named action with its argv written in the
/// binary - nothing takes a command from anywhere else - and asking goes
/// through polkit on a desktop or sudo on a terminal, so the password is
/// typed into a prompt the person already recognises.
fn fix(args: &[String]) -> Result<()> {
    use omen_core::elevate::{Action, Asker};

    let Some(name) = args.get(1) else {
        let asker = Asker::detect();
        println!("what needs root here\n");

        let mut offered = 0;
        for action in Action::all() {
            if !action.applicable() {
                continue;
            }
            offered += 1;
            println!("  {:<18} {}", action.as_str(), action.title());
            for line in wrap(action.why(), 66) {
                println!("  {:<18} {}", "", line);
            }
            println!("  {:<18} $ {}\n", "", action.command());
        }
        if offered == 0 {
            println!("  Nothing. The service is installed and running, the modules are");
            println!("  loaded, and you are in the 'omen' group.\n");
        }

        println!("  How it will ask: {}", asker.describe());
        if offered > 0 {
            println!("  To run one:      omenctl fix <name>");
        }
        return Ok(());
    };

    let action = Action::parse(name).ok_or_else(|| {
        anyhow::anyhow!(
            "unknown: {name}\n  one of: {}",
            Action::all()
                .iter()
                .map(|a| a.as_str())
                .collect::<Vec<_>>()
                .join(" / ")
        )
    })?;

    // Shown before the prompt, not after: somebody about to type a password
    // should be able to see what it is for.
    println!("{}", action.title());
    println!("  $ {}", action.command());
    println!("  asking through {}\n", Asker::detect().describe());

    match omen_core::elevate::run(action) {
        Ok(message) => {
            println!("{message}");
            Ok(())
        }
        Err(e) => bail!("{e}"),
    }
}

/// What this machine can do, and why not the rest.
///
/// A separate command rather than a line in `status` because it answers a
/// different question: status is about right now, this is about the machine.
/// It is also the first thing to run on a board that is not the verified one,
/// which is the case this project has to handle more honestly than most - on
/// an unverified OMEN some of it works and some of it cannot.
fn capabilities() -> Result<()> {
    let caps = omen_core::caps::Caps::detect();

    println!("{}\n", caps.confidence());
    field(
        "vendor",
        caps.vendor.clone().unwrap_or_else(|| "unknown".into()),
    );
    field(
        "model",
        caps.model.clone().unwrap_or_else(|| "unknown".into()),
    );
    field(
        "board",
        caps.board.clone().unwrap_or_else(|| "unknown".into()),
    );

    println!();
    for (name, present, detail) in caps.lines() {
        println!(
            "  {} {name:<22} {detail}",
            if present { "yes" } else { " no" }
        );
    }

    println!("\n{}: {}", caps.level(), caps.level().describe());
    if let Some(remedy) = caps.remedy() {
        println!();
        for line in wrap(&remedy, 72) {
            println!("  {line}");
        }
    }
    Ok(())
}

/// Versions of everything, and what is out of date with respect to what.
///
/// The reason this is a command rather than a line in `status`: after an
/// upgrade the daemon keeps running the old binary and the old kernel module
/// stays loaded, and the resulting bug reports are against code that is no
/// longer on disk.
fn versions() -> Result<()> {
    use omen_core::about;

    let mut stale = Vec::new();

    println!("omen-control {}\n", about::VERSION);

    // Reachable-but-silent is its own answer, and the most likely one here:
    // a daemon old enough not to report a version at all is by definition
    // older than the tool asking.
    match client::send(&Request::Status) {
        Ok(Response::Ok(snap)) => match snap.version.as_deref() {
            Some(v) if v == about::VERSION => field("omend", format!("{v} (running)")),
            Some(v) => {
                field(
                    "omend",
                    format!("{v} (running) - this tool is {}", about::VERSION),
                );
                stale.push("sudo systemctl restart omend");
            }
            None => {
                field("omend", "running, but too old to report its version");
                stale.push("sudo systemctl restart omend");
            }
        },
        Ok(_) | Err(_) => field("omend", "not reachable"),
    }

    for m in about::modules() {
        if !m.loaded {
            field(&m.name, "not loaded");
            continue;
        }
        let version = m.version.clone().unwrap_or_else(|| "loaded".into());
        if m.stale() {
            field(
                &m.name,
                format!("{version} - a different build is installed"),
            );
            stale.push(match m.name.as_str() {
                "hp_wmi" => "sudo modprobe -r hp_wmi && sudo modprobe hp_wmi",
                _ => "sudo modprobe -r omen-kbd-rgb && sudo modprobe omen-kbd-rgb",
            });
        } else {
            field(&m.name, version);
        }
    }

    if stale.is_empty() {
        println!("\nEverything running is the version that is installed.");
    } else {
        println!("\nSomething installed is newer than what is running. To catch up:\n");
        for cmd in &stale {
            println!("    {cmd}");
        }
        println!("\n  A reboot does all of it, and is the safe answer if the keyboard is lit");
        println!("  or the fans are under load.");
    }
    Ok(())
}

/// The whole installation, checked.
///
/// `--text` prints the same thing without colour or alignment, which is the
/// form to paste into a bug report.
fn doctor(args: &[String]) -> Result<()> {
    use omen_core::diagnose::{self, Verdict};

    let report = diagnose::run();

    if args.iter().any(|a| a == "--text") {
        print!("{}", report.to_text());
        return Ok(());
    }

    // Colour only when something is reading it. A redirected doctor run is
    // usually on its way into a text field.
    let tty = std::io::IsTerminal::is_terminal(&std::io::stdout());
    let paint = |v: Verdict| -> String {
        let label = v.label();
        if !tty {
            return format!("{label:<4}");
        }
        let colour = match v {
            Verdict::Ok => "32",
            Verdict::Warn => "33",
            Verdict::Fail => "31",
            Verdict::Skip => "90",
        };
        format!("\x1b[{colour}m{label:<4}\x1b[0m")
    };

    for section in &report.sections {
        println!("\n{}", section.title.to_uppercase());
        for c in &section.checks {
            println!("  {} {:<26} {}", paint(c.verdict), c.title, c.detail);
            if let Some(fix) = &c.fix {
                // Wrapped by hand rather than by a crate: the fixes are
                // written to fit, and a wrapping dependency for five lines of
                // output is not worth the build time.
                for line in wrap(fix, 68) {
                    println!("       {line}");
                }
            }
        }
    }

    println!("\n{}", report.summary());
    if report.count(Verdict::Fail) > 0 || report.count(Verdict::Warn) > 0 {
        println!("Paste-able version: omenctl doctor --text");
    }
    Ok(())
}

/// Everything a bug report needs, in one file.
///
/// Written to a file rather than printed by default, because that is what
/// happens to it next: it is several hundred lines and it goes into an issue
/// as an attachment. `-` prints it, for piping.
fn report(args: &[String]) -> Result<()> {
    let text = omen_core::bundle::report();

    let target = args.get(1).map(String::as_str).unwrap_or_default();
    if target == "-" {
        print!("{text}");
        return Ok(());
    }

    let path = if target.is_empty() {
        std::path::PathBuf::from(format!(
            "omen-report-{}.txt",
            std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .map(|d| d.as_secs())
                .unwrap_or_default()
        ))
    } else {
        std::path::PathBuf::from(target)
    };

    std::fs::write(&path, &text)
        .map_err(|e| anyhow::anyhow!("could not write {}: {e}", path.display()))?;

    println!("{}", path.display());
    println!(
        "  {} lines. Read it before posting it anywhere - it describes",
        text.lines().count()
    );
    println!("  your machine's hardware and configuration, and nothing else.");
    if !omen_core::ipc::client::send(&Request::Status).is_ok() {
        println!("\n  The daemon did not answer, so the report has no live state in it.");
        println!("  For the useful version: sudo omenctl report");
    }
    Ok(())
}

/// Greedy word wrap.
fn wrap(text: &str, width: usize) -> Vec<String> {
    let mut lines = Vec::new();
    let mut line = String::new();
    for word in text.split_whitespace() {
        if !line.is_empty() && line.len() + 1 + word.len() > width {
            lines.push(std::mem::take(&mut line));
        }
        if !line.is_empty() {
            line.push(' ');
        }
        line.push_str(word);
    }
    if !line.is_empty() {
        lines.push(line);
    }
    lines
}

fn clean_fans(args: &[String]) -> Result<()> {
    let seconds = match args.get(1) {
        Some(raw) => raw
            .parse()
            .map_err(|_| anyhow::anyhow!("{raw:?} is not a number of seconds"))?,
        None => 20,
    };
    client::report(client::send(&Request::CleanFans { seconds })?)
}

/// Measures what the fans actually do at each setpoint.
///
/// Why this is worth a command: every RPM number in this project came off one
/// machine. `min_rpm` and `max_rpm` in the config are HP's own bounds from
/// OMEN Gaming Hub's profiles.json (1800-4800), and on another board they may
/// simply be wrong - a curve built on a maximum the fans cannot reach quietly
/// does nothing at the top, and one built on a minimum below the real
/// fan-stop threshold makes the machine noisier than it needs to be.
///
/// It goes through the daemon like everything else, so the critical cutout,
/// the stall detector and restore-on-exit all still apply while it runs. It
/// stops early if the machine gets hot: measuring a fan is never worth
/// cooking a CPU for.
fn calibrate(args: &[String]) -> Result<()> {
    use std::time::Duration;

    /// How long to let the fans settle at each step. The tachometer lags the
    /// setpoint by several seconds, and a reading taken too early measures
    /// the previous step.
    const SETTLE: Duration = Duration::from_secs(8);

    let snap = app_snapshot()?;
    if snap.mode.is_none() {
        bail!("this machine has no fan setpoint to measure - see 'omenctl caps'");
    }
    let before = snap.mode.unwrap_or(ControlMode::Curve);

    let steps: Vec<u32> = {
        let cfg = Config::load(&Config::default_path()).unwrap_or_default();
        let (min, max) = (cfg.fan.min_rpm, cfg.fan.max_rpm);
        let mut v = vec![min];
        // Five points across the range, on the EC's own hundred-RPM grid.
        for i in 1..=4 {
            v.push((min + (max - min) * i / 4) / 100 * 100);
        }
        v.dedup();
        v
    };

    if !args.iter().any(|a| a == "--yes" || a == "-y") {
        println!(
            "This runs the fans at {} setpoints for {}s each - about {} minute(s) of",
            steps.len(),
            SETTLE.as_secs(),
            (steps.len() as u64 * SETTLE.as_secs()).div_ceil(60)
        );
        println!("noise - and puts the fan back to {before} afterwards.\n");
        println!("Re-run with --yes to go ahead.");
        return Ok(());
    }

    println!("{:>10}  {:>10}  {:>10}", "setpoint", "fan 1", "fan 2");
    let mut measured: Vec<(u32, Option<u32>, Option<u32>)> = Vec::new();

    for rpm in &steps {
        client::send(&Request::SetMode(ControlMode::Manual { rpm: *rpm }))?;
        std::thread::sleep(SETTLE);

        let now = app_snapshot()?;
        // The guard has taken over, or the machine is hot. Either way this is
        // not the time to be holding a fan at a fixed speed for science.
        if now.safety_fallback {
            println!(
                "\nstopped: a safety override is active ({})",
                now.safety_reason.as_deref().unwrap_or("no reason given")
            );
            break;
        }
        if let Some(temp) = now.driver_temp_c {
            if temp >= 85.0 {
                println!("\nstopped: {temp:.0} C is too hot to keep measuring");
                break;
            }
        }

        println!(
            "{rpm:>10}  {:>10}  {:>10}",
            now.fan1_rpm
                .map(|v| v.to_string())
                .unwrap_or_else(|| "-".into()),
            now.fan2_rpm
                .map(|v| v.to_string())
                .unwrap_or_else(|| "-".into()),
        );
        measured.push((*rpm, now.fan1_rpm, now.fan2_rpm));
    }

    // Always, including after an early stop: leaving somebody's fans pinned
    // at a measured setpoint is the one outcome this must not have.
    client::send(&Request::SetMode(before))?;
    println!("\nfan back to {before}");

    let real: Vec<u32> = measured
        .iter()
        .filter_map(|(_, a, b)| match (a, b) {
            (Some(a), Some(b)) => Some((*a).max(*b)),
            (Some(v), None) | (None, Some(v)) => Some(*v),
            _ => None,
        })
        .collect();

    let (Some(low), Some(high)) = (real.iter().min(), real.iter().max()) else {
        println!("nothing was measured - the tachometers read nothing at all");
        return Ok(());
    };

    println!("\nmeasured range: {low}-{high} RPM");
    let cfg = Config::load(&Config::default_path()).unwrap_or_default();
    // A tolerance rather than an exact match: the tachometer is noisy and the
    // fan does not hold a setpoint to the RPM.
    const TOLERANCE: u32 = 300;
    if high + TOLERANCE < cfg.fan.max_rpm {
        println!(
            "\n  The fans never reached the configured maximum ({} RPM). The top of any\n               curve above about {high} RPM is doing nothing on this machine. In\n               /etc/omen/omend.toml:\n\n      [fan]\n      max_rpm = {high}",
            cfg.fan.max_rpm
        );
    } else if *low > cfg.fan.min_rpm + TOLERANCE {
        println!(
            "\n  The fans never went below {low} RPM, but the configuration says they can\n               reach {}. A curve asking for less than {low} will be quietly clamped.",
            cfg.fan.min_rpm
        );
    } else {
        println!(
            "  That matches the configured {}-{} RPM range.",
            cfg.fan.min_rpm, cfg.fan.max_rpm
        );
    }
    Ok(())
}

/// The battery's charge, and the limit if this machine has one.
///
/// It reads sysfs directly for the report and goes through the daemon to
/// change anything, like everything else here: the threshold file is
/// root-owned, and the daemon is also what puts the limit back after a
/// suspend.
fn battery(args: &[String]) -> Result<()> {
    use omen_core::battery::Battery;

    let Some(bat) = Battery::discover() else {
        bail!("no battery was found - is this a desktop?");
    };

    let Some(arg) = args.get(1).map(String::as_str) else {
        field(
            "charge",
            match omen_core::power::battery_percent() {
                Some(p) => format!("{p}%"),
                None => "unknown".into(),
            },
        );
        field(
            "on",
            match omen_core::power::on_ac() {
                Some(true) => "mains",
                Some(false) => "battery",
                None => "unknown",
            },
        );
        match (bat.supports_limit(), bat.limit()) {
            (true, Some(100)) | (true, None) => field("charge limit", "off (charges to full)"),
            (true, Some(p)) => field("charge limit", format!("charging stops at {p}%")),
            (false, _) => {
                field("charge limit", "not available");
                println!("\n  {}", bat.unsupported_reason());
            }
        }
        return Ok(());
    };

    let percent = match arg {
        "off" | "none" | "full" | "100" => None,
        other => Some(
            other
                .trim_end_matches('%')
                .parse::<u8>()
                .map_err(|_| anyhow::anyhow!("{other:?} is not a percentage, or 'off'"))?,
        ),
    };
    client::report(client::send(&Request::SetChargeLimit { percent })?)
}

/// Rules that follow the machine's own state.
///
/// The same edit-the-file-not-the-snapshot rule as the application profiles,
/// and for the same reason: a read-modify-write against a snapshot taken just
/// after a previous edit resurrects what was removed.
fn triggers(args: &[String]) -> Result<()> {
    use omen_core::triggers::{Kind, Trigger};

    let snap = app_snapshot()?;
    let mut list = match args.get(1).map(String::as_str) {
        Some("add") | Some("remove") => {
            let path = snap
                .config_path
                .as_deref()
                .map(std::path::PathBuf::from)
                .unwrap_or_else(Config::default_path);
            Config::load(&path)
                .map(|c| c.triggers)
                .unwrap_or_else(|_| snap.triggers.clone())
        }
        _ => snap.triggers.clone(),
    };

    // Spelled with a hyphen on the command line and an underscore in the
    // file. Both are accepted here; nobody should have to remember which.
    let parse_kind = |raw: &str| -> Result<Kind> {
        Ok(match raw.replace('-', "_").as_str() {
            "temp_above" | "hot" => Kind::TempAbove,
            "battery_below" | "battery" => Kind::BatteryBelow,
            "idle" => Kind::Idle,
            "lid_closed" | "lid" => Kind::LidClosed,
            "time_between" | "time" => Kind::TimeBetween,
            "wifi_ssid" | "wifi" | "ssid" => Kind::WifiSsid,
            other => bail!(
                "unknown trigger: {other}                  (temp-above / battery-below / idle / lid-closed)"
            ),
        })
    };

    match args.get(1).map(String::as_str) {
        None | Some("list") => {
            if list.is_empty() {
                println!("no triggers");
                println!("  add one with: omenctl trigger add temp-above 88 performance");
                return Ok(());
            }
            println!("triggers  (first matching entry wins; an app profile beats all of them)\n");
            for t in &list {
                let active = snap.active_trigger.as_deref() == Some(t.name().as_str());
                println!(
                    "  {}{:<24} {}",
                    if active { "* " } else { "  " },
                    t.condition(),
                    t.summary()
                );
            }
            println!();
            field("idle for", format!("{} min", snap.idle_secs / 60));
            if let Some(active) = &snap.active_trigger {
                println!("  in force: {active}");
            }
            Ok(())
        }

        Some("add") => {
            let raw = args.get(2).ok_or_else(|| {
                anyhow::anyhow!("which condition? (temp-above / battery-below / idle / lid-closed)")
            })?;
            let when = parse_kind(raw)?;

            let mut entry = Trigger {
                when,
                value: None,
                profile: None,
                fan: None,
                curve: None,
                from: None,
                to: None,
                ssid: None,
            };

            // The two that carry their own arguments take them first, in the
            // order anyone would say them out loud.
            let mut rest = &args[3..];
            match when {
                Kind::TimeBetween => {
                    let (Some(from), Some(to)) = (rest.first(), rest.get(1)) else {
                        bail!("time-between needs two times, e.g. 23:00 07:00");
                    };
                    entry.from = Some(from.clone());
                    entry.to = Some(to.clone());
                    rest = &rest[2..];
                }
                Kind::WifiSsid => {
                    let Some(ssid) = rest.first() else {
                        bail!("wifi-ssid needs a network name");
                    };
                    entry.ssid = Some(ssid.clone());
                    rest = &rest[1..];
                }
                _ => {}
            }

            // The value comes first when the condition takes one, and a
            // number in any other position is a fan setpoint - same
            // shape-based parsing as everywhere else here.
            if when.unit().is_some() {
                let raw = rest.first().ok_or_else(|| {
                    anyhow::anyhow!("{when} needs a value in {}", when.unit().unwrap_or(""))
                })?;
                entry.value = Some(
                    raw.trim_end_matches(['C', 'c', '%'])
                        .parse::<f32>()
                        .map_err(|_| anyhow::anyhow!("{raw:?} is not a number"))?,
                );
                rest = &rest[1..];
            }

            for arg in rest {
                if let Some(name) = parse_curve_arg(arg)? {
                    entry.curve = Some(name);
                    entry.fan = Some(ControlMode::Curve);
                    continue;
                }
                match parse_fan(arg) {
                    Ok(mode) => entry.fan = Some(mode),
                    Err(_) => entry.profile = Some(arg.clone()),
                }
            }

            entry.check().map_err(|e| anyhow::anyhow!("{e}"))?;

            // One entry per condition: two rules watching the same thing can
            // only disagree, and the second would never fire.
            list.retain(|t| t.when != when);
            list.push(entry);
            client::report(client::send(&Request::SetTriggers { triggers: list })?)
        }

        Some("remove") => {
            let raw = args
                .get(2)
                .ok_or_else(|| anyhow::anyhow!("which condition?"))?;
            let when = parse_kind(raw)?;
            let before = list.len();
            list.retain(|t| t.when != when);
            if list.len() == before {
                bail!("no {when} trigger is configured");
            }
            client::report(client::send(&Request::SetTriggers { triggers: list })?)
        }

        Some(other) => bail!("unknown subcommand: {other} (list / add / remove)"),
    }
}

fn power_rules(args: &[String]) -> Result<()> {
    use omen_core::power::PowerRule;

    let snap = app_snapshot()?;
    let mut on_ac = snap.power_ac.clone();
    let mut on_battery = snap.power_battery.clone();

    let Some(which) = args.get(1).map(String::as_str) else {
        let now = match snap.on_ac {
            Some(true) => "on mains",
            Some(false) => "on battery",
            None => "power source unknown",
        };
        println!("currently {now}\n");
        field("on mains", on_ac.summary());
        field("on battery", on_battery.summary());
        if on_ac.is_empty() && on_battery.is_empty() {
            println!("\n  Nothing is applied automatically. Set a rule with:");
            println!("    omenctl power battery low-power");
        }
        return Ok(());
    };

    let target = match which {
        "ac" | "mains" => &mut on_ac,
        "battery" | "bat" => &mut on_battery,
        other => bail!("unknown power source: {other} (ac / battery)"),
    };

    let first = args
        .get(2)
        .ok_or_else(|| anyhow::anyhow!("a profile is required, or 'none' to clear the rule"))?;

    if first == "none" {
        *target = PowerRule::default();
    } else {
        // Same shape-based parsing as the application profiles: a fan mode is
        // a number or one of three words, everything else is a profile.
        *target = PowerRule::default();
        for arg in &args[2..] {
            if let Some(name) = parse_curve_arg(arg)? {
                target.curve = Some(name);
                target.fan = Some(ControlMode::Curve);
                continue;
            }
            match parse_fan(arg) {
                Ok(mode) => target.fan = Some(mode),
                Err(_) => target.profile = Some(arg.clone()),
            }
        }
    }

    client::report(client::send(&Request::SetPowerRules { on_ac, on_battery })?)
}

fn gpu_power(args: &[String]) -> Result<()> {
    if args.get(1).map(String::as_str) == Some("boost") {
        let Some(arg) = args.get(2) else {
            let snap = app_snapshot()?;
            let Some(b) = snap.gpu_boost else {
                bail!(
                    "cTGP and Dynamic Boost are not reported here. They need omen-kbd-rgb \
                     0.2.0 or newer and an NVIDIA GPU."
                );
            };
            let on = |v: bool| if v { "on" } else { "off" };
            field("cTGP", on(b.ctgp));
            field("Dynamic Boost", on(b.ppab));
            field(
                "follows",
                if b.follows_profile {
                    "the profile (performance: both on, balanced: Dynamic Boost, low-power: neither)"
                } else {
                    "nothing - left to the firmware"
                },
            );
            if b.ppab && !omen_core::diagnose::nvidia_powerd_active() {
                println!();
                println!("  Dynamic Boost is on, but nvidia-powerd is not running - the driver");
                println!("  side of it. Start it: sudo systemctl enable --now nvidia-powerd");
            }
            return Ok(());
        };
        let want = omen_core::gpu::Boost::parse(arg)
            .ok_or_else(|| anyhow::anyhow!("unknown setting: {arg} (profile / leave)"))?;
        return client::report(client::send(&Request::SetGpuBoost(want))?);
    }
    if args.get(1).map(String::as_str) == Some("mux") {
        let snap = app_snapshot()?;
        let Some(mux) = snap.mux.clone() else {
            bail!(
                "no graphics mux was found. Either this machine has none, or \
                 omen-kbd-rgb is not loaded - it is the thing that asks the firmware."
            );
        };
        let Some(mode) = args.get(2) else {
            field("current", mux.current.clone().unwrap_or_else(|| "?".into()));
            if mux.pending_reboot == Some(true) {
                field("pending", "yes - a reboot applies it");
            }
            field("supported", mux.supported.join(" "));
            println!("\n  Switching takes effect at the next boot: the firmware re-wires");
            println!("  the panel during POST, nothing changes while the machine is up.");
            println!();
            println!("  Know the way back before switching to discrete. The panel is then");
            println!("  driven by the NVIDIA GPU, and if that does not come up you need a");
            println!("  working machine to undo it: a text console (Ctrl+Alt+F3) or ssh is");
            println!("  enough, since 'omenctl gpu mux hybrid' does not need a desktop.");
            return Ok(());
        };
        return client::report(client::send(&Request::SetGpuMux { mode: mode.clone() })?);
    }

    match args.get(1) {
        None => {
            let mut gpu = app_snapshot().ok().and_then(|s| s.gpu.clone());
            if let Some(gpu) = gpu.as_mut() {
                omen_core::gpu::merge_local_holders(gpu);
            }
            print_gpu(gpu);
            println!();
            println!("  In hybrid, a program runs on the integrated GPU unless it asks for");
            println!("  the other one. To make one ask - in Steam, before %command%:");
            println!();
            println!("    {}", omen_core::gpu::OFFLOAD_ENV);
            println!();
            println!("  And to stop one reaching the discrete GPU at all, which is how a");
            println!("  program that merely enumerates devices ends up keeping it awake:");
            println!();
            println!("    {}", omen_core::gpu::igpu_env());
            Ok(())
        }
        Some(arg) => {
            let want = omen_core::gpu::DgpuPower::parse(arg)
                .ok_or_else(|| anyhow::anyhow!("unknown setting: {arg} (auto / on)"))?;
            client::report(client::send(&Request::SetDgpuPower(want))?)
        }
    }
}

fn field(name: &str, value: impl std::fmt::Display) {
    println!("  {name:<16} {value}");
}

/// Discrete GPU runtime power management.
///
/// The interesting number is `suspended` - if the GPU is allowed to suspend
/// and never has, something is holding it open, and that something costs
/// battery for as long as it runs.
fn print_gpu(from_daemon: Option<omen_core::gpu::GpuPower>) {
    // Prefer the daemon's view: it runs as root and therefore sees every
    // process, where we only see our own.
    let via_daemon = from_daemon.is_some();
    let Some(gpu) = from_daemon.or_else(omen_core::gpu::discover) else {
        return;
    };

    println!("\ndiscrete GPU");
    field("pci", &gpu.address);
    field(
        "runtime pm",
        match gpu.control.as_str() {
            "auto" => "auto  (may suspend)".to_string(),
            "on" => "on  (pinned awake)".to_string(),
            other => other.to_string(),
        },
    );
    field("state", &gpu.status);
    field(
        "suspended",
        if gpu.suspended_ms == 0 {
            "never".to_string()
        } else {
            format!("{:.1} min total", gpu.suspended_ms as f64 / 60_000.0)
        },
    );
    if let Some(dpm) = omen_core::gpu::dynamic_power_management() {
        field("nvidia dpm", &dpm);
    }

    // Listed whenever there are any, not only when the GPU has never slept.
    // "What is using it right now" is the question someone asks when the
    // battery is going, and it has an answer either way.
    if !gpu.holders.is_empty() {
        println!("  held open by");
        for h in &gpu.holders {
            println!("    {:<18} pid {:<7} {}", h.name, h.pid, h.nodes.join(" "));
        }
    } else if gpu.awake_despite_pm() && !via_daemon {
        println!("  (run as root, or with omend running, to see what holds it open)");
    }

    if gpu.awake_despite_pm() {
        println!("  ! the GPU is allowed to suspend but never has");
    }
}

fn status() -> Result<()> {
    let mut daemon_temps: Option<Vec<(String, f32)>> = None;
    let mut daemon_gpu: Option<omen_core::gpu::GpuPower> = None;

    // When the daemon is running its view is richer: drive mode, whether the
    // critical cutout has tripped, the target setpoint. Otherwise we fall
    // back to reading sysfs.
    if let Ok(Response::Ok(snap)) = client::send(&Request::Status) {
        daemon_temps = Some(snap.temps.clone());
        daemon_gpu = snap.gpu.clone();
        println!("omend");
        // No mode at all means there is no fan setpoint on this machine.
        // Printing an empty field there reads as a bug; saying so does not.
        field(
            "mode",
            snap.mode
                .map(|m| m.to_string())
                .unwrap_or_else(|| "no fan control on this machine".into()),
        );
        if snap.safety_fallback {
            println!("  ! the critical cutout has tripped - control is with the EC");
        }
        if let (Some(l), Some(c)) = (&snap.driver_label, snap.driver_temp_c) {
            field("driving sensor", format!("{l} {c:.1} C"));
        }
        // target_rpm is only set when there is a fixed setpoint. It being
        // empty does NOT mean "automatic" - it is empty in max mode too, and
        // there the fans are at full power. The mode has to be read with it.
        // A dust run drives the fans regardless of the mode, so it has to be
        // said before the mode is: otherwise the mode reads "curve" while the
        // fans are at full power for reasons the curve knows nothing about.
        if let Some(left) = snap.cleaning_secs_left {
            field(
                "target",
                format!("full power - clearing dust, {left}s left"),
            );
        } else {
            match (snap.mode, snap.target_rpm) {
                // Zero is a setpoint we are holding, not an absent one - see the
                // bottom of the curve.
                (_, Some(0)) => field("target", "fans off (idle, setpoint ours)"),
                (_, Some(rpm)) => field("target", format!("{rpm} RPM")),
                (Some(ControlMode::Max), None) => field("target", "full power"),
                // A machine with no setpoint is not "control is with the EC":
                // there is no control to hand over in the first place.
                (None, None) => field("target", "nothing to drive - see 'omenctl caps'"),
                (_, None) => field("target", "control is with the EC"),
            }
        }
        field("uptime", format!("{} s", snap.uptime_secs));
        // What the hardware refused, most recent last - the same list the
        // window turns into notifications.
        for p in snap.problems.iter().rev().take(3).rev() {
            let ago = snap.uptime_secs.saturating_sub(p.at_secs);
            field("refused", format!("{} ({ago} s ago)", p.what));
        }
        println!();
    }

    println!("hardware");
    let board = sysfs::read_string(std::path::Path::new("/sys/class/dmi/id/board_name"))
        .unwrap_or_else(|_| "?".into());
    field(
        "board",
        format!(
            "{board}{}",
            if board == "8D24" {
                ""
            } else {
                "  (expected: 8D24)"
            }
        ),
    );
    field(
        "kernel",
        sysfs::read_string(std::path::Path::new("/proc/sys/kernel/osrelease"))
            .unwrap_or_else(|_| "?".into()),
    );

    print_gpu(daemon_gpu);

    println!("\nplatform profile");
    match PlatformProfile::discover() {
        Some(pp) => {
            field("active", pp.get().unwrap_or_else(|_| "?".into()));
            field("choices", pp.choices().join(" "));
            for h in PlatformProfile::handlers() {
                field("handler", format!("{} -> {}", h.name, h.profile));
            }
            if !PlatformProfile::hp_wmi_active() {
                println!("  ! hp-wmi is not a handler - the 8D24 patch may be missing");
            }
        }
        None => println!("  no platform_profile"),
    }

    println!("\nfan");
    match Fan::discover(
        omen_core::fan::DEFAULT_MIN_RPM,
        omen_core::fan::DEFAULT_MAX_RPM,
    ) {
        Ok(fan) => {
            field("hwmon", fan.hwmon_path().display());
            // Named apart from the daemon's own "mode" above: one is what
            // omend intends, the other is what the hardware reports, and
            // printing both as "mode" made them look like a repetition
            // rather than a cross-check.
            field(
                "pwm1_enable",
                fan.mode()
                    .map(|m| m.to_string())
                    .unwrap_or_else(|e| format!("? ({e})")),
            );
            for i in 1..=2u8 {
                if let Ok(rpm) = fan.rpm(i) {
                    field(
                        &format!("fan{i}"),
                        if rpm == 0 {
                            "0 RPM  (stopped)".to_string()
                        } else {
                            format!("{rpm} RPM")
                        },
                    );
                }
            }
            if let Ok(pwm) = fan.pwm() {
                field("pwm1", format!("{pwm}/255  (~{} RPM)", fan.pwm_to_rpm(pwm)));
            }
        }
        Err(e) => println!("  {e}"),
    }

    println!("\ntemperatures");
    // The daemon's list when it is reachable, ours otherwise.
    //
    // These differ, and the daemon's is the one that matters: it runs as root
    // and can read the EC, where the discrete GPU lives. Showing our own list
    // would quietly omit the sensor the curve is most likely to be driven by
    // under load, and give the impression it is not being watched.
    match daemon_temps {
        Some(temps) if !temps.is_empty() => {
            for (label, c) in &temps {
                field(label, format!("{c:.1} C"));
            }
        }
        _ => match Thermal::discover() {
            Ok(t) => {
                for (label, value) in t.read_all() {
                    match value {
                        Ok(c) => field(&label, format!("{c:.1} C")),
                        Err(e) => field(&label, format!("unreadable ({e})")),
                    }
                }
                println!(
                    "  (omend not reachable; the EC sensors it reads as root are missing here)"
                );
                if let Ok((label, c)) = t.hottest() {
                    println!("  -> driving the curve: {label} {c:.1} C");
                }
            }
            Err(e) => println!("  {e}"),
        },
    }

    Ok(())
}

/// `45:0,50:1800,70:2400` -> points.
///
/// Whitespace around the separators is allowed because the obvious way to
/// type this is with spaces after the commas, and rejecting that would be
/// pedantry.
fn parse_points(spec: &str) -> Result<Vec<omen_core::curve::Point>> {
    let mut points = Vec::new();
    for field in spec.split(',').map(str::trim).filter(|f| !f.is_empty()) {
        let (temp, rpm) = field
            .split_once(':')
            .ok_or_else(|| anyhow::anyhow!("{field:?} is not a temperature:RPM pair"))?;
        points.push(omen_core::curve::Point {
            temp_c: temp
                .trim()
                .parse()
                .map_err(|_| anyhow::anyhow!("{temp:?} is not a temperature"))?,
            rpm: rpm
                .trim()
                .parse()
                .map_err(|_| anyhow::anyhow!("{rpm:?} is not an RPM value"))?,
        });
    }
    if points.len() < 2 {
        bail!("a curve needs at least two points");
    }
    Ok(points)
}

fn set_curve(args: &[String]) -> Result<()> {
    let spec = args
        .get(2)
        .ok_or_else(|| anyhow::anyhow!("expected points, e.g. 45:0,50:1800,70:2400,90:3300"))?;
    let points = parse_points(spec)?;

    // Rejected here as well as in the daemon, so a typo gives an error that
    // names the problem rather than a socket round-trip that does.
    omen_core::curve::Curve::new(points.clone())?;

    client::report(client::send(&Request::SetCurve(CurveSpec {
        points,
        interpolation: Default::default(),
    }))?)
}

fn curve(args: &[String]) -> Result<()> {
    match args.get(1).map(String::as_str) {
        Some("set") => return set_curve(args),
        Some("reset") => return client::report(client::send(&Request::ResetCurve)?),
        Some("code") => {
            // From the daemon when it is running, so what you share is what
            // is actually in force - including a preset a game profile swapped
            // in. Falling back to the file keeps it useful without a daemon.
            let curve = match client::send(&Request::Status) {
                Ok(Response::Ok(snap)) => snap.curve.and_then(|c| {
                    omen_core::curve::Curve::with_interpolation(c.points, c.interpolation).ok()
                }),
                _ => None,
            };
            let curve = match curve {
                Some(c) => c,
                None => Config::load(&Config::default_path())?.curve()?,
            };
            println!("{}", omen_core::curve::code::encode(&curve));
            return Ok(());
        }
        Some("import") => {
            let text = args
                .get(2)
                .ok_or_else(|| anyhow::anyhow!("paste a code: omenctl curve import omen1:..."))?;
            let curve = omen_core::curve::code::decode(text)?;
            // Shown before it is applied. A code is opaque enough that
            // somebody should see what it does to their fans.
            println!("importing:");
            for p in curve.points() {
                println!(
                    "  {:>5.0} C  {}",
                    p.temp_c,
                    if p.rpm == 0 {
                        "fans off".to_string()
                    } else {
                        format!("{} RPM", p.rpm)
                    }
                );
            }
            return client::report(client::send(&Request::SetCurve(CurveSpec {
                points: curve.points().to_vec(),
                interpolation: curve.interpolation(),
            }))?);
        }
        Some("preset") => {
            let Some(name) = args.get(2) else {
                println!("presets:\n");
                for (name, what) in omen_core::curve::PRESETS {
                    println!("  {name:<12} {what}");
                }
                return Ok(());
            };
            let curve = omen_core::curve::preset(name).ok_or_else(|| {
                anyhow::anyhow!(
                    "unknown preset: {name} ({})",
                    omen_core::curve::PRESETS
                        .iter()
                        .map(|(n, _)| *n)
                        .collect::<Vec<_>>()
                        .join(" / ")
                )
            })?;
            return client::report(client::send(&Request::SetCurve(CurveSpec {
                points: curve.points().to_vec(),
                interpolation: curve.interpolation(),
            }))?);
        }
        _ => {}
    }

    let path = match args.iter().position(|a| a == "-c" || a == "--config") {
        Some(i) => args
            .get(i + 1)
            .map(std::path::PathBuf::from)
            .ok_or_else(|| anyhow::anyhow!("--config expects a path"))?,
        None => Config::default_path(),
    };

    let cfg = Config::load(&path)?;
    let curve = cfg.curve()?;

    if path.exists() {
        println!("source: {}", path.display());
    } else {
        println!(
            "source: built-in default ({} does not exist)",
            path.display()
        );
    }
    println!("\n  {:>11}  target", "temperature");
    for p in curve.points() {
        let target = if p.rpm == 0 {
            "fans off (idle)".to_string()
        } else {
            format!("{} RPM", p.rpm)
        };
        println!("  {:>9.0} C  {target}", p.temp_c);
    }
    println!(
        "\n  hysteresis {:.1} C, minimum dwell {} s, sampling every {} s",
        cfg.fan.hysteresis_c, cfg.fan.min_dwell_secs, cfg.fan.interval_secs
    );
    println!(
        "  critical cutout {:.0} C, the curve re-engages below {:.0} C",
        cfg.safety.critical_c,
        cfg.safety.critical_c - cfg.safety.recover_delta_c
    );
    Ok(())
}
