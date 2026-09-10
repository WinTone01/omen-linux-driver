//! Fan egrisi ve yalpalama (hunting) onleyici yonetici.
//!
//! Bu katmanin iki tasarim karari var:
//!
//! 1. **`rpm = 0` "fanlari durdur" degil, "kontrolu EC'ye birak" demektir.**
//!    Faz 2'de olculdu: EC kendi otomatiginde 45C'de fanlari tamamen
//!    durduruyor (fan-stop). Egrinin alt ucunda manuel moda gecip 1800 RPM
//!    dayatsaydik makineyi fabrika ayarindan DAHA GURULTULU yapardik.
//!    O yuzden alt bolgede kontrolu geri veriyoruz.
//!
//! 2. **Setpoint donanimin cozunurlugune yuvarlanir.** Faz 1 §3.2: EC'nin
//!    fan hedefi (`SRP1`/`SRP2`) **yuz RPM** biriminde, yani gercek adim
//!    100 RPM. `pwm1` 0-255 oldugu icin ondan daha ince gorunuyor ama
//!    cekirdek `pwm_to_rpm` ile yuz RPM'e indiriyor: pwm 99 ve 100 ayni
//!    EC degerine (18) dusuyor. Yuvarlamazsak 0.1C'lik degisimler icin
//!    hicbir seyi degistirmeyen WMI cagrilari yapariz.
//!
//! 3. **Yukari cikmak serbest, asagi inmek gecikmeli.** Sogutmayi artirmak
//!    her zaman guvenli taraftir, aninda uygulanir. Azaltmak icin hem
//!    sicakligin histerezis kadar dusmesi hem asgari bekleme suresinin
//!    dolmasi gerekir - yoksa fan esik civarinda surekli inip cikar.

use std::time::{Duration, Instant};

use serde::{Deserialize, Serialize};

use crate::error::{Error, Result};

/// Egri uzerinde tek bir nokta. `rpm = 0` -> otomatige birak.
#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub struct Point {
    pub temp_c: f32,
    pub rpm: u32,
}

/// Hedef fan durumu. `None` = kontrol EC'de.
pub type Target = Option<u32>;

/// Karsilastirma icin "ne kadar sogutma" siralamasi.
/// Otomatik bolge egrinin en altinda oldugu icin en dusuk sirada.
fn cooling_rank(t: Target) -> u32 {
    t.unwrap_or(0)
}

/// EC'nin fan hedefi yuz RPM biriminde (Faz 1 §3.2), yani gercek adim bu.
pub const EC_STEP_RPM: u32 = 100;

#[derive(Debug, Clone)]
pub struct Curve {
    points: Vec<Point>,
}

impl Curve {
    pub fn new(mut points: Vec<Point>) -> Result<Self> {
        if points.len() < 2 {
            return Err(Error::Curve("en az iki nokta gerekli".into()));
        }
        points.sort_by(|a, b| a.temp_c.total_cmp(&b.temp_c));

        for w in points.windows(2) {
            if w[0].temp_c == w[1].temp_c {
                return Err(Error::Curve(format!(
                    "ayni sicaklikta iki nokta: {}C",
                    w[0].temp_c
                )));
            }
            // Sicaklik artarken fan yavaslayamaz.
            if w[1].rpm != 0 && w[0].rpm > w[1].rpm {
                return Err(Error::Curve(format!(
                    "{}C -> {}C arasinda RPM dusuyor ({} -> {})",
                    w[0].temp_c, w[1].temp_c, w[0].rpm, w[1].rpm
                )));
            }
            // Otomatik bolge yalnizca egrinin altinda olabilir; arada bir
            // yerde 0 gorursek yukarisi da otomatik saniliyor demektir.
            if w[0].rpm != 0 && w[1].rpm == 0 {
                return Err(Error::Curve(format!(
                    "otomatik bolge (rpm=0) yalnizca egrinin altinda olabilir, {}C'de var",
                    w[1].temp_c
                )));
            }
        }
        Ok(Self { points })
    }

    pub fn points(&self) -> &[Point] {
        &self.points
    }

    /// Verilen sicaklik icin hedef. Noktalar arasi dogrusal ara deger;
    /// alt ucun altinda ilk nokta, ust ucun ustunde son nokta gecerli.
    pub fn target(&self, temp_c: f32) -> Target {
        let first = self.points[0];
        let last = self.points[self.points.len() - 1];

        if temp_c <= first.temp_c {
            return (first.rpm != 0).then_some(first.rpm);
        }
        if temp_c >= last.temp_c {
            return (last.rpm != 0).then_some(last.rpm);
        }

        for w in self.points.windows(2) {
            let (a, b) = (w[0], w[1]);
            if temp_c >= a.temp_c && temp_c <= b.temp_c {
                // Otomatik bolgeden ilk gercek noktaya gecerken ara deger
                // hesaplamak anlamsiz - 0 bir RPM degeri degil, bir mod.
                if a.rpm == 0 {
                    return (b.rpm != 0).then_some(b.rpm);
                }
                let ratio = (temp_c - a.temp_c) / (b.temp_c - a.temp_c);
                let rpm = a.rpm as f32 + ratio * (b.rpm as f32 - a.rpm as f32);
                return Some(rpm.round() as u32);
            }
        }
        None
    }
}

#[derive(Debug, Clone, Copy)]
struct Applied {
    temp_c: f32,
    target: Target,
    at: Instant,
}

/// Egriyi histerezis ile isleten yonetici.
#[derive(Debug)]
pub struct Governor {
    curve: Curve,
    down_delta_c: f32,
    min_dwell: Duration,
    step_rpm: u32,
    applied: Option<Applied>,
}

impl Governor {
    pub fn new(curve: Curve, down_delta_c: f32, min_dwell: Duration, step_rpm: u32) -> Self {
        Self {
            curve,
            down_delta_c: down_delta_c.max(0.0),
            min_dwell,
            step_rpm: step_rpm.max(1),
            applied: None,
        }
    }

    /// Hedefi donanim adimina yuvarlar. YUKARI yuvarlar - yuvarlama hatasi
    /// her zaman daha cok sogutma yonunde olsun.
    fn quantize(&self, target: Target) -> Target {
        target.map(|rpm| rpm.div_ceil(self.step_rpm) * self.step_rpm)
    }

    pub fn curve(&self) -> &Curve {
        &self.curve
    }

    pub fn current(&self) -> Option<Target> {
        self.applied.map(|a| a.target)
    }

    /// Bu sicaklik icin ne yapilmali?
    ///
    /// `None` -> degisiklik yok (mevcut setpoint korunur).
    /// `Some(target)` -> uygula.
    pub fn decide(&mut self, temp_c: f32, now: Instant) -> Option<Target> {
        let want = self.quantize(self.curve.target(temp_c));

        let Some(applied) = self.applied else {
            return Some(self.commit(temp_c, want, now));
        };

        if want == applied.target {
            return None;
        }

        // Daha fazla sogutma: aninda.
        if cooling_rank(want) > cooling_rank(applied.target) {
            return Some(self.commit(temp_c, want, now));
        }

        // Daha az sogutma: iki kosul birden.
        let cooled_enough = temp_c <= applied.temp_c - self.down_delta_c;
        let waited_enough = now.duration_since(applied.at) >= self.min_dwell;
        if cooled_enough && waited_enough {
            return Some(self.commit(temp_c, want, now));
        }
        None
    }

    fn commit(&mut self, temp_c: f32, target: Target, now: Instant) -> Target {
        self.applied = Some(Applied {
            temp_c,
            target,
            at: now,
        });
        target
    }

    /// Guvenlik moduna dusuldugunde cagrilir: bir sonraki karar sifirdan
    /// verilsin, histerezis eski duruma takilmasin.
    pub fn reset(&mut self) {
        self.applied = None;
    }
}

/// Faz 1 §6.3'te OGH'nin `profiles.json` dosyasindan alinan egri.
/// Alt bolge otomatige birakilir - EC'nin fan-stop davranisi korunsun.
pub fn default_curve() -> Curve {
    Curve::new(vec![
        Point {
            temp_c: 60.0,
            rpm: 0,
        },
        Point {
            temp_c: 70.0,
            rpm: 1800,
        },
        Point {
            temp_c: 80.0,
            rpm: 2400,
        },
        Point {
            temp_c: 90.0,
            rpm: 3300,
        },
        Point {
            temp_c: 95.0,
            rpm: 4800,
        },
    ])
    .expect("gomulu varsayilan egri gecerli olmali")
}

#[cfg(test)]
mod tests {
    use super::*;

    fn c() -> Curve {
        default_curve()
    }

    #[test]
    fn alt_bolge_otomatik() {
        assert_eq!(c().target(30.0), None);
        assert_eq!(c().target(59.9), None);
    }

    #[test]
    fn ust_uc_son_noktada_kalir() {
        assert_eq!(c().target(95.0), Some(4800));
        assert_eq!(c().target(120.0), Some(4800));
    }

    #[test]
    fn ara_deger_dogrusal() {
        assert_eq!(c().target(75.0), Some(2100));
        assert_eq!(c().target(85.0), Some(2850));
    }

    #[test]
    fn otomatikten_cikis_ara_deger_hesaplamaz() {
        // 60-70 arasi: alt uc otomatik, ust uc 1800. Aradaki her deger 1800.
        assert_eq!(c().target(65.0), Some(1800));
    }

    #[test]
    fn dusen_rpm_reddedilir() {
        let bad = Curve::new(vec![
            Point {
                temp_c: 60.0,
                rpm: 3000,
            },
            Point {
                temp_c: 70.0,
                rpm: 2000,
            },
        ]);
        assert!(bad.is_err());
    }

    #[test]
    fn ortada_otomatik_bolge_reddedilir() {
        let bad = Curve::new(vec![
            Point {
                temp_c: 60.0,
                rpm: 1800,
            },
            Point {
                temp_c: 70.0,
                rpm: 0,
            },
        ]);
        assert!(bad.is_err());
    }

    #[test]
    fn isinma_aninda_uygulanir() {
        let mut g = Governor::new(c(), 5.0, Duration::from_secs(30), EC_STEP_RPM);
        let t0 = Instant::now();
        assert_eq!(g.decide(50.0, t0), Some(None));
        // Hemen isindi: beklemeden yukari cik.
        assert_eq!(g.decide(80.0, t0), Some(Some(2400)));
    }

    #[test]
    fn sogumada_histerezis_ve_bekleme_aranir() {
        let mut g = Governor::new(c(), 5.0, Duration::from_secs(30), EC_STEP_RPM);
        let t0 = Instant::now();
        g.decide(80.0, t0);

        // 2C dustu, histerezis yetmiyor -> degisiklik yok.
        assert_eq!(g.decide(78.0, t0 + Duration::from_secs(60)), None);
        // 6C dustu ama sure dolmadi -> yine yok.
        assert_eq!(g.decide(74.0, t0 + Duration::from_secs(5)), None);
        // Ikisi de saglandi -> in.
        // 74C ham hedefi 2040; 100'e yukari yuvarlanip 2100 oluyor.
        assert_eq!(
            g.decide(74.0, t0 + Duration::from_secs(60)),
            Some(Some(2100))
        );
    }

    #[test]
    fn kucuk_isinma_yazma_uretmez() {
        // Yavas isinmada her 0.1C icin yeni setpoint yazilmamali: EC'nin
        // adimi 100 RPM, arasindaki degerler ayni yere dusuyor.
        let mut g = Governor::new(c(), 5.0, Duration::from_secs(30), EC_STEP_RPM);
        let t0 = Instant::now();
        g.decide(70.0, t0);

        let mut writes = 0;
        // 70.0 -> 74.9 arasi 50 olcum; ham hedef 1800 -> 2094.
        for i in 0..50 {
            let temp = 70.0 + i as f32 * 0.1;
            if g.decide(temp, t0 + Duration::from_secs(i * 2)).is_some() {
                writes += 1;
            }
        }
        // 1800 -> 1900 -> 2000 -> 2100: en fazla 3 gercek degisiklik.
        assert!(writes <= 3, "{writes} yazma uretti, beklenen <= 3");
    }

    #[test]
    fn yuvarlama_yukari() {
        let g = Governor::new(c(), 5.0, Duration::from_secs(30), EC_STEP_RPM);
        assert_eq!(g.quantize(Some(1801)), Some(1900));
        assert_eq!(g.quantize(Some(1800)), Some(1800));
        assert_eq!(g.quantize(None), None);
    }

    #[test]
    fn yalpalama_yok() {
        // Esik civarinda gidip gelen sicaklik setpoint'i her turda
        // degistirmemeli.
        let mut g = Governor::new(c(), 5.0, Duration::from_secs(30), EC_STEP_RPM);
        let t0 = Instant::now();
        g.decide(70.0, t0);

        let mut changes = 0;
        for i in 0..100 {
            let temp = if i % 2 == 0 { 69.5 } else { 70.5 };
            if g.decide(temp, t0 + Duration::from_secs(i * 10)).is_some() {
                changes += 1;
            }
        }
        assert!(changes <= 2, "esik civarinda {changes} kez degisti");
    }
}
