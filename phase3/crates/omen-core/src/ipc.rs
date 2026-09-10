//! The protocol between the daemon and its clients.
//!
//! One JSON object per line over a unix stream socket. Why that: few
//! dependencies, testable by hand with `socat`/`nc`, and the Tauri UI (M3)
//! will speak the same protocol, so there is no second interface to write.
//!
//! Authority model (phase3-plan §4, safety rule 5): the daemon is the only
//! thing that writes to the fan. Clients say what they want done, they do not
//! do it themselves. That keeps clamping, the critical cutout and
//! restore-on-exit guaranteed in a single place, on every path.

use serde::{Deserialize, Serialize};

pub const SOCKET_PATH: &str = "/run/omend/omend.sock";

/// Socket path. `OMEND_SOCKET` overrides it when set.
///
/// Needed to try things without root, to run a second instance on the same
/// machine, and to run in a container. The daemon and the client use the same
/// function, so they always agree on where to look.
pub fn socket_path() -> std::path::PathBuf {
    std::env::var_os("OMEND_SOCKET")
        .map(std::path::PathBuf::from)
        .unwrap_or_else(|| std::path::PathBuf::from(SOCKET_PATH))
}

/// Unix socket paths must fit in `sockaddr_un.sun_path` - 108 bytes on Linux,
/// terminator included. Past that the kernel's error ("path must be shorter
/// than SUN_LEN") does not say why.
pub const SUN_PATH_MAX: usize = 107;

pub fn check_socket_path(path: &std::path::Path) -> Result<(), String> {
    let len = path.as_os_str().as_encoded_bytes().len();
    if len > SUN_PATH_MAX {
        return Err(format!(
            "socket path too long ({len} bytes, max {SUN_PATH_MAX}): {}\n  \
             pass a shorter one with OMEND_SOCKET",
            path.display()
        ));
    }
    Ok(())
}

/// How the fan should be driven.
#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
#[serde(tag = "mode", rename_all = "lowercase")]
pub enum ControlMode {
    /// Default: the curve drives.
    Curve,
    /// Fixed target. The critical cutout still applies - a user request does
    /// not disable thermal protection.
    Manual { rpm: u32 },
    /// Control belongs to the EC.
    Auto,
    /// Fans at full power (WMI 0x27).
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
    /// Current state.
    Status,
    /// Change how the fan is driven.
    SetMode(ControlMode),
    /// Change the platform profile (balanced / performance / low-power).
    SetProfile { profile: String },
    /// Re-read the config from disk.
    Reload,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "status", rename_all = "snake_case")]
pub enum Response {
    Ok(Box<Snapshot>),
    Done { message: String },
    Error { message: String },
}

/// The daemon's view as of its last tick.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct Snapshot {
    pub mode: Option<ControlMode>,
    /// The mode the fan reports in sysfs (auto/manual/max).
    pub hw_mode: Option<String>,
    /// The sensor driving the curve, and its reading.
    pub driver_label: Option<String>,
    pub driver_temp_c: Option<f32>,
    /// The setpoint currently in effect. `None` -> control is with the EC.
    pub target_rpm: Option<u32>,
    pub fan1_rpm: Option<u32>,
    pub fan2_rpm: Option<u32>,
    pub pwm: Option<u8>,
    pub profile: Option<String>,
    /// Whether the critical cutout has tripped.
    pub safety_fallback: bool,
    pub temps: Vec<(String, f32)>,
    pub uptime_secs: u64,
}

/// Client side of the protocol. Shared by omenctl and the UI so there is only
/// one implementation of "talk to the daemon".
pub mod client {
    use std::io::{BufRead, BufReader, Write};
    use std::os::unix::net::UnixStream;

    use super::{check_socket_path, socket_path, Request, Response};

    #[derive(Debug, thiserror::Error)]
    pub enum ClientError {
        #[error("{0}")]
        Path(String),
        #[error("could not connect to omend ({path}): {source}")]
        Connect {
            path: String,
            #[source]
            source: std::io::Error,
        },
        #[error("transport error: {0}")]
        Io(#[from] std::io::Error),
        #[error("could not parse the reply: {0}")]
        Json(#[from] serde_json::Error),
        #[error("omend closed the connection without replying")]
        Empty,
    }

    pub fn send(req: &Request) -> Result<Response, ClientError> {
        let path = socket_path();
        check_socket_path(&path).map_err(ClientError::Path)?;
        let stream = UnixStream::connect(&path).map_err(|source| ClientError::Connect {
            path: path.display().to_string(),
            source,
        })?;

        let mut writer = stream.try_clone()?;
        let mut line = serde_json::to_string(req)?;
        line.push('\n');
        writer.write_all(line.as_bytes())?;
        writer.flush()?;

        let mut reader = BufReader::new(stream);
        let mut buf = String::new();
        if reader.read_line(&mut buf)? == 0 {
            return Err(ClientError::Empty);
        }
        Ok(serde_json::from_str(&buf)?)
    }
}
