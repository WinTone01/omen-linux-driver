use std::path::PathBuf;

#[derive(Debug, thiserror::Error)]
pub enum Error {
    #[error("could not read {path}: {source}")]
    Read {
        path: PathBuf,
        #[source]
        source: std::io::Error,
    },

    #[error("could not write {path}: {source}")]
    Write {
        path: PathBuf,
        #[source]
        source: std::io::Error,
    },

    #[error("contents of {path} are not a number: {raw:?}")]
    Parse { path: PathBuf, raw: String },

    /// The hp-wmi hwmon is missing. There is almost always one reason: the
    /// 8D24 DMI entry is absent, i.e. the Phase 2 patch was never applied.
    #[error("hp-wmi hwmon not found - is the 8D24 patch applied? (phase2/scripts/verify.sh)")]
    HwmonNotFound,

    #[error(
        "no pwm1 - fan writes are unsupported. Without the 8D24 DMI match pwm1 never appears."
    )]
    PwmUnsupported,

    #[error("no temperature source found (k10temp / amdgpu / acpitz)")]
    NoTempSource,

    #[error("invalid fan curve: {0}")]
    Curve(String),
}

pub type Result<T> = std::result::Result<T, Error>;
