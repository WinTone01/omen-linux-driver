//! Checking what the keyboard's keys actually send, and fixing the ones that
//! send the wrong thing.
//!
//! omen-space installs a blanket hwdb rule for every HP laptop (PrtSc as
//! sysrq, 0xab as F1, and so on) - fixes for boards where those keys were
//! wrong. Applied to a board where they were right, the same rule would break
//! them. So nothing is assumed here: the key is pressed, the scancode and the
//! keycode it produced are read from the keyboard's own event device, and a
//! rule is written only for a key that was measured to be wrong, only for this
//! board.
//!
//! Reading `/dev/input/eventN` needs root or the `input` group. Installing
//! the rule needs root.

use std::io::Read;
use std::os::unix::fs::OpenOptionsExt;
use std::path::PathBuf;
use std::time::{Duration, Instant};

/// Where the rule goes. `90-` so it sorts after systemd's own 60-keyboard.
pub const HWDB_PATH: &str = "/etc/udev/hwdb.d/90-omen-keyboard.hwdb";

const EV_KEY: u16 = 0x01;
const EV_MSC: u16 = 0x04;
const MSC_SCAN: u16 = 0x04;
/// struct input_event on 64-bit: a 16-byte timeval, then type, code, value.
const EVENT_SIZE: usize = 24;
const O_NONBLOCK: i32 = 0o4000;

/// A key worth checking: what to ask for, and what it should produce.
#[derive(Debug, Clone, Copy)]
pub struct Expected {
    pub label: &'static str,
    /// The keycode, as in linux/input-event-codes.h.
    pub code: u16,
    /// Its hwdb name: the KEY_ constant, lower case, without the prefix.
    pub name: &'static str,
    /// A top-row key: asked for on its own and with Fn, because HP's top row
    /// is dual-purpose and which half is the default is a BIOS setting.
    pub top_row: bool,
}

/// The keys other projects have had to remap on HP laptops, plus the ones a
/// wrong map would be most noticed on.
pub const CHECKS: &[Expected] = &[
    Expected {
        label: "Print Screen (PrtSc)",
        code: 99,
        name: "sysrq",
        top_row: false,
    },
    Expected {
        label: "F1",
        code: 59,
        name: "f1",
        top_row: true,
    },
    Expected {
        label: "F12",
        code: 88,
        name: "f12",
        top_row: true,
    },
    Expected {
        label: "Windows (Super)",
        code: 125,
        name: "leftmeta",
        top_row: false,
    },
    Expected {
        label: "Insert",
        code: 110,
        name: "insert",
        top_row: false,
    },
    Expected {
        label: "Delete",
        code: 111,
        name: "delete",
        top_row: false,
    },
];

/// One key press as the keyboard reported it.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Press {
    /// The raw scancode, when the keyboard sent one (AT keyboards do).
    pub scancode: Option<u32>,
    /// The keycode the kernel turned it into.
    pub code: u16,
}

/// The built-in keyboard's event device.
pub fn keyboard_device() -> Option<PathBuf> {
    let text = std::fs::read_to_string("/proc/bus/input/devices").ok()?;
    for block in text.split("\n\n") {
        if !block.contains("N: Name=\"AT Translated Set 2 keyboard\"") {
            continue;
        }
        let handlers = block.lines().find(|l| l.starts_with("H: Handlers="))?;
        let event = handlers
            .split_whitespace()
            .find(|h| h.starts_with("event"))?;
        return Some(PathBuf::from("/dev/input").join(event));
    }
    None
}

/// An open keyboard, read without blocking so a key that does not exist can
/// be skipped by waiting.
pub struct Keyboard {
    file: std::fs::File,
}

impl Keyboard {
    pub fn open(path: &std::path::Path) -> std::io::Result<Self> {
        let file = std::fs::OpenOptions::new()
            .read(true)
            .custom_flags(O_NONBLOCK)
            .open(path)?;
        Ok(Self { file })
    }

    /// Throws away whatever is queued - the Enter that started the command,
    /// the release of the previous key.
    pub fn drain(&mut self) {
        let mut buf = [0u8; EVENT_SIZE * 64];
        while matches!(self.file.read(&mut buf), Ok(n) if n > 0) {}
    }

    /// Everything one key sent, or an empty list if nothing came within
    /// `wait`.
    ///
    /// A list, not the first press: a key can send several. On 8D24 the F1
    /// key sent the Super key's scancode first, and a check that stopped at
    /// the first press concluded "F1 is broken" and wrote a rule turning the
    /// Super key into F1. So once the first press arrives, whatever follows
    /// within a fraction of a second belongs to the same key.
    pub fn next_presses(&mut self, wait: Duration) -> Vec<Press> {
        const SAME_KEY: Duration = Duration::from_millis(300);
        let mut deadline = Instant::now() + wait;
        let mut scancode = None;
        let mut presses = Vec::new();
        let mut buf = [0u8; EVENT_SIZE];
        while Instant::now() < deadline {
            match self.file.read(&mut buf) {
                Ok(EVENT_SIZE) => {
                    let (kind, code, value) = parse_event(&buf);
                    if kind == EV_MSC && code == MSC_SCAN {
                        scancode = Some(value as u32);
                    } else if kind == EV_KEY && value == 1 {
                        if presses.is_empty() {
                            deadline = Instant::now() + SAME_KEY;
                        }
                        presses.push(Press {
                            scancode: scancode.take(),
                            code,
                        });
                    }
                }
                _ => std::thread::sleep(Duration::from_millis(10)),
            }
        }
        presses
    }
}

fn parse_event(buf: &[u8; EVENT_SIZE]) -> (u16, u16, i32) {
    let kind = u16::from_ne_bytes([buf[16], buf[17]]);
    let code = u16::from_ne_bytes([buf[18], buf[19]]);
    let value = i32::from_ne_bytes([buf[20], buf[21], buf[22], buf[23]]);
    (kind, code, value)
}

/// Keys that are never remapped, whatever a check sees: turning one of these
/// into something else breaks every shortcut that uses it. Ctrl, Shift, Alt
/// and Super on both sides, and Fn.
pub const MODIFIERS: &[u16] = &[29, 42, 54, 56, 97, 100, 125, 126, 464];

/// What one check found.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Verdict {
    /// Nothing was pressed in time.
    Skipped,
    /// The expected key was among what was sent. `with` lists anything sent
    /// alongside it - a key that sends a combination is the firmware's
    /// design, not a fault.
    Right { with: Vec<u16> },
    /// The expected key was not sent. `fix` is the scancode to remap, when
    /// there is exactly one ordinary key to remap; `None` when what came was
    /// only modifiers, several keys, or had no scancode.
    Wrong { sent: Vec<u16>, fix: Option<u32> },
}

/// Judges what one key sent against what it should have.
pub fn judge(want: &Expected, presses: &[Press]) -> Verdict {
    if presses.is_empty() {
        return Verdict::Skipped;
    }
    if presses.iter().any(|p| p.code == want.code) {
        return Verdict::Right {
            with: presses
                .iter()
                .map(|p| p.code)
                .filter(|&c| c != want.code)
                .collect(),
        };
    }
    let ordinary: Vec<&Press> = presses
        .iter()
        .filter(|p| !MODIFIERS.contains(&p.code))
        .collect();
    let fix = match ordinary.as_slice() {
        [only] => only.scancode,
        _ => None,
    };
    Verdict::Wrong {
        sent: presses.iter().map(|p| p.code).collect(),
        fix,
    }
}

/// A key's name for a report, from linux/input-event-codes.h. Only the keys
/// a laptop keyboard is likely to send; anything else is shown by number.
pub fn key_name(code: u16) -> String {
    let name = match code {
        1 => "esc",
        14 => "backspace",
        15 => "tab",
        25 => "p",
        28 => "enter",
        29 => "leftctrl",
        42 => "leftshift",
        54 => "rightshift",
        56 => "leftalt",
        57 => "space",
        59..=68 => return format!("f{}", code - 58),
        87 => "f11",
        88 => "f12",
        97 => "rightctrl",
        99 => "sysrq",
        100 => "rightalt",
        110 => "insert",
        111 => "delete",
        113 => "mute",
        114 => "volumedown",
        115 => "volumeup",
        125 => "leftmeta",
        126 => "rightmeta",
        138 => "help",
        140 => "calc",
        148 => "prog1",
        149 => "prog2",
        224 => "brightnessdown",
        225 => "brightnessup",
        227 => "switchvideomode",
        228 => "kbdillumtoggle",
        238 => "wlan",
        247 => "rfkill",
        248 => "micmute",
        464 => "fn",
        _ => return format!("keycode {code}"),
    };
    name.to_owned()
}

/// What a key sent, for a report: "leftmeta(0xdb) + p(0x19)".
pub fn describe(presses: &[Press]) -> String {
    presses
        .iter()
        .map(|p| match p.scancode {
            Some(s) => format!("{}(0x{s:x})", key_name(p.code)),
            None => key_name(p.code),
        })
        .collect::<Vec<_>>()
        .join(" + ")
}

/// Why a key that sent nothing may not be broken, when there is a known
/// reason. On 8D24 Fn+F12 is the Windows-key lock: the firmware swallows the
/// key while it is on and sends no event for the toggle itself, so a silent
/// Windows key looks exactly like a dead one.
pub fn silent_hint(want: &Expected) -> Option<&'static str> {
    match want.code {
        125 => Some("the Windows-key lock may be on - Fn+F12 toggles it on this board"),
        88 => Some("with Fn this is the Windows-key lock on this board, which sends nothing"),
        _ => None,
    }
}

/// A remap for one key: this scancode should produce this key.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Fix {
    pub scancode: u32,
    pub name: &'static str,
    pub label: &'static str,
}

/// The hwdb rule for a set of fixes, matched to this board only.
///
/// The match uses the board name from DMI (`rn`), not the product family: the
/// point is not to change anything on a machine nobody measured.
pub fn hwdb_rule(board: &str, fixes: &[Fix]) -> String {
    let mut out = String::from(
        "# Written by 'omenctl keys check' from keys pressed on this machine.\n\
         # Remove this file to undo it; see docs/usage.md.\n",
    );
    out.push_str(&format!("evdev:atkbd:dmi:*:svnHP:*:rn{board}:*\n"));
    for fix in fixes {
        out.push_str(&format!(
            " KEYBOARD_KEY_{:x}={}    # {}\n",
            fix.scancode, fix.name, fix.label
        ));
    }
    out
}

/// Puts the built-in keyboard's keymap back to the driver's defaults, and
/// lets udev apply what hwdb says on top.
///
/// Needed because udev only ever *adds* mappings. Removing a rule and
/// re-triggering does not undo the one it set: the kernel keeps the old
/// keycode until the device is created again. The first version of this
/// check left the Super key sending F1 after `keys reset` for exactly that
/// reason. Unbinding and re-binding atkbd creates the device again. The
/// keyboard is gone for a moment, which is harmless. Root only.
pub fn reset_keymap() -> std::io::Result<()> {
    let driver = std::path::Path::new("/sys/bus/serio/drivers/atkbd");
    for entry in std::fs::read_dir(driver)?.flatten() {
        let name = entry.file_name();
        let Some(name) = name.to_str() else { continue };
        if !name.starts_with("serio") {
            continue;
        }
        std::fs::write(driver.join("unbind"), name)?;
        std::fs::write(driver.join("bind"), name)?;
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn an_event_is_read_where_the_kernel_puts_it() {
        let mut buf = [0u8; EVENT_SIZE];
        buf[16..18].copy_from_slice(&EV_MSC.to_ne_bytes());
        buf[18..20].copy_from_slice(&MSC_SCAN.to_ne_bytes());
        buf[20..24].copy_from_slice(&0xb7i32.to_ne_bytes());
        assert_eq!(parse_event(&buf), (EV_MSC, MSC_SCAN, 0xb7));
    }

    const F1: Expected = Expected {
        label: "F1",
        code: 59,
        name: "f1",
        top_row: true,
    };
    fn press(scancode: u32, code: u16) -> Press {
        Press {
            scancode: Some(scancode),
            code,
        }
    }

    #[test]
    fn a_key_that_sends_a_combination_is_not_broken() {
        // What 8D24's F1 did: Super first, then the key itself.
        let v = judge(&F1, &[press(0xdb, 125), press(0x3b, 59)]);
        assert_eq!(v, Verdict::Right { with: vec![125] });
    }

    #[test]
    fn a_modifier_is_never_offered_as_the_fix() {
        // The rule the first version wrote: Super remapped to F1.
        let v = judge(&F1, &[press(0xdb, 125)]);
        assert_eq!(
            v,
            Verdict::Wrong {
                sent: vec![125],
                fix: None
            }
        );
    }

    #[test]
    fn one_wrong_ordinary_key_is_offered() {
        let v = judge(&F1, &[press(0xab, 138)]);
        assert_eq!(
            v,
            Verdict::Wrong {
                sent: vec![138],
                fix: Some(0xab)
            }
        );
        assert_eq!(judge(&F1, &[]), Verdict::Skipped);
    }

    #[test]
    fn the_rule_is_for_this_board_and_these_keys_only() {
        let rule = hwdb_rule(
            "8D24",
            &[Fix {
                scancode: 0xb7,
                name: "sysrq",
                label: "Print Screen",
            }],
        );
        assert!(rule.contains("evdev:atkbd:dmi:*:svnHP:*:rn8D24:*\n"));
        assert!(rule.contains(" KEYBOARD_KEY_b7=sysrq"));
        assert_eq!(rule.matches("KEYBOARD_KEY_").count(), 1);
    }
}
