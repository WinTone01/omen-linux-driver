//! The unix socket listener.
//!
//! One JSON request per line, one JSON reply per line. To poke at it by hand:
//! `sudo socat - UNIX-CONNECT:/run/omend/omend.sock` then `{"cmd":"status"}`

use std::io::{BufRead, BufReader, Write};
use std::os::unix::fs::PermissionsExt;
use std::os::unix::net::{UnixListener, UnixStream};
use std::path::Path;

use anyhow::{Context, Result};
use log::{debug, error, info, warn};

use omen_core::ipc::{check_socket_path, socket_path, Request, Response};
use omen_core::profile::PlatformProfile;

use crate::shared::Shared;

/// How long a synchronous mode change waits for a loop iteration.
const APPLY_TIMEOUT: std::time::Duration = std::time::Duration::from_secs(5);

/// Creates the socket and moves the listener onto a background thread.
pub fn spawn(shared: Shared) -> Result<()> {
    let owned = socket_path();
    let path: &Path = &owned;
    check_socket_path(path).map_err(anyhow::Error::msg)?;

    // A socket file may be left over from a previous run. If something is
    // actually listening, bind would fail anyway; here we only remove an
    // orphaned file.
    if path.exists() {
        if UnixStream::connect(path).is_ok() {
            anyhow::bail!(
                "{} is already being listened on - another omend may be running",
                path.display()
            );
        }
        std::fs::remove_file(path)
            .with_context(|| format!("could not remove the stale socket: {}", path.display()))?;
    }

    let listener = UnixListener::bind(path)
        .with_context(|| format!("could not open the socket: {}", path.display()))?;

    // Fan control should not be open to everyone. 0660, plus the 'omen' group
    // where it exists; without that group it stays root-owned and clients
    // need sudo.
    std::fs::set_permissions(path, std::fs::Permissions::from_mode(0o660))
        .context("could not set socket permissions")?;
    match omen_group_gid() {
        // When the systemd unit runs with Group=omen the socket is already
        // created in the right group, so do not even attempt a chown - the
        // empty CapabilityBoundingSet means CAP_CHOWN is gone and trying
        // would only produce noise.
        Some(gid) if socket_gid(path) == Some(gid) => {
            info!("socket: {} (group 'omen', 0660)", path.display());
        }
        Some(gid) => match std::os::unix::fs::chown(path, None, Some(gid)) {
            Ok(()) => info!("socket: {} (group 'omen', 0660)", path.display()),
            Err(e) => warn!(
                "could not move the socket to the 'omen' group ({e}) - clients will need sudo. \
                 Under systemd, does the unit have 'Group=omen'?"
            ),
        },
        None => info!(
            "socket: {} (root, 0660 - no 'omen' group, clients will need sudo)",
            path.display()
        ),
    }

    std::thread::Builder::new()
        .name("omend-ipc".into())
        .spawn(move || {
            for stream in listener.incoming() {
                match stream {
                    Ok(s) => {
                        if let Err(e) = handle(s, &shared) {
                            debug!("client error: {e}");
                        }
                    }
                    Err(e) => error!("could not accept a connection: {e}"),
                }
            }
        })
        .context("could not start the listener thread")?;

    Ok(())
}

fn socket_gid(path: &Path) -> Option<u32> {
    use std::os::unix::fs::MetadataExt;
    std::fs::metadata(path).ok().map(|m| m.gid())
}

/// The gid of the 'omen' group from /etc/group. We parse the file ourselves
/// rather than pull in libc - the format is fixed and simple.
fn omen_group_gid() -> Option<u32> {
    let content = std::fs::read_to_string("/etc/group").ok()?;
    content.lines().find_map(|line| {
        let mut f = line.split(':');
        (f.next()? == "omen").then(|| f.nth(1)?.parse().ok())?
    })
}

fn handle(stream: UnixStream, shared: &Shared) -> Result<()> {
    let reader = BufReader::new(stream.try_clone()?);
    let mut writer = stream;

    for line in reader.lines() {
        let line = line?;
        if line.trim().is_empty() {
            continue;
        }
        let response = match serde_json::from_str::<Request>(&line) {
            Ok(req) => dispatch(req, shared),
            Err(e) => Response::Error {
                message: format!("could not parse the request: {e}"),
            },
        };
        let mut json = serde_json::to_string(&response)?;
        json.push('\n');
        writer.write_all(json.as_bytes())?;
        writer.flush()?;
    }
    Ok(())
}

fn dispatch(req: Request, shared: &Shared) -> Response {
    match req {
        Request::Status => Response::Ok(Box::new(shared.snapshot())),

        Request::SetMode(mode) => {
            info!("request: mode -> {mode}");
            // We wait for a loop iteration so the reply describes what is
            // actually in effect. Two intervals is plenty; past that the
            // request stays queued and is handled on the next tick.
            match shared.request_mode(mode, APPLY_TIMEOUT) {
                Some(applied) if applied == mode => Response::Done {
                    message: format!("mode: {applied}"),
                },
                Some(applied) => Response::Done {
                    message: format!(
                        "{mode} was requested but the drive stayed at {applied} \
                         (the critical cutout may have tripped)"
                    ),
                },
                None => Response::Done {
                    message: format!("{mode} queued (the loop did not respond)"),
                },
            }
        }

        Request::SetProfile { profile } => {
            let Some(pp) = PlatformProfile::discover() else {
                return Response::Error {
                    message: "no platform_profile".into(),
                };
            };
            let choices = pp.choices();
            if !choices.contains(&profile) {
                return Response::Error {
                    message: format!(
                        "invalid profile {profile:?}; choices: {}",
                        choices.join(" ")
                    ),
                };
            }
            match pp.set(&profile) {
                Ok(()) => {
                    info!("profile -> {profile}");
                    Response::Done {
                        message: format!("profile {profile}"),
                    }
                }
                Err(e) => Response::Error {
                    message: e.to_string(),
                },
            }
        }

        Request::Reload => {
            shared.request_reload();
            Response::Done {
                message: "the configuration will be re-read".into(),
            }
        }
    }
}
