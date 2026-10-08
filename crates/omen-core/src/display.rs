//! The internal panel's refresh rate.
//!
//! OMEN Gaming Hub changes it per application (OMEN AI's
//! `ChangeRefreshRateBaseMetadataId`); this board has no firmware-driven
//! dynamic rate (`IsAutoDrrSupport = False`), so on Windows it is software
//! too. On Linux the rate belongs to the compositor, and every compositor
//! has its own way of being asked:
//!
//! | Session | Tool |
//! |---|---|
//! | KDE Plasma | `kscreen-doctor` |
//! | Hyprland | `hyprctl` |
//! | sway, river, other wlroots | `wlr-randr` |
//! | X11 | `xrandr` |
//!
//! GNOME has no command-line tool for it - Mutter takes a whole monitor
//! configuration over D-Bus - so it is reported as unsupported rather than
//! half-done.
//!
//! None of this can run in the daemon, which is outside every session. The
//! daemon says what rate is wanted; `omenctl session`, running as the user,
//! applies it.

use std::process::Command;

use serde_json::Value;

/// The rates a rule may ask for. Below 24 nothing is a display; above 500
/// nothing is this one.
pub const MIN_HZ: u32 = 24;
pub const MAX_HZ: u32 = 500;

pub fn check_rate(hz: Option<u32>) -> Result<(), String> {
    match hz {
        Some(hz) if !(MIN_HZ..=MAX_HZ).contains(&hz) => {
            Err(format!("{hz} Hz is not a refresh rate ({MIN_HZ}-{MAX_HZ})"))
        }
        _ => Ok(()),
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Backend {
    Kde,
    Hyprland,
    Wlroots,
    X11,
}

impl Backend {
    pub fn tool(self) -> &'static str {
        match self {
            Self::Kde => "kscreen-doctor",
            Self::Hyprland => "hyprctl",
            Self::Wlroots => "wlr-randr",
            Self::X11 => "xrandr",
        }
    }
}

/// The internal panel as the compositor reports it.
#[derive(Debug, Clone, PartialEq)]
pub struct Panel {
    pub name: String,
    pub width: u32,
    pub height: u32,
    pub rate: f32,
    /// What the panel offers at its current resolution, and how each is
    /// asked for (a mode id under KDE, the rate itself elsewhere).
    pub rates: Vec<(f32, String)>,
    /// Hyprland only: where the panel sits and its scale, which its monitor
    /// rule has to repeat.
    pub placement: Option<String>,
}

/// Which tool this session answers to, from its environment.
pub fn detect() -> Result<Backend, String> {
    let env = |k: &str| std::env::var(k).unwrap_or_default();
    let desktop = env("XDG_CURRENT_DESKTOP").to_ascii_lowercase();
    let wayland = !env("WAYLAND_DISPLAY").is_empty();

    let backend = if !env("HYPRLAND_INSTANCE_SIGNATURE").is_empty() {
        Backend::Hyprland
    } else if desktop.contains("kde") {
        Backend::Kde
    } else if desktop.contains("gnome") && wayland {
        return Err("GNOME has no command-line way to change the refresh rate".into());
    } else if wayland {
        Backend::Wlroots
    } else if !env("DISPLAY").is_empty() {
        Backend::X11
    } else {
        return Err("no graphical session in this environment".into());
    };
    if !on_path(backend.tool()) {
        return Err(format!("{} is not installed", backend.tool()));
    }
    Ok(backend)
}

fn on_path(tool: &str) -> bool {
    std::env::var_os("PATH")
        .is_some_and(|path| std::env::split_paths(&path).any(|dir| dir.join(tool).is_file()))
}

fn run(tool: &str, args: &[&str]) -> Result<String, String> {
    let out = Command::new(tool)
        .args(args)
        .output()
        .map_err(|e| format!("{tool}: {e}"))?;
    if !out.status.success() {
        return Err(format!(
            "{tool} {}: {}",
            args.join(" "),
            String::from_utf8_lossy(&out.stderr).trim()
        ));
    }
    Ok(String::from_utf8_lossy(&out.stdout).into_owned())
}

/// The built-in panel is eDP on every laptop this family ships; failing
/// that, the first output that is on.
fn is_internal(name: &str) -> bool {
    name.starts_with("eDP") || name.starts_with("LVDS")
}

pub fn panel(backend: Backend) -> Result<Panel, String> {
    match backend {
        Backend::Kde => parse_kde(&run("kscreen-doctor", &["-j"])?),
        Backend::Hyprland => parse_hyprland(&run("hyprctl", &["monitors", "-j"])?),
        Backend::Wlroots => parse_wlr(&run("wlr-randr", &["--json"])?),
        Backend::X11 => parse_xrandr(&run("xrandr", &["--query"])?),
    }
}

/// Switches the panel to the rate nearest `hz` at its current resolution.
/// Returns what was done, or `None` when it was already there.
pub fn set_rate(backend: Backend, hz: u32) -> Result<Option<String>, String> {
    let panel = panel(backend)?;
    let (rate, how) = nearest(&panel.rates, hz as f32)
        .ok_or_else(|| format!("{} reports no refresh rates", panel.name))?;
    if (rate - panel.rate).abs() < 0.5 {
        return Ok(None);
    }
    let mode = format!("{}x{}@{rate:.2}", panel.width, panel.height);
    match backend {
        Backend::Kde => run(
            "kscreen-doctor",
            &[&format!("output.{}.mode.{how}", panel.name)],
        )?,
        Backend::Hyprland => {
            let rule = format!(
                "{},{mode},{}",
                panel.name,
                panel.placement.as_deref().unwrap_or("auto,1")
            );
            run("hyprctl", &["keyword", "monitor", &rule])?
        }
        Backend::Wlroots => run(
            "wlr-randr",
            &["--output", &panel.name, "--mode", &format!("{mode}Hz")],
        )?,
        Backend::X11 => run("xrandr", &["--output", &panel.name, "--rate", &how])?,
    };
    Ok(Some(format!(
        "{} {:.0} -> {rate:.0} Hz",
        panel.name, panel.rate
    )))
}

fn nearest(rates: &[(f32, String)], hz: f32) -> Option<(f32, String)> {
    rates
        .iter()
        .min_by(|a, b| (a.0 - hz).abs().total_cmp(&(b.0 - hz).abs()))
        .cloned()
}

fn pick(outputs: &[Value], name: impl Fn(&Value) -> &str) -> Option<&Value> {
    outputs
        .iter()
        .find(|o| is_internal(name(o)))
        .or_else(|| outputs.first())
}

fn num(v: &Value) -> f32 {
    v.as_f64().unwrap_or_default() as f32
}

fn parse_kde(text: &str) -> Result<Panel, String> {
    let json: Value = serde_json::from_str(text).map_err(|e| format!("kscreen-doctor: {e}"))?;
    let outputs: Vec<Value> = json["outputs"]
        .as_array()
        .cloned()
        .unwrap_or_default()
        .into_iter()
        .filter(|o| o["enabled"].as_bool().unwrap_or(false))
        .collect();
    let o = pick(&outputs, |o| o["name"].as_str().unwrap_or("")).ok_or("no output is on")?;
    let current = o["currentModeId"].as_str().unwrap_or("").to_owned();
    let modes = o["modes"].as_array().cloned().unwrap_or_default();
    let cur = modes
        .iter()
        .find(|m| m["id"].as_str() == Some(current.as_str()))
        .ok_or("the current mode is not in the list")?;
    let size = |m: &Value| {
        (
            m["size"]["width"].as_u64().unwrap_or(0) as u32,
            m["size"]["height"].as_u64().unwrap_or(0) as u32,
        )
    };
    let (width, height) = size(cur);
    Ok(Panel {
        name: o["name"].as_str().unwrap_or_default().to_owned(),
        width,
        height,
        rate: num(&cur["refreshRate"]),
        rates: modes
            .iter()
            .filter(|m| size(m) == (width, height))
            .map(|m| {
                (
                    num(&m["refreshRate"]),
                    m["id"].as_str().unwrap_or_default().to_owned(),
                )
            })
            .collect(),
        placement: None,
    })
}

fn parse_hyprland(text: &str) -> Result<Panel, String> {
    let outputs: Vec<Value> = serde_json::from_str(text).map_err(|e| format!("hyprctl: {e}"))?;
    let o = pick(&outputs, |o| o["name"].as_str().unwrap_or("")).ok_or("no monitor")?;
    let width = o["width"].as_u64().unwrap_or(0) as u32;
    let height = o["height"].as_u64().unwrap_or(0) as u32;
    let prefix = format!("{width}x{height}@");
    let rates = o["availableModes"]
        .as_array()
        .cloned()
        .unwrap_or_default()
        .iter()
        .filter_map(|m| {
            m.as_str()?
                .strip_prefix(&prefix)?
                .strip_suffix("Hz")?
                .parse()
                .ok()
        })
        .map(|r: f32| (r, format!("{r:.2}")))
        .collect();
    Ok(Panel {
        name: o["name"].as_str().unwrap_or_default().to_owned(),
        width,
        height,
        rate: num(&o["refreshRate"]),
        rates,
        placement: Some(format!(
            "{}x{},{}",
            o["x"].as_i64().unwrap_or(0),
            o["y"].as_i64().unwrap_or(0),
            o["scale"].as_f64().unwrap_or(1.0)
        )),
    })
}

fn parse_wlr(text: &str) -> Result<Panel, String> {
    let outputs: Vec<Value> = serde_json::from_str::<Vec<Value>>(text)
        .map_err(|e| format!("wlr-randr: {e}"))?
        .into_iter()
        .filter(|o| o["enabled"].as_bool().unwrap_or(true))
        .collect();
    let o = pick(&outputs, |o| o["name"].as_str().unwrap_or("")).ok_or("no output is on")?;
    let modes = o["modes"].as_array().cloned().unwrap_or_default();
    let cur = modes
        .iter()
        .find(|m| m["current"].as_bool() == Some(true))
        .ok_or("no current mode")?;
    let size = |m: &Value| {
        (
            m["width"].as_u64().unwrap_or(0) as u32,
            m["height"].as_u64().unwrap_or(0) as u32,
        )
    };
    let (width, height) = size(cur);
    Ok(Panel {
        name: o["name"].as_str().unwrap_or_default().to_owned(),
        width,
        height,
        rate: num(&cur["refresh"]),
        rates: modes
            .iter()
            .filter(|m| size(m) == (width, height))
            .map(|m| {
                let r = num(&m["refresh"]);
                (r, format!("{r:.3}"))
            })
            .collect(),
        placement: None,
    })
}

/// `xrandr --query`: an output line, then its modes indented beneath it,
/// the current one marked `*`.
fn parse_xrandr(text: &str) -> Result<Panel, String> {
    let mut best: Option<Panel> = None;
    let mut current: Option<String> = None;
    for line in text.lines() {
        if !line.starts_with(' ') {
            let mut words = line.split_whitespace();
            let name = words.next().unwrap_or_default();
            current = (words.next() == Some("connected")).then(|| name.to_owned());
            continue;
        }
        let Some(name) = &current else { continue };
        if !line.contains('*') {
            continue;
        }
        let mut words = line.split_whitespace();
        let Some((w, h)) = words.next().and_then(|m| m.split_once('x')) else {
            continue;
        };
        let mut panel = Panel {
            name: name.clone(),
            width: w.parse().unwrap_or(0),
            height: h.trim_end_matches('i').parse().unwrap_or(0),
            rate: 0.0,
            rates: Vec::new(),
            placement: None,
        };
        for word in words {
            let r: f32 = match word.trim_end_matches(['*', '+']).parse() {
                Ok(r) => r,
                Err(_) => continue,
            };
            if word.contains('*') {
                panel.rate = r;
            }
            panel.rates.push((r, format!("{r:.2}")));
        }
        let internal = is_internal(&panel.name);
        if best.is_none() || internal {
            best = Some(panel);
        }
        if internal {
            break;
        }
    }
    best.ok_or_else(|| "xrandr reports no output in use".into())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn rates_outside_a_display_are_refused() {
        assert!(check_rate(Some(10)).is_err());
        assert!(check_rate(Some(1000)).is_err());
        assert!(check_rate(Some(60)).is_ok());
        assert!(check_rate(None).is_ok());
    }

    #[test]
    fn the_nearest_rate_is_chosen() {
        let rates = vec![(60.0, "a".to_owned()), (165.0, "b".to_owned())];
        assert_eq!(nearest(&rates, 144.0).unwrap().1, "b");
        assert_eq!(nearest(&rates, 48.0).unwrap().1, "a");
    }

    #[test]
    fn xrandr_finds_the_panel_and_its_rates() {
        let text = "\
Screen 0: minimum 320 x 200, current 2560 x 1600, maximum 16384 x 16384
HDMI-1 disconnected (normal left inverted right x axis y axis)
eDP-1 connected primary 2560x1600+0+0 (normal left inverted right x axis y axis) 344mm x 215mm
   2560x1600    165.00*+  60.00
   1920x1200    165.00    60.00
";
        let p = parse_xrandr(text).unwrap();
        assert_eq!(p.name, "eDP-1");
        assert_eq!((p.width, p.height), (2560, 1600));
        assert_eq!(p.rate, 165.0);
        assert_eq!(p.rates.len(), 2);
    }

    #[test]
    fn kde_modes_at_another_resolution_are_not_offered() {
        let text = r#"{"outputs":[{"name":"eDP-1","enabled":true,"currentModeId":"2",
            "modes":[{"id":"1","refreshRate":60.0,"size":{"width":2560,"height":1600}},
                     {"id":"2","refreshRate":165.0,"size":{"width":2560,"height":1600}},
                     {"id":"3","refreshRate":240.0,"size":{"width":1280,"height":800}}]}]}"#;
        let p = parse_kde(text).unwrap();
        assert_eq!(p.rate, 165.0);
        assert_eq!(p.rates.len(), 2);
        assert_eq!(nearest(&p.rates, 60.0).unwrap().1, "1");
    }

    #[test]
    fn hyprland_keeps_the_placement() {
        let text = r#"[{"name":"eDP-1","width":2560,"height":1600,"refreshRate":165.0,
            "x":0,"y":0,"scale":1.25,
            "availableModes":["2560x1600@165.00Hz","2560x1600@60.00Hz","1920x1200@60.00Hz"]}]"#;
        let p = parse_hyprland(text).unwrap();
        assert_eq!(p.rates.len(), 2);
        assert_eq!(p.placement.as_deref(), Some("0x0,1.25"));
    }

    #[test]
    fn wlr_reads_the_current_mode() {
        let text = r#"[{"name":"eDP-1","enabled":true,"modes":[
            {"width":2560,"height":1600,"refresh":165.0,"current":true},
            {"width":2560,"height":1600,"refresh":60.0,"current":false}]}]"#;
        let p = parse_wlr(text).unwrap();
        assert_eq!(p.rate, 165.0);
        assert_eq!(p.rates.len(), 2);
    }
}
