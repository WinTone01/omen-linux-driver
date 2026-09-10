use std::path::PathBuf;

#[derive(Debug, thiserror::Error)]
pub enum Error {
    #[error("{path} okunamadi: {source}")]
    Read {
        path: PathBuf,
        #[source]
        source: std::io::Error,
    },

    #[error("{path} yazilamadi: {source}")]
    Write {
        path: PathBuf,
        #[source]
        source: std::io::Error,
    },

    #[error("{path} icerigi sayiya cevrilemedi: {raw:?}")]
    Parse { path: PathBuf, raw: String },

    /// hp-wmi hwmon'u bulunamadi. Neredeyse her zaman tek bir sebebi var:
    /// 8D24 DMI kaydi eksik, yani Faz 2 yamasi uygulanmamis.
    #[error("hp-wmi hwmon bulunamadi - 8D24 yamasi uygulandi mi? (phase2/scripts/verify.sh)")]
    HwmonNotFound,

    #[error("pwm1 yok - fan yazma destegi kapali. 8D24 DMI eslesmesi olmadan pwm1 acilmaz.")]
    PwmUnsupported,

    #[error("sicaklik kaynagi bulunamadi (k10temp / amdgpu / acpitz)")]
    NoTempSource,

    #[error("gecersiz fan egrisi: {0}")]
    Curve(String),
}

pub type Result<T> = std::result::Result<T, Error>;
