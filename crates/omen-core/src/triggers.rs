//! Rules that follow the machine's own state rather than a program.
//!
//! An application profile answers "what is running", a power rule answers
//! "what is it plugged into". Between them there is a third question people
//! actually ask - "it got hot", "the lid is shut", "nobody has touched it for
//! half an hour" - and this is that.
//!
//! The shape is deliberately the same as the other two: a condition, and the
//! same three things to apply (a platform profile, a fan mode, a named
//! curve). Nothing here writes anything; the daemon owns every write, and a
//! trigger only says what it would like.
//!
//! Precedence, most specific first:
//!
//! 1. **Application profiles.** A named program is the most specific
//!    statement anyone can make about what the machine is doing.
//! 2. **Triggers.** A described state of the machine.
//! 3. **Power rules.** Mains or battery - true for hours at a time.
//!
//! Each condition releases on a slightly easier test than it engaged on. A
//! trigger at exactly its threshold would otherwise flap between applied and
//! restored every couple of seconds, and each flap changes the platform
//! profile.

use serde::{Deserialize, Serialize};

use crate::ipc::ControlMode;

/// How far back across the threshold the machine has to come before a
/// trigger lets go. Three degrees and three percentage points are both well
/// outside sensor noise and well inside "it really did change".
const RELEASE_MARGIN: f32 = 3.0;

/// What is being watched.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Kind {
    /// The hottest sensor is above `value` degrees.
    TempAbove,
    /// The battery has fallen below `value` percent.
    BatteryBelow,
    /// Nothing much has happened for `value` minutes. See [`Idle`] for what
    /// "nothing much" means - it is measured, not guessed.
    Idle,
    /// The lid is shut. Takes no value.
    LidClosed,
    /// The local clock is inside a window - `from` to `to`, which may wrap
    /// past midnight.
    TimeBetween,
    /// The machine is on a particular wireless network. "At work, stay
    /// quiet" is the rule people actually want, and the network is the only
    /// thing on a laptop that knows where it is.
    WifiSsid,
}

impl Kind {
    pub fn as_str(self) -> &'static str {
        match self {
            Self::TempAbove => "temp_above",
            Self::BatteryBelow => "battery_below",
            Self::Idle => "idle",
            Self::LidClosed => "lid_closed",
            Self::TimeBetween => "time_between",
            Self::WifiSsid => "wifi_ssid",
        }
    }

    /// Whether this kind needs a number, and what it means.
    pub fn unit(self) -> Option<&'static str> {
        match self {
            Self::TempAbove => Some("C"),
            Self::BatteryBelow => Some("%"),
            Self::Idle => Some("min"),
            Self::LidClosed | Self::TimeBetween | Self::WifiSsid => None,
        }
    }

    /// Whether this kind is evaluated against something that costs a process
    /// to find out. Sampled only when one of these is configured - see
    /// Reading.
    pub fn is_expensive(self) -> bool {
        matches!(self, Self::TimeBetween | Self::WifiSsid)
    }
}

impl std::fmt::Display for Kind {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(self.as_str())
    }
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Trigger {
    /// What to watch.
    pub when: Kind,

    /// The threshold. Required for every kind except `lid_closed`, which has
    /// nothing to compare.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub value: Option<f32>,

    /// Platform profile to select while the condition holds.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub profile: Option<String>,

    /// How the fan should be driven while it holds.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub fan: Option<ControlMode>,

    /// A named curve to run while it holds. Same reasoning as the
    /// application profiles: the configured curve is not rewritten, it is
    /// swapped in and swapped back.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub curve: Option<String>,

    /// The window for `time_between`, as "HH:MM". A `from` later than `to`
    /// wraps past midnight, which is how anybody would write "23:00 to
    /// 07:00" and expect it to mean one night rather than nothing.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub from: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub to: Option<String>,

    /// The network name for `wifi_ssid`. Compared case-insensitively.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub ssid: Option<String>,
}

/// Everything a condition can be evaluated against, sampled once per tick.
///
/// A struct rather than four arguments: the set grows, and a caller that
/// forgets one should not compile.
#[derive(Debug, Clone, Default)]
pub struct Reading {
    /// The hottest sensor, the same number the curve is driven from.
    pub temp_c: Option<f32>,
    pub battery_percent: Option<u8>,
    /// How long the machine has been idle, in seconds.
    pub idle_secs: u64,
    /// `None` on a machine with no lid switch - a desktop, or a kernel that
    /// does not export one. Never guessed.
    pub lid_closed: Option<bool>,
    /// Minutes since local midnight. `None` unless a time trigger is
    /// configured: finding out costs a process (see local_minutes).
    pub minutes: Option<u16>,
    /// The wireless network this machine is on, if any. Same rule - only
    /// looked up when something asks about it.
    pub ssid: Option<String>,
}

impl Trigger {
    /// Whether the condition holds.
    ///
    /// `engaged` says whether this trigger is the one currently applied, and
    /// only affects where the threshold sits: a trigger that has taken over
    /// keeps it until the machine is properly back the other side.
    pub fn holds(&self, now: &Reading, engaged: bool) -> bool {
        let slack = if engaged { RELEASE_MARGIN } else { 0.0 };
        match self.when {
            Kind::TempAbove => match (now.temp_c, self.value) {
                (Some(temp), Some(limit)) => temp > limit - slack,
                // No reading is not "cool enough to let go": a trigger that
                // released because a sensor disappeared would be doing the
                // opposite of what it was configured for.
                _ => engaged,
            },
            Kind::BatteryBelow => match (now.battery_percent, self.value) {
                (Some(pct), Some(limit)) => (pct as f32) < limit + slack,
                _ => false,
            },
            Kind::Idle => match self.value {
                Some(minutes) => now.idle_secs as f32 >= minutes * 60.0,
                None => false,
            },
            // No hysteresis: a lid is open or it is shut, and there is no
            // noise in between to smooth.
            Kind::LidClosed => now.lid_closed.unwrap_or(false),

            // Nor here. A clock does not wobble across a boundary, and a
            // network name is a name.
            Kind::TimeBetween => match (now.minutes, self.window()) {
                (Some(now), Some((from, to))) => in_window(now, from, to),
                // The clock could not be read. Hold what was applied rather
                // than letting go for a reason that is not about the time.
                _ => engaged,
            },
            Kind::WifiSsid => match (&now.ssid, &self.ssid) {
                (Some(on), Some(want)) => on.eq_ignore_ascii_case(want.trim()),
                _ => false,
            },
        }
    }

    /// The window as minutes since midnight, when this is a time trigger and
    /// both ends parse.
    pub fn window(&self) -> Option<(u16, u16)> {
        Some((
            parse_hm(self.from.as_deref()?)?,
            parse_hm(self.to.as_deref()?)?,
        ))
    }

    /// What this trigger is watching, in words.
    pub fn condition(&self) -> String {
        match (self.when, self.value) {
            (Kind::TempAbove, Some(v)) => format!("above {v:.0} C"),
            (Kind::BatteryBelow, Some(v)) => format!("battery below {v:.0}%"),
            (Kind::Idle, Some(v)) => format!("idle for {v:.0} min"),
            (Kind::LidClosed, _) => "the lid is shut".into(),
            (Kind::TimeBetween, _) => format!(
                "between {} and {}",
                self.from.as_deref().unwrap_or("?"),
                self.to.as_deref().unwrap_or("?")
            ),
            (Kind::WifiSsid, _) => {
                format!("on the {} network", self.ssid.as_deref().unwrap_or("?"))
            }
            (kind, None) => kind.as_str().into(),
        }
    }

    /// What it does, in words. Same wording as the application profiles and
    /// the power rules, because it is the same set of actions.
    pub fn summary(&self) -> String {
        let mut parts = Vec::new();
        if let Some(p) = &self.profile {
            parts.push(p.clone());
        }
        if let Some(c) = &self.curve {
            parts.push(format!("{c} curve"));
        } else if let Some(f) = &self.fan {
            parts.push(format!("fan {f}"));
        }
        if parts.is_empty() {
            "nothing to apply".into()
        } else {
            parts.join(", ")
        }
    }

    /// A stable name for this trigger, used in logs and as the thing the UI
    /// shows as "in force".
    pub fn name(&self) -> String {
        self.condition()
    }

    /// Whether the entry makes sense at all. Called from Config::validate,
    /// so a file that cannot do anything is refused at load rather than
    /// discovered as silence.
    pub fn check(&self) -> Result<(), String> {
        // The two that carry their own fields rather than a number.
        match self.when {
            Kind::TimeBetween => {
                if self.value.is_some() {
                    return Err("time_between takes from and to, not a value".into());
                }
                if self.window().is_none() {
                    return Err(
                        "time_between needs from and to as \"HH:MM\", e.g. from = \"23:00\"".into(),
                    );
                }
                if self.from == self.to {
                    return Err("a time window that starts where it ends is never true".into());
                }
            }
            Kind::WifiSsid => {
                if self.value.is_some() {
                    return Err("wifi_ssid takes a network name, not a value".into());
                }
                match self.ssid.as_deref().map(str::trim) {
                    None | Some("") => return Err("wifi_ssid needs a network name".into()),
                    Some(_) => {}
                }
            }
            _ => {
                if self.from.is_some() || self.to.is_some() || self.ssid.is_some() {
                    return Err(format!("{} takes a value, not from/to/ssid", self.when));
                }
            }
        }

        match (self.when, self.value) {
            (Kind::LidClosed, Some(_)) => {
                return Err("lid_closed takes no value".into());
            }
            (kind, None)
                if !matches!(kind, Kind::LidClosed | Kind::TimeBetween | Kind::WifiSsid) =>
            {
                return Err(format!(
                    "{kind} needs a value in {}",
                    kind.unit().unwrap_or("")
                ));
            }
            (Kind::BatteryBelow, Some(v)) if !(1.0..=100.0).contains(&v) => {
                return Err(format!("battery_below must be 1-100, got {v:.0}"));
            }
            (Kind::TempAbove, Some(v)) if !(30.0..=110.0).contains(&v) => {
                return Err(format!(
                    "temp_above must be between 30 and 110 C, got {v:.0}"
                ));
            }
            (Kind::Idle, Some(v)) if v < 1.0 => {
                return Err("idle must be at least one minute".into());
            }
            _ => {}
        }
        if self.profile.is_none() && self.fan.is_none() && self.curve.is_none() {
            return Err(format!("the {} trigger does nothing", self.condition()));
        }
        if let Some(p) = &self.profile {
            if p.trim().is_empty() {
                return Err("a trigger has an empty profile name".into());
            }
        }
        Ok(())
    }
}

/// The first trigger whose condition holds.
///
/// First rather than most severe: the order in the file is the user's own
/// priority, the same rule the application profiles follow. `engaged` is the
/// index of the trigger currently applied, so only that one gets the release
/// margin.
pub fn active(triggers: &[Trigger], now: &Reading, engaged: Option<usize>) -> Option<usize> {
    triggers
        .iter()
        .enumerate()
        .find(|(i, t)| t.holds(now, engaged == Some(*i)))
        .map(|(i, _)| i)
}

/// "HH:MM" as minutes since midnight.
fn parse_hm(text: &str) -> Option<u16> {
    let (h, m) = text.trim().split_once(':')?;
    let h: u16 = h.trim().parse().ok()?;
    let m: u16 = m.trim().parse().ok()?;
    (h < 24 && m < 60).then_some(h * 60 + m)
}

/// Whether `now` is inside the window, which may wrap past midnight.
///
/// "from 23:00 to 07:00" is one night, not an empty set - that is how anyone
/// writing it means it, and a rule that silently never fired would be a poor
/// way to find out otherwise.
fn in_window(now: u16, from: u16, to: u16) -> bool {
    if from <= to {
        now >= from && now < to
    } else {
        now >= from || now < to
    }
}

/// The local clock, as minutes since midnight.
///
/// Through `date` rather than a date crate. Two reasons: local time needs the
/// zone database and the current DST rules, which is exactly what `date`
/// already does correctly and what a dependency here would only wrap; and the
/// Rust crates that do it either pull in a large tree or refuse to read the
/// local offset from a process with threads, which this daemon has.
///
/// One process per evaluation is more than this deserves, so it is only
/// called when a time trigger is configured, and the caller caches it for a
/// minute - see `Clock`.
fn local_minutes() -> Option<u16> {
    let out = std::process::Command::new("date")
        .arg("+%H:%M")
        .output()
        .ok()?;
    out.status
        .success()
        .then(|| parse_hm(String::from_utf8_lossy(&out.stdout).trim()))?
}

/// The current wireless network, if there is one.
///
/// Three ways of asking, in the order they are likely to work, because no
/// single one is everywhere: NetworkManager runs most desktops, `iw` is in
/// every distribution's base wireless tooling, and `iwgetid` is the old
/// wireless-tools answer that some machines still have and others do not.
/// A machine with none of them simply has no SSID to match on.
fn current_ssid() -> Option<String> {
    // nmcli: the active connection on a wifi device.
    if let Ok(out) = std::process::Command::new("nmcli")
        .args(["-t", "-f", "active,ssid", "dev", "wifi"])
        .output()
    {
        if out.status.success() {
            let text = String::from_utf8_lossy(&out.stdout);
            if let Some(ssid) = text
                .lines()
                .find_map(|l| l.strip_prefix("yes:").map(str::trim))
                .filter(|s| !s.is_empty())
            {
                return Some(ssid.to_owned());
            }
        }
    }

    // iwgetid, which answers with just the name.
    if let Ok(out) = std::process::Command::new("iwgetid").arg("-r").output() {
        if out.status.success() {
            let name = String::from_utf8_lossy(&out.stdout).trim().to_owned();
            if !name.is_empty() {
                return Some(name);
            }
        }
    }

    // iw, which needs to be pointed at an interface.
    let wireless = std::fs::read_dir("/sys/class/net")
        .ok()?
        .flatten()
        .find(|e| e.path().join("wireless").exists())?;
    let name = wireless.file_name();
    let out = std::process::Command::new("iw")
        .args(["dev", name.to_str()?, "link"])
        .output()
        .ok()?;
    let text = String::from_utf8_lossy(&out.stdout);
    text.lines()
        .find_map(|l| l.trim().strip_prefix("SSID:"))
        .map(|s| s.trim().to_owned())
        .filter(|s| !s.is_empty())
}

/// The two readings that cost a process, remembered for a while.
///
/// Neither the clock nor the network name changes between two ticks in a way
/// anybody would notice, and asking every two seconds would mean a process
/// spawn every two seconds for as long as the machine is on.
#[derive(Debug, Clone, Default)]
pub struct Clock {
    minutes: Option<u16>,
    ssid: Option<String>,
    checked: Option<std::time::Instant>,
}

/// How long those two answers are kept. A minute is the resolution a time
/// window is written in anyway, and a network change that takes a minute to
/// notice is a network change nobody was watching.
const CLOCK_TTL: std::time::Duration = std::time::Duration::from_secs(60);

impl Clock {
    pub fn new() -> Self {
        Self::default()
    }

    /// Samples if anything configured actually asks for it, and if the last
    /// answer has gone stale.
    pub fn sample(&mut self, triggers: &[Trigger]) {
        let wanted = |kind: Kind| triggers.iter().any(|t| t.when == kind);
        let time = wanted(Kind::TimeBetween);
        let wifi = wanted(Kind::WifiSsid);
        if !time && !wifi {
            self.minutes = None;
            self.ssid = None;
            return;
        }
        if self.checked.is_some_and(|at| at.elapsed() < CLOCK_TTL) {
            return;
        }
        self.checked = Some(std::time::Instant::now());
        self.minutes = time.then(local_minutes).flatten();
        self.ssid = wifi.then(current_ssid).flatten();
    }

    pub fn minutes(&self) -> Option<u16> {
        self.minutes
    }

    pub fn ssid(&self) -> Option<String> {
        self.ssid.clone()
    }
}

/// Whether the lid is shut.
///
/// `/proc/acpi/button/lid/*/state` is the only interface for this that every
/// kernel still has; logind knows too, but asking it means a D-Bus client in
/// a daemon that otherwise has none.
pub fn lid_closed() -> Option<bool> {
    let dir = std::fs::read_dir("/proc/acpi/button/lid").ok()?;
    for entry in dir.flatten() {
        let Ok(raw) = std::fs::read_to_string(entry.path().join("state")) else {
            continue;
        };
        // "state:      closed"
        let value = raw.split(':').nth(1)?.trim().to_ascii_lowercase();
        return Some(value == "closed");
    }
    None
}

/// How busy the machine is, from `/proc/stat`.
///
/// What this measures is deliberately narrow and worth stating plainly: it is
/// **CPU idleness, not user presence.** The daemon runs as root outside any
/// login session, so it cannot see the keyboard or the pointer without
/// becoming a D-Bus client of whatever session happens to be current - and on
/// a machine with several sessions, or none, that answer is not obviously
/// right either.
///
/// CPU idleness is the honest thing it can measure, and for what triggers are
/// used for - quieten down when nothing is happening - it is also the more
/// useful one: a machine compiling something unattended is not idle, and a
/// machine sitting at a login screen is.
#[derive(Debug, Clone, Copy)]
pub struct Idle {
    last: Option<(u64, u64)>,
    idle_secs: u64,
}

/// Below this fraction of busy CPU time, the machine counts as doing nothing.
/// Five percent covers the daemon's own polling, a cursor blinking and a
/// mail client checking in.
const IDLE_BUSY_FRACTION: f64 = 0.05;

impl Default for Idle {
    fn default() -> Self {
        Self::new()
    }
}

impl Idle {
    pub fn new() -> Self {
        Self {
            last: None,
            idle_secs: 0,
        }
    }

    /// How long the machine has been idle, in seconds.
    pub fn secs(&self) -> u64 {
        self.idle_secs
    }

    /// Samples `/proc/stat` and advances the count. `elapsed` is the time
    /// since the previous call.
    pub fn sample(&mut self, elapsed: std::time::Duration) {
        let Some(now) = cpu_times() else { return };
        let Some(before) = self.last.replace(now) else {
            // The first sample has nothing to subtract from; a machine that
            // just booted is not credited with idle time it may not have had.
            return;
        };

        let busy = now.0.saturating_sub(before.0) as f64;
        let idle = now.1.saturating_sub(before.1) as f64;
        let total = busy + idle;
        if total <= 0.0 {
            return;
        }

        if busy / total < IDLE_BUSY_FRACTION {
            self.idle_secs = self.idle_secs.saturating_add(elapsed.as_secs());
        } else {
            self.idle_secs = 0;
        }
    }

    /// Forget the accumulated idle time - used when something has clearly
    /// happened that /proc/stat would not show, such as the lid opening.
    pub fn reset(&mut self) {
        self.idle_secs = 0;
    }
}

/// (busy, idle) jiffies across all CPUs.
fn cpu_times() -> Option<(u64, u64)> {
    let stat = std::fs::read_to_string("/proc/stat").ok()?;
    let line = stat.lines().next()?;
    let mut fields = line.split_whitespace();
    if fields.next()? != "cpu" {
        return None;
    }
    let values: Vec<u64> = fields.filter_map(|f| f.parse().ok()).collect();
    if values.len() < 5 {
        return None;
    }
    // user nice system idle iowait irq softirq steal ...
    // iowait counts as idle: the CPU is waiting, not working.
    let idle = values[3] + values[4];
    let busy: u64 = values.iter().sum::<u64>() - idle;
    Some((busy, idle))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn trigger(when: Kind, value: Option<f32>) -> Trigger {
        Trigger {
            when,
            value,
            profile: Some("performance".into()),
            fan: None,
            curve: None,
            from: None,
            to: None,
            ssid: None,
        }
    }

    #[test]
    fn a_temperature_trigger_engages_above_its_threshold() {
        let t = trigger(Kind::TempAbove, Some(85.0));
        let hot = Reading {
            temp_c: Some(86.0),
            ..Default::default()
        };
        let warm = Reading {
            temp_c: Some(83.5),
            ..Default::default()
        };
        assert!(t.holds(&hot, false));
        assert!(!t.holds(&warm, false));
        // Once engaged it holds on down to the release margin, so it does not
        // flap either side of 85.
        assert!(t.holds(&warm, true));
        assert!(!t.holds(
            &Reading {
                temp_c: Some(80.0),
                ..Default::default()
            },
            true
        ));
    }

    #[test]
    fn a_temperature_trigger_does_not_let_go_when_the_sensor_vanishes() {
        let t = trigger(Kind::TempAbove, Some(85.0));
        let blind = Reading::default();
        assert!(t.holds(&blind, true), "engaged: keep what was applied");
        assert!(
            !t.holds(&blind, false),
            "not engaged: do not invent a reason"
        );
    }

    #[test]
    fn the_battery_trigger_engages_below_its_threshold() {
        let t = trigger(Kind::BatteryBelow, Some(20.0));
        assert!(t.holds(
            &Reading {
                battery_percent: Some(19),
                ..Default::default()
            },
            false
        ));
        assert!(!t.holds(
            &Reading {
                battery_percent: Some(21),
                ..Default::default()
            },
            false
        ));
        // Engaged, it holds until charge is properly back above the line.
        assert!(t.holds(
            &Reading {
                battery_percent: Some(22),
                ..Default::default()
            },
            true
        ));
    }

    #[test]
    fn the_idle_trigger_counts_in_minutes() {
        let t = trigger(Kind::Idle, Some(30.0));
        assert!(!t.holds(
            &Reading {
                idle_secs: 1799,
                ..Default::default()
            },
            false
        ));
        assert!(t.holds(
            &Reading {
                idle_secs: 1800,
                ..Default::default()
            },
            false
        ));
    }

    #[test]
    fn a_lid_trigger_needs_a_lid() {
        let t = trigger(Kind::LidClosed, None);
        assert!(!t.holds(&Reading::default(), false));
        assert!(t.holds(
            &Reading {
                lid_closed: Some(true),
                ..Default::default()
            },
            false
        ));
    }

    #[test]
    fn the_first_matching_trigger_wins() {
        let list = vec![
            trigger(Kind::TempAbove, Some(85.0)),
            trigger(Kind::LidClosed, None),
        ];
        let now = Reading {
            temp_c: Some(90.0),
            lid_closed: Some(true),
            ..Default::default()
        };
        assert_eq!(active(&list, &now, None), Some(0));
        assert_eq!(
            active(
                &list,
                &Reading {
                    lid_closed: Some(true),
                    ..Default::default()
                },
                None
            ),
            Some(1)
        );
    }

    fn at(from: &str, to: &str) -> Trigger {
        Trigger {
            when: Kind::TimeBetween,
            value: None,
            profile: Some("low-power".into()),
            fan: None,
            curve: None,
            from: Some(from.into()),
            to: Some(to.into()),
            ssid: None,
        }
    }

    #[test]
    fn a_time_window_that_wraps_past_midnight_is_one_night() {
        let night = at("23:00", "07:00");
        let minutes = |h: u16, m: u16| Reading {
            minutes: Some(h * 60 + m),
            ..Default::default()
        };
        assert!(night.holds(&minutes(23, 30), false));
        assert!(night.holds(&minutes(2, 0), false));
        assert!(night.holds(&minutes(6, 59), false));
        assert!(
            !night.holds(&minutes(7, 0), false),
            "the window ends at 07:00"
        );
        assert!(!night.holds(&minutes(12, 0), false));
    }

    #[test]
    fn a_daytime_window_does_not_wrap() {
        let work = at("09:00", "17:30");
        let minutes = |h: u16, m: u16| Reading {
            minutes: Some(h * 60 + m),
            ..Default::default()
        };
        assert!(work.holds(&minutes(9, 0), false));
        assert!(work.holds(&minutes(17, 29), false));
        assert!(!work.holds(&minutes(17, 30), false));
        assert!(!work.holds(&minutes(8, 59), false));
    }

    #[test]
    fn a_clock_that_cannot_be_read_holds_what_was_applied() {
        let night = at("23:00", "07:00");
        assert!(night.holds(&Reading::default(), true));
        assert!(!night.holds(&Reading::default(), false));
    }

    #[test]
    fn a_network_name_is_matched_without_case() {
        let office = Trigger {
            when: Kind::WifiSsid,
            value: None,
            profile: Some("balanced".into()),
            fan: None,
            curve: None,
            from: None,
            to: None,
            ssid: Some("Office WiFi".into()),
        };
        assert!(office.holds(
            &Reading {
                ssid: Some("office wifi".into()),
                ..Default::default()
            },
            false
        ));
        assert!(!office.holds(
            &Reading {
                ssid: Some("Home".into()),
                ..Default::default()
            },
            false
        ));
        // Not on any network is not "on the office network".
        assert!(!office.holds(&Reading::default(), true));
    }

    #[test]
    fn the_new_kinds_refuse_the_wrong_arguments() {
        let mut t = at("23:00", "07:00");
        t.value = Some(5.0);
        assert!(t.check().is_err(), "a value is not what a window takes");

        let mut same = at("09:00", "09:00");
        same.value = None;
        assert!(same.check().is_err(), "a window that starts where it ends");

        let mut bad = at("25:00", "07:00");
        bad.value = None;
        assert!(bad.check().is_err(), "25:00 is not a time");

        let mut hot = trigger(Kind::TempAbove, Some(85.0));
        hot.ssid = Some("Office".into());
        assert!(hot.check().is_err(), "temp_above does not take an ssid");

        let empty = Trigger {
            when: Kind::WifiSsid,
            value: None,
            profile: Some("balanced".into()),
            fan: None,
            curve: None,
            from: None,
            to: None,
            ssid: Some("   ".into()),
        };
        assert!(empty.check().is_err());
    }

    #[test]
    fn nothing_is_sampled_for_triggers_nobody_configured() {
        // The clock and the network name each cost a process; a machine with
        // no such trigger must not pay for them.
        let mut clock = Clock::new();
        clock.sample(&[trigger(Kind::TempAbove, Some(85.0))]);
        assert_eq!(clock.minutes(), None);
        assert_eq!(clock.ssid(), None);
    }

    #[test]
    fn nonsense_entries_are_refused() {
        assert!(trigger(Kind::TempAbove, None).check().is_err());
        assert!(trigger(Kind::LidClosed, Some(5.0)).check().is_err());
        assert!(trigger(Kind::TempAbove, Some(500.0)).check().is_err());
        assert!(trigger(Kind::BatteryBelow, Some(0.0)).check().is_err());
        assert!(trigger(Kind::TempAbove, Some(85.0)).check().is_ok());

        let does_nothing = Trigger {
            when: Kind::LidClosed,
            value: None,
            profile: None,
            fan: None,
            curve: None,
            from: None,
            to: None,
            ssid: None,
        };
        assert!(does_nothing.check().is_err());
    }

    #[test]
    fn idleness_is_measured_rather_than_assumed() {
        let mut idle = Idle::new();
        // The first sample establishes a baseline and credits nothing.
        idle.sample(std::time::Duration::from_secs(2));
        assert_eq!(idle.secs(), 0);
        // Whatever the second one finds, reading /proc/stat must not panic.
        idle.sample(std::time::Duration::from_secs(2));
        idle.reset();
        assert_eq!(idle.secs(), 0);
    }

    #[test]
    fn reading_the_lid_does_not_panic() {
        let _ = lid_closed();
    }
}
