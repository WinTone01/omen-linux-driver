//! Temperature sources.
//!
//! We do not trust a single sensor: the CPU and the dGPU heat up
//! independently, and the curve should follow whichever is hotter. If no
//! source can be found that is an error - the caller must fall back to the
//! safe side (automatic mode).

use std::path::PathBuf;

use crate::error::{Error, Result};
use crate::sysfs::{self, Hwmon};

/// Whether a sensor is suitable for driving the curve.
///
/// `acpitz` reports a board-wide temperature: it lags the CPU and can read
/// HIGHER than it at idle. Blindly picking the hottest sensor lets acpitz
/// drive the curve, so the fan reacts to the chassis rather than to actual
/// load. Only real load sources are primary.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Role {
    /// CPU / GPU - these drive the curve.
    Primary,
    /// Used only when no primary sensor is available.
    Fallback,
}

#[derive(Debug, Clone)]
pub struct TempSensor {
    pub label: String,
    pub path: PathBuf,
    pub role: Role,
}

impl TempSensor {
    /// hwmon temperatures are in millidegrees.
    pub fn celsius(&self) -> Result<f32> {
        Ok(sysfs::read_i64(&self.path)? as f32 / 1000.0)
    }
}

#[derive(Debug, Clone, Default)]
pub struct Thermal {
    pub sensors: Vec<TempSensor>,
}

impl Thermal {
    /// Relevant on this machine (Strix Point + RTX 5060):
    ///   k10temp  Tctl  - CPU
    ///   amdgpu   edge  - iGPU / APU die
    ///   acpitz         - board-wide, a fallback when the others are missing
    pub fn discover() -> Result<Self> {
        let mut sensors = Vec::new();

        for hwmon in Hwmon::all() {
            let (prefix, role) = match hwmon.name.as_str() {
                "k10temp" => ("cpu", Role::Primary),
                "amdgpu" => ("igpu", Role::Primary),
                "acpitz" => ("board", Role::Fallback),
                _ => continue,
            };
            for idx in 1..=8 {
                let input = hwmon.attr(&format!("temp{idx}_input"));
                if !input.exists() {
                    continue;
                }
                // Use the label when there is one (Tctl, edge, ...), else the
                // index.
                let label = sysfs::read_string(&hwmon.attr(&format!("temp{idx}_label")))
                    .unwrap_or_else(|_| format!("temp{idx}"));
                sensors.push(TempSensor {
                    label: format!("{prefix}/{label}"),
                    path: input,
                    role,
                });
            }
        }

        if sensors.is_empty() {
            return Err(Error::NoTempSource);
        }
        Ok(Self { sensors })
    }

    pub fn read_all(&self) -> Vec<(String, Result<f32>)> {
        self.sensors
            .iter()
            .map(|s| (s.label.clone(), s.celsius()))
            .collect()
    }

    /// The value that drives the curve: the hottest primary sensor.
    ///
    /// If no primary sensor can be read we drop to the fallbacks - driving
    /// from acpitz beats flying blind. If none of them can be read either,
    /// this errors and the caller must fall back to automatic.
    pub fn hottest(&self) -> Result<(String, f32)> {
        self.hottest_of(Role::Primary)
            .or_else(|| self.hottest_of(Role::Fallback))
            .ok_or(Error::NoTempSource)
    }

    fn hottest_of(&self, role: Role) -> Option<(String, f32)> {
        let mut best: Option<(String, f32)> = None;
        for sensor in self.sensors.iter().filter(|s| s.role == role) {
            let Ok(c) = sensor.celsius() else { continue };
            // Discard nonsense (a disconnected sensor reading -273, say).
            if !(0.0..=150.0).contains(&c) {
                continue;
            }
            if best.as_ref().is_none_or(|(_, b)| c > *b) {
                best = Some((sensor.label.clone(), c));
            }
        }
        best
    }
}
