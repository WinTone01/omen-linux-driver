//! The sentinel that hands fan control back to the EC on every exit path.
//!
//! Safety rule 1 (phase3-plan §4): when the daemon dies, the fan must not be
//! left at its last setpoint. There are three doors:
//!
//!   1. Normal exit -> `Drop`
//!   2. Panic       -> `Drop` (runs during unwind)
//!   3. SIGKILL     -> `Drop` does NOT run; systemd `ExecStopPost` catches it
//!
//! The third is outside this type's reach and lives in the unit file. The
//! first two are here.

use log::{error, info};
use omen_core::fan::Fan;

pub struct AutoRestore {
    fan: Fan,
    armed: bool,
}

impl AutoRestore {
    pub fn new(fan: Fan) -> Self {
        Self { fan, armed: true }
    }

    /// If we never entered manual mode (--dry-run, for instance), do not touch
    /// anything on the way out.
    pub fn disarm(&mut self) {
        self.armed = false;
    }
}

impl Drop for AutoRestore {
    fn drop(&mut self) {
        if !self.armed {
            return;
        }
        match self.fan.restore_auto() {
            Ok(()) => info!("fan control handed back to the EC (pwm1_enable=2)"),
            // Panicking here would be pointless - we are already on the way
            // out, and a panic inside Drop aborts the process. Making it
            // visible is all we can do.
            Err(e) => error!("CRITICAL: could not return the fan to automatic: {e}"),
        }
    }
}
