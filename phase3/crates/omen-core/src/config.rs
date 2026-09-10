//! Yapilandirma. TOML, `/etc/omen/omend.toml`.
//!
//! Dosya yoksa gomulu varsayilanlar kullanilir - kurulum adimi olmadan
//! calisir. Gecersiz bir dosya ise SESSIZCE varsayilana dusmez: hata dondurur.
//! Fan egrisi soz konusu oldugunda "kullanicinin ne istedigini sandigimiz"
//! degil, "kullanicinin ne yazdigi" onemli.

use std::path::{Path, PathBuf};
use std::time::Duration;

use serde::{Deserialize, Serialize};

use crate::curve::{self, Curve, Point};
use crate::error::{Error, Result};
use crate::fan::{DEFAULT_MAX_RPM, DEFAULT_MIN_RPM};

pub const DEFAULT_PATH: &str = "/etc/omen/omend.toml";

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
#[derive(Default)]
pub struct Config {
    #[serde(default)]
    pub fan: FanConfig,
    #[serde(default)]
    pub safety: SafetyConfig,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct FanConfig {
    /// Egriyi isletmeyi tamamen kapatir; daemon yalnizca izler.
    #[serde(default = "yes")]
    pub enabled: bool,

    /// Olcum araligi (saniye).
    #[serde(default = "default_interval")]
    pub interval_secs: u64,

    /// Setpoint'i dusurmek icin sicakligin ne kadar dusmesi gerektigi.
    #[serde(default = "default_down_delta")]
    pub hysteresis_c: f32,

    /// Iki setpoint degisikligi arasi asgari sure (saniye).
    #[serde(default = "default_dwell")]
    pub min_dwell_secs: u64,

    #[serde(default = "default_min_rpm")]
    pub min_rpm: u32,

    #[serde(default = "default_max_rpm")]
    pub max_rpm: u32,

    /// `rpm = 0` -> o sicaklikta kontrolu EC'ye birak.
    #[serde(default)]
    pub curve: Vec<Point>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct SafetyConfig {
    /// Bu sicakligin ustunde egri birakilir, otomatige dusulur.
    /// Yazilim hatasi fani dusuk tutuyorsa donanim kendi egrisine donsun.
    #[serde(default = "default_critical")]
    pub critical_c: f32,

    /// Guvenlik modundan cikmak icin sicakligin inmesi gereken fark.
    #[serde(default = "default_recover")]
    pub recover_delta_c: f32,
}

fn yes() -> bool {
    true
}
fn default_interval() -> u64 {
    2
}
fn default_down_delta() -> f32 {
    5.0
}
fn default_dwell() -> u64 {
    20
}
fn default_min_rpm() -> u32 {
    DEFAULT_MIN_RPM
}
fn default_max_rpm() -> u32 {
    DEFAULT_MAX_RPM
}
fn default_critical() -> f32 {
    // Strix Point'in Tjmax'i ~100C. Sigorta egrinin en ust noktasinin
    // (95C) USTUNDE olmali - aksi halde egrinin en agresif bolgesi hic
    // kullanilamaz, sigorta oncesinde devreye girer. Bkz. validate().
    97.0
}
fn default_recover() -> f32 {
    10.0
}

impl Default for FanConfig {
    fn default() -> Self {
        Self {
            enabled: yes(),
            interval_secs: default_interval(),
            hysteresis_c: default_down_delta(),
            min_dwell_secs: default_dwell(),
            min_rpm: default_min_rpm(),
            max_rpm: default_max_rpm(),
            curve: Vec::new(),
        }
    }
}

impl Default for SafetyConfig {
    fn default() -> Self {
        Self {
            critical_c: default_critical(),
            recover_delta_c: default_recover(),
        }
    }
}

impl Config {
    /// Dosya yoksa varsayilan; varsa ayristirilir, bozuksa HATA doner.
    pub fn load(path: &Path) -> Result<Self> {
        if !path.exists() {
            return Ok(Self::default());
        }
        let raw = crate::sysfs::read_string(path)?;
        let cfg: Self = toml::from_str(&raw).map_err(|e| Error::Curve(format!("{path:?}: {e}")))?;
        cfg.validate()?;
        Ok(cfg)
    }

    pub fn default_path() -> PathBuf {
        PathBuf::from(DEFAULT_PATH)
    }

    fn validate(&self) -> Result<()> {
        if self.fan.interval_secs == 0 {
            return Err(Error::Curve("interval_secs 0 olamaz".into()));
        }
        if self.fan.min_rpm >= self.fan.max_rpm {
            return Err(Error::Curve(format!(
                "min_rpm ({}) >= max_rpm ({})",
                self.fan.min_rpm, self.fan.max_rpm
            )));
        }
        if self.safety.recover_delta_c <= 0.0 {
            return Err(Error::Curve("recover_delta_c pozitif olmali".into()));
        }

        // Egri gecerliligi Curve::new'de denetleniyor.
        let curve = self.curve()?;

        // Sigorta egrinin ust ucundan ONCE devreye girerse egrinin en
        // agresif bolgesi olu koda doner: sicaklik oraya varmadan kontrol
        // EC'ye gecer. Sessizce kabul etmek yerine soyluyoruz.
        let top = curve.points().last().map(|p| p.temp_c).unwrap_or_default();
        if self.safety.critical_c <= top {
            return Err(Error::Curve(format!(
                "critical_c ({:.0}C) egrinin ust ucundan ({top:.0}C) buyuk olmali - \
                 aksi halde egrinin ustu hic kullanilmaz",
                self.safety.critical_c
            )));
        }
        Ok(())
    }

    /// Yapilandirilmis egri, yoksa gomulu varsayilan.
    pub fn curve(&self) -> Result<Curve> {
        if self.fan.curve.is_empty() {
            Ok(curve::default_curve())
        } else {
            Curve::new(self.fan.curve.clone())
        }
    }

    pub fn interval(&self) -> Duration {
        Duration::from_secs(self.fan.interval_secs)
    }

    pub fn min_dwell(&self) -> Duration {
        Duration::from_secs(self.fan.min_dwell_secs)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn bos_yapilandirma_varsayilana_duser() {
        let cfg: Config = toml::from_str("").unwrap();
        assert!(cfg.fan.enabled);
        assert_eq!(cfg.safety.critical_c, 97.0);
        cfg.validate().unwrap();
        assert_eq!(cfg.curve().unwrap().points().len(), 5);
    }

    #[test]
    fn bilinmeyen_anahtar_reddedilir() {
        // Yazim hatasi sessizce yutulursa kullanici ayarinin uygulandigini
        // saniyor ama uygulanmiyor - fan egrisinde bu tehlikeli.
        let r: std::result::Result<Config, _> = toml::from_str("[fan]\nenabld = true\n");
        assert!(r.is_err());
    }

    #[test]
    fn bozuk_egri_yapilandirmayi_dusurur() {
        let cfg: Config = toml::from_str(
            r#"
            [fan]
            curve = [
              { temp_c = 60.0, rpm = 3000 },
              { temp_c = 70.0, rpm = 2000 },
            ]
            "#,
        )
        .unwrap();
        assert!(cfg.validate().is_err());
    }

    #[test]
    fn sigorta_egrinin_ustunde_olmali() {
        // Egri 95C'ye kadar cikiyor ama sigorta 90C'de - egrinin ustu
        // hic kullanilamaz. Bu bir yapilandirma celiskisi, hata vermeli.
        let cfg: Config = toml::from_str("[safety]\ncritical_c = 90.0\n").unwrap();
        let err = cfg.validate().unwrap_err().to_string();
        assert!(err.contains("critical_c"), "{err}");
    }

    #[test]
    fn ozel_egri_okunur() {
        let cfg: Config = toml::from_str(
            r#"
            [fan]
            interval_secs = 5
            curve = [
              { temp_c = 50.0, rpm = 0 },
              { temp_c = 80.0, rpm = 4000 },
            ]

            [safety]
            critical_c = 95.0
            "#,
        )
        .unwrap();
        cfg.validate().unwrap();
        assert_eq!(cfg.interval(), Duration::from_secs(5));
        assert_eq!(cfg.curve().unwrap().target(80.0), Some(4000));
    }
}
