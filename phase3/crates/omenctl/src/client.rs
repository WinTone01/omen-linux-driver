//! omend socket istemcisi.

use std::io::{BufRead, BufReader, Write};
use std::os::unix::net::UnixStream;

use anyhow::{bail, Context, Result};
use omen_core::ipc::{check_socket_path, socket_path, Request, Response};

pub fn send(req: &Request) -> Result<Response> {
    let path = socket_path();
    check_socket_path(&path).map_err(anyhow::Error::msg)?;
    let stream = UnixStream::connect(&path).with_context(|| {
        format!(
            "omend'e baglanilamadi ({}).\n  \
             Servis calisiyor mu?  systemctl status omend\n  \
             Izin hatasiysa: sudo omenctl ... (ya da 'omen' grubuna katil)",
            path.display()
        )
    })?;

    let mut writer = stream.try_clone()?;
    let mut line = serde_json::to_string(req)?;
    line.push('\n');
    writer.write_all(line.as_bytes())?;
    writer.flush()?;

    let mut reader = BufReader::new(stream);
    let mut buf = String::new();
    if reader.read_line(&mut buf)? == 0 {
        bail!("omend cevap vermeden baglantiyi kapatti");
    }
    Ok(serde_json::from_str(&buf)?)
}

/// Cevabi yazdirir; hata cevabi surecin cikis kodunu da belirler.
pub fn report(resp: Response) -> Result<()> {
    match resp {
        Response::Done { message } => {
            println!("{message}");
            Ok(())
        }
        Response::Error { message } => bail!("{message}"),
        Response::Ok(_) => Ok(()),
    }
}
