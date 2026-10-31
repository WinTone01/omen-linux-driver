//! Which machine this installation belongs to.
//!
//! A disk moves. The same system can boot on the laptop it was installed on
//! one day and on a desktop the next, and nothing about the files on it
//! changes in between. The kernel side copes on its own - omen-kbd-rgb and
//! hp-wmi bind to HP's WMI GUID and return -ENODEV where it is absent - but
//! the daemon does not bind to anything. It finds a `coretemp`, decides the
//! machine is "telemetry-only" and keeps running, and some of what it drives
//! is generic: the dGPU's runtime power is found by NVIDIA's vendor ID and a
//! display class, which on a desktop is the card driving the screen.
//!
//! So the installation remembers its board, and everything that would drive
//! hardware asks first. The record is written once, by the installer, from
//! the machine it ran on; it is not a configuration anybody edits.
//!
//! Without a record - a package installed on its own, or an installation
//! older than this file - the question falls back to "is this an OMEN or a
//! Victus", the same one install.sh asks. That cannot tell one OMEN from
//! another, but it is what the kernel module asks too, and it is enough to
//! keep the daemon off a desktop.

use std::path::Path;

use serde::{Deserialize, Serialize};

use crate::error::{Error, Result};

/// Where the installer writes the board it was installed on.
pub const RECORD_PATH: &str = "/etc/omen/machine";

/// Written at the top of the record, because whoever finds it will want to
/// know what reads it and how to change it without an editor.
const RECORD_HEADER: &str = "\
# The machine this installation belongs to, written by the installer.
# omend refuses to drive anything on another board, so a disk that boots on
# a different computer leaves it alone. After a motherboard replacement:
#   omenctl fix record-machine

";

/// The two DMI fields that name a board. The vendor is kept because board
/// names are short codes, and two makers can use the same one.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Identity {
    pub vendor: String,
    pub board: String,
}

impl std::fmt::Display for Identity {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{} {}", self.vendor, self.board)
    }
}

impl Identity {
    /// The record, or `None` when there is none. A record that exists but
    /// cannot be read is an error, not an absence: falling back to the
    /// family check would quietly undo the one thing the file is for.
    pub fn load(path: &Path) -> Result<Option<Self>> {
        let raw = match std::fs::read_to_string(path) {
            Ok(raw) => raw,
            Err(e) if e.kind() == std::io::ErrorKind::NotFound => return Ok(None),
            Err(source) => {
                return Err(Error::Read {
                    path: path.to_owned(),
                    source,
                })
            }
        };
        toml::from_str(&raw).map(Some).map_err(|e| Error::Read {
            path: path.to_owned(),
            source: std::io::Error::new(std::io::ErrorKind::InvalidData, e.message().to_owned()),
        })
    }

    /// Written through a temporary file and a rename, like the configuration:
    /// a half-written record would refuse the machine it was meant to name.
    pub fn save(&self, path: &Path) -> Result<()> {
        let body = toml::to_string(self).map_err(|e| Error::Write {
            path: path.to_owned(),
            source: std::io::Error::new(std::io::ErrorKind::InvalidData, e.to_string()),
        })?;
        let dir = path.parent().unwrap_or_else(|| Path::new("."));
        std::fs::create_dir_all(dir).map_err(|source| Error::Write {
            path: dir.to_owned(),
            source,
        })?;
        let tmp = path.with_extension("tmp");
        std::fs::write(&tmp, format!("{RECORD_HEADER}{body}")).map_err(|source| Error::Write {
            path: tmp.clone(),
            source,
        })?;
        std::fs::rename(&tmp, path).map_err(|source| Error::Write {
            path: path.to_owned(),
            source,
        })
    }
}

/// What DMI says about the machine this is running on. Every field is
/// world-readable, so the answer is the same for root and for a user
/// service.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct Dmi {
    pub vendor: Option<String>,
    pub product: Option<String>,
    pub family: Option<String>,
    pub board: Option<String>,
}

impl Dmi {
    pub fn read() -> Self {
        let field = |file: &str| {
            std::fs::read_to_string(format!("/sys/class/dmi/id/{file}"))
                .ok()
                .map(|s| s.trim().to_owned())
                .filter(|s| !s.is_empty())
        };
        Self {
            vendor: field("sys_vendor"),
            product: field("product_name"),
            family: field("product_family"),
            board: field("board_name"),
        }
    }

    /// The board, as a record would name it. `None` when DMI does not say,
    /// which a record can never match.
    pub fn identity(&self) -> Option<Identity> {
        Some(Identity {
            vendor: self.vendor.clone()?,
            board: self.board.clone()?,
        })
    }

    /// An HP OMEN or Victus - install.sh's test, word for word.
    pub fn omen_family(&self) -> bool {
        let hp = matches!(self.vendor.as_deref(), Some("HP" | "Hewlett-Packard"));
        let name = format!(
            "{} {}",
            self.product.as_deref().unwrap_or(""),
            self.family.as_deref().unwrap_or("")
        )
        .to_ascii_lowercase();
        hp && (name.contains("omen") || name.contains("victus"))
    }

    /// What to call this machine in a message.
    fn describe(&self) -> String {
        match (&self.vendor, &self.board, &self.product) {
            (Some(v), Some(b), Some(p)) if p != b => format!("{v} {b} ({p})"),
            (Some(v), Some(b), _) => format!("{v} {b}"),
            _ => "a machine DMI does not name".into(),
        }
    }
}

/// Whether this installation may drive the machine it is running on.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Verdict {
    /// The board the installer recorded.
    Recorded(Identity),
    /// No record, but an OMEN or a Victus.
    Family,
    /// The record names another board.
    Other { expected: Identity, found: Dmi },
    /// No record, and not an OMEN or a Victus.
    Foreign(Dmi),
    /// There is a record and it could not be read.
    BadRecord(String),
}

impl Verdict {
    pub fn allowed(&self) -> bool {
        matches!(self, Self::Recorded(_) | Self::Family)
    }

    /// One sentence, for a log line, a status or the window.
    pub fn describe(&self) -> String {
        match self {
            Self::Recorded(id) => format!("{id}, the machine this was installed on"),
            Self::Family => "an HP OMEN or Victus (no machine was recorded at install)".into(),
            Self::Other { expected, found } => format!(
                "installed on {expected}, but this is {} - nothing will be driven here",
                found.describe()
            ),
            Self::Foreign(found) => format!(
                "{} is not an HP OMEN or Victus - nothing will be driven here",
                found.describe()
            ),
            Self::BadRecord(e) => {
                format!("the machine record is unreadable, so nothing will be driven: {e}")
            }
        }
    }

    /// What to do about a refusal, when there is something to do. A desktop
    /// gets nothing: it is the case this exists for, and offering to record
    /// it would be offering to undo the protection.
    pub fn remedy(&self, dmi: &Dmi) -> Option<&'static str> {
        match self {
            Self::Other { .. } | Self::BadRecord(_) if dmi.omen_family() => Some(
                "If this OMEN is the same laptop with a new motherboard, record it: \
                 omenctl fix record-machine",
            ),
            _ => None,
        }
    }
}

/// Decides, from a record and DMI. Separate from [`check`] so it can be
/// tested without a machine.
pub fn judge(record: Result<Option<Identity>>, dmi: &Dmi) -> Verdict {
    match record {
        Err(e) => Verdict::BadRecord(e.to_string()),
        Ok(Some(expected)) => {
            if dmi.identity().as_ref() == Some(&expected) {
                Verdict::Recorded(expected)
            } else {
                Verdict::Other {
                    expected,
                    found: dmi.clone(),
                }
            }
        }
        Ok(None) if dmi.omen_family() => Verdict::Family,
        Ok(None) => Verdict::Foreign(dmi.clone()),
    }
}

/// Asks the machine. Two small reads; cheap enough to ask at every start.
pub fn check() -> Verdict {
    judge(Identity::load(Path::new(RECORD_PATH)), &Dmi::read())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn laptop() -> Dmi {
        Dmi {
            vendor: Some("HP".into()),
            product: Some("OMEN Gaming Laptop 16-ap0xxx".into()),
            family: Some("103C_5335M8 HP OMEN".into()),
            board: Some("8D24".into()),
        }
    }

    fn desktop() -> Dmi {
        Dmi {
            vendor: Some("Gigabyte Technology Co., Ltd.".into()),
            product: Some("H610M H DDR4".into()),
            family: None,
            board: Some("H610M H DDR4".into()),
        }
    }

    fn record() -> Identity {
        Identity {
            vendor: "HP".into(),
            board: "8D24".into(),
        }
    }

    #[test]
    fn the_recorded_board_is_allowed() {
        let v = judge(Ok(Some(record())), &laptop());
        assert_eq!(v, Verdict::Recorded(record()));
        assert!(v.allowed());
    }

    #[test]
    fn a_desktop_is_refused_with_or_without_a_record() {
        assert!(!judge(Ok(Some(record())), &desktop()).allowed());
        assert!(matches!(judge(Ok(None), &desktop()), Verdict::Foreign(_)));
    }

    #[test]
    fn another_omen_is_refused_when_a_record_names_a_board() {
        let mut other = laptop();
        other.board = Some("8E35".into());
        assert!(matches!(
            judge(Ok(Some(record())), &other),
            Verdict::Other { .. }
        ));
        // Without a record the family is all that can be asked.
        assert_eq!(judge(Ok(None), &other), Verdict::Family);
    }

    #[test]
    fn an_unreadable_record_refuses_rather_than_falling_back() {
        let e = Error::Read {
            path: RECORD_PATH.into(),
            source: std::io::Error::new(std::io::ErrorKind::InvalidData, "bad"),
        };
        assert!(!judge(Err(e), &laptop()).allowed());
    }

    #[test]
    fn missing_dmi_never_matches_a_record() {
        assert!(!judge(Ok(Some(record())), &Dmi::default()).allowed());
        assert!(!judge(Ok(None), &Dmi::default()).allowed());
    }

    #[test]
    fn the_desktop_is_not_offered_a_way_to_record_itself() {
        let v = judge(Ok(Some(record())), &desktop());
        assert!(v.remedy(&desktop()).is_none());
        let mut swapped = laptop();
        swapped.board = Some("8E35".into());
        let v = judge(Ok(Some(record())), &swapped);
        assert!(v.remedy(&swapped).is_some());
    }

    #[test]
    fn a_record_survives_a_round_trip() {
        let dir = std::env::temp_dir().join(format!("omen-machine-{}", std::process::id()));
        let path = dir.join("machine");
        record().save(&path).unwrap();
        assert_eq!(Identity::load(&path).unwrap(), Some(record()));
        assert_eq!(Identity::load(&dir.join("absent")).unwrap(), None);
        std::fs::write(&path, "board = \"8D24\"\n").unwrap();
        assert!(Identity::load(&path).is_err());
        let _ = std::fs::remove_dir_all(dir);
    }
}
