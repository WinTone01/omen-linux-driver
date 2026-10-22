//! Fan control through hp-wmi's hwmon interface.
//!
//! Verified in Phase 2: `pwm1` only appears when the 8D24 DMI entry matches.
//! The kernel-side contract (drivers/platform/x86/hp/hp-wmi.c):
//!
//!   * `pwm1_enable`  0 = MAX, 1 = MANUAL, 2 = AUTO
//!   * `pwm1`         0..255, mapped LINEARLY onto 0..max_rpm
//!   * writes to `pwm1` are only accepted in MANUAL mode (else -EINVAL)
//!   * the kernel additionally clamps the setpoint to min_rpm..max_rpm
//!
//! So clamping happens twice: here first, then in the kernel.
//!
//! One asymmetry is worth knowing before building anything on this: WRITING
//! `pwm1` sets the target, but READING it does not give that target back - it
//! converts the fan's CURRENT speed through the same scale. Measured
//! 2026-09-12: setpoint 1800, fans turning at 1700, `pwm1` reads 90
//! (90/255 x 4800 = 1694); mid-ramp, 2300 RPM and 122 (2296). So anything
//! that compares `pwm1` against what was written disagrees on every ramp -
//! see omend's check_drift, which used to.
//!
//! The second fan. Up to 7.2, hp-wmi sets both fans from `pwm1`, the second
//! at a fixed offset from the first - the first row's of the firmware's fan
//! table, -200 RPM on 8D24. From 7.3 it has `pwm2` and leaves the second fan
//! wherever it was until that is written. Where `pwm2` exists it is written
//! here, the way OMEN Gaming Hub chooses it: see [`second_fan_rpm`].

use std::cell::Cell;

use crate::error::{Error, Result};
use crate::sysfs::Hwmon;

/// The firmware's fan table, as omen-kbd-rgb reads it from WMI command 0x2F:
/// one row per line, fan 1 RPM, fan 2 RPM, noise in dB.
const FAN_TABLE: &str = "/sys/devices/platform/omen-kbd-rgb/fan_table";

/// (fan 1, fan 2) RPM per row of the firmware's table, lowest first. Empty
/// without omen-kbd-rgb 0.4.0, or where the firmware has no table.
pub fn fan_table() -> Vec<(u32, u32)> {
    std::fs::read_to_string(FAN_TABLE)
        .map(|s| parse_fan_table(&s))
        .unwrap_or_default()
}

fn parse_fan_table(text: &str) -> Vec<(u32, u32)> {
    text.lines()
        .filter_map(|line| {
            let mut it = line.split_whitespace().map(|v| v.parse::<u32>().ok());
            Some((it.next()??, it.next()??))
        })
        .collect()
}

/// The second fan's setpoint for a first-fan setpoint, as OMEN Gaming Hub
/// works it out (`SwFanControlTable.GetSameLevelFans`, reached from
/// `PerformanceControlHelper.SetSwFanControlLevel`): find the last row whose
/// first-fan speed is not above the target and keep that row's difference.
/// Below the first row, or with no table, the Hub uses 200 RPM less.
///
/// On 8D24 that puts the second fan two or three steps below the first at
/// the bottom of the table and above it from 2900 RPM up. The Hub's own log
/// has 3800 going out as 3800/4100 and 2100 as 2100/1900; hp-wmi's fixed
/// first-row offset would have sent 3800/3600.
pub fn second_fan_rpm(table: &[(u32, u32)], first: u32) -> u32 {
    if first == 0 {
        return 0;
    }
    match table.iter().rev().find(|(cpu, _)| *cpu <= first) {
        Some((_, 0)) => 0,
        Some((cpu, gpu)) => (first + gpu).saturating_sub(*cpu),
        None => first.saturating_sub(200),
    }
}

/// Names hp-wmi's hwmon may use in its `name` file. "hp" on 7.2; the second
/// catches a future rename.
const HWMON_NAMES: &[&str] = &["hp", "hp_wmi"];

/// Whether hp-wmi's automatic mode really hands the fans to the EC.
///
/// True with the hp-wmi this project builds (kernel/hp-wmi-8d24/fix-auto.sh),
/// which says so through its `firmware_auto` parameter; measured in
/// docs/research/ec-handover.md. False with stock hp-wmi, whose automatic
/// mode leaves this board's fans stopped for two minutes.
pub fn auto_hands_over() -> bool {
    std::fs::read_to_string("/sys/module/hp_wmi/parameters/firmware_auto")
        .is_ok_and(|v| v.trim() == "Y")
}

/// Which revision of this project's 8D24 changes the loaded hp-wmi carries
/// (kernel/hp-wmi-8d24/fix-auto.sh): 0 for stock, 1 for a build with only
/// the automatic-mode fix, 2 when a pwm of 0 also stops the fans, a power
/// change no longer writes a 0 W PL1 and Unleashed reads as performance.
pub fn hp_wmi_fixes() -> u8 {
    match std::fs::read_to_string("/sys/module/hp_wmi/parameters/omen_fixes") {
        Ok(v) => v.trim().parse().unwrap_or(0),
        Err(_) => u8::from(auto_hands_over()),
    }
}

/// The revision install.sh builds.
pub const HP_WMI_FIXES: u8 = 2;

/// Phase 1 §6.3: OGH's own `profiles.json` bounds are 18-48, i.e. 1800-4800 RPM.
pub const DEFAULT_MIN_RPM: u32 = 1800;
pub const DEFAULT_MAX_RPM: u32 = 4800;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PwmMode {
    /// Fans at full power. hp-wmi does this with WMI 0x27 (FFFS=1).
    Max,
    /// We drive the setpoint.
    Manual,
    /// Control belongs to the EC. Stock hp-wmi writes EC 0x34/0x35 as 0
    /// here, which on 8D24 means stopped until the firmware's user-defined
    /// state times out two minutes later. With hp-wmi built by this project
    /// it writes 0xff, the firmware's own "automatic", and the EC's curve
    /// takes over within two seconds - see [`auto_hands_over`].
    Auto,
}

impl PwmMode {
    fn from_raw(v: i64) -> Option<Self> {
        match v {
            0 => Some(Self::Max),
            1 => Some(Self::Manual),
            2 => Some(Self::Auto),
            _ => None,
        }
    }

    fn as_raw(self) -> i64 {
        match self {
            Self::Max => 0,
            Self::Manual => 1,
            Self::Auto => 2,
        }
    }
}

impl std::fmt::Display for PwmMode {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(match self {
            Self::Max => "max",
            Self::Manual => "manual",
            Self::Auto => "auto",
        })
    }
}

#[derive(Debug, Clone)]
pub struct Fan {
    hwmon: Hwmon,
    /// omen-kbd-rgb's hwmon, when it has the tachometers.
    ///
    /// hp-wmi reads them through a firmware method that starts with an SMI:
    /// 264 ms a read on 8D24, during which no other ACPI method runs. Three a
    /// tick held the ACPI interpreter for most of a second in every two, and
    /// the keyboard's effects stuttered on it. The module reads the same two
    /// numbers straight out of the EC's memory-mapped RAM. hp-wmi stays the
    /// fallback, and the only thing written to.
    tach: Option<Hwmon>,
    /// hp-wmi has `pwm2`: the second fan is set separately (7.3 and later).
    second: bool,
    /// The firmware's fan table, for the second fan's setpoint.
    table: Vec<(u32, u32)>,
    /// What `pwm2` was last set to, while hp-wmi still holds it.
    ///
    /// On 7.3 every pwm write re-sends both fans' setpoints to the firmware
    /// (GM 0x10, 0x27 and 0x2E), and omend rewrites its setpoint every ten
    /// seconds. Writing `pwm1` alone re-sends the second fan's value too, so
    /// `pwm2` is written only when it changes - otherwise every keep-alive
    /// costs six firmware calls instead of three, and they hold the ACPI
    /// interpreter while the keyboard's effects wait. Forgotten on any mode
    /// change: entering manual, hp-wmi re-seeds both from the tachometers.
    last_second: Cell<Option<u8>>,
    min_rpm: u32,
    max_rpm: u32,
}

impl Fan {
    /// Finds hp-wmi's hwmon and checks that `pwm1` is exposed.
    ///
    /// A missing `pwm1` almost always means the 8D24 patch was not applied -
    /// the error message says as much.
    pub fn discover(min_rpm: u32, max_rpm: u32) -> Result<Self> {
        let hwmon = Hwmon::find_any(HWMON_NAMES).ok_or(Error::HwmonNotFound)?;
        if !hwmon.has("pwm1") {
            return Err(Error::PwmUnsupported);
        }
        if max_rpm == 0 || min_rpm >= max_rpm {
            return Err(Error::Curve(format!(
                "invalid RPM range: {min_rpm}-{max_rpm}"
            )));
        }
        let tach = Hwmon::all()
            .into_iter()
            .find(|h| h.name == "omen" && h.has("fan1_input"));
        let second = hwmon.has("pwm2");
        Ok(Self {
            table: if second { fan_table() } else { Vec::new() },
            hwmon,
            tach,
            second,
            last_second: Cell::new(None),
            min_rpm,
            max_rpm,
        })
    }

    /// Whether the second fan is set on its own (hp-wmi 7.3 and later), and
    /// whether that follows the firmware's table rather than a fixed offset.
    pub fn second_fan(&self) -> (bool, bool) {
        (self.second, !self.table.is_empty())
    }

    pub fn hwmon_path(&self) -> &std::path::Path {
        &self.hwmon.path
    }

    pub fn min_rpm(&self) -> u32 {
        self.min_rpm
    }

    pub fn max_rpm(&self) -> u32 {
        self.max_rpm
    }

    /// Tachometer. `index` is 1 or 2 (CPU / GPU fan).
    pub fn rpm(&self, index: u8) -> Result<u32> {
        let attr = format!("fan{index}_input");
        if let Some(tach) = &self.tach {
            if let Ok(v) = tach.read(&attr) {
                return Ok(v.max(0) as u32);
            }
        }
        Ok(self.hwmon.read(&attr)?.max(0) as u32)
    }

    /// Whether the tachometers come from the fast path (see `tach`).
    pub fn fast_tach(&self) -> bool {
        self.tach.is_some()
    }

    pub fn mode(&self) -> Result<PwmMode> {
        let raw = self.hwmon.read("pwm1_enable")?;
        PwmMode::from_raw(raw).ok_or_else(|| Error::Parse {
            path: self.hwmon.attr("pwm1_enable"),
            raw: raw.to_string(),
        })
    }

    pub fn set_mode(&self, mode: PwmMode) -> Result<()> {
        let current = self.mode()?;
        if current == mode {
            return Ok(());
        }
        self.last_second.set(None);

        // Going straight from MAX to MANUAL does not take reliably: the
        // firmware has to be let out of max-fan first. omen-space does the
        // same thing for the same reason, and the short pause is theirs too.
        if current == PwmMode::Max && mode == PwmMode::Manual {
            self.hwmon.write("pwm1_enable", PwmMode::Auto.as_raw())?;
            std::thread::sleep(std::time::Duration::from_millis(50));
        }

        self.hwmon.write("pwm1_enable", mode.as_raw())
    }

    /// What `pwm1` reads. On this board hp-wmi does not give back the
    /// setpoint there but the first fan's measured speed on the PWM scale,
    /// through the same slow method - so with the fast tachometer it is
    /// worked out from that instead.
    pub fn pwm(&self) -> Result<u8> {
        if self.tach.is_some() {
            return Ok(self.rpm_to_pwm(self.rpm(1)?));
        }
        Ok(self.hwmon.read("pwm1")?.clamp(0, 255) as u8)
    }

    /// Writes the target speed in RPM.
    ///
    /// The mode is set first because the kernel rejects writes outside MANUAL.
    /// The value is clamped to the min/max range whatever the config says.
    pub fn set_target_rpm(&self, rpm: u32) -> Result<u32> {
        let clamped = rpm.clamp(self.min_rpm, self.max_rpm);
        self.set_mode(PwmMode::Manual)?;
        self.hwmon.write("pwm1", self.rpm_to_pwm(clamped) as i64)?;
        if self.second {
            let second = second_fan_rpm(&self.table, clamped).clamp(self.min_rpm, self.max_rpm);
            self.write_second(self.rpm_to_pwm(second))?;
        }
        Ok(clamped)
    }

    /// Fans off, with the setpoint still ours.
    ///
    /// NOT the same as handing control to the EC, and the difference is the
    /// whole point: `pwm1_enable = 2` writes EC 0x34/0x35 as 0, which is
    /// supposed to mean "revert to your own curve" - and on this board, once
    /// the driver has been in manual mode, the EC does not. It leaves the
    /// fans stopped and keeps them stopped while the machine heats up
    /// (measured: 78 -> 85 C in twelve seconds with pwm1_enable = 2).
    ///
    /// So a quiet machine has to be something we hold rather than something
    /// we hand over: stay in manual at pwm 0, and the next sample can spin
    /// the fans back up because control never left. omen-space reached the
    /// same conclusion on the same hardware family and never leaves manual
    /// mode either.
    ///
    /// Stock hp-wmi (7.2 and 7.3) clamps every pwm write to the fan table's
    /// lowest speed, so there 0 holds the fans at 1800 RPM. The hp-wmi this
    /// project builds passes 0 through on 8D24 (fix-auto.sh), and the fans
    /// stop - which is what OMEN Gaming Hub's idle sends.
    pub fn set_idle(&self) -> Result<()> {
        self.set_mode(PwmMode::Manual)?;
        self.hwmon.write("pwm1", 0)?;
        if self.second {
            self.write_second(0)?;
        }
        Ok(())
    }

    /// `pwm2`, when it differs from what hp-wmi already holds.
    fn write_second(&self, pwm: u8) -> Result<()> {
        if self.last_second.get() == Some(pwm) {
            return Ok(());
        }
        self.last_second.set(None);
        self.hwmon.write("pwm2", pwm as i64)?;
        self.last_second.set(Some(pwm));
        Ok(())
    }

    /// Hands control back to the EC. Safety rule 1: called on every exit path.
    pub fn restore_auto(&self) -> Result<()> {
        self.set_mode(PwmMode::Auto)
    }

    /// RPM -> PWM. Rounds UP, so rounding error always lands on the side of
    /// MORE cooling, never less.
    pub fn rpm_to_pwm(&self, rpm: u32) -> u8 {
        let rpm = rpm.min(self.max_rpm);
        let scaled = (rpm as u64 * 255).div_ceil(self.max_rpm as u64);
        scaled.min(255) as u8
    }

    pub fn pwm_to_rpm(&self, pwm: u8) -> u32 {
        (pwm as u64 * self.max_rpm as u64 / 255) as u32
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn fan(min: u32, max: u32) -> Fan {
        Fan {
            hwmon: Hwmon {
                path: "/dev/null".into(),
                name: "hp".into(),
            },
            tach: None,
            second: false,
            table: Vec::new(),
            last_second: Cell::new(None),
            min_rpm: min,
            max_rpm: max,
        }
    }

    /// 8D24's GM2F, as omen-kbd-rgb prints it (P1F1/P1F2/P1DB in the DSDT).
    const TABLE_8D24: &str = "1800 1600 22\n2100 1900 25\n2400 2100 28\n2600 2400 31\n\
        2800 2600 34\n2900 3200 37\n3300 3500 40\n3600 3900 43\n4200 4400 46\n\
        4500 4700 48\n4800 5100 50\n";

    #[test]
    fn the_table_parses() {
        let t = parse_fan_table(TABLE_8D24);
        assert_eq!(t.len(), 11);
        assert_eq!(t[0], (1800, 1600));
        assert_eq!(t[10], (4800, 5100));
        assert!(parse_fan_table("garbage\n\n").is_empty());
    }

    #[test]
    fn the_second_fan_follows_the_hubs_log() {
        // Pairs OMEN Gaming Hub logged on 8D24 (phase1-findings.md §6.3/6.4).
        let t = parse_fan_table(TABLE_8D24);
        assert_eq!(second_fan_rpm(&t, 2100), 1900);
        assert_eq!(second_fan_rpm(&t, 2400), 2100);
        assert_eq!(second_fan_rpm(&t, 3800), 4100);
        assert_eq!(second_fan_rpm(&t, 4400), 4600);
    }

    #[test]
    fn the_second_fan_below_the_table_and_without_one() {
        let t = parse_fan_table(TABLE_8D24);
        assert_eq!(second_fan_rpm(&t, 0), 0, "off is off");
        assert_eq!(second_fan_rpm(&t, 1500), 1300);
        assert_eq!(second_fan_rpm(&[], 3000), 2800);
        // A row with no second fan asks for none.
        assert_eq!(second_fan_rpm(&[(1800, 0)], 2000), 0);
    }

    #[test]
    fn pwm_endpoints_are_right() {
        let f = fan(1800, 4800);
        assert_eq!(f.rpm_to_pwm(0), 0);
        assert_eq!(f.rpm_to_pwm(4800), 255);
        // A request above the ceiling saturates at 255 rather than wrapping.
        assert_eq!(f.rpm_to_pwm(9999), 255);
    }

    #[test]
    fn rounding_never_undershoots() {
        // For every RPM: converting back must not land below what was asked.
        let f = fan(1800, 4800);
        for rpm in (0..=4800).step_by(100) {
            let back = f.pwm_to_rpm(f.rpm_to_pwm(rpm));
            assert!(
                back + 100 >= rpm,
                "rpm={rpm} -> pwm={} -> {back}, dropped too far",
                f.rpm_to_pwm(rpm)
            );
        }
    }

    #[test]
    fn mode_conversion_is_symmetric() {
        for m in [PwmMode::Max, PwmMode::Manual, PwmMode::Auto] {
            assert_eq!(PwmMode::from_raw(m.as_raw()), Some(m));
        }
        assert_eq!(PwmMode::from_raw(3), None);
    }
}
