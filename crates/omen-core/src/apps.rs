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

use std::path::Path;

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

    /// The internal panel's refresh rate while this is open, in Hz.
    ///
    /// Asked for here and applied by the desktop session's side - `omenctl
    /// session` - because a refresh rate belongs to the compositor, and the
    /// daemon runs outside any session. See display.rs.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub refresh_hz: Option<u32>,
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
            parts.push(crate::curve::rule_curve_label(c));
        } else if let Some(f) = &self.fan {
            parts.push(format!("fan {f}"));
        }
        if let Some(hz) = self.refresh_hz {
            parts.push(format!("{hz} Hz"));
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
            // A Windows game's own name, in full - comm has only the first
            // fifteen characters of it.
            if let Some(name) = windows_name(&exe, &dir) {
                let name = name.to_ascii_lowercase();
                if !names.contains(&name) {
                    names.push(name);
                }
            }
        }
        let _ = pid;
    }
    names
}

/// The Windows program a Wine or Proton process is running, if it is one.
///
/// Under Wine every Windows program's executable is Wine's own loader -
/// wine64-preloader, wine-preloader or plain wine, depending on the version -
/// so /proc/<pid>/exe says "wine64-preloader" for Cyberpunk2077.exe and for
/// every other game alike. The loader puts the Windows path in argv[0]
/// (`C:\...\bin\x64\Cyberpunk2077.exe`), and that is the name a person is
/// looking for.
fn windows_name(exe: &Path, dir: &Path) -> Option<String> {
    let loader = exe.file_name()?.to_str()?;
    if !is_wine_loader(loader) {
        return None;
    }
    let cmdline = std::fs::read(dir.join("cmdline")).ok()?;
    let argv0 = cmdline.split(|&b| b == 0).next()?;
    let argv0 = String::from_utf8_lossy(argv0);
    windows_basename(&argv0)
}

fn is_wine_loader(name: &str) -> bool {
    let name = name.trim_end_matches(" (deleted)");
    matches!(
        name,
        "wine" | "wine64" | "wine-preloader" | "wine64-preloader"
    )
}

/// `C:\Games\Foo\foo.exe` or `/home/x/foo.exe` -> `foo.exe`; anything that is
/// not a Windows program -> None.
fn windows_basename(path: &str) -> Option<String> {
    let base = path.rsplit(['\\', '/']).next()?.trim();
    let lower = base.to_ascii_lowercase();
    (lower.len() > 4 && (lower.ends_with(".exe") || lower.ends_with(".com")))
        .then(|| base.to_owned())
}

/// Wine's own processes, and Proton's: running alongside every Windows game,
/// so they are listed after the things a person is looking for, like the
/// desktop's plumbing is.
fn is_wine_plumbing(name: &str) -> bool {
    const PLUMBING: &[&str] = &[
        "wineserver",
        "services.exe",
        "winedevice.exe",
        "plugplay.exe",
        "svchost.exe",
        "explorer.exe",
        "rpcss.exe",
        "tabtip.exe",
        "conhost.exe",
        "rundll32.exe",
        "start.exe",
        "steam.exe",
        "wineboot.exe",
        "winemenubuilder.exe",
        "mscorsvw.exe",
        "pv-adverb",
        "reaper",
        "srt-bwrap",
    ];
    let lower = name.to_ascii_lowercase();
    PLUMBING.contains(&lower.as_str()) || is_wine_loader(&lower)
}

/// The programs this user is running, as names you could put in a profile.
///
/// For the "which process is my game?" problem, which is the one thing about
/// application profiles that people get wrong: the name has to match what the
/// kernel calls it, and a launcher usually spawns something else entirely.
/// Rather than guess from an installed-games list - Steam's manifests name
/// the game, not the binary - this lists what is actually running now, so the
/// answer is "start the game, then pick it from the list".
///
/// Filtered to this user's own programs with a real executable: kernel
/// threads have none, and system daemons belong to other users. That leaves
/// roughly what a person would recognise.
pub fn user_programs() -> Vec<String> {
    let Ok(entries) = std::fs::read_dir("/proc") else {
        return Vec::new();
    };
    let me = std::fs::metadata("/proc/self").map(|m| {
        use std::os::unix::fs::MetadataExt;
        m.uid()
    });
    let Ok(me) = me else { return Vec::new() };

    // (from the system's own directories?, name). Games live in a home
    // directory, /opt, a Steam library or a flatpak; the desktop's own
    // plumbing lives in /usr. Both are listed - a denylist of session
    // daemons would be guesswork that goes stale - but the ones somebody is
    // actually looking for come first.
    let mut names: Vec<(bool, String)> = Vec::new();
    for entry in entries.flatten() {
        let dir = entry.path();
        if entry.file_name().to_string_lossy().parse::<u32>().is_err() {
            continue;
        }
        // Ours?
        let owned = std::fs::metadata(&dir)
            .map(|m| {
                use std::os::unix::fs::MetadataExt;
                m.uid() == me
            })
            .unwrap_or(false);
        if !owned {
            continue;
        }
        // A real executable on disk. This is what drops kernel threads, and
        // it is also the name a profile should match.
        let Ok(exe) = std::fs::read_link(dir.join("exe")) else {
            continue;
        };
        let Some(name) = exe.file_name().and_then(|n| n.to_str()) else {
            continue;
        };
        // Deleted binaries come back as "thing (deleted)".
        let name = name.trim_end_matches(" (deleted)").to_owned();
        // A Windows game is named after itself, not after Wine's loader.
        let name = windows_name(&exe, &dir).unwrap_or(name);
        if name.is_empty() || names.iter().any(|(_, n)| *n == name) {
            continue;
        }
        let system = is_wine_plumbing(&name)
            || ["/usr/", "/bin/", "/sbin/"]
                .iter()
                .any(|prefix| exe.to_string_lossy().starts_with(prefix));
        names.push((system, name));
    }
    names.sort_by_key(|(system, name)| (*system, name.to_ascii_lowercase()));
    names.into_iter().map(|(_, name)| name).collect()
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
            refresh_hz: None,
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
    fn the_running_programs_are_ours_and_named() {
        // Whatever this machine is running, the list must contain no empty
        // names, no duplicates, and nothing with a path in it - these go
        // straight into a profile's process field.
        let names = user_programs();
        let mut seen = names.clone();
        seen.dedup();
        assert_eq!(seen.len(), names.len(), "duplicates");
        for name in &names {
            assert!(!name.is_empty());
            assert!(!name.contains('/'), "{name} is a path, not a name");
            assert!(!name.ends_with("(deleted)"), "{name}");
        }
    }

    #[test]
    fn a_windows_game_is_named_after_itself_not_after_wine() {
        assert_eq!(
            windows_basename(r"C:\Program Files\Cyberpunk 2077\bin\x64\Cyberpunk2077.exe")
                .as_deref(),
            Some("Cyberpunk2077.exe")
        );
        assert_eq!(
            windows_basename("Z:\\home\\me\\game.EXE").as_deref(),
            Some("game.EXE")
        );
        assert_eq!(
            windows_basename("/home/me/.steam/x/Game.exe").as_deref(),
            Some("Game.exe")
        );
        // Wine's loader started on something that is not a program.
        assert_eq!(windows_basename("/usr/bin/wine64-preloader"), None);
        assert_eq!(windows_basename(".exe"), None);
        assert!(is_wine_loader("wine64-preloader"));
        assert!(!is_wine_loader("wineserver"));
    }

    #[test]
    fn the_full_windows_name_matches_where_comm_has_fifteen_characters() {
        // comm for Cyberpunk2077.exe is "Cyberpunk2077.e"; the profile
        // matches either that or the full name taken from argv[0].
        let p = profile("Cyberpunk2077.exe");
        assert!(p.matches("cyberpunk2077.e"));
        assert!(p.matches("cyberpunk2077.exe"));
    }

    #[test]
    fn wine_plumbing_is_not_mistaken_for_the_game() {
        for name in ["wineserver", "services.exe", "explorer.exe", "steam.exe"] {
            assert!(is_wine_plumbing(name), "{name}");
        }
        assert!(!is_wine_plumbing("Cyberpunk2077.exe"));
    }

    #[test]
    fn an_empty_process_name_matches_nothing() {
        assert!(!profile("").matches(""));
        assert!(!profile("   ").matches("steam"));
    }
}
