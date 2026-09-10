//! HP OMEN 16-ap0xxx (board 8D24) icin fan, termal ve RGB kontrol katmani.
//!
//! Tasarim ilkesi: kendi sysfs agacimizi icat etmiyoruz. Fan `hwmon`,
//! profil `platform_profile`, RGB (Faz 3 M2) `leds-multicolor` uzerinden
//! yonetiliyor - hepsi cekirdegin var olan sinif arayuzleri. Boylece
//! `sensors`, KDE guc ayarlari, `upower` gibi mevcut araclar bu projeden
//! habersiz calismaya devam eder.
//!
//! Fan tarafinin calismasi icin `hp-wmi`de 8D24 DMI kaydi gerekiyor
//! (bkz. `phase2/`). Kayit yoksa `pwm1` acilmaz ve [`fan::Fan::discover`]
//! bunu soyleyen bir hata dondurur.

pub mod config;
pub mod curve;
pub mod error;
pub mod fan;
pub mod profile;
pub mod sysfs;
pub mod thermal;

pub use error::{Error, Result};
