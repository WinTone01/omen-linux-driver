//! How the previous session ended.
//!
//! A thermal cutout is the one failure this project exists to prevent, and it
//! is also the one that leaves no trace anybody looks at: the machine goes
//! off, it comes back, and the next question is "why did it reboot?" with
//! nothing to answer it. The journal from the boot before is still there, and
//! it knows.
//!
//! Two questions, kept separate because they have different answers:
//!
//! * **Did the machine shut down, or did it stop?** A clean shutdown leaves a
//!   trail - services stopped, targets reached, filesystems unmounted - and
//!   its absence means the machine went down without one: a power loss, a
//!   held power button, a panic, or a thermal cutout. What it does NOT leave
//!   reliably is its own last word: the journal is stopped before the end, so
//!   the final "Reached target Power-Off" usually never reaches the disk.
//!   Looking for that line reports every clean shutdown as a crash, which is
//!   what the first version of this did.
//! * **Was it hot?** The kernel says so when it is - `critical temperature
//!   reached`, a thermal shutdown, a machine check. That evidence is what
//!   turns "it stopped" into "it stopped because of heat", and without it we
//!   do not claim the second.
//!
//! Nothing here is a dirty flag of our own. A flag written at start and
//! cleared at exit cannot tell a power cut from this daemon being killed, and
//! the system's own record already carries the distinction.

use serde::{Deserialize, Serialize};

/// How many lines of the previous boot's tail to look at. A clean shutdown
/// puts its markers in the last dozen; this is generous.
const TAIL: usize = 60;

/// What the kernel says on its way down when the cause is heat. Matched
/// case-insensitively against the previous boot.
const THERMAL_PATTERNS: &str =
    "critical temperature|thermal shutdown|temperature above threshold|Machine check|mce:";

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Ending {
    /// systemd wrote its shutdown markers: the machine was told to go.
    Clean,
    /// It stopped without them.
    Unclean,
    /// There is no previous boot in the journal, or it cannot be read from
    /// here. Not a finding - a machine with a volatile journal is an ordinary
    /// machine, and so is a user who is not in the systemd-journal group.
    Unknown,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LastBoot {
    pub ending: Ending,
    /// The line that says it was hot, when there is one. Quoted rather than
    /// summarised: "the kernel said this" is evidence, "it overheated" is a
    /// conclusion, and the difference matters in a bug report.
    pub thermal: Option<String>,
}

impl LastBoot {
    /// One sentence about the previous session.
    pub fn describe(&self) -> String {
        match (self.ending, &self.thermal) {
            (Ending::Clean, _) => "the last shutdown was clean".into(),
            (Ending::Unclean, Some(line)) => {
                format!("the machine went down without shutting down, and the log before it says: {line}")
            }
            (Ending::Unclean, None) => {
                "the machine went down without shutting down - a power loss, a held power \
                 button, a panic or a thermal cutout all look like this"
                    .into()
            }
            (Ending::Unknown, _) => "there is no previous boot in the journal to read".into(),
        }
    }
}

/// Asks the journal.
///
/// Shelling out to journalctl for the same reason the report does: the
/// journal is a binary format whose reader is a library nobody should link
/// for two questions, and the command is on every machine that runs systemd.
pub fn probe() -> LastBoot {
    let Some(tail) = journal(&["-b", "-1", "-n", &TAIL.to_string()]) else {
        return LastBoot {
            ending: Ending::Unknown,
            thermal: None,
        };
    };

    let clean = ended_cleanly(&tail);

    // Only worth asking when it was not clean: on a machine that shut down
    // properly, a thermal line from hours earlier is history, not a cause.
    let thermal = (!clean)
        .then(|| journal(&["-b", "-1", "-g", THERMAL_PATTERNS, "-n", "3"]))
        .flatten()
        .and_then(|text| {
            text.lines()
                .map(str::trim)
                .find(|l| !l.is_empty() && !l.starts_with("-- "))
                .map(str::to_owned)
        });

    LastBoot {
        ending: if clean {
            Ending::Clean
        } else {
            Ending::Unclean
        },
        thermal,
    }
}

/// Whether the tail of a boot's journal looks like a shutdown.
///
/// By the trail rather than by the last word, for the reason in the module
/// note. Unmounting a filesystem and stopping a target are things that happen
/// on the way out and essentially nowhere else, so a couple of them in the
/// last minute of a boot is a shutdown in progress. One alone is not:
/// a removable disk is unmounted at runtime, and a socket unit stops.
///
/// Erring towards "clean" is deliberate. Reporting a crash that did not
/// happen is worse than missing one that did: the first teaches people to
/// ignore the check, and the second still shows up the next time.
pub fn ended_cleanly(tail: &str) -> bool {
    const STRONG: &[&str] = &[
        "Reached target Power-Off",
        "Reached target Reboot",
        "Reached target Shutdown",
        "Reached target Halt",
        "systemd-shutdown",
        "Powering off",
        "Rebooting",
    ];
    if STRONG.iter().any(|marker| tail.contains(marker)) {
        return true;
    }

    let marks = tail
        .lines()
        .filter(|line| {
            line.contains(": Unmounted ")
                || line.contains("Stopped target ")
                || line.contains("Stopping ")
                || line.contains("Shutting down")
        })
        .count();
    marks >= 2
}

fn journal(args: &[&str]) -> Option<String> {
    let out = std::process::Command::new("journalctl")
        .args(args)
        .args(["--no-pager", "-o", "short-iso"])
        .output()
        .ok()?;
    // A failure here is "no previous boot" or "not allowed to read it", and
    // both are Unknown rather than something to report.
    out.status
        .success()
        .then(|| String::from_utf8_lossy(&out.stdout).into_owned())
        .filter(|text| !text.trim().is_empty())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn probing_answers_something_on_any_machine() {
        // A laptop with a persistent journal answers clean or unclean; a
        // container answers unknown. All three are fine.
        let boot = probe();
        assert!(!boot.describe().is_empty());
    }

    #[test]
    fn a_clean_shutdown_is_recognised_by_its_trail() {
        // Real tail from this machine, which the first version of this called
        // a crash: the journal stops before systemd's last word, so what
        // survives is the unmounting.
        let tail = "\
systemd[1]: Unmounted /boot/efi.
systemd[1]: root.mount: Deactivated successfully.
systemd[1]: Unmounted /root.
systemd[1]: home.mount: Deactivated successfully.
systemd[1]: Unmounted /home.
systemd[1]: systemd-timesyncd.service: Deactivated successfully.
systemd[1]: Stopped Network Time Synchronization.";
        assert!(ended_cleanly(tail));
    }

    #[test]
    fn a_machine_that_simply_stopped_is_not_clean() {
        // Ordinary runtime noise, right up to the last line.
        let tail = "\
kernel: amdgpu: pm: 1 traps
NetworkManager[900]: <info> dhcp4 lease renewed
systemd[1]: Started Daily man-db regeneration.
kernel: CPU3: Package temperature/speed normal";
        assert!(!ended_cleanly(tail));
    }

    #[test]
    fn one_ordinary_unmount_is_not_a_shutdown() {
        let tail = "\
kernel: usb 1-2: USB disconnect
systemd[1]: Unmounted /run/media/wintone/STICK.
NetworkManager[900]: <info> dhcp4 lease renewed";
        assert!(
            !ended_cleanly(tail),
            "pulling a memory stick is not a shutdown"
        );
    }

    #[test]
    fn an_unclean_ending_without_evidence_does_not_blame_the_heat() {
        let boot = LastBoot {
            ending: Ending::Unclean,
            thermal: None,
        };
        let text = boot.describe();
        assert!(text.contains("power loss"), "{text}");
        assert!(!text.contains("thermal cutout."), "no conclusion: {text}");
    }

    #[test]
    fn an_unclean_ending_with_evidence_quotes_it() {
        let boot = LastBoot {
            ending: Ending::Unclean,
            thermal: Some("kernel: CPU0: Core temperature above threshold".into()),
        };
        assert!(boot.describe().contains("above threshold"));
    }
}
