//! Fan kontrolunu her cikis yolunda EC'ye geri veren nobetci.
//!
//! Guvenlik kurali 1 (phase3-plan §4): daemon oldugunde fan son setpoint'te
//! kalmamali. Uc kapi var:
//!
//!   1. Normal cikis  -> `Drop`
//!   2. Panic         -> `Drop` (unwind sirasinda calisir)
//!   3. SIGKILL       -> `Drop` CALISMAZ; systemd `ExecStopPost` yakalar
//!
//! Ucuncusu bu tipin kapsaminda degil, paketleme adiminda unit dosyasina
//! yazilacak. Ilk ikisi burada.

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

    /// Manuel moda hic gecmediysek (ornegin --dry-run) cikista dokunma.
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
            Ok(()) => info!("fan kontrolu EC'ye geri verildi (pwm1_enable=2)"),
            // Burada panic etmek anlamsiz - zaten cikiyoruz ve panic
            // Drop icinde surec sonlandirir. Yapabilecegimiz tek sey
            // bunu gorunur kilmak.
            Err(e) => error!("KRITIK: fan otomatige alinamadi: {e}"),
        }
    }
}
