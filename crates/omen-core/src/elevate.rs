//! The handful of things here that need root, and how to ask for it.
//!
//! Almost nothing in this project does. That is the design: the daemon holds
//! the privileges, clients talk to it over a socket owned by the `omen`
//! group, and the LEDs are reachable through a udev rule. What is left is the
//! plumbing around it - restarting the service after an upgrade, reloading a
//! module, loading `ec_sys` so the GPU temperature can be read, joining the
//! group in the first place.
//!
//! Until now those were printed as commands to copy into a terminal. That is
//! fine in a terminal and poor everywhere else: the window ends up telling
//! people to go and find a shell, and the diagnosis knows exactly what needs
//! running but cannot run it.
//!
//! So this asks, through whatever the machine has:
//!
//! * **`pkexec`** on a desktop - polkit puts up the session's own password
//!   dialog, which is the one people already recognise and the only one that
//!   should ever be typed into.
//! * **`sudo`** on a terminal, where a prompt in the terminal is expected.
//! * **Neither** - the command is handed back to be run by hand, which is
//!   where this started.
//!
//! **What may be run is a closed list.** Every action is an `Action` variant
//! with its argv written here, in the binary. Nothing accepts a command from
//! a caller, a config file or the window - a "run this as root" API that
//! takes a string is a root shell with extra steps, and the UI is the last
//! place that should have one.

use serde::{Deserialize, Serialize};

/// Something that needs root, named rather than spelled.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum Action {
    /// Restart the service - what an upgrade needs before the new daemon is
    /// the one running.
    RestartDaemon,
    /// Start it and have it start at boot.
    EnableDaemon,
    /// Reload hp-wmi, so a newly installed build replaces the loaded one.
    ReloadHpWmi,
    /// The same for our own module.
    ReloadRgb,
    /// Load `ec_sys` read-only, which is how the discrete GPU's temperature
    /// becomes readable. Explicitly `write_support=0`: on this board a bad EC
    /// write locks the keyboard controller until a power cycle.
    LoadEcSys,
    /// Add this user to the `omen` group, so the socket is reachable without
    /// sudo. Takes effect at the next login, which the caller is told.
    JoinOmenGroup,
}

impl Action {
    pub fn as_str(self) -> &'static str {
        match self {
            Self::RestartDaemon => "restart-daemon",
            Self::EnableDaemon => "enable-daemon",
            Self::ReloadHpWmi => "reload-hp-wmi",
            Self::ReloadRgb => "reload-rgb",
            Self::LoadEcSys => "load-ec-sys",
            Self::JoinOmenGroup => "join-omen-group",
        }
    }

    pub fn parse(name: &str) -> Option<Self> {
        Some(match name.trim() {
            "restart-daemon" => Self::RestartDaemon,
            "enable-daemon" => Self::EnableDaemon,
            "reload-hp-wmi" => Self::ReloadHpWmi,
            "reload-rgb" => Self::ReloadRgb,
            "load-ec-sys" => Self::LoadEcSys,
            "join-omen-group" => Self::JoinOmenGroup,
            _ => return None,
        })
    }

    pub fn all() -> &'static [Action] {
        &[
            Action::RestartDaemon,
            Action::EnableDaemon,
            Action::ReloadHpWmi,
            Action::ReloadRgb,
            Action::LoadEcSys,
            Action::JoinOmenGroup,
        ]
    }

    /// What it does, in a few words.
    pub fn title(self) -> &'static str {
        match self {
            Self::RestartDaemon => "Restart the service",
            Self::EnableDaemon => "Start the service, and at every boot",
            Self::ReloadHpWmi => "Reload hp-wmi",
            Self::ReloadRgb => "Reload omen-kbd-rgb",
            Self::LoadEcSys => "Load ec_sys (read-only)",
            Self::JoinOmenGroup => "Join the 'omen' group",
        }
    }

    /// Why anyone would want it. Shown next to the button, because a
    /// password prompt with no stated reason is one people learn to click
    /// through.
    pub fn why(self) -> &'static str {
        match self {
            Self::RestartDaemon => {
                "An upgrade leaves the old daemon running until it is restarted."
            }
            Self::EnableDaemon => "Nothing runs the fan curve until the service is running.",
            Self::ReloadHpWmi => {
                "A module keeps running the build that was loaded, not the one installed."
            }
            Self::ReloadRgb => {
                "Same for the lighting module - the keyboard keeps the old build until it is \
                 reloaded."
            }
            Self::LoadEcSys => {
                "The discrete GPU's temperature comes from the EC. Without this the curve only \
                 follows the CPU."
            }
            Self::JoinOmenGroup => {
                "The daemon's socket belongs to that group; without it every command needs sudo. \
                 Log out and back in afterwards."
            }
        }
    }

    /// Exactly what will be run, as it would be typed. Shown before anything
    /// is run, and printed when there is no way to ask for a password.
    pub fn command(self) -> String {
        self.argv()
            .into_iter()
            // Quoted where it matters, so what is printed is what you could
            // paste. `sh -c modprobe -r hp_wmi && modprobe hp_wmi` is not the
            // command we run, and printing it that way invites somebody to
            // run something else by hand.
            .map(|part| {
                if part.contains(' ') {
                    format!("'{part}'")
                } else {
                    part
                }
            })
            .collect::<Vec<_>>()
            .join(" ")
    }

    /// The argv, fixed here and nowhere else.
    ///
    /// The two module reloads are a remove and an insert, which is two
    /// commands; they go through `sh -c` with a constant string rather than
    /// prompting twice. The constant is the point - nothing from outside this
    /// file reaches a shell.
    fn argv(self) -> Vec<String> {
        let owned = |parts: &[&str]| parts.iter().map(|s| (*s).to_owned()).collect();
        match self {
            Self::RestartDaemon => owned(&["systemctl", "restart", "omend"]),
            Self::EnableDaemon => owned(&["systemctl", "enable", "--now", "omend"]),
            Self::ReloadHpWmi => owned(&["sh", "-c", "modprobe -r hp_wmi && modprobe hp_wmi"]),
            Self::ReloadRgb => owned(&[
                "sh",
                "-c",
                "modprobe -r omen-kbd-rgb && modprobe omen-kbd-rgb",
            ]),
            Self::LoadEcSys => owned(&["modprobe", "ec_sys", "write_support=0"]),
            Self::JoinOmenGroup => {
                vec![
                    "usermod".into(),
                    "-aG".into(),
                    "omen".into(),
                    // Our own login name, read from the system rather than
                    // taken from anywhere a caller could set.
                    current_user(),
                ]
            }
        }
    }

    /// Whether this machine actually needs it right now.
    ///
    /// Not "is it installed" but "is it out of step": a list of things that
    /// could be run is a menu, and a menu of root commands is exactly what
    /// this was meant to replace. A clean machine offers nothing.
    pub fn applicable(self) -> bool {
        match self {
            // Installed and out of date with what is on disk. The daemon
            // keeps running the binary it started with, which after an
            // upgrade is the old one.
            Self::RestartDaemon => service_installed() && service_active() && daemon_is_stale(),
            Self::EnableDaemon => service_installed() && !service_active(),
            Self::ReloadHpWmi => crate::about::module_status("hp_wmi").stale(),
            Self::ReloadRgb => crate::about::module_status("omen_kbd_rgb").stale(),
            // Only worth offering where it would buy something: the GPU
            // temperature comes from the EC, and without the module nothing
            // can read it.
            Self::LoadEcSys => {
                !std::path::Path::new("/sys/module/ec_sys").exists()
                    && std::path::Path::new("/sys/module/hp_wmi").exists()
            }
            Self::JoinOmenGroup => group_exists() && !in_omen_group(),
        }
    }
}

impl std::fmt::Display for Action {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(self.as_str())
    }
}

/// How root can be asked for here.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Asker {
    /// Already root: nothing to ask.
    Root,
    /// polkit, with the desktop's own dialog.
    Pkexec,
    /// sudo, prompting on this terminal.
    Sudo,
    /// Neither is usable from here.
    None,
}

impl Asker {
    /// What this machine will use.
    ///
    /// pkexec is preferred wherever there is a session to put a dialog in
    /// front of, because that dialog is the one the desktop itself uses - and
    /// a password should only ever be typed into a prompt somebody already
    /// recognises. A terminal with no display falls back to sudo, where the
    /// prompt appears where the person is looking.
    pub fn detect() -> Self {
        if is_root() {
            return Self::Root;
        }
        let graphical =
            std::env::var_os("WAYLAND_DISPLAY").is_some() || std::env::var_os("DISPLAY").is_some();
        if graphical && which("pkexec") {
            return Self::Pkexec;
        }
        if which("sudo") {
            return Self::Sudo;
        }
        if which("pkexec") {
            return Self::Pkexec;
        }
        Self::None
    }

    pub fn describe(self) -> &'static str {
        match self {
            Self::Root => "already running as root",
            Self::Pkexec => "your desktop's own password dialog (polkit)",
            Self::Sudo => "sudo, which will ask on this terminal",
            Self::None => "nothing here can ask for a password",
        }
    }
}

/// Runs one action, asking for a password the way this machine asks.
///
/// Returns what it printed, or an error that includes the command so it can
/// be run by hand. A cancelled password dialog is an error like any other -
/// deliberately not retried, and deliberately not distinguished with a
/// special case that could loop.
pub fn run(action: Action) -> Result<String, String> {
    let asker = Asker::detect();
    let argv = action.argv();

    let mut cmd = match asker {
        Asker::Root => {
            let mut c = std::process::Command::new(&argv[0]);
            c.args(&argv[1..]);
            c
        }
        Asker::Pkexec => {
            let mut c = std::process::Command::new("pkexec");
            c.args(&argv);
            c
        }
        Asker::Sudo => {
            let mut c = std::process::Command::new("sudo");
            c.args(&argv);
            c
        }
        Asker::None => {
            return Err(format!(
                "neither pkexec nor sudo is available here. Run this yourself:\n    {}",
                action.command()
            ))
        }
    };

    let out = cmd
        .output()
        .map_err(|e| format!("could not run {}: {e}", action.command()))?;

    if out.status.success() {
        let text = String::from_utf8_lossy(&out.stdout).trim().to_owned();
        return Ok(if text.is_empty() {
            format!("{} - done", action.title())
        } else {
            text
        });
    }

    let stderr = String::from_utf8_lossy(&out.stderr).trim().to_owned();
    Err(format!(
        "{} failed{}{}\n    the command was: {}",
        action.title(),
        if stderr.is_empty() { "" } else { ": " },
        stderr,
        action.command()
    ))
}

fn service_installed() -> bool {
    [
        "/usr/lib/systemd/system/omend.service",
        "/etc/systemd/system/omend.service",
    ]
    .iter()
    .any(|p| std::path::Path::new(p).exists())
}

fn service_active() -> bool {
    std::process::Command::new("systemctl")
        .args(["is-active", "--quiet", "omend"])
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

/// Whether the daemon that is running is older than the one installed.
///
/// Asked of the daemon rather than inferred from file times: it is the only
/// thing that knows what it was built from, and a daemon too old to report a
/// version at all is by definition older than this binary.
fn daemon_is_stale() -> bool {
    match crate::ipc::client::send(&crate::ipc::Request::Status) {
        Ok(crate::ipc::Response::Ok(snap)) => {
            snap.version.as_deref() != Some(crate::about::VERSION)
        }
        // Unreachable is not stale: it may be a permission problem, and
        // offering to restart the service over that would be a wrong guess
        // with a password prompt attached.
        _ => false,
    }
}

fn group_exists() -> bool {
    std::fs::read_to_string("/etc/group")
        .map(|g| g.lines().any(|l| l.starts_with("omen:")))
        .unwrap_or(false)
}

fn which(program: &str) -> bool {
    std::env::var_os("PATH")
        .map(|paths| {
            std::env::split_paths(&paths).any(|dir| {
                let path = dir.join(program);
                path.is_file() && is_executable(&path)
            })
        })
        .unwrap_or(false)
}

fn is_executable(path: &std::path::Path) -> bool {
    use std::os::unix::fs::PermissionsExt;
    std::fs::metadata(path)
        .map(|m| m.permissions().mode() & 0o111 != 0)
        .unwrap_or(false)
}

fn is_root() -> bool {
    std::fs::read_to_string("/proc/self/status")
        .ok()
        .and_then(|s| {
            s.lines()
                .find_map(|l| l.strip_prefix("Uid:"))
                .and_then(|l| l.split_whitespace().next().map(|v| v == "0"))
        })
        .unwrap_or(false)
}

/// This process's login name, from the system's own idea of it.
///
/// `$USER` is not trusted for this: it is an environment variable, and the
/// one place this value goes is an argv that runs as root.
fn current_user() -> String {
    let uid = std::fs::read_to_string("/proc/self/status")
        .ok()
        .and_then(|s| {
            s.lines()
                .find_map(|l| l.strip_prefix("Uid:"))
                .and_then(|l| l.split_whitespace().next().map(str::to_owned))
        })
        .unwrap_or_default();

    std::fs::read_to_string("/etc/passwd")
        .ok()
        .and_then(|passwd| {
            passwd.lines().find_map(|line| {
                let mut f = line.split(':');
                let name = f.next()?;
                let _pw = f.next()?;
                (f.next()? == uid).then(|| name.to_owned())
            })
        })
        // No name is better than the wrong name: usermod will refuse an empty
        // argument, which is the failure we want if it ever comes to that.
        .unwrap_or_default()
}

fn in_omen_group() -> bool {
    let Ok(status) = std::fs::read_to_string("/proc/self/status") else {
        return false;
    };
    let Some(groups) = status.lines().find_map(|l| l.strip_prefix("Groups:")) else {
        return false;
    };
    let Ok(passwd) = std::fs::read_to_string("/etc/group") else {
        return false;
    };
    let Some(gid) = passwd.lines().find_map(|line| {
        let mut f = line.split(':');
        if f.next()? != "omen" {
            return None;
        }
        // name:password:gid - skip the password field.
        f.nth(1).map(str::to_owned)
    }) else {
        return false;
    };
    groups.split_whitespace().any(|g| g == gid)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn every_action_round_trips_through_its_name() {
        for action in Action::all() {
            assert_eq!(Action::parse(action.as_str()), Some(*action));
        }
        assert_eq!(Action::parse("rm -rf /"), None);
        assert_eq!(Action::parse(""), None);
    }

    #[test]
    fn nothing_outside_this_file_can_reach_a_shell() {
        // The two module reloads use sh -c, and the string they pass has to
        // stay a constant. If a future edit interpolates anything into it,
        // this is the test that should fail first.
        for action in Action::all() {
            let argv = action.argv();
            if argv.first().map(String::as_str) == Some("sh") {
                let script = argv.get(2).cloned().unwrap_or_default();
                assert!(
                    script.contains("modprobe"),
                    "the only shell we run is a module reload"
                );
                assert!(
                    !script.contains('$') && !script.contains('`'),
                    "no substitution in a command that runs as root: {script}"
                );
            }
        }
    }

    #[test]
    fn the_user_name_comes_from_the_system_not_the_environment() {
        // Whatever this machine says, it must not be what $USER says if the
        // two disagree - so assert only that the lookup does not read it.
        let source = include_str!("elevate.rs");
        let uses_env_user = source.matches("\"USER\"").count();
        assert_eq!(uses_env_user, 0, "$USER must not decide who is elevated");
    }

    #[test]
    fn asking_is_possible_here_or_says_why_not() {
        // On any developer machine this is pkexec or sudo; in a container it
        // may be neither, and that has to be a sentence rather than a panic.
        let asker = Asker::detect();
        assert!(!asker.describe().is_empty());
    }

    #[test]
    fn commands_are_printable_without_running_them() {
        for action in Action::all() {
            let text = action.command();
            assert!(!text.is_empty());
            assert!(!action.title().is_empty());
            assert!(!action.why().is_empty());
        }
    }
}
