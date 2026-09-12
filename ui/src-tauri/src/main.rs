//! OMEN Control - the desktop front end.
//!
//! Two paths on purpose, for two different risk profiles:
//!
//!   fan / profile  -> omend over the unix socket. Fan writes have to be
//!                     arbitrated in one place: clamping, the critical cutout
//!                     and restore-on-exit are guaranteed there and nowhere
//!                     else.
//!   RGB            -> the LED class directly. A wrong colour is a wrong
//!                     colour; the udev rule
//!                     (packaging/99-omen-leds.rules) is the idiomatic Linux
//!                     answer and keeps the LEDs usable from other tools.
//!
//! The UI never touches WMI or the EC.

#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod fwupd;
mod settings;
mod single;
mod sysinfo;

use std::sync::atomic::{AtomicBool, Ordering};

use serde::{Deserialize, Serialize};
use tauri::{
    menu::{Menu, MenuItem, PredefinedMenuItem},
    tray::{MouseButton, MouseButtonState, TrayIconBuilder, TrayIconEvent},
    Emitter, Manager, WindowEvent,
};

use omen_core::ipc::{client, ControlMode, Request, Response, Snapshot};
use omen_core::leds::{LedState, Leds, Rgb};

/// Whether the tray icon actually came up.
///
/// Closing to the tray is only safe if there is a tray to close to. Without
/// libappindicator the icon never appears, and hiding the window then would
/// leave the user with a running process and no way back to it.
static HAS_TRAY: AtomicBool = AtomicBool::new(false);

/// Everything the UI needs for one refresh, in a single round trip.
#[derive(Debug, Serialize)]
struct UiState {
    /// `None` when the daemon is not reachable.
    daemon: Option<Snapshot>,
    /// Why the daemon is unreachable, so the UI can say something useful
    /// instead of just "disconnected".
    daemon_error: Option<String>,
    /// A plain-language next step for the common causes. The raw error says
    /// "Permission denied", which does not tell anyone that the fix is a new
    /// login session.
    daemon_hint: Option<String>,
    leds: Option<LedState>,
    leds_error: Option<String>,
    /// False when the LED files are read-only for us: the udev rule is not
    /// installed, or the 'omen' group membership needs a new login.
    leds_writable: bool,
    profile_choices: Vec<String>,
    /// The active curve, so the UI can draw it. Read from the config file
    /// rather than asked of the daemon: the daemon's snapshot carries what it
    /// is doing now, not the table behind it, and the file is world-readable.
    curve: Vec<CurvePoint>,
    /// Whether a tray icon came up. "Start hidden" is only offered when
    /// there is somewhere to hide.
    has_tray: bool,
    /// Whether HP's BIOS-settings driver is present, so the battery card can
    /// say - in the window's language - that the setting is not published
    /// through it either. Without this the card would have to repeat the
    /// daemon's English sentence into a Turkish page.
    bioscfg_present: bool,
    /// "step" or "linear" - the chart has to be drawn the way the curve is
    /// actually read, or it would show a ramp where the daemon holds a value.
    interpolation: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct CurvePoint {
    temp_c: f32,
    rpm: u32,
}

fn snapshot() -> (Option<Snapshot>, Option<String>, Option<String>) {
    match client::send(&Request::Status) {
        Ok(Response::Ok(s)) => (Some(*s), None, None),
        Ok(Response::Error { message }) | Ok(Response::Done { message }) => {
            (None, Some(message), None)
        }
        Ok(Response::History { .. }) | Ok(Response::Samples { .. }) => {
            (None, Some("unexpected reply".into()), None)
        }
        Err(e) => {
            let hint = daemon_hint(&e);
            (None, Some(e.to_string()), hint)
        }
    }
}

/// Where this process stands with respect to the 'omen' group.
///
/// "Are you a member" and "did this process get the group" are different
/// questions, and confusing them costs real time: a `usermod -aG` only takes
/// effect for sessions started afterwards, so a window launched from an older
/// session is denied even though the user is plainly a member.
#[derive(Debug, PartialEq)]
enum GroupState {
    /// The group does not exist - the sysusers file was never installed.
    Missing,
    /// The group exists but the user is not in it.
    NotMember,
    /// The user is a member, but this process did not inherit it.
    MemberNotEffective,
    Effective,
}

fn omen_gid() -> Option<u32> {
    let content = std::fs::read_to_string("/etc/group").ok()?;
    content.lines().find_map(|line| {
        let mut f = line.split(':');
        (f.next()? == "omen").then(|| f.nth(1)?.parse().ok())?
    })
}

/// The login name for our real uid.
///
/// Deliberately not $USER: that is not guaranteed to be set - a desktop
/// launcher may start us without it - and an empty value would make the
/// membership check say "you are not a member" with confidence. The uid is
/// always there.
fn current_user() -> Option<String> {
    let status = std::fs::read_to_string("/proc/self/status").ok()?;
    let uid: u32 = status
        .lines()
        .find_map(|l| l.strip_prefix("Uid:"))?
        .split_whitespace()
        .next()?
        .parse()
        .ok()?;

    let passwd = std::fs::read_to_string("/etc/passwd").ok()?;
    passwd.lines().find_map(|line| {
        let mut f = line.split(':');
        let name = f.next()?;
        (f.nth(1)? == uid.to_string()).then(|| name.to_owned())
    })
}

fn user_is_member() -> bool {
    let Some(user) = current_user() else {
        return false;
    };
    let Ok(content) = std::fs::read_to_string("/etc/group") else {
        return false;
    };
    content.lines().any(|line| {
        let mut f = line.split(':');
        f.next() == Some("omen")
            && f.nth(2)
                .is_some_and(|m| m.split(',').any(|n| !n.is_empty() && n == user))
    })
}

/// Reads this process's own credentials from /proc rather than pulling in
/// libc for getgroups(). `Gid` covers the primary group - which is what
/// `newgrp` sets - and `Groups` the supplementary list; a process can hold
/// the group through either, so both have to be checked.
fn process_has_gid(gid: u32) -> bool {
    let Ok(status) = std::fs::read_to_string("/proc/self/status") else {
        return false;
    };
    status.lines().any(
        |line| match line.strip_prefix("Groups:").or(line.strip_prefix("Gid:")) {
            Some(rest) => rest.split_whitespace().any(|g| g.parse() == Ok(gid)),
            None => false,
        },
    )
}

fn group_state() -> GroupState {
    let Some(gid) = omen_gid() else {
        return GroupState::Missing;
    };
    if process_has_gid(gid) {
        GroupState::Effective
    } else if user_is_member() {
        GroupState::MemberNotEffective
    } else {
        GroupState::NotMember
    }
}

/// Turns a connection failure into a next step. "Permission denied" on its
/// own does not tell anyone what to do about it.
fn daemon_hint(e: &client::ClientError) -> Option<String> {
    use std::io::ErrorKind;

    let client::ClientError::Connect { source, .. } = e else {
        return None;
    };

    let text = match source.kind() {
        ErrorKind::PermissionDenied => match group_state() {
            GroupState::Missing => concat!(
                "The 'omen' group does not exist. Install the sysusers file ",
                "(<code>packaging/omen-sysusers.conf</code>) and run ",
                "<code>sudo systemd-sysusers</code>."
            ),
            GroupState::NotMember => concat!(
                "You are not in the 'omen' group. Run ",
                "<code>sudo usermod -aG omen $USER</code>, then log out and back in."
            ),
            GroupState::MemberNotEffective => concat!(
                "You are a member of the 'omen' group, but <strong>this window did not ",
                "inherit it</strong> - it was started from a session that began before the ",
                "membership was granted. Log out and back in, or launch it from a fresh ",
                "session."
            ),
            // Denied while we do hold the group: the socket's own permissions
            // are the problem, not ours.
            GroupState::Effective => concat!(
                "This process does hold the 'omen' group, so the socket's permissions are ",
                "the problem. Check <code>ls -l /run/omend/omend.sock</code> - it should be ",
                "<code>root:omen</code>, mode 0660."
            ),
        },
        ErrorKind::NotFound | ErrorKind::ConnectionRefused => concat!(
            "The service does not appear to be running. Start it with ",
            "<code>sudo systemctl enable --now omend</code>."
        ),
        _ => return None,
    };
    Some(text.to_owned())
}

#[tauri::command]
fn get_state() -> UiState {
    let (daemon, daemon_error, daemon_hint) = snapshot();

    // The daemon reports the curve it is actually running; the file is the
    // fallback for when it is not up. Preferring the daemon matters after an
    // edit: the file is written first and re-read a moment later, and during
    // that moment only the daemon knows which of the two is in force.
    //
    // A broken config file must not blank the whole panel, so a failure here
    // just means no chart.
    let curve = daemon
        .as_ref()
        .and_then(|d| d.curve.as_ref())
        .and_then(|spec| {
            omen_core::curve::Curve::with_interpolation(spec.points.clone(), spec.interpolation)
                .ok()
        })
        .or_else(|| {
            omen_core::config::Config::load(&omen_core::config::Config::default_path())
                .ok()
                .and_then(|c| c.curve().ok())
        });

    // The daemon reports the GPU, but not usefully who is holding it awake:
    // it runs with an empty capability set, and reading another user's
    // /proc/<pid>/fd needs one. This process is the user, so it can see the
    // user's own programs - which are exactly the ones keeping a laptop GPU
    // busy. The daemon's list is kept when it has one (a root process could
    // be the culprit) and this one is merged in.
    let mut daemon = daemon;
    if let Some(gpu) = daemon.as_mut().and_then(|s| s.gpu.as_mut()) {
        omen_core::gpu::merge_local_holders(gpu);
    }

    let (leds, leds_error, leds_writable) = match Leds::discover() {
        Ok(l) => (Some(l.state()), None, l.writable()),
        Err(e) => (None, Some(e.to_string()), false),
    };

    UiState {
        daemon,
        daemon_error,
        daemon_hint,
        leds,
        leds_error,
        leds_writable,
        profile_choices: omen_core::profile::PlatformProfile::discover()
            .map(|p| p.choices())
            .unwrap_or_default(),
        curve: curve
            .as_ref()
            .map(|c| {
                c.points()
                    .iter()
                    .map(|p| CurvePoint {
                        temp_c: p.temp_c,
                        rpm: p.rpm,
                    })
                    .collect()
            })
            .unwrap_or_default(),
        has_tray: HAS_TRAY.load(Ordering::Relaxed),
        bioscfg_present: omen_core::battery::bioscfg_present(),
        interpolation: match curve.as_ref().map(|c| c.interpolation()) {
            Some(omen_core::curve::Interpolation::Linear) => "linear".into(),
            _ => "step".into(),
        },
    }
}

/// Turns a daemon reply into something the UI can show. `Done` carries the
/// mode that was ACTUALLY applied, which may differ from what was asked when
/// the critical cutout has tripped - so we pass the text through rather than
/// inventing our own.
fn talk(req: Request) -> Result<String, String> {
    match client::send(&req).map_err(|e| e.to_string())? {
        Response::Done { message } => Ok(message),
        Response::Error { message } => Err(message),
        Response::Ok(_) | Response::History { .. } | Response::Samples { .. } => Ok(String::new()),
    }
}

#[tauri::command]
fn set_mode(mode: ControlMode) -> Result<String, String> {
    talk(Request::SetMode(mode))
}

#[tauri::command]
fn set_profile(profile: String) -> Result<String, String> {
    talk(Request::SetProfile { profile })
}

#[tauri::command]
fn reload_config() -> Result<String, String> {
    talk(Request::Reload)
}

/// Saves a curve. The daemon validates it, writes the config file and re-reads
/// it - the UI never touches /etc itself, the same way it never touches the
/// fan itself.
#[tauri::command]
fn set_curve(points: Vec<CurvePoint>, interpolation: String) -> Result<String, String> {
    talk(Request::SetCurve(omen_core::ipc::CurveSpec {
        points: points
            .into_iter()
            .map(|p| omen_core::curve::Point {
                temp_c: p.temp_c,
                rpm: p.rpm,
            })
            .collect(),
        interpolation: if interpolation == "linear" {
            omen_core::curve::Interpolation::Linear
        } else {
            omen_core::curve::Interpolation::Step
        },
    }))
}

/// Keyboard effects belong to the daemon, not to this process: an effect has
/// to keep running when the window is closed.
#[tauri::command]
fn set_effect(effect: String, speed: u8, color: omen_core::leds::Rgb) -> Result<String, String> {
    let effect = omen_core::anim::Effect::parse(&effect)
        .ok_or_else(|| format!("unknown effect: {effect}"))?;
    talk(Request::SetEffect(omen_core::anim::EffectSpec {
        effect,
        speed,
        color,
    }))
}

/// The two lighting switches that are not the effect: whether the colours are
/// remembered across a reboot, and whether the backlight follows the power
/// source. Machine settings, so they go to the daemon.
#[tauri::command]
fn set_lighting_options(restore_on_start: bool, off_on_battery: bool) -> Result<String, String> {
    talk(Request::SetLightingOptions {
        restore_on_start,
        off_on_battery,
    })
}

/// A dust-clearing run. The daemon clamps the length; this is a button, and a
/// button that can leave the fans at full power indefinitely is a trap.
#[tauri::command]
fn clean_fans(seconds: u64) -> Result<String, String> {
    talk(Request::CleanFans { seconds })
}

/// One of the named curves. Sent as points rather than by name so the daemon
/// has one way in for a curve, and the editor can start from a preset and
/// change it without the two paths behaving differently.
#[tauri::command]
fn set_curve_preset(name: String) -> Result<String, String> {
    let curve = omen_core::curve::preset(&name).ok_or_else(|| format!("unknown preset: {name}"))?;
    talk(Request::SetCurve(omen_core::ipc::CurveSpec {
        points: curve.points().to_vec(),
        interpolation: curve.interpolation(),
    }))
}

/// Per-application profiles. The list is replaced wholesale rather than
/// patched, because its order is meaningful - the first running entry wins -
/// and an add/remove API would have to invent a way to express that anyway.
/// What fwupd can see, and what it has an update for. Never flashes anything
/// - see the note at the top of fwupd.rs.
#[tauri::command]
async fn firmware() -> fwupd::Firmware {
    // On a worker thread: the scan spawns fwupdmgr twice and the first call
    // after boot starts the fwupd daemon, which is seconds, not milliseconds.
    tauri::async_runtime::spawn_blocking(fwupd::scan)
        .await
        .unwrap_or_else(|e| fwupd::Firmware {
            available: false,
            error: Some(e.to_string()),
            ..Default::default()
        })
}

#[tauri::command]
async fn firmware_refresh() -> Result<String, String> {
    tauri::async_runtime::spawn_blocking(fwupd::refresh)
        .await
        .map_err(|e| e.to_string())?
}

/// Mains and battery rules, replaced as a pair - the daemon stores them that
/// way, and sending one at a time could leave the two halves out of step.
#[tauri::command]
fn set_power_rules(
    on_ac: omen_core::power::PowerRule,
    on_battery: omen_core::power::PowerRule,
) -> Result<String, String> {
    talk(Request::SetPowerRules { on_ac, on_battery })
}

/// A machine setting, not a window one: it changes what happens at the next
/// boot, for everyone.
#[tauri::command]
fn set_startup_profile(profile: Option<String>) -> Result<String, String> {
    talk(Request::SetStartupProfile { profile })
}

#[tauri::command]
fn get_settings() -> settings::Settings {
    settings::Settings::load()
}

#[tauri::command]
fn set_settings(settings: settings::Settings) -> Result<String, String> {
    settings.save()?;
    Ok("settings saved".into())
}

/// Versions of everything, and whether anything running is older than what is
/// installed. See omen_core::about for why that question is worth asking.
#[derive(Debug, Serialize)]
struct VersionInfo {
    app: String,
    daemon: Option<String>,
    daemon_reachable: bool,
    modules: Vec<omen_core::about::ModuleStatus>,
}

#[tauri::command]
fn versions() -> VersionInfo {
    let (daemon, reachable) = match client::send(&Request::Status) {
        Ok(Response::Ok(snap)) => (snap.version.clone(), true),
        Ok(_) => (None, true),
        Err(_) => (None, false),
    };
    VersionInfo {
        app: omen_core::about::VERSION.to_owned(),
        daemon,
        daemon_reachable: reachable,
        modules: omen_core::about::modules(),
    }
}

/// The whole installation, checked. Same checks the CLI runs - see
/// omen_core::diagnose for why they live there rather than here.
/// The recent setpoint decisions. Asked for only when the panel is open -
/// see ipc::Request::History.
#[tauri::command]
fn history(limit: usize) -> Vec<omen_core::ipc::Decision> {
    match client::send(&Request::History { limit }) {
        Ok(Response::History { decisions }) => decisions,
        _ => Vec::new(),
    }
}

/// The readings behind the graph, so a freshly opened window shows the last
/// half hour rather than starting from a blank chart and filling in from now.
#[tauri::command]
fn samples(limit: usize) -> Vec<omen_core::ipc::Sample> {
    match client::send(&Request::Samples { limit }) {
        Ok(Response::Samples { samples }) => samples,
        _ => Vec::new(),
    }
}

#[tauri::command]
fn set_triggers(triggers: Vec<omen_core::triggers::Trigger>) -> Result<String, String> {
    talk(Request::SetTriggers { triggers })
}

#[tauri::command]
fn set_charge_limit(percent: Option<u8>) -> Result<String, String> {
    talk(Request::SetChargeLimit { percent })
}

/// The running curve as one line of text, to hand to somebody else.
#[tauri::command]
fn curve_code() -> Result<String, String> {
    let curve = match client::send(&Request::Status) {
        Ok(Response::Ok(snap)) => snap.curve.and_then(|c| {
            omen_core::curve::Curve::with_interpolation(c.points, c.interpolation).ok()
        }),
        _ => None,
    };
    let curve = match curve {
        Some(c) => c,
        None => omen_core::config::Config::load(&omen_core::config::Config::default_path())
            .map_err(|e| e.to_string())?
            .curve()
            .map_err(|e| e.to_string())?,
    };
    Ok(omen_core::curve::code::encode(&curve))
}

/// Loads a curve somebody pasted in. Decoded here so an invalid code is
/// refused with its own message before anything is sent to the daemon.
#[tauri::command]
fn import_curve_code(code: String) -> Result<String, String> {
    let curve = omen_core::curve::code::decode(&code).map_err(|e| e.to_string())?;
    talk(Request::SetCurve(omen_core::ipc::CurveSpec {
        points: curve.points().to_vec(),
        interpolation: curve.interpolation(),
    }))
}

/// Writes the full diagnostic report and returns where it went.
///
/// Saved rather than copied: it is several hundred lines, and a clipboard
/// that size is awkward to paste anywhere useful. The path is returned so the
/// window can show it.
#[tauri::command]
async fn save_report() -> Result<String, String> {
    tauri::async_runtime::spawn_blocking(|| {
        let text = omen_core::bundle::report();
        let name = format!(
            "omen-report-{}.txt",
            std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .map(|d| d.as_secs())
                .unwrap_or_default()
        );
        // The user's own directory, because that is where they will look for
        // it and where the window can always write.
        let dir = std::env::var_os("HOME")
            .map(std::path::PathBuf::from)
            .unwrap_or_else(std::env::temp_dir);
        let path = dir.join(name);
        std::fs::write(&path, text)
            .map(|()| path.display().to_string())
            .map_err(|e| format!("could not write {}: {e}", path.display()))
    })
    .await
    .unwrap_or_else(|e| Err(e.to_string()))
}

/// The things this machine needs done as root, if any.
///
/// Only what is actually out of step - a list of what *could* be run as root
/// is a menu, and offering a menu of root commands is what this replaces.
#[derive(Debug, Serialize)]
struct PrivilegedAction {
    id: String,
    title: String,
    why: String,
    command: String,
}

#[tauri::command]
fn privileged_actions() -> Vec<PrivilegedAction> {
    omen_core::elevate::Action::all()
        .iter()
        .filter(|a| a.applicable())
        .map(|a| PrivilegedAction {
            id: a.as_str().to_owned(),
            title: a.title().to_owned(),
            why: a.why().to_owned(),
            command: a.command(),
        })
        .collect()
}

/// How a password will be asked for here, so the button can say so before it
/// is pressed.
#[tauri::command]
fn privileged_asker() -> String {
    omen_core::elevate::Asker::detect().describe().to_owned()
}

/// Runs one of them.
///
/// The window sends a NAME, never a command: what each name runs is written
/// in omen_core::elevate and nowhere else. An unknown name is refused rather
/// than interpreted - this is the one place in the app where being liberal in
/// what it accepts would hand somebody a root shell.
#[tauri::command]
async fn run_privileged(action: String) -> Result<String, String> {
    let Some(action) = omen_core::elevate::Action::parse(&action) else {
        return Err(format!("unknown action: {action}"));
    };
    // On a worker thread: pkexec puts up a dialog and waits for a person,
    // which is a very long time to block the UI thread for.
    tauri::async_runtime::spawn_blocking(move || omen_core::elevate::run(action))
        .await
        .unwrap_or_else(|e| Err(e.to_string()))
}

#[tauri::command]
async fn diagnose() -> omen_core::diagnose::Report {
    // On a worker thread: the checks talk to the daemon, walk /proc and shell
    // out to modinfo, which is milliseconds but not none, and the window
    // should stay live while they run.
    tauri::async_runtime::spawn_blocking(omen_core::diagnose::run)
        .await
        .unwrap_or_else(|_| omen_core::diagnose::Report { sections: vec![] })
}

/// The same report as text, for pasting into a bug report. Rendered from the
/// checks rather than assembled separately, so the page and the paste cannot
/// describe the machine differently.
#[tauri::command]
async fn diagnose_text() -> String {
    tauri::async_runtime::spawn_blocking(|| omen_core::diagnose::run().to_text())
        .await
        .unwrap_or_default()
}

/// CPU, memory, disks and the busiest processes - the parts of the Hub's
/// System Vitals page that are not thermal.
#[tauri::command]
fn system_info() -> sysinfo::SysInfo {
    sysinfo::read()
}

/// The two env prefixes: one to send a program to the discrete GPU, one to
/// keep it away from it. Computed rather than hard-coded - see
/// omen_core::gpu::igpu_env.
#[derive(Debug, Serialize)]
struct GpuEnv {
    offload: String,
    igpu: String,
}

#[tauri::command]
fn gpu_env() -> GpuEnv {
    GpuEnv {
        offload: omen_core::gpu::OFFLOAD_ENV.to_owned(),
        igpu: omen_core::gpu::igpu_env(),
    }
}

/// Which GPU drives the screen from the next boot. Goes through the daemon:
/// the attribute is root-owned, and a change that only shows up after a
/// reboot should be announced by the thing that knows that.
#[tauri::command]
fn set_gpu_mux(mode: String) -> Result<String, String> {
    talk(Request::SetGpuMux { mode })
}

/// Whether the discrete GPU may suspend when idle. Not a graphics switch -
/// this board has no mux.
#[tauri::command]
fn set_dgpu_power(power: String) -> Result<String, String> {
    let want = omen_core::gpu::DgpuPower::parse(&power)
        .ok_or_else(|| format!("unknown setting: {power}"))?;
    talk(Request::SetDgpuPower(want))
}

#[tauri::command]
fn set_app_profiles(apps: Vec<omen_core::apps::AppProfile>) -> Result<String, String> {
    talk(Request::SetAppProfiles { apps })
}

#[tauri::command]
fn reset_curve() -> Result<String, String> {
    talk(Request::ResetCurve)
}

#[tauri::command]
fn set_zone(index: usize, r: u8, g: u8, b: u8) -> Result<(), String> {
    Leds::discover()
        .map_err(|e| e.to_string())?
        .set_zone(index, Rgb { r, g, b })
        .map_err(|e| e.to_string())
}

#[tauri::command]
fn set_all_zones(r: u8, g: u8, b: u8) -> Result<(), String> {
    let leds = Leds::discover().map_err(|e| e.to_string())?;
    for i in 0..omen_core::leds::ZONE_COUNT {
        leds.set_zone(i, Rgb { r, g, b })
            .map_err(|e| e.to_string())?;
    }
    Ok(())
}

#[tauri::command]
fn set_brightness(value: u8) -> Result<(), String> {
    Leds::discover()
        .map_err(|e| e.to_string())?
        .set_brightness(value)
        .map_err(|e| e.to_string())
}

fn show_window(app: &tauri::AppHandle) {
    if let Some(window) = app.get_webview_window("main") {
        let _ = window.show();
        let _ = window.unminimize();
        let _ = window.set_focus();
        // Resume polling, and refresh at once: the readings on screen are as
        // old as the time it spent hidden.
        let _ = window.emit("omen://visible", true);
    }
}

/// Builds the tray icon, or explains why it could not.
///
/// Not fatal: the window works on its own, and a laptop without
/// libappindicator should still get the app rather than a failed start.
fn build_tray(app: &tauri::App) -> tauri::Result<()> {
    let show = MenuItem::with_id(app, "show", "Open OMEN Control", true, None::<&str>)?;
    let quit = MenuItem::with_id(app, "quit", "Quit", true, None::<&str>)?;

    // The two things worth doing without opening a window: change the
    // performance profile, and put the fans back on the curve or up to full.
    // Anything more belongs in the window, where there is room to explain it.
    //
    // The profile list comes from the firmware rather than being hard-coded,
    // so the menu cannot offer a profile this machine does not have. It is
    // built once, at startup: a tray menu that rebuilds itself while open is
    // a menu that closes under the pointer.
    let choices = omen_core::profile::PlatformProfile::discover()
        .map(|p| p.choices())
        .unwrap_or_default();

    let profile_items: Vec<MenuItem<tauri::Wry>> = choices
        .iter()
        .map(|name| MenuItem::with_id(app, format!("profile:{name}"), name, true, None::<&str>))
        .collect::<tauri::Result<_>>()?;

    let fan_curve = MenuItem::with_id(app, "fan:curve", "Automatic", true, None::<&str>)?;
    let fan_max = MenuItem::with_id(app, "fan:max", "Full power", true, None::<&str>)?;

    let mut items: Vec<&dyn tauri::menu::IsMenuItem<tauri::Wry>> = vec![&show];
    let sep1 = PredefinedMenuItem::separator(app)?;
    let sep2 = PredefinedMenuItem::separator(app)?;
    let sep3 = PredefinedMenuItem::separator(app)?;

    let profile_header;
    if !profile_items.is_empty() {
        items.push(&sep1);
        profile_header = MenuItem::with_id(app, "hdr:profile", "Profile", false, None::<&str>)?;
        items.push(&profile_header);
        for item in &profile_items {
            items.push(item);
        }
    }

    let fan_header = MenuItem::with_id(app, "hdr:fan", "Fans", false, None::<&str>)?;
    items.push(&sep2);
    items.push(&fan_header);
    items.push(&fan_curve);
    items.push(&fan_max);
    items.push(&sep3);
    items.push(&quit);

    let menu = Menu::with_items(app, &items)?;

    let icon = app
        .default_window_icon()
        .cloned()
        .ok_or_else(|| tauri::Error::UnknownPath)?;

    TrayIconBuilder::with_id("omen-tray")
        .icon(icon)
        .tooltip("OMEN Control")
        .menu(&menu)
        // The menu belongs on the right button; the left one opens the
        // window, which is what people expect of a tray icon.
        .show_menu_on_left_click(false)
        .on_menu_event(|app, event| {
            let id = event.id.as_ref();
            match id {
                "show" => show_window(app),
                "quit" => app.exit(0),
                _ => {
                    // Fire and forget: the tray has nowhere to show an error,
                    // and the window will show the state that resulted
                    // either way.
                    if let Some(name) = id.strip_prefix("profile:") {
                        let _ = talk(Request::SetProfile {
                            profile: name.to_owned(),
                        });
                    } else if let Some(mode) = id.strip_prefix("fan:") {
                        let mode = if mode == "max" {
                            ControlMode::Max
                        } else {
                            ControlMode::Curve
                        };
                        let _ = talk(Request::SetMode(mode));
                    }
                }
            }
        })
        .on_tray_icon_event(|tray, event| {
            if let TrayIconEvent::Click {
                button: MouseButton::Left,
                button_state: MouseButtonState::Up,
                ..
            } = event
            {
                show_window(tray.app_handle());
            }
        })
        .build(app)?;

    Ok(())
}

fn main() {
    // Before anything else: if this app is already running, ask that copy to
    // show itself and stop here. See single.rs - a second instance reaching
    // GTK takes the first one down with it.
    // `--tab <name>` opens (or raises) the window on one page.
    let args: Vec<String> = std::env::args().collect();
    let tab = args
        .iter()
        .position(|a| a == "--tab")
        .and_then(|i| args.get(i + 1))
        .cloned();

    if !single::claim(tab.as_deref()) {
        return;
    }

    tauri::Builder::default()
        .setup(move |app| {
            match build_tray(app) {
                Ok(()) => HAS_TRAY.store(true, Ordering::Relaxed),
                Err(e) => eprintln!(
                    "no tray icon ({e}); closing the window will quit. \
                     Install libappindicator-gtk3 for one."
                ),
            }

            single::listen(app.handle());

            // The first instance honours --tab too, so the flag behaves the
            // same whether or not the app was already open.
            if let (Some(tab), Some(window)) = (&tab, app.get_webview_window("main")) {
                let _ = window.emit("omen://open-tab", tab.clone());
            }

            // Starting hidden is only offered when there is a tray to be
            // hidden into; without one the user would have a running process
            // and no way back to it.
            if HAS_TRAY.load(Ordering::Relaxed) && settings::Settings::load().start_hidden {
                if let Some(window) = app.get_webview_window("main") {
                    let _ = window.hide();
                }
            }
            Ok(())
        })
        .on_window_event(|window, event| {
            // Close to the tray rather than exiting, the way a control panel
            // that watches temperatures should behave - but only when there
            // is a tray to reopen it from.
            if let WindowEvent::CloseRequested { api, .. } = event {
                if HAS_TRAY.load(Ordering::Relaxed) {
                    api.prevent_close();
                    let _ = window.hide();
                    // Tell the page it is not being looked at. A hidden
                    // window polling the daemon every two seconds for the
                    // rest of the session is work nobody sees, on a laptop.
                    // WebKit does not reliably fire visibilitychange when a
                    // window is unmapped, so this is said explicitly.
                    let _ = window.emit("omen://visible", false);
                }
            }
        })
        .invoke_handler(tauri::generate_handler![
            get_state,
            set_mode,
            set_profile,
            reload_config,
            set_curve,
            set_curve_preset,
            clean_fans,
            set_lighting_options,
            reset_curve,
            set_effect,
            set_app_profiles,
            set_dgpu_power,
            set_gpu_mux,
            gpu_env,
            system_info,
            set_startup_profile,
            set_power_rules,
            firmware,
            firmware_refresh,
            get_settings,
            set_settings,
            versions,
            history,
            samples,
            set_triggers,
            set_charge_limit,
            curve_code,
            import_curve_code,
            save_report,
            privileged_actions,
            privileged_asker,
            run_privileged,
            diagnose,
            diagnose_text,
            set_zone,
            set_all_zones,
            set_brightness,
        ])
        .run(tauri::generate_context!())
        .expect("could not start the OMEN Control window");

    single::release();
}
