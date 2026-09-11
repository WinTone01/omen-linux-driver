//! Per-application profiles: "when this program is running, run the machine
//! like this".
//!
//! The idea is omen-space's, and the shape of the problem is the same: a game
//! wants performance and loud fans, and the machine should go back to what it
//! was when the game exits. Two things are done differently here, both
//! because of how it behaves when it is wrong:
//!
//! * **What gets restored is what was there before**, not a hard-coded
//!   "balanced". Restoring to a fixed profile means launching a game quietly
//!   rewrites a choice the user made an hour ago.
//! * **A profile is not restored if the user has since changed things.** If
//!   the state no longer matches what we applied, someone else has had an
//!   opinion, and stamping over it when a process exits would be rude.
//!
//! Matching is by process name. `/proc/<pid>/comm` is the cheap source and is
//! truncated to 15 characters by the kernel, so a long name is compared on
//! its first 15 characters; the executable's own basename is checked too, for
//! the cases where that differs.

use serde::{Deserialize, Serialize};

use crate::ipc::ControlMode;

/// The kernel's TASK_COMM_LEN - 1. Names longer than this are truncated in
/// `/proc/<pid>/comm`, which is why matching is prefix-based.
const COMM_MAX: usize = 15;

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct AppProfile {
    /// Process name, e.g. "steam" or "cyberpunk2077". Case-insensitive.
    pub process: String,

    /// Platform profile to switch to: balanced / performance / low-power.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub profile: Option<String>,

    /// How the fan should be driven while this is running.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub fan: Option<ControlMode>,

    /// A named fan curve to run while this is open: quiet, default or
    /// performance.
    ///
    /// Separate from `fan` because they answer different questions - `fan`
    /// says whether the curve drives at all, this says which curve. The
    /// configured curve is not touched: it is swapped in the running daemon
    /// and swapped back when the program exits, because a game profile that
    /// rewrote the curve you drew would be a poor trade.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub curve: Option<String>,
}

impl AppProfile {
    /// Whether a process name from /proc matches this entry.
    pub fn matches(&self, name: &str) -> bool {
        let want = self.process.trim().to_ascii_lowercase();
        if want.is_empty() {
            return false;
        }
        let have = name.trim().to_ascii_lowercase();
        if have == want {
            return true;
        }
        // comm is truncated; compare what the kernel would have kept.
        want.len() > COMM_MAX && have == want[..COMM_MAX]
    }

    /// A one-line description, for the CLI and the UI.
    pub fn summary(&self) -> String {
        let mut parts = Vec::new();
        if let Some(p) = &self.profile {
            parts.push(p.clone());
        }
        // The curve says more than "fan curve" does, so it replaces that half
        // rather than being listed next to it.
        if let Some(c) = &self.curve {
            parts.push(format!("{c} curve"));
        } else if let Some(f) = &self.fan {
            parts.push(format!("fan {f}"));
        }
        if parts.is_empty() {
            "nothing to apply".into()
        } else {
            parts.join(", ")
        }
    }
}

/// Process names currently running, lowercased.
///
/// Reads /proc directly rather than shelling out to ps: this runs on a timer
/// in a daemon, and a process spawn every few seconds to list processes is a
/// silly way to find out whether a game is open.
pub fn running_processes() -> Vec<String> {
    let Ok(entries) = std::fs::read_dir("/proc") else {
        return Vec::new();
    };

    let mut names = Vec::new();
    for entry in entries.flatten() {
        let Ok(pid) = entry.file_name().to_string_lossy().parse::<u32>() else {
            continue;
        };
        let dir = entry.path();

        if let Ok(comm) = std::fs::read_to_string(dir.join("comm")) {
            names.push(comm.trim().to_ascii_lowercase());
        }
        // The executable's real name, for processes whose comm was renamed or
        // truncated. Unreadable for other users' processes, which is fine:
        // the daemon is root and sees them all.
        if let Ok(exe) = std::fs::read_link(dir.join("exe")) {
            if let Some(base) = exe.file_name().and_then(|n| n.to_str()) {
                let base = base.to_ascii_lowercase();
                if !names.contains(&base) {
                    names.push(base);
                }
            }
        }
        let _ = pid;
    }
    names
}

/// The first configured profile whose process is running.
///
/// First rather than best: the order in the config file is the user's own
/// priority, and picking by some other rule would make two overlapping
/// entries behave in a way nobody can predict from reading the file.
pub fn active<'a>(profiles: &'a [AppProfile], running: &[String]) -> Option<&'a AppProfile> {
    profiles
        .iter()
        .find(|p| running.iter().any(|name| p.matches(name)))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn profile(process: &str) -> AppProfile {
        AppProfile {
            process: process.into(),
            profile: Some("performance".into()),
            fan: None,
            curve: None,
        }
    }

    #[test]
    fn matching_ignores_case() {
        assert!(profile("Steam").matches("steam"));
        assert!(profile("steam").matches("STEAM"));
    }

    #[test]
    fn a_long_name_matches_the_truncated_comm() {
        // The kernel would report this as "ThisIsAVeryLong".
        let p = profile("ThisIsAVeryLongProcessName");
        assert!(p.matches("thisisaverylong"));
        assert!(!p.matches("thisisaverylon"));
    }

    #[test]
    fn a_short_name_is_not_a_prefix_match() {
        // "steam" must not match "steamwebhelper" - that is a different
        // program, and it is running most of the time.
        assert!(!profile("steam").matches("steamwebhelper"));
    }

    #[test]
    fn the_first_running_entry_wins() {
        let list = vec![profile("alpha"), profile("beta")];
        let running = vec!["beta".to_string(), "alpha".to_string()];
        assert_eq!(active(&list, &running).unwrap().process, "alpha");
        assert!(active(&list, &["gamma".to_string()]).is_none());
    }

    #[test]
    fn an_empty_process_name_matches_nothing() {
        assert!(!profile("").matches(""));
        assert!(!profile("   ").matches("steam"));
    }
}
