//! Firmware updates, through fwupd.
//!
//! This reports and never flashes. Firmware is the one thing on the machine
//! that cannot be rolled back from a shell: a half-written BIOS is a service
//! appointment, and the checks that make flashing safe - AC power, battery
//! level, the right reboot method, a polkit prompt the user actually reads -
//! belong to fwupdmgr, which already does all of them. Duplicating that here
//! would add risk and remove nothing.
//!
//! So the card answers "is there anything to install, and what do I run",
//! and the running is done by fwupdmgr in a terminal.
//!
//! Talking to fwupd over D-Bus would avoid the process spawns, but it would
//! also mean tracking its interface across versions for output we render as
//! text anyway. The JSON these commands print is a stable, documented
//! interface.

use serde::Serialize;

/// Long enough for fwupd to start on demand and enumerate everything - the
/// first call after boot starts the daemon - and short enough that a wedged
/// call does not look like a frozen card forever.
const TIMEOUT: std::time::Duration = std::time::Duration::from_secs(45);
/// Refresh talks to the network, which can be slower than the local calls.
const REFRESH_TIMEOUT: std::time::Duration = std::time::Duration::from_secs(90);

#[derive(Debug, Serialize, Default)]
pub struct Firmware {
    pub available: bool,
    /// Why not, when it is not.
    pub error: Option<String>,
    pub devices: Vec<Device>,
    /// True when at least one device has an update waiting.
    pub updates: bool,
}

#[derive(Debug, Serialize)]
pub struct Device {
    pub name: String,
    pub version: Option<String>,
    /// The newest version fwupd knows of, when it is newer than the
    /// installed one.
    pub update: Option<String>,
    pub updatable: bool,
    /// Needs a reboot (or worse) to apply.
    pub needs_reboot: bool,
}

/// Runs a command with a deadline, rather than waiting on it forever.
///
/// `Command::output` has no timeout, and fwupdmgr can block indefinitely on a
/// device that is not answering. The child is killed when the deadline
/// passes, so a stuck scan reports a failure instead of hanging the card.
fn run(args: &[&str], timeout: std::time::Duration) -> Result<String, String> {
    use std::process::{Command, Stdio};

    let mut child = Command::new("fwupdmgr")
        .args(args)
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()
        .map_err(|e| format!("fwupdmgr could not be started: {e}"))?;

    let deadline = std::time::Instant::now() + timeout;
    loop {
        match child.try_wait() {
            Ok(Some(_)) => break,
            Ok(None) if std::time::Instant::now() >= deadline => {
                let _ = child.kill();
                let _ = child.wait();
                return Err(format!("fwupdmgr {} timed out", args[0]));
            }
            Ok(None) => std::thread::sleep(std::time::Duration::from_millis(100)),
            Err(e) => return Err(e.to_string()),
        }
    }

    let out = child
        .wait_with_output()
        .map_err(|e| format!("fwupdmgr: {e}"))?;
    // The exit status is deliberately ignored: `get-updates` exits non-zero
    // when there is simply nothing to update, which is a normal answer and
    // not a failure. What matters is whether the JSON parses.
    String::from_utf8(out.stdout).map_err(|_| "fwupdmgr printed something that is not text".into())
}

fn flags(dev: &serde_json::Value) -> Vec<String> {
    dev.get("Flags")
        .and_then(|f| f.as_array())
        .map(|a| {
            a.iter()
                .filter_map(|v| v.as_str().map(str::to_owned))
                .collect()
        })
        .unwrap_or_default()
}

/// Everything fwupd can see, plus whichever of them have an update waiting.
///
/// Two calls, because they answer different questions: get-devices is the
/// inventory and works offline; get-updates compares it against the metadata
/// already on disk. Neither goes near the network - that is `refresh`, and it
/// only happens when someone asks for it.
pub fn scan() -> Firmware {
    let devices_json = match run(&["get-devices", "--json"], TIMEOUT) {
        Ok(s) => s,
        Err(e) => {
            return Firmware {
                available: false,
                error: Some(e),
                ..Default::default()
            }
        }
    };
    // An error here is not a failure: get-updates exits non-zero and prints
    // nothing useful when there is nothing to update, which is the normal
    // case on a machine that is already up to date.
    let updates_json = run(&["get-updates", "--json"], TIMEOUT).unwrap_or_default();

    parse(&devices_json, &updates_json)
}

/// Turns the two JSON documents into the list the card renders.
///
/// Separate from the commands that produce them so it can be tested against
/// fixed input: this is the part that silently goes wrong when fwupd renames
/// a field, and "the card is empty" is a poor way to find that out.
fn parse(devices_json: &str, updates_json: &str) -> Firmware {
    let parsed: serde_json::Value = match serde_json::from_str(devices_json) {
        Ok(v) => v,
        Err(e) => {
            return Firmware {
                available: false,
                error: Some(format!("fwupd's output could not be read: {e}")),
                ..Default::default()
            }
        }
    };

    // Which devices have a newer version available, by id.
    let mut pending: std::collections::HashMap<String, String> = std::collections::HashMap::new();
    if let Ok(v) = serde_json::from_str::<serde_json::Value>(updates_json) {
        for dev in v
            .get("Devices")
            .and_then(|d| d.as_array())
            .unwrap_or(&vec![])
        {
            let id = dev.get("DeviceId").and_then(|i| i.as_str()).unwrap_or("");
            let newest = dev
                .get("Releases")
                .and_then(|r| r.as_array())
                .and_then(|r| r.first())
                .and_then(|r| r.get("Version"))
                .and_then(|v| v.as_str());
            if let (false, Some(newest)) = (id.is_empty(), newest) {
                pending.insert(id.to_owned(), newest.to_owned());
            }
        }
    }

    let mut devices = Vec::new();
    for dev in parsed
        .get("Devices")
        .and_then(|d| d.as_array())
        .unwrap_or(&vec![])
    {
        let name = dev
            .get("Name")
            .and_then(|n| n.as_str())
            .unwrap_or("")
            .to_owned();
        // A device with no name is an internal node of fwupd's tree, not
        // something a person can act on.
        if name.is_empty() {
            continue;
        }
        let f = flags(dev);
        let id = dev.get("DeviceId").and_then(|i| i.as_str()).unwrap_or("");

        devices.push(Device {
            update: pending.get(id).cloned(),
            version: dev
                .get("Version")
                .and_then(|v| v.as_str())
                .map(str::to_owned),
            updatable: f.iter().any(|x| x == "updatable"),
            needs_reboot: f.iter().any(|x| x == "needs-reboot"),
            name,
        });
    }

    // The interesting ones first: something to install, then things that
    // could be updated, then the rest.
    devices.sort_by_key(|d| (d.update.is_none(), !d.updatable));

    Firmware {
        available: true,
        error: None,
        updates: devices.iter().any(|d| d.update.is_some()),
        devices,
    }
}

/// Downloads the update metadata from LVFS. The one thing here that uses the
/// network, so it only ever runs when the user presses the button.
pub fn refresh() -> Result<String, String> {
    run(&["refresh", "--force"], REFRESH_TIMEOUT)?;
    Ok("metadata refreshed".into())
}

#[cfg(test)]
mod tests {
    use super::*;

    const DEVICES: &str = r#"{"Devices":[
        {"Name":"System Firmware","DeviceId":"aaa","Version":"F.09",
         "Flags":["internal","updatable","needs-reboot"]},
        {"Name":"TPM","DeviceId":"bbb","Version":"10.6.0.4","Flags":["internal"]},
        {"DeviceId":"ccc","Version":"1","Flags":["updatable"]}
    ]}"#;

    const UPDATES: &str = r#"{"Devices":[
        {"Name":"System Firmware","DeviceId":"aaa",
         "Releases":[{"Version":"F.12"},{"Version":"F.10"}]}
    ]}"#;

    #[test]
    fn an_update_is_matched_to_its_device_and_sorted_first() {
        let fw = parse(DEVICES, UPDATES);
        assert!(fw.available);
        assert!(fw.updates);
        let sys = &fw.devices[0];
        assert_eq!(sys.name, "System Firmware");
        // The newest release is the first in the list, not the last.
        assert_eq!(sys.update.as_deref(), Some("F.12"));
        assert!(sys.needs_reboot);
    }

    #[test]
    fn nameless_entries_are_dropped() {
        // fwupd's tree contains internal nodes nobody can act on.
        let fw = parse(DEVICES, UPDATES);
        assert_eq!(fw.devices.len(), 2);
    }

    #[test]
    fn nothing_waiting_is_not_an_error() {
        let fw = parse(DEVICES, r#"{"Devices":[]}"#);
        assert!(fw.available);
        assert!(!fw.updates);
        assert!(fw.devices.iter().all(|d| d.update.is_none()));
    }

    #[test]
    fn an_empty_updates_document_still_lists_the_devices() {
        // get-updates exits non-zero and prints nothing when there is nothing
        // to do; that must not blank the device list.
        let fw = parse(DEVICES, "");
        assert!(fw.available);
        assert_eq!(fw.devices.len(), 2);
    }

    #[test]
    fn unreadable_output_is_reported_rather_than_shown_as_empty() {
        let fw = parse("not json", "");
        assert!(!fw.available);
        assert!(fw.error.is_some());
    }
}
