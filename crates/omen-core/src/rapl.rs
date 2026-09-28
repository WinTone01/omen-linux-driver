//! CPU package power, from the RAPL energy counter.
//!
//! The kernel exposes AMD's package energy through the same powercap tree as
//! Intel's (`intel-rapl:0`, named `package-0`). The counter is in microjoules
//! and wraps at `max_energy_range_uj`; power is the difference between two
//! readings over the time between them.
//!
//! Readable without root on this machine. Some kernels restrict
//! `energy_uj` to root (it was a side channel once), in which case
//! [`Package::discover`] still finds the counter and the first read fails.

use std::path::{Path, PathBuf};
use std::time::Instant;

use crate::error::{Error, Result};
use crate::sysfs;

const POWERCAP: &str = "/sys/class/powercap";

pub struct Package {
    dir: PathBuf,
    wrap: u64,
    last: Option<(Instant, u64)>,
}

impl Package {
    /// The package domain, if there is one.
    pub fn discover() -> Option<Self> {
        let entries = std::fs::read_dir(POWERCAP).ok()?;
        for entry in entries.flatten() {
            let dir = entry.path();
            if sysfs::read_string(&dir.join("name")).ok().as_deref() == Some("package-0") {
                let wrap = sysfs::read_string(&dir.join("max_energy_range_uj"))
                    .ok()
                    .and_then(|s| s.parse().ok())
                    .unwrap_or(u64::MAX);
                return Some(Self {
                    dir,
                    wrap,
                    last: None,
                });
            }
        }
        None
    }

    pub fn path(&self) -> &Path {
        &self.dir
    }

    fn energy_uj(&self) -> Result<u64> {
        let path = self.dir.join("energy_uj");
        let raw = sysfs::read_string(&path)?;
        raw.trim().parse().map_err(|_| Error::Parse { path, raw })
    }

    /// Watts since the previous call. `None` on the first call, which only
    /// takes the starting reading.
    pub fn watts(&mut self) -> Result<Option<f32>> {
        let now = (Instant::now(), self.energy_uj()?);
        let Some((t0, e0)) = self.last.replace(now) else {
            return Ok(None);
        };
        let secs = now.0.duration_since(t0).as_secs_f64();
        if secs <= 0.0 {
            return Ok(None);
        }
        let delta = if now.1 >= e0 {
            now.1 - e0
        } else {
            // The counter wrapped between the two readings.
            self.wrap - e0 + now.1
        };
        Ok(Some((delta as f64 / 1e6 / secs) as f32))
    }
}
