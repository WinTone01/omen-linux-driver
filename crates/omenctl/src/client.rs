//! Thin wrapper over omen_core::ipc::client.
//!
//! The transport lives in omen-core so the CLI and the UI share one
//! implementation; this file only adds the CLI's error wording and how a
//! reply is printed.

use anyhow::{bail, Context, Result};
use omen_core::ipc::{client, Request, Response};

pub fn send(req: &Request) -> Result<Response> {
    client::send(req).with_context(|| {
        // On a machine the installation does not belong to the service is
        // skipped on purpose, and "is it running" sends people looking for
        // a fault that is not there.
        let verdict = omen_core::machine::check();
        if !verdict.allowed() {
            return format!("omend does not run here: {}", verdict.describe());
        }
        "Is the service running?  systemctl status omend\n  \
         If this is a permission error: sudo omenctl ... (or join the 'omen' group)"
            .to_owned()
    })
}

/// Prints the reply; an error reply also determines the process exit code.
pub fn report(resp: Response) -> Result<()> {
    match resp {
        Response::Done { message } => {
            println!("{message}");
            Ok(())
        }
        Response::Error { message } => bail!("{message}"),
        Response::Ok(_)
        | Response::History { .. }
        | Response::Samples { .. }
        | Response::Presses { .. } => Ok(()),
    }
}
