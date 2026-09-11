//! Temperature sources.
//!
//! We do not trust a single sensor: the CPU and the dGPU heat up
//! independently, and the curve should follow whichever is hotter. If no
//! source can be found that is an error - the caller must fall back to the
//! safe side (automatic mode).

use std::io::{Read, Seek, SeekFrom};
use std::path::{Path, PathBuf};

use crate::error::{Error, Result};
use crate::sysfs::{self, Hwmon};

/// The EC's register window, as exposed by the `ec_sys` module.
const EC_IO: &str = "/sys/kernel/debug/ec/ec0/io";

/// dGPU temperature, in degrees, one byte (Phase 1 §4: `GTMP`).
///
/// This is the only way to see the discrete GPU on this machine. The NVIDIA
/// driver registers no hwmon here - `nvidia-smi` reports a temperature while
/// `/sys/class/hwmon` shows nothing for it - so a curve driven from hwmon
/// alone never reacts to the GPU heating up. On a laptop with an RTX 5060
/// that is most of the thermal load.
///
/// The omen-space project reads the same register on the same family, which
/// is an independent confirmation of the Phase 1 map.
const EC_GPU_TEMP: u64 = 0xB7;

/// Where a reading comes from, because they are not read the same way.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Source {
    /// An hwmon `tempN_input`, in millidegrees.
    Hwmon,
    /// A single byte in the EC window, in whole degrees.
    EcByte(u64),
}

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
    pub source: Source,
}

impl TempSensor {
    pub fn celsius(&self) -> Result<f32> {
        match self.source {
            Source::Hwmon => Ok(sysfs::read_i64(&self.path)? as f32 / 1000.0),
            Source::EcByte(offset) => read_ec_byte(&self.path, offset).map(|b| b as f32),
        }
    }
}

fn read_ec_byte(path: &Path, offset: u64) -> Result<u8> {
    let mut file = std::fs::File::open(path).map_err(|source| Error::Read {
        path: path.to_owned(),
        source,
    })?;
    file.seek(SeekFrom::Start(offset))
        .map_err(|source| Error::Read {
            path: path.to_owned(),
            source,
        })?;
    let mut byte = [0u8; 1];
    file.read_exact(&mut byte).map_err(|source| Error::Read {
        path: path.to_owned(),
        source,
    })?;
    Ok(byte[0])
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
                    source: Source::Hwmon,
                });
            }
        }

        // The discrete GPU, which hwmon does not expose at all here. Read-only
        // and best-effort: without the `ec_sys` module there is simply no dGPU
        // reading, and the rest still works.
        let ec = Path::new(EC_IO);
        if ec.exists() {
            sensors.push(TempSensor {
                label: "dgpu/ec".to_string(),
                path: ec.to_owned(),
                role: Role::Primary,
                source: Source::EcByte(EC_GPU_TEMP),
            });
        }

        if sensors.is_empty() {
            return Err(Error::NoTempSource);
        }
        Ok(Self { sensors })
    }

    /// Whether the discrete GPU is being watched.
    ///
    /// Worth surfacing rather than leaving implicit: without it the curve is
    /// blind to most of the heat a game produces, and the only symptom is fans
    /// that stay quiet while the machine cooks.
    pub fn has_dgpu(&self) -> bool {
        self.sensors
            .iter()
            .any(|s| matches!(s.source, Source::EcByte(EC_GPU_TEMP)))
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
            // Discard nonsense. The floor is 10 rather than 0 on purpose: an
            // EC register that is not populated reads as 0, and a running
            // laptop is never at 0 C, so treating it as a real reading would
            // quietly drag the "hottest" sensor down.
            if !(10.0..=150.0).contains(&c) {
                continue;
            }
            if best.as_ref().is_none_or(|(_, b)| c > *b) {
                best = Some((sensor.label.clone(), c));
            }
        }
        best
    }
}
