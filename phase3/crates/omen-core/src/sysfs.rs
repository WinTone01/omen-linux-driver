//! sysfs reads and writes, plus hwmon discovery.
//!
//! Deliberately thin: one `write` per write, one `read_to_string` per read.
//! sysfs files are small and atomic, so buffering and locking buy nothing.

use std::fs;
use std::path::{Path, PathBuf};

use crate::error::{Error, Result};

pub fn read_string(path: &Path) -> Result<String> {
    fs::read_to_string(path)
        .map(|s| s.trim().to_owned())
        .map_err(|source| Error::Read {
            path: path.to_owned(),
            source,
        })
}

pub fn read_i64(path: &Path) -> Result<i64> {
    let raw = read_string(path)?;
    raw.parse().map_err(|_| Error::Parse {
        path: path.to_owned(),
        raw,
    })
}

pub fn write_i64(path: &Path, value: i64) -> Result<()> {
    fs::write(path, value.to_string()).map_err(|source| Error::Write {
        path: path.to_owned(),
        source,
    })
}

/// One hwmon directory (`/sys/class/hwmon/hwmonN`).
#[derive(Debug, Clone)]
pub struct Hwmon {
    pub path: PathBuf,
    pub name: String,
}

impl Hwmon {
    pub fn all() -> Vec<Hwmon> {
        let Ok(entries) = fs::read_dir("/sys/class/hwmon") else {
            return Vec::new();
        };
        let mut found: Vec<Hwmon> = entries
            .flatten()
            .filter_map(|e| {
                let path = e.path();
                let name = read_string(&path.join("name")).ok()?;
                Some(Hwmon { path, name })
            })
            .collect();
        // hwmonN numbers depend on probe order and shift between boots, so
        // sort by name for a stable order; the path breaks ties when several
        // devices share a name (spd5118, for example).
        found.sort_by(|a, b| (&a.name, &a.path).cmp(&(&b.name, &b.path)));
        found
    }

    /// Returns the hwmon matching the FIRST name that is present; the order of
    /// `names` is the order of preference.
    pub fn find_any(names: &[&str]) -> Option<Hwmon> {
        let all = Self::all();
        names
            .iter()
            .find_map(|want| all.iter().find(|h| h.name == *want).cloned())
    }

    pub fn attr(&self, name: &str) -> PathBuf {
        self.path.join(name)
    }

    pub fn has(&self, name: &str) -> bool {
        self.attr(name).exists()
    }

    pub fn read(&self, name: &str) -> Result<i64> {
        read_i64(&self.attr(name))
    }

    pub fn write(&self, name: &str, value: i64) -> Result<()> {
        write_i64(&self.attr(name), value)
    }
}
