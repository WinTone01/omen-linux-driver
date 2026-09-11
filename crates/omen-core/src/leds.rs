//! 4-zone RGB keyboard, through the standard `leds-multicolor` interface.
//!
//! Provided by the `omen-kbd-rgb` module (kernel). We do not talk to
//! WMI or the EC from here - the kernel already exposes the LED class, and
//! going through it means `brightnessctl`, desktop brightness keys and
//! anything else keep working the same way.
//!
//! Why this is NOT routed through the daemon like fan control is: a wrong fan
//! setpoint can stop the fans while thermal protection fails to step in, so
//! writes have to be arbitrated in one place. A wrong colour is a wrong
//! colour. The idiomatic Linux answer for LEDs is a udev rule granting the
//! group write access (packaging/99-omen-leds.rules), which also lets
//! tools other than ours drive the keyboard.

use std::path::{Path, PathBuf};

use serde::{Deserialize, Serialize};

use crate::error::{Error, Result};
use crate::sysfs;

const LED_DIR: &str = "/sys/class/leds";
/// The driver reports whether the keyboard is actually lit here. Colours and
/// brightness read back correctly even while the backlight is off, so this is
/// the only honest answer to "will anything be visible".
const BACKLIGHT_ACTIVE: &str = "/sys/devices/platform/omen-kbd-rgb/backlight_active";
const GLOBAL_LED: &str = "omen::kbd_backlight";
const ZONE_PREFIX: &str = "omen:rgb:kbd_backlight_zone";
pub const ZONE_COUNT: usize = 4;

/// Physical position of each zone, matching the module's numbering.
/// Kept here so the UI does not have to hard-code it.
pub const ZONE_LABELS: [&str; ZONE_COUNT] = ["left", "wasd", "centre", "numpad"];

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub struct Rgb {
    pub r: u8,
    pub g: u8,
    pub b: u8,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LedState {
    /// Global brightness, 0-100. `None` when the LED is absent.
    pub brightness: Option<u8>,
    pub zones: Vec<Rgb>,
    /// Set when the keyboard is dark. Writing colours will show nothing until
    /// it is on, and only Fn+F4 can do that (see docs/rgb-protocol.md §5) -
    /// the UI needs to be able to say so.
    pub backlight_off: bool,
}

#[derive(Debug, Clone)]
pub struct Leds {
    global: Option<PathBuf>,
    zones: Vec<PathBuf>,
}

impl Leds {
    /// Finds the LEDs. Absent means the `omen-kbd-rgb` module is not loaded.
    pub fn discover() -> Result<Self> {
        let base = Path::new(LED_DIR);
        let global = base.join(GLOBAL_LED);
        let mut zones = Vec::with_capacity(ZONE_COUNT);
        for i in 0..ZONE_COUNT {
            let p = base.join(format!("{ZONE_PREFIX}{i}"));
            if !p.exists() {
                return Err(Error::Curve(format!(
                    "{} not found - is the omen-kbd-rgb module loaded?",
                    p.display()
                )));
            }
            zones.push(p);
        }
        Ok(Self {
            global: global.exists().then_some(global),
            zones,
        })
    }

    pub fn brightness(&self) -> Option<u8> {
        let p = self.global.as_ref()?;
        sysfs::read_i64(&p.join("brightness"))
            .ok()
            .map(|v| v.clamp(0, 100) as u8)
    }

    pub fn set_brightness(&self, value: u8) -> Result<()> {
        let p = self
            .global
            .as_ref()
            .ok_or_else(|| Error::Curve(format!("{GLOBAL_LED} not found")))?;
        sysfs::write_i64(&p.join("brightness"), value.min(100) as i64)
    }

    pub fn zone(&self, index: usize) -> Result<Rgb> {
        let p = self
            .zones
            .get(index)
            .ok_or_else(|| Error::Curve(format!("zone {index} is out of range")))?;
        let raw = sysfs::read_string(&p.join("multi_intensity"))?;
        let mut it = raw.split_whitespace().map(|v| v.parse::<u8>().unwrap_or(0));
        Ok(Rgb {
            r: it.next().unwrap_or(0),
            g: it.next().unwrap_or(0),
            b: it.next().unwrap_or(0),
        })
    }

    /// Writes a zone's colour.
    ///
    /// `multi_intensity` is only the ratio between the channels; the LED
    /// class computes the final colour as intensity * brightness / max. So we
    /// also pin the zone's own brightness to 255, otherwise a colour written
    /// while that value happens to be 0 would show nothing.
    pub fn set_zone(&self, index: usize, c: Rgb) -> Result<()> {
        let p = self
            .zones
            .get(index)
            .ok_or_else(|| Error::Curve(format!("zone {index} is out of range")))?;
        sysfs::write_i64(&p.join("brightness"), 255)?;
        std::fs::write(
            p.join("multi_intensity"),
            format!("{} {} {}", c.r, c.g, c.b),
        )
        .map_err(|source| Error::Write {
            path: p.join("multi_intensity"),
            source,
        })
    }

    /// Whether the keyboard is actually lit.
    ///
    /// Asks the driver first, which reads the byte that tracks it. Only if
    /// that is unavailable does it fall back to "brightness is zero", which
    /// is a poor proxy: the backlight can be off with brightness set to 100,
    /// and that is exactly the case that made a working driver look broken.
    fn backlight_off(&self, brightness: Option<u8>) -> bool {
        match sysfs::read_string(Path::new(BACKLIGHT_ACTIVE)) {
            Ok(v) => v.trim() == "0",
            Err(_) => brightness == Some(0),
        }
    }

    pub fn state(&self) -> LedState {
        let brightness = self.brightness();
        LedState {
            zones: (0..ZONE_COUNT)
                .map(|i| self.zone(i).unwrap_or(Rgb { r: 0, g: 0, b: 0 }))
                .collect(),
            backlight_off: self.backlight_off(brightness),
            brightness,
        }
    }

    /// Whether the LED files can be written without root. False means the
    /// udev rule is not installed, or the user is not in the 'omen' group
    /// yet (a fresh group membership needs a new login session).
    pub fn writable(&self) -> bool {
        self.zones.first().is_some_and(|p| {
            std::fs::OpenOptions::new()
                .write(true)
                .open(p.join("multi_intensity"))
                .is_ok()
        })
    }
}
