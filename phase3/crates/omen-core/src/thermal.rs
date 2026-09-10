//! Sicaklik kaynaklari.
//!
//! Tek bir sensore guvenmiyoruz: CPU ve dGPU ayri isinabiliyor, egri hangisi
//! sicaksa ona gore surulmeli. Kaynak bulunamazsa bu bir hata - cagiran taraf
//! guvenli tarafa (otomatik moda) dusmeli.

use std::path::PathBuf;

use crate::error::{Error, Result};
use crate::sysfs::{self, Hwmon};

/// Sensorun egriyi surmeye uygun olup olmadigi.
///
/// `acpitz` kart genelinde bir sicaklik verir: CPU'dan yavas tepki verir ve
/// rolantide ondan YUKSEK okuyabilir. En sicak sensoru korlemesine secersek
/// egriyi acpitz surer ve fan gercek yuke degil kartin genel isisina tepki
/// verir. O yuzden yalnizca gercek yuk kaynaklari birincil.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Role {
    /// CPU / GPU - egriyi bunlar surer.
    Primary,
    /// Yalnizca birincil sensor yoksa kullanilir.
    Fallback,
}

#[derive(Debug, Clone)]
pub struct TempSensor {
    pub label: String,
    pub path: PathBuf,
    pub role: Role,
}

impl TempSensor {
    /// hwmon sicakliklari milidereceden gelir.
    pub fn celsius(&self) -> Result<f32> {
        Ok(sysfs::read_i64(&self.path)? as f32 / 1000.0)
    }
}

#[derive(Debug, Clone, Default)]
pub struct Thermal {
    pub sensors: Vec<TempSensor>,
}

impl Thermal {
    /// Bu makinede (Strix Point + RTX 5060) ilgili olanlar:
    ///   k10temp  Tctl  - CPU
    ///   amdgpu   edge  - iGPU / APU kalibi
    ///   acpitz         - kart genel, digerleri yoksa yedek
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
                // Etiket varsa kullan (Tctl, edge, ...), yoksa indisi yaz.
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

    /// Egriyi suren deger: birincil sensorlerin en sicagi.
    ///
    /// Birincillerin hicbiri okunamazsa yedeklere duseriz - fani korlemesine
    /// birakmaktansa acpitz ile surmek iyidir. Hicbiri okunamazsa hata doner
    /// ve cagiran taraf otomatige dusmeli.
    pub fn hottest(&self) -> Result<(String, f32)> {
        self.hottest_of(Role::Primary)
            .or_else(|| self.hottest_of(Role::Fallback))
            .ok_or(Error::NoTempSource)
    }

    fn hottest_of(&self, role: Role) -> Option<(String, f32)> {
        let mut best: Option<(String, f32)> = None;
        for sensor in self.sensors.iter().filter(|s| s.role == role) {
            let Ok(c) = sensor.celsius() else { continue };
            // Sacma degerleri (kopuk sensor, -273 gibi) ele.
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
