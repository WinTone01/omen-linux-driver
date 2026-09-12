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

/// The hwmon drivers worth driving a curve from, and what to call them.
///
/// Named rather than "anything with a temperature": a laptop exposes a dozen
/// hwmon devices - the NVMe, the wireless card, the battery - and the hottest
/// of those is not what a fan curve should follow.
///
/// The list covers the family rather than this machine. An OMEN or a Victus
/// is as likely to be Intel as AMD, and on an Intel one `k10temp` simply does
/// not exist: this used to find no CPU at all there, leaving the curve to run
/// off the chassis sensor - or the daemon to refuse to start.
const CPU_DRIVERS: &[&str] = &[
    "k10temp",  // AMD, in-tree
    "zenpower", // AMD, the out-of-tree replacement some people run
    "coretemp", // Intel
];

/// Graphics, integrated and discrete. `amdgpu` is the APU die on this
/// machine; `nouveau` and `nvidia` appear on machines whose driver registers
/// hwmon, which the proprietary one mostly does not - hence the EC read below.
const GPU_DRIVERS: &[&str] = &["amdgpu", "i915", "xe", "nouveau", "nvidia"];

impl Thermal {
    /// Relevant on this machine (Strix Point + RTX 5060):
    ///   k10temp  Tctl  - CPU
    ///   amdgpu   edge  - iGPU / APU die
    ///   acpitz         - board-wide, a fallback when the others are missing
    ///
    /// On an Intel machine of the same family it is `coretemp` and, failing
    /// that, the `x86_pkg_temp` thermal zone; see below.
    pub fn discover() -> Result<Self> {
        let mut sensors = Vec::new();

        for hwmon in Hwmon::all() {
            let name = hwmon.name.as_str();
            let (prefix, role) = if CPU_DRIVERS.contains(&name) {
                ("cpu", Role::Primary)
            } else if GPU_DRIVERS.contains(&name) {
                (if name == "amdgpu" { "igpu" } else { "gpu" }, Role::Primary)
            } else if name == "acpitz" {
                ("board", Role::Fallback)
            } else {
                continue;
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

        // Intel's package temperature, for machines where coretemp is not
        // built or not loaded. It is the same silicon reading, reached
        // through the thermal framework rather than hwmon, and on an Intel
        // laptop with neither this is the difference between a curve that
        // follows the CPU and one that follows the chassis.
        if !sensors.iter().any(|s| s.role == Role::Primary) {
            sensors.extend(thermal_zones());
        }

        // The discrete GPU, which hwmon does not expose at all here. Read-only
        // and best-effort: without the `ec_sys` module there is simply no dGPU
        // reading, and the rest still works.
        //
        // Only on the family this register was read from. The map came out of
        // one machine's firmware and is corroborated across OMEN and Victus
        // models by omen-space; on anything else 0xB7 is some other byte, and
        // a plausible-looking number from the wrong register would drive the
        // fan from nothing at all.
        let ec = Path::new(EC_IO);
        if ec.exists() && is_omen_family() {
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

/// Whether this is an OMEN or a Victus, by model name.
///
/// Asked here rather than through caps.rs because caps asks *this* module
/// what it can see; the two would call each other. It is one file read.
fn is_omen_family() -> bool {
    std::fs::read_to_string("/sys/class/dmi/id/product_name")
        .map(|name| {
            let name = name.to_ascii_lowercase();
            name.contains("omen") || name.contains("victus")
        })
        .unwrap_or(false)
}

/// CPU temperature through the thermal framework, for machines with no hwmon
/// driver for it.
///
/// Only `x86_pkg_temp` - Intel's package sensor, which is the CPU and nothing
/// else. The rest of a laptop's thermal zones are chassis, battery and
/// charger sensors that lag the load by minutes, and a curve driven from one
/// of those is a curve that spins the fans up after the game has ended.
fn thermal_zones() -> Vec<TempSensor> {
    let Ok(entries) = std::fs::read_dir("/sys/class/thermal") else {
        return Vec::new();
    };
    let mut found = Vec::new();
    for entry in entries.flatten() {
        let dir = entry.path();
        let Ok(kind) = sysfs::read_string(&dir.join("type")) else {
            continue;
        };
        if kind != "x86_pkg_temp" {
            continue;
        }
        let input = dir.join("temp");
        if input.exists() {
            found.push(TempSensor {
                label: "cpu/package".to_string(),
                path: input,
                role: Role::Primary,
                source: Source::Hwmon,
            });
        }
    }
    found
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn discovery_finds_something_on_this_machine() {
        // Whatever the silicon is, a laptop has a CPU sensor of some kind.
        // The list covers AMD, Intel and the thermal-zone fallback, so
        // finding nothing here would mean a real gap rather than a quirk.
        let t = Thermal::discover().expect("no temperature source");
        assert!(!t.sensors.is_empty());
        let (label, celsius) = t.hottest().expect("nothing readable");
        assert!(!label.is_empty());
        assert!((10.0..=150.0).contains(&celsius), "{celsius}");
    }

    #[test]
    fn every_known_cpu_driver_is_treated_as_the_cpu() {
        // The point of the list: an Intel machine of this family has
        // coretemp where this one has k10temp, and used to end up with no
        // primary sensor at all.
        assert!(CPU_DRIVERS.contains(&"k10temp"));
        assert!(CPU_DRIVERS.contains(&"coretemp"));
        assert!(GPU_DRIVERS.contains(&"amdgpu"));
    }

    #[test]
    fn the_ec_gpu_register_is_only_read_on_the_family_it_came_from() {
        // It is a single byte at a fixed offset, read out of one firmware.
        // On a machine that is not one of these, that byte is something else.
        let t = Thermal::discover().expect("no temperature source");
        if !is_omen_family() {
            assert!(!t.has_dgpu(), "the EC register is not ours to read here");
        }
    }
}
