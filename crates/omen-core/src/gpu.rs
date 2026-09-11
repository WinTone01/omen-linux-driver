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
    /// Which of the GPU's device files it has open, by name.
    ///
    /// Worth reporting rather than collapsing to a yes: /dev/nvidia0 means a
    /// driver client - the program is set up to render there - while
    /// /dev/dri/card1 alone is usually a program that opened every card it
    /// could find. They are different problems with different fixes.
    #[serde(default)]
    pub nodes: Vec<String>,
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
                holders(&drm_nodes(&dev))
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
/// The device files this GPU answers to: /dev/dri/card1, /dev/dri/renderD128
/// and so on, read from the PCI device rather than assumed.
///
/// Which number a GPU gets is not fixed. On this machine the DISCRETE card is
/// renderD128 - the first one, the one anything that opens "a render node"
/// without choosing gets - which is exactly why programs end up on it without
/// anyone asking them to.
fn drm_nodes(dev: &Path) -> Vec<PathBuf> {
    let Ok(entries) = std::fs::read_dir(dev.join("drm")) else {
        return Vec::new();
    };
    entries
        .flatten()
        .filter_map(|e| {
            let name = e.file_name();
            let name = name.to_str()?;
            (name.starts_with("card") || name.starts_with("renderD"))
                .then(|| PathBuf::from("/dev/dri").join(name))
        })
        .collect()
}

fn holders(drm: &[PathBuf]) -> Vec<Holder> {
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

        let mut nodes: Vec<String> = fds
            .flatten()
            .filter_map(|fd| std::fs::read_link(fd.path()).ok())
            .filter(|target| is_nvidia_node(target) || drm.iter().any(|n| n == target))
            .filter_map(|target| target.to_str().map(str::to_owned))
            .collect();
        nodes.sort();
        nodes.dedup();

        if !nodes.is_empty() {
            let name = sysfs::read_string(&entry.path().join("comm")).unwrap_or_default();
            found.push(Holder { pid, name, nodes });
        }
    }
    found.sort_by_key(|h| h.pid);
    found
}

/// The proprietary driver's own nodes.
///
/// Kept alongside the DRM ones rather than replaced by them: a program can
/// hold either, and holding either is enough to keep the GPU awake.
fn is_nvidia_node(target: &Path) -> bool {
    // /dev/nvidia0, /dev/nvidiactl, /dev/nvidia-modeset, /dev/nvidia-uvm...
    // but not /dev/nvidia-caps, which is a directory of counters that
    // everything touches and nothing keeps awake.
    let Some(name) = target.file_name().and_then(|n| n.to_str()) else {
        return false;
    };
    target.starts_with("/dev") && name.starts_with("nvidia") && !name.starts_with("nvidia-caps")
}

/// Adds the holders this process can see to a GPU reported by the daemon.
///
/// The daemon runs with an empty capability set, and reading another user's
/// /proc/<pid>/fd needs one - so it can see the GPU but not who is using it.
/// A tool running as the user can see the user's own programs, which are
/// exactly the ones that keep a laptop GPU busy. Both lists are kept: a root
/// process could be the culprit, and only the daemon would see that one.
pub fn merge_local_holders(gpu: &mut GpuPower) {
    let Some(local) = discover() else {
        return;
    };
    for holder in local.holders {
        if !gpu.holders.iter().any(|h| h.pid == holder.pid) {
            gpu.holders.push(holder);
        }
    }
    gpu.holders.sort_by_key(|h| h.pid);
}

/// What to put in front of a command to run it on the discrete GPU.
pub const OFFLOAD_ENV: &str = "__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia";

/// What to put in front of a command to keep it OFF the discrete GPU.
///
/// This is the more useful direction on this machine. The discrete card is
/// renderD128 - the FIRST render node - so a program that opens "a GPU"
/// without choosing, or that enumerates all of them to see what is there,
/// lands on it and keeps it awake for as long as it runs. Firefox's decoder
/// process and a Qt shell both do exactly that here.
///
/// Restricting the EGL and Vulkan driver lists is stronger than asking
/// politely with DRI_PRIME, which the proprietary driver does not honour: the
/// process is left with no NVIDIA driver to load, so there is nothing for it
/// to enumerate. The paths are checked rather than assumed, because handing
/// someone a command that points at a file they do not have would break the
/// program it is meant to fix.
pub fn igpu_env() -> String {
    let mut parts = vec!["__GLX_VENDOR_LIBRARY_NAME=mesa".to_string()];

    let mesa = "/usr/share/glvnd/egl_vendor.d/50_mesa.json";
    if Path::new(mesa).exists() {
        parts.push(format!("__EGL_VENDOR_LIBRARY_FILENAMES={mesa}"));
    }
    for icd in [
        "/usr/share/vulkan/icd.d/radeon_icd.x86_64.json",
        "/usr/share/vulkan/icd.d/radeon_icd.json",
    ] {
        if Path::new(icd).exists() {
            parts.push(format!("VK_DRIVER_FILES={icd}"));
            break;
        }
    }
    parts.join(" ")
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

/// The graphics mux.
///
/// This board has one, which took some finding. The runtime view does not
/// show it: in hybrid mode the panel is wired to the integrated GPU and the
/// NVIDIA card enumerates only HDMI, which is indistinguishable from a
/// machine with no mux at all. The answer is in the firmware's own system
/// design data - the DSDT's GM28 method computes byte 7 as
/// BIT(0)|BIT(1)|BIT(2), meaning UMA, hybrid and discrete are all supported.
///
/// The kernel side is in omen-kbd-rgb, which asks the firmware and exposes
/// it. Switching takes effect at the next boot: the firmware re-wires the
/// panel during POST.
pub mod mux {
    use std::path::{Path, PathBuf};

    use serde::{Deserialize, Serialize};

    const DIR: &str = "/sys/devices/platform/omen-kbd-rgb";

    #[derive(Debug, Clone, Serialize, Deserialize)]
    pub struct Mux {
        /// What the firmware says it can do: "hybrid", "discrete", "uma".
        pub supported: Vec<String>,
        /// What it is set to now.
        pub current: Option<String>,
    }

    fn path(file: &str) -> PathBuf {
        Path::new(DIR).join(file)
    }

    fn read(file: &str) -> Option<String> {
        std::fs::read_to_string(path(file))
            .ok()
            .map(|s| s.trim().to_owned())
            .filter(|s| !s.is_empty())
    }

    /// `None` when this machine has no mux, or the module that reports it is
    /// not loaded.
    pub fn discover() -> Option<Mux> {
        let supported: Vec<String> = read("gpu_mux_supported")?
            .split_whitespace()
            .map(str::to_owned)
            .collect();
        if supported.is_empty() {
            return None;
        }
        Some(Mux {
            current: read("gpu_mux_mode"),
            supported,
        })
    }

    /// Asks the firmware to use `mode` from the next boot. Root only.
    ///
    /// Checked against the supported list first, rather than letting the
    /// write fail: the kernel refuses an unsupported mode too, but the error
    /// a user sees should say what the machine can actually do.
    pub fn set(mode: &str) -> crate::error::Result<()> {
        let mux = discover()
            .ok_or_else(|| crate::Error::Curve("this machine has no graphics mux".into()))?;
        if !mux.supported.iter().any(|m| m == mode) {
            return Err(crate::Error::Curve(format!(
                "{mode:?} is not supported; this machine offers {}",
                mux.supported.join(", ")
            )));
        }
        let file = path("gpu_mux_mode");
        std::fs::write(&file, mode).map_err(|source| crate::Error::Write { path: file, source })
    }
}
