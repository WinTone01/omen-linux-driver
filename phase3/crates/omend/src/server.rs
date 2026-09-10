//! Unix socket dinleyicisi.
//!
//! Satir basina bir JSON istek, satir basina bir JSON cevap. Elle denemek
//! icin:  `sudo socat - UNIX-CONNECT:/run/omend.sock`  sonra
//! `{"cmd":"status"}`

use std::io::{BufRead, BufReader, Write};
use std::os::unix::fs::PermissionsExt;
use std::os::unix::net::{UnixListener, UnixStream};
use std::path::Path;

use anyhow::{Context, Result};
use log::{debug, error, info, warn};

use omen_core::ipc::{check_socket_path, socket_path, Request, Response};
use omen_core::profile::PlatformProfile;

use crate::shared::Shared;

/// Senkron mod degisikliginde dongu turunu ne kadar bekleyecegimiz.
const APPLY_TIMEOUT: std::time::Duration = std::time::Duration::from_secs(5);

/// Socket'i olusturur ve dinleyiciyi arka plan thread'ine alir.
pub fn spawn(shared: Shared) -> Result<()> {
    let owned = socket_path();
    let path: &Path = &owned;
    check_socket_path(path).map_err(anyhow::Error::msg)?;

    // Onceki calistirmadan kalmis olabilir. Bagli bir socket varsa
    // bind zaten hata verir; burada yalnizca sahipsiz dosyayi siliyoruz.
    if path.exists() {
        if UnixStream::connect(path).is_ok() {
            anyhow::bail!(
                "{} zaten dinleniyor - baska bir omend calisiyor olabilir",
                path.display()
            );
        }
        std::fs::remove_file(path)
            .with_context(|| format!("eski socket silinemedi: {}", path.display()))?;
    }

    let listener = UnixListener::bind(path)
        .with_context(|| format!("socket acilamadi: {}", path.display()))?;

    // Fan kontrolu herkese acik olmamali. 0660 + mumkunse 'omen' grubu;
    // grup yoksa root'ta kalir ve istemciler sudo ister.
    std::fs::set_permissions(path, std::fs::Permissions::from_mode(0o660))
        .context("socket izinleri ayarlanamadi")?;
    match omen_group_gid() {
        // systemd unit'i Group=omen ile kosuyorsa socket zaten dogru
        // grupta dogar; chown'a hic kalkismayalim. CapabilityBoundingSet
        // bos oldugu icin CAP_CHOWN yok, kalkisirsak yalnizca gurultu
        // uretiriz.
        Some(gid) if socket_gid(path) == Some(gid) => {
            info!("socket: {} (grup 'omen', 0660)", path.display());
        }
        Some(gid) => match std::os::unix::fs::chown(path, None, Some(gid)) {
            Ok(()) => info!("socket: {} (grup 'omen', 0660)", path.display()),
            Err(e) => warn!(
                "socket 'omen' grubuna verilemedi ({e}) - istemciler sudo ister. \
                 systemd altindaysan unit'te 'Group=omen' var mi?"
            ),
        },
        None => info!(
            "socket: {} (root, 0660 - 'omen' grubu yok, istemciler sudo ister)",
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
                            debug!("istemci hatasi: {e}");
                        }
                    }
                    Err(e) => error!("baglanti kabul edilemedi: {e}"),
                }
            }
        })
        .context("dinleyici thread'i baslatilamadi")?;

    Ok(())
}

fn socket_gid(path: &Path) -> Option<u32> {
    use std::os::unix::fs::MetadataExt;
    std::fs::metadata(path).ok().map(|m| m.gid())
}

/// /etc/group icinden 'omen' grubunun gid'i. libc bagimliligi getirmemek
/// icin dosyayi kendimiz okuyoruz - bicim sabit ve basit.
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
                message: format!("istek ayristirilamadi: {e}"),
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
            info!("istek: mod -> {mode}");
            // Dongu turunu bekliyoruz ki cevap gercekten uygulanan
            // durumu soylesin. Iki tur suresi yeterli; asilirsa istek
            // kuyrukta kalir ve bir sonraki turda islenir.
            match shared.request_mode(mode, APPLY_TIMEOUT) {
                Some(applied) if applied == mode => Response::Done {
                    message: format!("mod: {applied}"),
                },
                Some(applied) => Response::Done {
                    message: format!(
                        "mod {mode} istendi ama surus {applied} olarak kaldi \
                         (kritik sigorta atmis olabilir)"
                    ),
                },
                None => Response::Done {
                    message: format!("mod {mode} kuyruga alindi (dongu yanit vermedi)"),
                },
            }
        }

        Request::SetProfile { profile } => {
            let Some(pp) = PlatformProfile::discover() else {
                return Response::Error {
                    message: "platform_profile yok".into(),
                };
            };
            let choices = pp.choices();
            if !choices.contains(&profile) {
                return Response::Error {
                    message: format!(
                        "gecersiz profil {profile:?}; secenekler: {}",
                        choices.join(" ")
                    ),
                };
            }
            match pp.set(&profile) {
                Ok(()) => {
                    info!("profil -> {profile}");
                    Response::Done {
                        message: format!("profil {profile}"),
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
                message: "yapilandirma yeniden okunacak".into(),
            }
        }
    }
}
