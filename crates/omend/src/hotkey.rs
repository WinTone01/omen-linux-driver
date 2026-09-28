//! The OMEN key.
//!
//! hp-wmi maps WMI event 0x21a5 to KEY_PROG2 and delivers it through an input
//! device called "HP WMI hotkeys" (drivers/platform/x86/hp/hp-wmi.c). The
//! desktop usually has nothing bound to it, so the key does nothing at all -
//! which is a waste of the one button on this machine that exists for us.
//!
//! What it does is configurable, and by default it opens the window - which
//! is what the key does on Windows and therefore what someone pressing it
//! expects. Cycling the performance profile is the alternative: a whole
//! action in itself, needing no window and no desktop.
//!
//! Events are read as raw `struct input_event` rather than through a crate.
//! The layout is kernel ABI - it cannot change - and it is 24 bytes on the
//! only architecture this driver exists for. A dependency to parse three
//! integers is not a good trade in a daemon that controls fans.

use std::fs::File;
use std::io::Read;
use std::os::unix::fs::FileTypeExt;
use std::path::PathBuf;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{Arc, Mutex};

use log::{debug, info, warn};

use omen_core::config::OmenKey;
use omen_core::profile::PlatformProfile;

/// EV_KEY. The only event type we care about.
const EV_KEY: u16 = 0x01;
/// KEY_PROG2 - the OMEN key on this board. KEY_PROG1 is here too because HP
/// uses it for the same button on some models, and a key that does nothing is
/// a cheap thing to also listen for.
const KEY_PROG1: u16 = 148;
const KEY_PROG2: u16 = 149;
/// Key down. Repeats (value 2) are ignored: holding the key must not cycle
/// through every profile.
const PRESS: i32 = 1;

/// Size of `struct input_event` on 64-bit Linux: two 64-bit timeval fields,
/// two u16 and one i32.
const EVENT_SIZE: usize = 24;

/// Starts the listener, if the hotkey device is there and can be opened.
///
/// The action is shared rather than copied, so changing it in the
/// configuration applies to the next press instead of the next boot.
///
/// Never fatal: no hotkeys is a laptop that works fine with one less button.
pub fn spawn(action: Arc<Mutex<OmenKey>>) {
    let Some(path) = find_device() else {
        debug!("no HP WMI hotkey device - the OMEN key will do nothing");
        return;
    };

    let mut file = match File::open(&path) {
        Ok(f) => f,
        Err(e) => {
            warn!(
                "could not open {} ({e}) - the OMEN key will do nothing",
                path.display()
            );
            return;
        }
    };

    let started = std::thread::Builder::new()
        .name("omend-hotkey".into())
        .spawn(move || {
            info!("watching {} for the OMEN key", path.display());
            let mut buf = [0u8; EVENT_SIZE];
            loop {
                // A short read means the device went away - a module unload,
                // or a suspend that re-created it. Stopping is right; the
                // daemon does not need to own a keyboard to control fans.
                if let Err(e) = file.read_exact(&mut buf) {
                    debug!("hotkey device closed: {e}");
                    return;
                }
                let kind = u16::from_ne_bytes([buf[16], buf[17]]);
                let code = u16::from_ne_bytes([buf[18], buf[19]]);
                let value = i32::from_ne_bytes([buf[20], buf[21], buf[22], buf[23]]);

                if kind == EV_KEY && value == PRESS && (code == KEY_PROG1 || code == KEY_PROG2) {
                    let want = *action.lock().unwrap_or_else(|e| e.into_inner());
                    if want.opens_window() {
                        show_window();
                    }
                    if want.cycles_profile() {
                        cycle_profile();
                    }
                }
            }
        });

    if let Err(e) = started {
        warn!("could not start the hotkey thread: {e}");
    }
}

/// The input device hp-wmi creates. Found by name rather than by a fixed
/// event number, which changes with what else is plugged in.
fn find_device() -> Option<PathBuf> {
    let entries = std::fs::read_dir("/sys/class/input").ok()?;

    for entry in entries.flatten() {
        let name = entry.file_name();
        let name = name.to_string_lossy();
        if !name.starts_with("event") {
            continue;
        }
        let label = std::fs::read_to_string(entry.path().join("device/name")).ok()?;
        if !label.trim().eq_ignore_ascii_case("HP WMI hotkeys") {
            continue;
        }
        let dev = PathBuf::from("/dev/input").join(name.as_ref());
        // Confirmed to be a character device before opening it: a stale sysfs
        // entry is better found here than in a read loop.
        if std::fs::metadata(&dev).is_ok_and(|m| m.file_type().is_char_device()) {
            return Some(dev);
        }
    }
    None
}

/// How many times the OMEN key has asked for the window.
///
/// The window asks for this number (Request::OmenKeyPresses) and shows itself
/// when it goes up. The other way round - the daemon reaching into the user's
/// session to raise it - cannot work under the service's sandbox:
/// ProtectHome=yes hides /run/user entirely, and a root process with an empty
/// capability set could not enter someone's 0700 runtime directory anyway.
/// The first version tried exactly that, and it only ever looked like it
/// worked when the daemon under test was run as the user.
static PRESSES: AtomicU64 = AtomicU64::new(0);

pub fn presses() -> u64 {
    PRESSES.load(Ordering::Relaxed)
}

fn show_window() {
    PRESSES.fetch_add(1, Ordering::Relaxed);
    info!("OMEN key: asking the window to show itself");
}

/// Next profile in the list the firmware offers, wrapping round.
///
/// The order is the kernel's own, which on this machine reads low-power ->
/// balanced -> performance: quiet to loud, which is the order someone
/// pressing a button repeatedly expects.
fn cycle_profile() {
    let Some(pp) = PlatformProfile::discover() else {
        return;
    };
    let choices = pp.choices();
    if choices.is_empty() {
        return;
    }

    let current = pp.get().unwrap_or_default();
    let next = choices
        .iter()
        .position(|c| *c == current)
        .map(|i| (i + 1) % choices.len())
        .unwrap_or(0);

    match pp.set(&choices[next]) {
        Ok(()) => info!("OMEN key: profile {current} -> {}", choices[next]),
        Err(e) => warn!("OMEN key: could not change the profile: {e}"),
    }
}
