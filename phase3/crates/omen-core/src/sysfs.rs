//! sysfs okuma/yazma ve hwmon kesfi.
//!
//! Bilerek ince tutuldu: her yazma tek bir `write` cagrisi, her okuma tek bir
//! `read_to_string`. sysfs dosyalari kucuk ve atomik, tampon/kilit gerekmiyor.

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

/// Bir hwmon dizini (`/sys/class/hwmon/hwmonN`).
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
        // hwmonN numaralari acilis sirasina gore degisir; kararli sira icin
        // isme gore sirala - ayni isimden birden fazla varsa (spd5118 gibi)
        // yol adi ikincil anahtar olur.
        found.sort_by(|a, b| (&a.name, &a.path).cmp(&(&b.name, &b.path)));
        found
    }

    /// Verilen isimlerden ILKINE uyan hwmon'u dondurur; sira oncelik demektir.
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
