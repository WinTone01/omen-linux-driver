//! Discrete GPU runtime power management.
//!
//! Why this is here at all: on this machine the dGPU is the single largest
//! draw on battery, and the usual advice - set `NVreg_DynamicPowerManagement`
//! and `power/control=auto` - is already satisfied out of the box on CachyOS.
//! The GPU still never suspends, because something is holding its device
//! files open. That is not something a fan daemon can fix, but it is
//! something it can *name*, which turns "the battery is bad" into "these two
//! processes are keeping the GPU awake".

use std::cell::RefCell;
use std::path::{Path, PathBuf};
use std::time::{Duration, Instant};

use serde::{Deserialize, Serialize};

use crate::sysfs;

const PCI_DEVICES: &str = "/sys/bus/pci/devices";
const NVIDIA_VENDOR: &str = "0x10de";

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GpuPower {
    /// PCI address, e.g. "0000:04:00.0".
    pub address: String,
    /// `power/control`: "auto" means runtime PM is allowed, "on" pins it awake.
    pub control: String,
    /// `power/runtime_status`: "suspended", "active", "suspending"...
    pub status: String,
    /// Total time spent suspended, in milliseconds. Zero means it has never
    /// gone to sleep, which is the interesting case.
    pub suspended_ms: u64,
    /// Processes holding /dev/nvidia*, which is what usually prevents it.
    pub holders: Vec<Holder>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Holder {
    pub pid: u32,
    pub name: String,
}

impl GpuPower {
    /// True when runtime PM is permitted but the device has never used it.
    pub fn awake_despite_pm(&self) -> bool {
        self.control == "auto" && self.suspended_ms == 0 && self.status != "suspended"
    }
}

/// What the dGPU's runtime power management is allowed to do.
///
/// This is not a graphics switch, because this board does not have one: the
/// panel is wired to the integrated GPU (the NVIDIA card has no eDP
/// connector, only HDMI), there is no `gpu_mux_mode`, and the DSDT does not
/// mention a mux at all. What can be chosen is whether the discrete GPU is
/// allowed to sleep when nothing is using it.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum DgpuPower {
    /// Suspend when idle. The default, and what a laptop wants on battery.
    #[default]
    Auto,
    /// Keep it awake. Costs several watts at idle; worth it only to rule the
    /// GPU out when chasing a wake-up or resume problem.
    On,
}

impl DgpuPower {
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Auto => "auto",
            Self::On => "on",
        }
    }

    pub fn parse(s: &str) -> Option<Self> {
        match s.trim().to_ascii_lowercase().as_str() {
            "auto" | "sleep" | "save" => Some(Self::Auto),
            "on" | "awake" | "always" => Some(Self::On),
            _ => None,
        }
    }
}

impl std::fmt::Display for DgpuPower {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(self.as_str())
    }
}

/// Sets `power/control` on the discrete GPU. Root only.
pub fn set_power(want: DgpuPower) -> crate::error::Result<()> {
    let Some(gpu) = discover() else {
        return Err(crate::Error::Curve("no discrete GPU".into()));
    };
    let path = PathBuf::from(PCI_DEVICES)
        .join(&gpu.address)
        .join("power/control");
    std::fs::write(&path, want.as_str()).map_err(|source| crate::Error::Write { path, source })
}

/// The discrete GPU, if there is one.
///
/// Matched on vendor plus PCI class rather than on the driver name, so it
/// still reports something useful when nouveau is loaded or no driver is
/// bound at all.
pub fn discover() -> Option<GpuPower> {
    let entries = std::fs::read_dir(PCI_DEVICES).ok()?;

    for entry in entries.flatten() {
        let dev = entry.path();
        let vendor = sysfs::read_string(&dev.join("vendor")).unwrap_or_default();
        let class = sysfs::read_string(&dev.join("class")).unwrap_or_default();

        // 0x0300xx is a VGA controller, 0x0302xx a 3D controller - a dGPU in
        // a hybrid laptop shows up as one or the other.
        if vendor != NVIDIA_VENDOR || !class.starts_with("0x030") {
            continue;
        }

        let status = sysfs::read_string(&dev.join("power/runtime_status")).unwrap_or_default();

        return Some(GpuPower {
            address: entry.file_name().to_string_lossy().into_owned(),
            control: sysfs::read_string(&dev.join("power/control")).unwrap_or_default(),
            // Walking every process's file descriptors is not free, so only
            // do it when the answer can be interesting. A suspended GPU by
            // definition has nobody holding it open.
            holders: if status == "suspended" {
                Vec::new()
            } else {
                holders()
            },
            status,
            suspended_ms: sysfs::read_string(&dev.join("power/runtime_suspended_time"))
                .ok()
                .and_then(|s| s.parse().ok())
                .unwrap_or(0),
        });
    }
    None
}

/// Processes with an open file descriptor on an NVIDIA device node.
///
/// Reads /proc directly rather than shelling out to lsof: this runs in a
/// daemon on a timer, and a process spawn every couple of seconds to answer
/// a question that is usually "nobody" would be wasteful.
///
/// Only processes the caller can see are found. Run as root - as the daemon
/// is - that is all of them; run as a user it is only their own, which is why
/// the daemon reports this rather than the CLI working it out itself.
fn holders() -> Vec<Holder> {
    let Ok(entries) = std::fs::read_dir("/proc") else {
        return Vec::new();
    };

    let mut found = Vec::new();
    for entry in entries.flatten() {
        let Ok(pid) = entry.file_name().to_string_lossy().parse::<u32>() else {
            continue;
        };
        let fd_dir = entry.path().join("fd");
        let Ok(fds) = std::fs::read_dir(&fd_dir) else {
            continue;
        };

        let holds = fds.flatten().any(|fd| {
            std::fs::read_link(fd.path())
                .map(|target| is_nvidia_node(&target))
                .unwrap_or(false)
        });

        if holds {
            let name = sysfs::read_string(&entry.path().join("comm")).unwrap_or_default();
            found.push(Holder { pid, name });
        }
    }
    found.sort_by_key(|h| h.pid);
    found
}

fn is_nvidia_node(target: &Path) -> bool {
    // /dev/nvidia0, /dev/nvidiactl, /dev/nvidia-modeset, /dev/nvidia-uvm...
    // but not /dev/nvidia-caps, which is a directory of counters that
    // everything touches and nothing keeps awake.
    let Some(name) = target.file_name().and_then(|n| n.to_str()) else {
        return false;
    };
    target.starts_with("/dev") && name.starts_with("nvidia") && !name.starts_with("nvidia-caps")
}

/// Where the module options live, for reporting whether dynamic power
/// management is actually on.
pub fn dynamic_power_management() -> Option<String> {
    let path = PathBuf::from("/sys/module/nvidia/parameters/NVreg_DynamicPowerManagement");
    sysfs::read_string(&path).ok()
}

/// Caching wrapper, so a UI polling the daemon once a second does not make it
/// walk every process's file descriptors once a second.
pub struct Watch {
    cached: RefCell<Option<(Instant, Option<GpuPower>)>>,
    ttl: Duration,
}

impl Watch {
    pub fn new() -> Self {
        Self {
            cached: RefCell::new(None),
            ttl: Duration::from_secs(5),
        }
    }

    pub fn get(&self) -> Option<GpuPower> {
        let mut cached = self.cached.borrow_mut();
        if let Some((at, value)) = cached.as_ref() {
            if at.elapsed() < self.ttl {
                return value.clone();
            }
        }
        let fresh = discover();
        *cached = Some((Instant::now(), fresh.clone()));
        fresh
    }
}

impl Watch {
    /// Drops the cached reading, for when we have just changed something and
    /// the next caller should see it.
    pub fn invalidate(&self) {
        *self.cached.borrow_mut() = None;
    }
}

impl Default for Watch {
    fn default() -> Self {
        Self::new()
    }
}
