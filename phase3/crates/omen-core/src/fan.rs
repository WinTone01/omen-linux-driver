//! hp-wmi'nin hwmon arayuzu uzerinden fan kontrolu.
//!
//! Faz 2'de dogrulandi: `pwm1` yalnizca 8D24 DMI eslesmesi varken aciliyor.
//! Cekirdek tarafindaki sozlesme (drivers/platform/x86/hp/hp-wmi.c):
//!
//!   * `pwm1_enable`  0 = MAX, 1 = MANUAL, 2 = AUTO
//!   * `pwm1`         0..255, 0..max_rpm araligina LINEER esleniyor
//!   * `pwm1`e yazma yalnizca MANUAL modda kabul ediliyor (aksi halde -EINVAL)
//!   * cekirdek setpoint'i ayrica min_rpm..max_rpm'e kelepceliyor
//!
//! Yani kelepceleme iki katmanli: once burada, sonra cekirdekte.

use crate::error::{Error, Result};
use crate::sysfs::Hwmon;

/// hp-wmi hwmon'unun `name` dosyasinda gorunebilecek degerler.
/// 7.2'de "hp"; ileride degisirse ikincisi yakalar.
const HWMON_NAMES: &[&str] = &["hp", "hp_wmi"];

/// Faz 1 §6.3: OGH'nin `profiles.json` sinirlari 18-48, yani 1800-4800 RPM.
pub const DEFAULT_MIN_RPM: u32 = 1800;
pub const DEFAULT_MAX_RPM: u32 = 4800;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PwmMode {
    /// Fan tam guc. hp-wmi bunu WMI 0x27 (FFFS=1) ile yapiyor.
    Max,
    /// Setpoint'i biz suruyoruz.
    Manual,
    /// Kontrol EC'de. Faz 2'de dogrulandi: bu modda EC 0x34/0x35 = 0 yaziliyor,
    /// bu "fan kapali" degil "otomatige don" demek (HP_FAN_SPEED_AUTOMATIC).
    Auto,
}

impl PwmMode {
    fn from_raw(v: i64) -> Option<Self> {
        match v {
            0 => Some(Self::Max),
            1 => Some(Self::Manual),
            2 => Some(Self::Auto),
            _ => None,
        }
    }

    fn as_raw(self) -> i64 {
        match self {
            Self::Max => 0,
            Self::Manual => 1,
            Self::Auto => 2,
        }
    }
}

impl std::fmt::Display for PwmMode {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(match self {
            Self::Max => "max",
            Self::Manual => "manual",
            Self::Auto => "auto",
        })
    }
}

#[derive(Debug, Clone)]
pub struct Fan {
    hwmon: Hwmon,
    min_rpm: u32,
    max_rpm: u32,
}

impl Fan {
    /// hp-wmi hwmon'unu bulur ve `pwm1`in acik oldugunu dogrular.
    ///
    /// `pwm1`in yoklugu neredeyse her zaman 8D24 yamasinin uygulanmadigi
    /// anlamina gelir - hata mesaji bunu soyluyor.
    pub fn discover(min_rpm: u32, max_rpm: u32) -> Result<Self> {
        let hwmon = Hwmon::find_any(HWMON_NAMES).ok_or(Error::HwmonNotFound)?;
        if !hwmon.has("pwm1") {
            return Err(Error::PwmUnsupported);
        }
        if max_rpm == 0 || min_rpm >= max_rpm {
            return Err(Error::Curve(format!(
                "gecersiz RPM araligi: {min_rpm}-{max_rpm}"
            )));
        }
        Ok(Self {
            hwmon,
            min_rpm,
            max_rpm,
        })
    }

    pub fn hwmon_path(&self) -> &std::path::Path {
        &self.hwmon.path
    }

    pub fn min_rpm(&self) -> u32 {
        self.min_rpm
    }

    pub fn max_rpm(&self) -> u32 {
        self.max_rpm
    }

    /// Takometre. `index` 1 veya 2 (CPU / GPU fani).
    pub fn rpm(&self, index: u8) -> Result<u32> {
        Ok(self.hwmon.read(&format!("fan{index}_input"))?.max(0) as u32)
    }

    pub fn mode(&self) -> Result<PwmMode> {
        let raw = self.hwmon.read("pwm1_enable")?;
        PwmMode::from_raw(raw).ok_or_else(|| Error::Parse {
            path: self.hwmon.attr("pwm1_enable"),
            raw: raw.to_string(),
        })
    }

    pub fn set_mode(&self, mode: PwmMode) -> Result<()> {
        if self.mode()? == mode {
            return Ok(());
        }
        self.hwmon.write("pwm1_enable", mode.as_raw())
    }

    pub fn pwm(&self) -> Result<u8> {
        Ok(self.hwmon.read("pwm1")?.clamp(0, 255) as u8)
    }

    /// Hedef hizi RPM olarak yazar.
    ///
    /// Cekirdek MANUAL disindaki modlarda yazmayi reddettigi icin once mod
    /// ayarlanir. Deger min/max araligina kelepcelenir - yapilandirma dosyasi
    /// ne derse desin.
    pub fn set_target_rpm(&self, rpm: u32) -> Result<u32> {
        let clamped = rpm.clamp(self.min_rpm, self.max_rpm);
        self.set_mode(PwmMode::Manual)?;
        self.hwmon.write("pwm1", self.rpm_to_pwm(clamped) as i64)?;
        Ok(clamped)
    }

    /// Kontrolu EC'ye geri verir. Guvenlik kurali 1: her cikis yolundan cagrilir.
    pub fn restore_auto(&self) -> Result<()> {
        self.set_mode(PwmMode::Auto)
    }

    /// RPM -> PWM. Yukari yuvarlar: yuvarlama hatasi her zaman DAHA COK
    /// sogutma yonunde olsun, daha az degil.
    pub fn rpm_to_pwm(&self, rpm: u32) -> u8 {
        let rpm = rpm.min(self.max_rpm);
        let scaled = (rpm as u64 * 255).div_ceil(self.max_rpm as u64);
        scaled.min(255) as u8
    }

    pub fn pwm_to_rpm(&self, pwm: u8) -> u32 {
        (pwm as u64 * self.max_rpm as u64 / 255) as u32
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn fan(min: u32, max: u32) -> Fan {
        Fan {
            hwmon: Hwmon {
                path: "/dev/null".into(),
                name: "hp".into(),
            },
            min_rpm: min,
            max_rpm: max,
        }
    }

    #[test]
    fn pwm_uclari_dogru() {
        let f = fan(1800, 4800);
        assert_eq!(f.rpm_to_pwm(0), 0);
        assert_eq!(f.rpm_to_pwm(4800), 255);
        // ust siniri asan istek 255'te kalir, tasmaz
        assert_eq!(f.rpm_to_pwm(9999), 255);
    }

    #[test]
    fn yuvarlama_asagi_dusmez() {
        // Her RPM icin: geri cevirdigimizde istenenin altina inmemeliyiz.
        let f = fan(1800, 4800);
        for rpm in (0..=4800).step_by(100) {
            let back = f.pwm_to_rpm(f.rpm_to_pwm(rpm));
            assert!(
                back + 100 >= rpm,
                "rpm={rpm} -> pwm={} -> {back}, fazla dustu",
                f.rpm_to_pwm(rpm)
            );
        }
    }

    #[test]
    fn mod_donusumu_simetrik() {
        for m in [PwmMode::Max, PwmMode::Manual, PwmMode::Auto] {
            assert_eq!(PwmMode::from_raw(m.as_raw()), Some(m));
        }
        assert_eq!(PwmMode::from_raw(3), None);
    }
}
