//! The unix socket listener.
//!
//! One JSON request per line, one JSON reply per line. To poke at it by hand:
//! `sudo socat - UNIX-CONNECT:/run/omend/omend.sock` then `{"cmd":"status"}`

use std::io::{BufRead, BufReader, Write};
use std::os::unix::fs::PermissionsExt;
use std::os::unix::net::{UnixListener, UnixStream};
use std::path::{Path, PathBuf};

use anyhow::{Context, Result};
use log::{debug, error, info, warn};

use omen_core::config::Config;
use omen_core::curve;
use omen_core::ipc::{check_socket_path, socket_path, CurveSpec, Request, Response};
use omen_core::profile::PlatformProfile;

use crate::shared::Shared;

/// The most readings a client can ask for at once. The daemon keeps this
/// many; asking for more would only pad the reply.
const SAMPLE_MAX: usize = 900;

/// How long a synchronous mode change waits for a loop iteration.
const APPLY_TIMEOUT: std::time::Duration = std::time::Duration::from_secs(5);

/// Creates the socket and moves the listener onto a background thread.
pub fn spawn(shared: Shared, config_path: PathBuf) -> Result<()> {
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
                        if let Err(e) = handle(s, &shared, &config_path) {
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

fn handle(stream: UnixStream, shared: &Shared, config_path: &Path) -> Result<()> {
    let reader = BufReader::new(stream.try_clone()?);
    let mut writer = stream;

    for line in reader.lines() {
        let line = line?;
        if line.trim().is_empty() {
            continue;
        }
        let response = match serde_json::from_str::<Request>(&line) {
            Ok(req) => dispatch(req, shared, config_path),
            Err(e) => Response::Error {
                message: format!("could not parse the request: {e}"),
            },
        };
        // A reply that cannot be serialised used to drop the connection with
        // only a debug line, which looks exactly like a hung daemon from the
        // client side. It has happened twice, both times for the same reason
        // (serde cannot put a sequence under an internal tag), so answer with
        // the error instead of disappearing.
        let mut json = match serde_json::to_string(&response) {
            Ok(json) => json,
            Err(e) => {
                error!("a reply could not be serialised: {e}");
                serde_json::to_string(&Response::Error {
                    message: format!("the daemon could not encode its reply: {e}"),
                })?
            }
        };
        json.push('\n');
        writer.write_all(json.as_bytes())?;
        writer.flush()?;
    }
    Ok(())
}

fn dispatch(req: Request, shared: &Shared, config_path: &Path) -> Response {
    match req {
        Request::Status => Response::Ok(Box::new(shared.snapshot())),
        Request::OmenKeyPresses => Response::Presses {
            count: crate::hotkey::presses(),
        },

        // Capped here as well as in the daemon: a client asking for a million
        // entries should not be able to make the daemon build a million-entry
        // reply.
        Request::History { limit } => Response::History {
            decisions: shared.history(limit.min(500)),
        },

        Request::Samples { limit } => Response::Samples {
            samples: shared.samples(limit.min(SAMPLE_MAX)),
        },

        Request::SetMode(mode) => {
            // Answered here rather than queued, so a machine with no pwm1
            // says why instead of timing out and reporting that the loop did
            // not respond - which would be true and useless.
            if let Some(why) = no_fan_here() {
                return Response::Error { message: why };
            }
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

        Request::SetCurve(spec) => {
            info!(
                "request: curve -> {} points, {:?}",
                spec.points.len(),
                spec.interpolation
            );
            write_curve(config_path, shared, Some(spec))
        }

        Request::ResetCurve => {
            info!("request: curve -> built-in default");
            write_curve(config_path, shared, None)
        }

        Request::SetEffect(spec) => {
            info!(
                "request: lighting -> {} at speed {}",
                spec.effect, spec.speed
            );
            let mut cfg = match Config::load(config_path) {
                Ok(cfg) => cfg,
                Err(e) => {
                    return Response::Error {
                        message: format!("the current configuration could not be read: {e}"),
                    }
                }
            };
            cfg.lighting.set_spec(spec);
            if let Err(e) = cfg.save(config_path) {
                return Response::Error {
                    message: e.to_string(),
                };
            }
            shared.request_reload_sync(APPLY_TIMEOUT);
            Response::Done {
                message: match spec.effect {
                    omen_core::anim::Effect::None => "lighting effects off".into(),
                    other => format!("lighting: {other}"),
                },
            }
        }

        Request::SetAppProfiles { apps } => {
            info!("request: {} application profile(s)", apps.len());
            let mut cfg = match Config::load(config_path) {
                Ok(cfg) => cfg,
                Err(e) => {
                    return Response::Error {
                        message: format!("the current configuration could not be read: {e}"),
                    }
                }
            };
            cfg.apps = apps;
            if let Err(e) = cfg.save(config_path) {
                return Response::Error {
                    message: e.to_string(),
                };
            }
            shared.request_reload_sync(APPLY_TIMEOUT);
            Response::Done {
                message: format!("{} application profile(s) saved", cfg.apps.len()),
            }
        }

        Request::SetTriggers { triggers } => {
            info!("request: {} trigger(s)", triggers.len());
            let mut cfg = match Config::load(config_path) {
                Ok(cfg) => cfg,
                Err(e) => {
                    return Response::Error {
                        message: format!("the current configuration could not be read: {e}"),
                    }
                }
            };
            // Checked here as well as in validate(), so the error names the
            // trigger the client just sent rather than arriving as "the
            // configuration could not be saved".
            for t in &triggers {
                if let Err(e) = t.check() {
                    return Response::Error { message: e };
                }
            }
            cfg.triggers = triggers;
            if let Err(e) = cfg.save(config_path) {
                return Response::Error {
                    message: e.to_string(),
                };
            }
            shared.request_reload_sync(APPLY_TIMEOUT);
            Response::Done {
                message: format!("{} trigger(s) saved", cfg.triggers.len()),
            }
        }

        Request::SetGpuBoost(want) => {
            info!("request: GPU power allowance -> {want}");
            let mut cfg = match Config::load(config_path) {
                Ok(cfg) => cfg,
                Err(e) => {
                    return Response::Error {
                        message: format!("the current configuration could not be read: {e}"),
                    }
                }
            };
            if want == omen_core::gpu::Boost::Profile
                && omen_core::gpu::boost::read_state().is_none()
            {
                return Response::Error {
                    message: "this machine does not report cTGP or Dynamic Boost - it needs \
                              omen-kbd-rgb 0.2.0 and an NVIDIA GPU"
                        .into(),
                };
            }
            cfg.graphics.gpu_boost = want;
            if let Err(e) = cfg.save(config_path) {
                return Response::Error {
                    message: e.to_string(),
                };
            }
            shared.request_reload_sync(APPLY_TIMEOUT);
            Response::Done {
                message: match want {
                    omen_core::gpu::Boost::Profile => {
                        "cTGP and Dynamic Boost now follow the profile".into()
                    }
                    omen_core::gpu::Boost::Leave => {
                        "cTGP and Dynamic Boost are left to the firmware".into()
                    }
                },
            }
        }
        Request::SetDgpuPower(want) => {
            info!("request: dGPU runtime power -> {want}");
            let mut cfg = match Config::load(config_path) {
                Ok(cfg) => cfg,
                Err(e) => {
                    return Response::Error {
                        message: format!("the current configuration could not be read: {e}"),
                    }
                }
            };
            cfg.graphics.dgpu_power = want;
            if let Err(e) = cfg.save(config_path) {
                return Response::Error {
                    message: e.to_string(),
                };
            }
            shared.request_reload_sync(APPLY_TIMEOUT);
            Response::Done {
                message: match want {
                    omen_core::gpu::DgpuPower::Auto => {
                        "the discrete GPU may suspend when idle".into()
                    }
                    omen_core::gpu::DgpuPower::On => "the discrete GPU is kept awake".into(),
                },
            }
        }

        Request::SetOmenKey { action } => {
            let Some(want) = omen_core::config::OmenKey::parse(&action) else {
                return Response::Error {
                    message: format!(
                        "unknown action {action:?}; choices: window / profile / both / none"
                    ),
                };
            };
            let mut cfg = match Config::load(config_path) {
                Ok(cfg) => cfg,
                Err(e) => {
                    return Response::Error {
                        message: format!("the current configuration could not be read: {e}"),
                    }
                }
            };
            cfg.automation.omen_key = want;
            if let Err(e) = cfg.save(config_path) {
                return Response::Error {
                    message: e.to_string(),
                };
            }
            shared.request_reload_sync(APPLY_TIMEOUT);
            Response::Done {
                message: match want {
                    omen_core::config::OmenKey::Window => "the OMEN key opens the window".into(),
                    omen_core::config::OmenKey::Profile => {
                        "the OMEN key steps through the profiles".into()
                    }
                    omen_core::config::OmenKey::Both => {
                        "the OMEN key opens the window and steps the profile".into()
                    }
                    omen_core::config::OmenKey::None => "the OMEN key does nothing".into(),
                },
            }
        }

        Request::SetStartupProfile { profile } => {
            let mut cfg = match Config::load(config_path) {
                Ok(cfg) => cfg,
                Err(e) => {
                    return Response::Error {
                        message: format!("the current configuration could not be read: {e}"),
                    }
                }
            };
            // Checked against the machine's own list: a profile the firmware
            // does not have would only fail at the next boot, where nobody is
            // watching.
            if let Some(want) = &profile {
                match PlatformProfile::discover() {
                    Some(pp) if pp.choices().contains(want) => {}
                    Some(pp) => {
                        return Response::Error {
                            message: format!(
                                "invalid profile {want:?}; choices: {}",
                                pp.choices().join(" ")
                            ),
                        }
                    }
                    None => {
                        return Response::Error {
                            message: "no platform_profile".into(),
                        }
                    }
                }
            }
            cfg.automation.startup_profile = profile.clone();
            if let Err(e) = cfg.save(config_path) {
                return Response::Error {
                    message: e.to_string(),
                };
            }
            shared.request_reload_sync(APPLY_TIMEOUT);
            Response::Done {
                message: match profile {
                    Some(p) => format!("{p} will be selected at startup"),
                    None => "the startup profile will be left to the firmware".into(),
                },
            }
        }

        Request::SetPowerRules { on_ac, on_battery } => {
            info!(
                "request: on mains -> {}, on battery -> {}",
                on_ac.summary(),
                on_battery.summary()
            );
            let mut cfg = match Config::load(config_path) {
                Ok(cfg) => cfg,
                Err(e) => {
                    return Response::Error {
                        message: format!("the current configuration could not be read: {e}"),
                    }
                }
            };
            for rule in [&on_ac, &on_battery] {
                if let Some(want) = &rule.profile {
                    match PlatformProfile::discover() {
                        Some(pp) if pp.choices().contains(want) => {}
                        Some(pp) => {
                            return Response::Error {
                                message: format!(
                                    "invalid profile {want:?}; choices: {}",
                                    pp.choices().join(" ")
                                ),
                            }
                        }
                        None => {
                            return Response::Error {
                                message: "no platform_profile".into(),
                            }
                        }
                    }
                }
            }
            cfg.automation.on_ac = on_ac;
            cfg.automation.on_battery = on_battery;
            if let Err(e) = cfg.save(config_path) {
                return Response::Error {
                    message: e.to_string(),
                };
            }
            shared.request_reload_sync(APPLY_TIMEOUT);
            Response::Done {
                message: "power rules saved".into(),
            }
        }

        Request::SetLightingOptions {
            restore_on_start,
            off_on_battery,
        } => {
            let mut cfg = match Config::load(config_path) {
                Ok(cfg) => cfg,
                Err(e) => {
                    return Response::Error {
                        message: format!("the current configuration could not be read: {e}"),
                    }
                }
            };
            cfg.lighting.restore_on_start = restore_on_start;
            cfg.lighting.off_on_battery = off_on_battery;
            if let Err(e) = cfg.save(config_path) {
                return Response::Error {
                    message: e.to_string(),
                };
            }
            shared.request_reload_sync(APPLY_TIMEOUT);
            Response::Done {
                message: "lighting options saved".into(),
            }
        }

        Request::CleanFans { seconds } => {
            if let Some(why) = no_fan_here() {
                return Response::Error { message: why };
            }
            let seconds = seconds.clamp(5, 120);
            shared.request_clean(seconds);
            Response::Done {
                message: format!(
                    "running the fans at full power for {seconds}s, then back to normal"
                ),
            }
        }

        Request::SetGpuMux { mode } => {
            // Written by the daemon because the attribute is root-owned, and
            // because this is the kind of change that should go through the
            // thing that can also say what it means.
            match omen_core::gpu::mux::set(&mode) {
                Ok(()) => {
                    info!("graphics mux -> {mode} (at the next boot)");
                    Response::Done {
                        message: format!("graphics set to {mode}; it takes effect after a reboot"),
                    }
                }
                Err(e) => Response::Error {
                    message: e.to_string(),
                },
            }
        }

        Request::SetChargeLimit { percent } => {
            // Refused up front on a machine without the control, rather than
            // saved and silently never applied. A setting that is stored but
            // has no effect is the failure mode this project keeps finding in
            // other tools.
            let Some(battery) = omen_core::battery::Battery::discover() else {
                return Response::Error {
                    message: "no battery was found".into(),
                };
            };
            if !battery.supports_limit() {
                return Response::Error {
                    message: battery.unsupported_reason(),
                };
            }
            if let Err(e) = battery.set_limit(percent) {
                return Response::Error {
                    message: e.to_string(),
                };
            }

            let mut cfg = match Config::load(config_path) {
                Ok(cfg) => cfg,
                Err(e) => {
                    return Response::Error {
                        message: format!("the current configuration could not be read: {e}"),
                    }
                }
            };
            cfg.battery.charge_limit = percent;
            if let Err(e) = cfg.save(config_path) {
                return Response::Error {
                    message: e.to_string(),
                };
            }
            shared.request_reload_sync(APPLY_TIMEOUT);
            Response::Done {
                message: match percent {
                    Some(p) => format!("charging stops at {p}%"),
                    None => "the charge limit is off; the battery charges to full".into(),
                },
            }
        }

        Request::Reload => Response::Done {
            message: if shared.request_reload_sync(APPLY_TIMEOUT) {
                "the configuration has been re-read".into()
            } else {
                // The loop is busy or wedged. The request stays queued, so
                // say what is true rather than claiming it is done.
                "the configuration will be re-read on the next tick".into()
            },
        },
    }
}

/// The reason a fan request cannot be honoured here, when there is one.
///
/// The message names the remedy, because on an unverified OMEN there is a
/// real one: this board is missing from hp-wmi's DMI table, and that is a
/// one-line change.
fn no_fan_here() -> Option<String> {
    if omen_core::caps::fan_setpoint_present() {
        return None;
    }
    let caps = omen_core::caps::Caps::detect();
    Some(format!(
        "there is no fan setpoint on this machine ({}). {}",
        caps.level().describe(),
        caps.remedy().unwrap_or_default()
    ))
}

/// Validates a curve, writes it to the config file and asks the loop to
/// re-read it.
///
/// Validation happens against the WHOLE configuration, not the points alone:
/// a curve whose top point sits above the critical cutout is individually
/// well formed and still wrong, and that is exactly the mistake an editor
/// with a draggable top point invites. Config::validate already knows this,
/// so there is no second copy of the rule here.
///
/// `None` means "back to the built-in curve" - written as an empty list,
/// which is how the config file spells that.
fn write_curve(config_path: &Path, shared: &Shared, spec: Option<CurveSpec>) -> Response {
    let mut cfg = match Config::load(config_path) {
        Ok(cfg) => cfg,
        Err(e) => {
            return Response::Error {
                message: format!("the current configuration could not be read: {e}"),
            }
        }
    };

    match &spec {
        Some(spec) => {
            cfg.fan.curve = spec.points.clone();
            cfg.fan.interpolation = spec.interpolation;
        }
        None => cfg.fan.curve.clear(),
    }

    if let Err(e) = cfg.save(config_path) {
        return Response::Error {
            message: e.to_string(),
        };
    }

    // Only now does it take effect: the loop owns the governor, and the loop
    // is the only thread that touches the fan. Waited for, so the reply is
    // true when it arrives rather than one tick later.
    shared.request_reload_sync(APPLY_TIMEOUT);

    let points = match &spec {
        Some(spec) => spec.points.len(),
        None => curve::default_curve().points().len(),
    };
    Response::Done {
        message: format!(
            "curve saved to {} ({points} points){}",
            config_path.display(),
            if spec.is_none() { ", built-in" } else { "" }
        ),
    }
}
