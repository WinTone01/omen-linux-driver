//! The sentinel that puts the fans in a safe state on every exit path.
//!
//! Safety rule 1 (phase3-plan §4): when the daemon dies, the fan must not be
//! left at a setpoint nobody is maintaining. There are three doors:
//!
//!   1. Normal exit -> `Drop`
//!   2. Panic       -> `Drop` (runs during unwind)
//!   3. SIGKILL     -> `Drop` does NOT run; systemd `ExecStopPost` catches it
//!
//! The third is outside this type's reach and lives in the unit file. The
//! first two are here.
//!
//! What "a safe state" means changed once the machine was measured. Handing
//! control back to the EC looked like the obvious answer - it is the hardware
//! default, and it is what the driver's own `HP_FAN_SPEED_AUTOMATIC` implies.
//! But on this board the EC does not take the fans back: they sit at 0 RPM
//! while the CPU climbs. So stopping the service while the machine is hot
//! would leave it with no cooling at all. Above the stall threshold we
//! therefore leave the fans at full power instead - loud, but the machine
//! survives being unattended.

use log::{error, info, warn};
use omen_core::fan::{Fan, PwmMode};
use omen_core::thermal::Thermal;

pub struct AutoRestore {
    fan: Fan,
    thermal: Thermal,
    /// Above this temperature, exit at full power rather than handing the
    /// fans to an EC that will not drive them.
    hot_above_c: f32,
    armed: bool,
}

impl AutoRestore {
    pub fn new(fan: Fan, thermal: Thermal, hot_above_c: f32) -> Self {
        Self {
            fan,
            thermal,
            hot_above_c,
            armed: true,
        }
    }

    /// If we never took manual control (--dry-run, for instance), do not
    /// touch anything on the way out.
    pub fn disarm(&mut self) {
        self.armed = false;
    }
}

/// Leaves the fans in the safest state we can justify, and says which and why.
///
/// Shared with `--restore-auto`, so the systemd stop path and the in-process
/// path cannot drift apart.
pub fn park(fan: &Fan, thermal: Option<&Thermal>, hot_above_c: f32) {
    // If the temperature cannot be read we assume the worst: an unattended
    // machine with no cooling is far worse than one with loud fans.
    let temp = thermal.and_then(|t| t.hottest().ok());
    let hot = match &temp {
        Some((_, c)) => *c >= hot_above_c,
        None => true,
    };

    if hot {
        let where_from = match &temp {
            Some((label, c)) => format!("{label} {c:.1}C"),
            None => "no temperature reading".to_string(),
        };
        warn!("{where_from} - leaving the fans at FULL POWER rather than handing them to the EC");
        match fan.set_mode(PwmMode::Max) {
            Ok(()) => return,
            Err(e) => error!("could not set full power ({e}) - falling back to automatic"),
        }
    }

    match fan.restore_auto() {
        Ok(()) => info!("fan control handed back to the EC (pwm1_enable=2)"),
        // Panicking here would be pointless - we are already on the way out,
        // and a panic inside Drop aborts the process. Making it visible is
        // all we can do.
        Err(e) => error!("CRITICAL: could not put the fans in a safe state: {e}"),
    }
}

impl Drop for AutoRestore {
    fn drop(&mut self) {
        if !self.armed {
            return;
        }
        park(&self.fan, Some(&self.thermal), self.hot_above_c);
    }
}
