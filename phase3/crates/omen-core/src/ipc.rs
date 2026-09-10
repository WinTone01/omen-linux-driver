//! Daemon ile istemciler arasindaki protokol.
//!
//! Satir basina bir JSON nesnesi, unix stream socket uzerinden. Neden bu:
//! bagimliligi az, `socat`/`nc` ile elle denenebiliyor, ve Tauri arayuzu
//! (M3) ayni protokolu kullanacagi icin ikinci bir arayuz yazmaya gerek yok.
//!
//! Yetki modeli (phase3-plan §4, guvenlik kurali 5): fan'a yazan tek sey
//! daemon. Istemciler NE yapilmasini istediklerini soyler, kendileri
//! yazmaz. Boylece kelepceleme, kritik sigorta ve cikista otomatige donme
//! her yol icin tek bir yerde garanti altinda.

use serde::{Deserialize, Serialize};

pub const SOCKET_PATH: &str = "/run/omend/omend.sock";

/// Socket yolu. `OMEND_SOCKET` ayarliysa o kullanilir.
///
/// Root olmadan denemek, ayni makinede ikinci bir ornek kosturmak ve
/// konteynerde calistirmak icin gerekiyor. Daemon ve istemci ayni
/// fonksiyonu kullandigi icin ikisi her zaman ayni yere bakar.
pub fn socket_path() -> std::path::PathBuf {
    std::env::var_os("OMEND_SOCKET")
        .map(std::path::PathBuf::from)
        .unwrap_or_else(|| std::path::PathBuf::from(SOCKET_PATH))
}

/// Unix socket yollari `sockaddr_un.sun_path` icine sigmali - Linux'ta
/// 108 bayt, sonlandirici dahil. Asilirsa cekirdegin verdigi hata
/// ("path must be shorter than SUN_LEN") sebebi soylemiyor.
pub const SUN_PATH_MAX: usize = 107;

pub fn check_socket_path(path: &std::path::Path) -> Result<(), String> {
    let len = path.as_os_str().as_encoded_bytes().len();
    if len > SUN_PATH_MAX {
        return Err(format!(
            "socket yolu cok uzun ({len} bayt, en fazla {SUN_PATH_MAX}): {}\n  \
             OMEND_SOCKET ile daha kisa bir yol verin",
            path.display()
        ));
    }
    Ok(())
}

/// Fanin nasil surulecegi.
#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
#[serde(tag = "mode", rename_all = "lowercase")]
pub enum ControlMode {
    /// Varsayilan: egri surer.
    Curve,
    /// Sabit hedef. Kritik sigorta yine gecerli - kullanici istegi
    /// termal korumayi devre disi birakmaz.
    Manual { rpm: u32 },
    /// Kontrol EC'de.
    Auto,
    /// Fan tam guc (WMI 0x27).
    Max,
}

impl std::fmt::Display for ControlMode {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Curve => f.write_str("curve"),
            Self::Manual { rpm } => write!(f, "manual({rpm} RPM)"),
            Self::Auto => f.write_str("auto"),
            Self::Max => f.write_str("max"),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "cmd", rename_all = "snake_case")]
pub enum Request {
    /// Anlik durum.
    Status,
    /// Fan surus modunu degistir.
    SetMode(ControlMode),
    /// Platform profilini degistir (balanced / performance / low-power).
    SetProfile { profile: String },
    /// Yapilandirmayi diskten yeniden oku.
    Reload,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "status", rename_all = "snake_case")]
pub enum Response {
    Ok(Box<Snapshot>),
    Done { message: String },
    Error { message: String },
}

/// Daemon'in son turdaki gorunumu.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct Snapshot {
    pub mode: Option<ControlMode>,
    /// Fanin sysfs'te bildirdigi mod (auto/manual/max).
    pub hw_mode: Option<String>,
    /// Egriyi suren sensor ve degeri.
    pub driver_label: Option<String>,
    pub driver_temp_c: Option<f32>,
    /// O an gecerli setpoint. `None` -> kontrol EC'de.
    pub target_rpm: Option<u32>,
    pub fan1_rpm: Option<u32>,
    pub fan2_rpm: Option<u32>,
    pub pwm: Option<u8>,
    pub profile: Option<String>,
    /// Kritik sigorta atmis mi.
    pub safety_fallback: bool,
    pub temps: Vec<(String, f32)>,
    pub uptime_secs: u64,
}
