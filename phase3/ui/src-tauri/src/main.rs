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

use serde::Serialize;

use omen_core::ipc::{client, ControlMode, Request, Response, Snapshot};
use omen_core::leds::{LedState, Leds, Rgb};

/// Everything the UI needs for one refresh, in a single round trip.
#[derive(Debug, Serialize)]
struct UiState {
    /// `None` when the daemon is not reachable.
    daemon: Option<Snapshot>,
    /// Why the daemon is unreachable, so the UI can say something useful
    /// instead of just "disconnected".
    daemon_error: Option<String>,
    leds: Option<LedState>,
    leds_error: Option<String>,
    /// False when the LED files are read-only for us: the udev rule is not
    /// installed, or the 'omen' group membership needs a new login.
    leds_writable: bool,
    profile_choices: Vec<String>,
}

fn snapshot() -> (Option<Snapshot>, Option<String>) {
    match client::send(&Request::Status) {
        Ok(Response::Ok(s)) => (Some(*s), None),
        Ok(Response::Error { message }) => (None, Some(message)),
        Ok(Response::Done { message }) => (None, Some(message)),
        Err(e) => (None, Some(e.to_string())),
    }
}

#[tauri::command]
fn get_state() -> UiState {
    let (daemon, daemon_error) = snapshot();

    let (leds, leds_error, leds_writable) = match Leds::discover() {
        Ok(l) => (Some(l.state()), None, l.writable()),
        Err(e) => (None, Some(e.to_string()), false),
    };

    UiState {
        daemon,
        daemon_error,
        leds,
        leds_error,
        leds_writable,
        profile_choices: omen_core::profile::PlatformProfile::discover()
            .map(|p| p.choices())
            .unwrap_or_default(),
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

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![
            get_state,
            set_mode,
            set_profile,
            reload_config,
            set_zone,
            set_all_zones,
            set_brightness,
        ])
        .run(tauri::generate_context!())
        .expect("could not start the OMEN Control window");
}
