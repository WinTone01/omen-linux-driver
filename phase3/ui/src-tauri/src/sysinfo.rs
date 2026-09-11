//! The numbers OMEN Gaming Hub puts on its System Vitals page.
//!
//! None of this is hardware-specific and none of it goes through the daemon:
//! CPU load, memory and disk usage are the same on every Linux machine, and
//! reading them needs no privileges. They are here because the page would
//! otherwise be a thermal panel with three gaps in it.
//!
//! Everything is read from /proc and /sys rather than by running ps or df.
//! This is polled, and a process spawn per poll to print numbers the kernel
//! already exports would be a poor trade.

use std::collections::HashMap;
use std::sync::Mutex;

use serde::Serialize;

#[derive(Debug, Serialize, Default)]
pub struct SysInfo {
    /// 0-100 across all cores, over the interval since the last call.
    pub cpu_percent: Option<f32>,
    pub mem_used_gb: f32,
    pub mem_total_gb: f32,
    pub mem_percent: f32,
    pub disks: Vec<Disk>,
    /// The busiest few processes, as the Hub shows them.
    pub processes: Vec<Process>,
}

#[derive(Debug, Serialize)]
pub struct Disk {
    pub mount: String,
    pub free_gb: f32,
    pub total_gb: f32,
    pub used_percent: f32,
}

#[derive(Debug, Serialize)]
pub struct Process {
    pub pid: u32,
    pub name: String,
    pub cpu_percent: f32,
    pub mem_mb: f32,
}

/// CPU time is a counter; a percentage needs two readings. The previous one
/// lives here rather than being taken fresh with a sleep in the middle -
/// blocking the UI for a sampling interval to draw one number is not a trade
/// worth making, and the poll already provides the interval.
#[derive(Default)]
struct Previous {
    cpu: Option<(u64, u64)>,
    /// pid -> (utime + stime, total cpu time at that moment)
    procs: HashMap<u32, (u64, u64)>,
}

static PREVIOUS: Mutex<Option<Previous>> = Mutex::new(None);

const GB: f32 = 1024.0 * 1024.0 * 1024.0;

pub fn read() -> SysInfo {
    let mut guard = PREVIOUS.lock().unwrap_or_else(|e| e.into_inner());
    let previous = guard.get_or_insert_with(Previous::default);

    let (cpu_percent, total_jiffies) = cpu(previous);

    SysInfo {
        cpu_percent,
        processes: processes(previous, total_jiffies),
        ..memory()
    }
}

/// Overall CPU busy percentage since the previous call, plus the current
/// total so per-process shares can use the same denominator.
fn cpu(previous: &mut Previous) -> (Option<f32>, u64) {
    let Ok(stat) = std::fs::read_to_string("/proc/stat") else {
        return (None, 0);
    };
    let Some(line) = stat.lines().next() else {
        return (None, 0);
    };

    let values: Vec<u64> = line
        .split_whitespace()
        .skip(1)
        .filter_map(|v| v.parse().ok())
        .collect();
    if values.len() < 4 {
        return (None, 0);
    }
    let total: u64 = values.iter().sum();
    // Fields 4 and 5 are idle and iowait: time the CPU was not working.
    let idle: u64 = values[3] + values.get(4).copied().unwrap_or(0);

    let percent = previous.cpu.and_then(|(prev_total, prev_idle)| {
        let dt = total.checked_sub(prev_total)?;
        let di = idle.checked_sub(prev_idle)?;
        (dt > 0).then(|| ((dt - di) as f32 / dt as f32) * 100.0)
    });
    previous.cpu = Some((total, idle));
    (percent, total)
}

fn memory() -> SysInfo {
    let mut total_kb = 0.0f32;
    let mut available_kb = 0.0f32;

    if let Ok(text) = std::fs::read_to_string("/proc/meminfo") {
        for line in text.lines() {
            let mut parts = line.split_whitespace();
            let key = parts.next().unwrap_or("");
            let value: f32 = parts.next().and_then(|v| v.parse().ok()).unwrap_or(0.0);
            match key {
                "MemTotal:" => total_kb = value,
                // Available, not Free: free counts cache as used and reports a
                // number that alarms people for no reason.
                "MemAvailable:" => available_kb = value,
                _ => {}
            }
        }
    }

    let total = total_kb * 1024.0 / GB;
    let used = (total_kb - available_kb) * 1024.0 / GB;

    SysInfo {
        mem_used_gb: used,
        mem_total_gb: total,
        mem_percent: if total > 0.0 {
            (used / total) * 100.0
        } else {
            0.0
        },
        disks: disks(),
        ..Default::default()
    }
}

/// Real filesystems the user actually has, with free space.
///
/// Only the root and anything mounted under /home or /mnt or /run/media:
/// listing every tmpfs and overlay would be honest and useless.
fn disks() -> Vec<Disk> {
    let mut out = Vec::new();
    let Ok(mounts) = std::fs::read_to_string("/proc/mounts") else {
        return out;
    };

    for line in mounts.lines() {
        let mut f = line.split_whitespace();
        let (_dev, mount, fstype) = (f.next(), f.next(), f.next());
        let (Some(mount), Some(fstype)) = (mount, fstype) else {
            continue;
        };
        let interesting = mount == "/"
            || mount.starts_with("/home")
            || mount.starts_with("/mnt")
            || mount.starts_with("/run/media");
        let real = !matches!(
            fstype,
            "tmpfs" | "devtmpfs" | "proc" | "sysfs" | "overlay" | "squashfs" | "efivarfs"
        );
        if !interesting || !real {
            continue;
        }
        if out.iter().any(|d: &Disk| d.mount == mount) {
            continue;
        }
        if let Some(disk) = statvfs(mount) {
            out.push(disk);
        }
    }
    out.truncate(3);
    out
}

fn statvfs(mount: &str) -> Option<Disk> {
    let path = std::ffi::CString::new(mount).ok()?;
    // SAFETY: the struct is zeroed before the call and only read on success;
    // the path is a valid NUL-terminated string for the duration.
    let stat = unsafe {
        let mut stat: libc::statvfs = std::mem::zeroed();
        if libc::statvfs(path.as_ptr(), &mut stat) != 0 {
            return None;
        }
        stat
    };

    let block = stat.f_frsize as f32;
    let total = stat.f_blocks as f32 * block / GB;
    // bavail, not bfree: the blocks reserved for root are not free space to
    // anyone who would be looking at this.
    let free = stat.f_bavail as f32 * block / GB;
    if total <= 0.0 {
        return None;
    }
    Some(Disk {
        mount: mount.to_owned(),
        free_gb: free,
        total_gb: total,
        used_percent: ((total - free) / total) * 100.0,
    })
}

/// The busiest processes since the previous call.
fn processes(previous: &mut Previous, total_jiffies: u64) -> Vec<Process> {
    let Ok(entries) = std::fs::read_dir("/proc") else {
        return Vec::new();
    };
    let prev_total = previous
        .procs
        .values()
        .next()
        .map(|(_, total)| *total)
        .unwrap_or(0);
    let delta_total = total_jiffies.saturating_sub(prev_total) as f32;

    let mut current = HashMap::new();
    let mut out = Vec::new();

    for entry in entries.flatten() {
        let Ok(pid) = entry.file_name().to_string_lossy().parse::<u32>() else {
            continue;
        };
        let Ok(stat) = std::fs::read_to_string(entry.path().join("stat")) else {
            continue;
        };
        // The name is in parentheses and may itself contain spaces, so the
        // fields after it are found from the LAST ')' rather than by
        // splitting the whole line.
        let (Some(open), Some(close)) = (stat.find('('), stat.rfind(')')) else {
            continue;
        };
        let name = stat[open + 1..close].to_owned();
        let fields: Vec<&str> = stat[close + 1..].split_whitespace().collect();
        // After the name: state is [0], so utime is [11] and stime [12].
        let utime: u64 = fields.get(11).and_then(|v| v.parse().ok()).unwrap_or(0);
        let stime: u64 = fields.get(12).and_then(|v| v.parse().ok()).unwrap_or(0);
        let rss_pages: u64 = fields.get(21).and_then(|v| v.parse().ok()).unwrap_or(0);
        let busy = utime + stime;

        current.insert(pid, (busy, total_jiffies));

        let cpu = previous
            .procs
            .get(&pid)
            .filter(|_| delta_total > 0.0)
            .map(|(prev_busy, _)| (busy.saturating_sub(*prev_busy) as f32 / delta_total) * 100.0)
            .unwrap_or(0.0);

        // 4 KiB pages. Reading the real page size for a display number is not
        // worth a syscall on every process.
        let mem_mb = rss_pages as f32 * 4096.0 / (1024.0 * 1024.0);
        if cpu < 0.05 && mem_mb < 1.0 {
            continue;
        }
        out.push(Process {
            pid,
            name,
            cpu_percent: cpu,
            mem_mb,
        });
    }

    previous.procs = current;
    out.sort_by(|a, b| b.cpu_percent.total_cmp(&a.cpu_percent));
    out.truncate(5);
    out
}
