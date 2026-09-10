//! Daemon dongusu ile socket dinleyicisi arasindaki ortak durum.
//!
//! Kasitli olarak kucuk: dinleyici NE istendigini yazar, dongu okur ve
//! uygular. Fan'a yazan tek yer ana dongu - iki thread'in birbirinin
//! setpoint'i uzerine yazmasi diye bir durum yok.
//!
//! Condvar'in sebebi: istek sadece bir bayrak olsaydi dongu onu ancak bir
//! sonraki olcum turunda (varsayilan 2 sn) gorurdu. Simdi istek donguyi
//! uyandiriyor.
//!
//! Ama tek basina uyandirmak yetmiyor: `omenctl set` istegi kuyruga
//! birakip hemen donerse, ardindan gelen `status` hala eski turun
//! goruntusunu okuyabiliyor. O yuzden `request_mode` SENKRON - dongu
//! turunu bitirene kadar bekliyor ve gercekten uygulanan modu donduruyor.
//! Boylece cevap metni de dogru oluyor: "istendi" degil, "ayarlandi".

use std::sync::{Arc, Condvar, Mutex};
use std::time::{Duration, Instant};

use omen_core::ipc::{ControlMode, Snapshot};

#[derive(Debug, Default)]
pub struct Inner {
    /// Istemcinin istedigi mod. `None` -> bekleyen istek yok.
    pub requested: Option<ControlMode>,
    /// Yapilandirmayi yeniden oku.
    pub reload: bool,
    /// Son turun gorunumu; `status` bunu dondurur.
    pub snapshot: Snapshot,
    /// Her tamamlanan dongu turunda artar. Senkron isteklerin "turum
    /// islendi mi" sorusunu cevaplamasi icin.
    pub tick_seq: u64,
}

impl Inner {
    fn pending(&self) -> bool {
        self.requested.is_some() || self.reload
    }
}

#[derive(Debug, Clone, Default)]
pub struct Shared(Arc<(Mutex<Inner>, Condvar)>);

impl Shared {
    pub fn new() -> Self {
        Self::default()
    }

    /// Kilit zehirlenmesini yutuyoruz: bir thread panic ettiyse veri
    /// tutarsiz olabilir ama fan kontrolunu durdurmak daha kotu.
    fn lock(&self) -> std::sync::MutexGuard<'_, Inner> {
        self.0 .0.lock().unwrap_or_else(|e| e.into_inner())
    }

    /// Modu ister ve dongu turu bitene kadar bekler.
    ///
    /// Donen deger dongunun GERCEKTEN uyguladigi mod. Kritik sigorta
    /// atmissa istegimiz kabul edilmis ama surus otomatige dusmus
    /// olabilir - cagiran taraf bunu gorebilsin.
    pub fn request_mode(&self, mode: ControlMode, timeout: Duration) -> Option<ControlMode> {
        let mut guard = self.lock();
        guard.requested = Some(mode);
        let seq = guard.tick_seq;
        self.0 .1.notify_all();

        let deadline = Instant::now() + timeout;
        while guard.tick_seq == seq {
            let now = Instant::now();
            if now >= deadline {
                // Dongu takildiysa istegi kuyrukta birakiyoruz; bir
                // sonraki turda islenir. Cagirana "bilmiyorum" diyoruz.
                return None;
            }
            let (next, _) = self
                .0
                 .1
                .wait_timeout(guard, deadline - now)
                .unwrap_or_else(|e| e.into_inner());
            guard = next;
        }
        guard.snapshot.mode
    }

    pub fn request_reload(&self) {
        self.lock().reload = true;
        self.0 .1.notify_all();
    }

    /// Dongu turunu tamamlandi olarak isaretler ve bekleyenleri uyandirir.
    pub fn finish_tick(&self) {
        self.lock().tick_seq += 1;
        self.0 .1.notify_all();
    }

    /// Bekleyen istegi alir ve temizler.
    pub fn take_request(&self) -> Option<ControlMode> {
        self.lock().requested.take()
    }

    pub fn take_reload(&self) -> bool {
        std::mem::take(&mut self.lock().reload)
    }

    pub fn has_pending(&self) -> bool {
        self.lock().pending()
    }

    pub fn snapshot(&self) -> Snapshot {
        self.lock().snapshot.clone()
    }

    pub fn publish(&self, snapshot: Snapshot) {
        self.lock().snapshot = snapshot;
    }

    /// `deadline`e kadar bekler; istek gelirse erken doner.
    ///
    /// `slice` sinyal bayragina ne siklikta bakilacagini belirler -
    /// SIGTERM'e condvar uzerinden haber veremiyoruz.
    pub fn wait_until(&self, deadline: Instant, slice: Duration) {
        let mut guard = self.lock();
        while !guard.pending() {
            let now = Instant::now();
            if now >= deadline {
                return;
            }
            let wait = slice.min(deadline - now);
            let (next, timeout) = self
                .0
                 .1
                .wait_timeout(guard, wait)
                .unwrap_or_else(|e| e.into_inner());
            guard = next;
            if timeout.timed_out() {
                return;
            }
        }
    }
}
