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

use std::sync::atomic::{AtomicBool, Ordering};

use serde::{Deserialize, Serialize};
use tauri::{
    menu::{Menu, MenuItem},
    tray::{MouseButton, MouseButtonState, TrayIconBuilder, TrayIconEvent},
    Manager, WindowEvent,
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
        Response::Ok(_) => Ok(String::new()),
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
    }
}

/// Builds the tray icon, or explains why it could not.
///
/// Not fatal: the window works on its own, and a laptop without
/// libappindicator should still get the app rather than a failed start.
fn build_tray(app: &tauri::App) -> tauri::Result<()> {
    let show = MenuItem::with_id(app, "show", "Open OMEN Control", true, None::<&str>)?;
    let quit = MenuItem::with_id(app, "quit", "Quit", true, None::<&str>)?;
    let menu = Menu::with_items(app, &[&show, &quit])?;

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
        .on_menu_event(|app, event| match event.id.as_ref() {
            "show" => show_window(app),
            "quit" => app.exit(0),
            _ => {}
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
    tauri::Builder::default()
        .setup(|app| {
            match build_tray(app) {
                Ok(()) => HAS_TRAY.store(true, Ordering::Relaxed),
                Err(e) => eprintln!(
                    "no tray icon ({e}); closing the window will quit. \
                     Install libappindicator-gtk3 for one."
                ),
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
                }
            }
        })
        .invoke_handler(tauri::generate_handler![
            get_state,
            set_mode,
            set_profile,
            reload_config,
            set_curve,
            reset_curve,
            set_effect,
            set_zone,
            set_all_zones,
            set_brightness,
        ])
        .run(tauri::generate_context!())
        .expect("could not start the OMEN Control window");
}
