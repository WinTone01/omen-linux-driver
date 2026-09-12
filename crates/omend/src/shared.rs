//! State shared between the daemon loop and the socket listener.
//!
//! Deliberately small: the listener records what was requested, the loop reads
//! it and applies it. The loop is the only place that writes to the fan, so
//! two threads can never overwrite each other's setpoint.
//!
//! Why a condvar: if the request were only a flag, the loop would not see it
//! until the next sample (2 s by default). Now the request wakes the loop.
//!
//! But waking is not enough on its own: if `omenctl set` dropped the request
//! in a queue and returned immediately, a following `status` could still read
//! the previous tick's view. So `request_mode` is SYNCHRONOUS - it waits for
//! the loop to finish a tick and returns the mode that was actually applied.
//! That also makes the reply text honest: "mode: manual", not "requested".

use std::sync::{Arc, Condvar, Mutex};
use std::time::{Duration, Instant};

use omen_core::ipc::{ControlMode, Snapshot};

#[derive(Debug, Default)]
pub struct Inner {
    /// The mode the client asked for. `None` -> nothing pending.
    pub requested: Option<ControlMode>,
    /// Re-read the configuration.
    pub reload: bool,
    /// A dust-clearing run, in seconds, waiting to be started by the loop.
    pub clean_secs: Option<u64>,
    /// The last tick's view; this is what `status` returns.
    pub snapshot: Snapshot,
    /// The decision log. Kept here rather than read from the loop's own copy
    /// because the listener thread must not borrow the loop's state.
    pub history: Vec<omen_core::ipc::Decision>,
    /// The readings behind the graph, published the same way.
    pub samples: Vec<omen_core::ipc::Sample>,
    /// Incremented on every completed loop iteration, so synchronous requests
    /// can answer "has my turn been processed yet".
    pub tick_seq: u64,
}

impl Inner {
    fn pending(&self) -> bool {
        self.requested.is_some() || self.reload || self.clean_secs.is_some()
    }
}

#[derive(Debug, Clone, Default)]
pub struct Shared(Arc<(Mutex<Inner>, Condvar)>);

impl Shared {
    pub fn new() -> Self {
        Self::default()
    }

    /// We swallow lock poisoning: if a thread panicked the data may be
    /// inconsistent, but stopping fan control is worse.
    fn lock(&self) -> std::sync::MutexGuard<'_, Inner> {
        self.0 .0.lock().unwrap_or_else(|e| e.into_inner())
    }

    /// Requests a mode and waits for a loop iteration to complete.
    ///
    /// The returned value is the mode the loop ACTUALLY applied. If the
    /// critical cutout has tripped, the request may be accepted while the
    /// drive stays in automatic - the caller should be able to see that.
    pub fn request_mode(&self, mode: ControlMode, timeout: Duration) -> Option<ControlMode> {
        let mut guard = self.lock();
        guard.requested = Some(mode);
        let seq = guard.tick_seq;
        self.0 .1.notify_all();

        let deadline = Instant::now() + timeout;
        while guard.tick_seq == seq {
            let now = Instant::now();
            if now >= deadline {
                // If the loop is wedged we leave the request queued; it will
                // be handled next time round. We tell the caller we do not
                // know.
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

    /// Marks a loop iteration complete and wakes anyone waiting.
    pub fn finish_tick(&self) {
        self.lock().tick_seq += 1;
        self.0 .1.notify_all();
    }

    /// Takes the pending request and clears it.
    pub fn take_request(&self) -> Option<ControlMode> {
        self.lock().requested.take()
    }

    pub fn request_clean(&self, seconds: u64) {
        self.lock().clean_secs = Some(seconds);
        self.0 .1.notify_all();
    }

    pub fn take_clean(&self) -> Option<u64> {
        self.lock().clean_secs.take()
    }

    pub fn take_reload(&self) -> bool {
        std::mem::take(&mut self.lock().reload)
    }

    pub fn has_pending(&self) -> bool {
        self.lock().pending()
    }

    /// The decision log, published by the loop alongside the snapshot.
    pub fn history(&self, limit: usize) -> Vec<omen_core::ipc::Decision> {
        let log = &self.lock().history;
        log.iter().rev().take(limit).rev().cloned().collect()
    }

    pub fn publish_history(&self, history: Vec<omen_core::ipc::Decision>) {
        self.lock().history = history;
    }

    pub fn samples(&self, limit: usize) -> Vec<omen_core::ipc::Sample> {
        let log = &self.lock().samples;
        log.iter().rev().take(limit).rev().cloned().collect()
    }

    pub fn publish_samples(&self, samples: Vec<omen_core::ipc::Sample>) {
        self.lock().samples = samples;
    }

    pub fn snapshot(&self) -> Snapshot {
        self.lock().snapshot.clone()
    }

    pub fn publish(&self, snapshot: Snapshot) {
        self.lock().snapshot = snapshot;
    }

    /// Waits until `deadline`; returns early if a request arrives.
    ///
    /// `slice` controls how often the signal flag is checked - we cannot get
    /// SIGTERM delivered through the condvar.
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
