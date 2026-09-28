//! One window, however many times the icon is clicked.
//!
//! Without this, launching the app while it is already running kills BOTH
//! copies. The mechanism is worth writing down because it is not obvious:
//! with a GTK application id set, the second process registers as a *remote*
//! instance and GTK forwards its activation to the first. tao answers that
//! activation by setting the application up again, and Tauri refuses - "a
//! webview with label `main` already exists" - which panics the process that
//! was working perfectly. The tray icon goes with it.
//!
//! So the second instance must never reach GTK. It connects to a socket the
//! first one is listening on, says "show yourself", and exits - which is also
//! the behaviour someone clicking a launcher icon wants.
//!
//! A unix socket rather than a lock file: a lock file left behind by a crash
//! is a lie that needs a liveness check, while a socket nobody is listening
//! on simply refuses the connection.

use std::io::{Read, Write};
use std::os::unix::net::{UnixListener, UnixStream};
use std::path::PathBuf;

use tauri::{Emitter, Manager};

/// What a later launch says to the one already running. A page name may
/// follow, so `omen-ui --tab graphics` raises the window on that page -
/// useful from a launcher, a script or a keyboard shortcut.
const MESSAGE: &str = "show";

fn socket_path() -> PathBuf {
    // The runtime directory is per-user and cleaned on logout, which is
    // exactly the lifetime this lock should have.
    let dir = std::env::var_os("XDG_RUNTIME_DIR")
        .map(PathBuf::from)
        .unwrap_or_else(std::env::temp_dir);
    dir.join("omen-control.sock")
}

/// Call before Tauri starts.
///
/// Returns `false` when another instance is already running and has been
/// asked to show itself; the caller should exit quietly.
pub fn claim(tab: Option<&str>) -> bool {
    let path = socket_path();

    if let Ok(mut stream) = UnixStream::connect(&path) {
        let message = match tab {
            Some(tab) => format!("{MESSAGE} {tab}\n"),
            None => format!("{MESSAGE}\n"),
        };
        let _ = stream.write_all(message.as_bytes());
        return false;
    }

    // Nothing answered. Either there is no other instance, or one died
    // without cleaning up - in both cases the file is ours to replace.
    let _ = std::fs::remove_file(&path);
    match UnixListener::bind(&path) {
        Ok(listener) => {
            LISTENER.set(listener).ok();
            true
        }
        // If the socket cannot be created we still run: a missing guard is a
        // worse day than a missing feature, but not a reason to refuse to
        // start.
        Err(e) => {
            eprintln!("could not create the single-instance socket ({e}); carrying on");
            true
        }
    }
}

static LISTENER: std::sync::OnceLock<UnixListener> = std::sync::OnceLock::new();

/// Starts answering later launches, once there is a window to show.
pub fn listen(app: &tauri::AppHandle) {
    let Some(listener) = LISTENER.get() else {
        return;
    };
    let Ok(listener) = listener.try_clone() else {
        return;
    };
    let app = app.clone();

    std::thread::Builder::new()
        .name("omen-single".into())
        .spawn(move || {
            for stream in listener.incoming().flatten() {
                let mut stream = stream;
                let mut buf = [0u8; 64];
                let read = stream.read(&mut buf).unwrap_or(0);
                let said = String::from_utf8_lossy(&buf[..read]);
                let mut words = said.split_whitespace();

                // Whatever was said, someone tried to start the app: show the
                // window. The word exists so a stray connection does not look
                // like a launch, not as a protocol.
                if words.next() != Some(MESSAGE) {
                    continue;
                }
                let tab = words.next().map(str::to_owned);

                show(&app, tab);
            }
        })
        .ok();
}

/// Brings the window up, optionally on a page.
fn show(app: &tauri::AppHandle, tab: Option<String>) {
    let handle = app.clone();
    // Windows may only be touched from the main thread.
    let _ = app.run_on_main_thread(move || {
        if let Some(window) = handle.get_webview_window("main") {
            let _ = window.show();
            let _ = window.unminimize();
            let _ = window.set_focus();
            if let Some(tab) = tab {
                let _ = window.emit("omen://open-tab", tab);
            }
        }
    });
}

/// Shows the window when the OMEN key is pressed.
///
/// The daemon sees the key - it arrives through hp-wmi's input device - but
/// cannot reach into this session to raise a window, so it counts presses
/// and this asks for the count. A few times a second over the daemon's own
/// socket is a handful of bytes, and it needs neither the 'input' group nor
/// any loosening of the service's sandbox.
///
/// The first answer only sets the baseline: presses from before the window
/// started are not a request to show it now.
pub fn watch_omen_key(app: &tauri::AppHandle) {
    use omen_core::ipc::{client, Request, Response};
    use std::time::Duration;

    let app = app.clone();
    std::thread::Builder::new()
        .name("omen-key".into())
        .spawn(move || {
            let mut seen: Option<u64> = None;
            loop {
                match client::send(&Request::OmenKeyPresses) {
                    Ok(Response::Presses { count }) => {
                        if seen.is_some_and(|before| count > before) {
                            show(&app, None);
                        }
                        // A restarted daemon starts again from zero; take its
                        // count as the new baseline rather than waiting for
                        // it to pass the old one.
                        seen = Some(count);
                        std::thread::sleep(Duration::from_millis(250));
                    }
                    // No daemon, or one too old to know the request: ask
                    // again later rather than hammer it.
                    _ => {
                        seen = None;
                        std::thread::sleep(Duration::from_secs(5));
                    }
                }
            }
        })
        .ok();
}

/// Removes the socket on the way out, so the next launch does not have to.
pub fn release() {
    let _ = std::fs::remove_file(socket_path());
}
