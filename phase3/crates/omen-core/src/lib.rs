//! Fan, thermal and RGB control layer for the HP OMEN 16-ap0xxx (board 8D24).
//!
//! Design principle: we do not invent our own sysfs tree. Fans go through
//! `hwmon`, profiles through `platform_profile`, and RGB (Phase 3 M2) through
//! `leds-multicolor` - all existing kernel class interfaces. That way
//! `sensors`, desktop power settings and `upower` keep working without
//! knowing this project exists.
//!
//! The fan side needs the 8D24 DMI entry in `hp-wmi` (see `phase2/`). Without
//! it `pwm1` never appears and [`fan::Fan::discover`] returns an error that
//! says so.

pub mod config;
pub mod curve;
pub mod error;
pub mod fan;
pub mod gpu;
pub mod ipc;
pub mod leds;
pub mod profile;
pub mod sysfs;
pub mod thermal;

pub use error::{Error, Result};
