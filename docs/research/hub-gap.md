# What OMEN Gaming Hub does that this project did not (8D24)

Surveyed 2026-10-06 on the OMEN 16-ap0xxx, Windows 11, OMEN Gaming Hub
1101.2609.3.0. Three sources, in order of how much they are worth:

1. **The Hub's own logs** -
   `%LOCALAPPDATA%\Packages\AD2F1837.OMENCommandCenter_v10z8vjag6ke6\LocalCache\Local\HPOMEN\`.
   They print every `Is…Support` decision and every WMI payload it sends.
2. **The platform configuration it ships for this board**, an embedded
   resource of `HP.Omen.Core.Common.dll` named
   `HP.Omen.Core.Common.PowerControl.JSON.Khalilah_STX_N22X4X6.json`. The log
   names it: `DeviceLib: Platform = Khalilah`, `LoadInitialConfig: Postfix =
   Khalilah_STX_N22X4X6`. *Khalilah* is HP's code name for this chassis.
3. **The Hub's .NET assemblies, decompiled** with ILSpy
   (`PerformanceControl.dll`, `HP.Omen.Background.PerformanceControl.dll`,
   `HP.Omen.Core.Model.Device.dll`). Used only to find out *which WMI command*
   carries a value the logs name but do not attribute. Nothing of HP's code
   is reproduced here or in the source tree; the facts taken from it are
   command numbers, byte layouts and the platform's numeric limits.

## What the Hub enables on this machine

From `DeviceModel::SortDeviceFeatures` in the log:

```
SystemInfo, PerformanceControl, OMENOverclocking, FourZone,
GraphicsSwitcher, NetworkBooster, KeyboardRemap, UMAmode
```

and the capability probes that matter:

| Probe | Value | Meaning |
|---|---|---|
| `IsUnleashedModeSupport` | True | the fourth thermal mode, HPCM `0x04` |
| `IsSurfaceTempSupport` | True | an IR skin-temperature sensor drives limits |
| `IsPowerLimit1Support` | True | the Hub sets the CPU's PL1 itself |
| `IsTppSupport` / `IsWmiSupportTpp` | True | CPU+GPU shared power ("TPP") is adjustable |
| `IsSwFanControlSupport` | True | the fan curve runs in software (already known, Phase 1 §6.4) |
| `IsBiosCoolModeSupported` | True | |
| `IsExtremeModeSupport` / `IsExtremeModeUnlock` | True / False | present but locked |
| `IsAutoDrrSupport` | False | no firmware dynamic refresh rate |
| `IsSystemSupportedPBO` | False | the Hub does not offer PBO here |
| `IsCtgpModeSupport`, `IsDynamicPowerLimitSupport`, `IsIccMaxSupport` | False | |
| `IsWin11PowerModeSyncSupport` | True | |

## The protocol, settled

### Surface (IR) temperature - GM `0x23`, EC `0x48`

The Hub's `GetIRSensorValue()` is `GetSensorValue(0)`, a call to group
`0x20008` command `0x23` with input `{0, 0, 0, 0}` (index 1 is ambient, 2 the
PCH, 3 the VR - none of which this board reports). On 8D24 the DSDT's `GM23`
ignores the index and returns `R480`, **EC register `0x48`**, in whole
degrees. `docs/acpi/extract/GM-LM-methods.asl`, `GM23`.

The only value the Hub logged in three days: `IrTemp (45)` with the machine
on a desk.

### Power limits and TPP - GM `0x29` (write), GM `0x2A` (read)

Four bytes, `0xFF` meaning "leave this one":

| Byte | GM29 writes | Hub's name |
|---|---|---|
| 0 | `OSPT`, EC `0x38` | PL2 (on AMD the Hub sends PL1 here too) |
| 1 | `OSPL`, EC `0x37` | **PL1**, watts |
| 2 | - (the SMI takes it) | PL4 |
| 3 | `NPCF.DATP = x * 8`, then `Notify(NPCF, 0xC0)` | **concurrent TDP** - CPU+GPU shared watts |

The payloads seen in the log are exactly this: `60,60,255,255` is
`SetPL1DefaultValue - PL1DefaultValue=60` (performance), `255,255,255,45` is
`SetConcurrentTdp - value=45`. Phase 1 §6.5 saw the same `…,45` and `…,65`
payloads and could not attribute them; this attributes them.

`GM2A` reads the state back: byte 3 `OSPT`, byte 4 `OSPL`, byte 7
`NPCF.ATPP / 8` - the concurrent TDP. The Hub decides TPP is supported when
that byte is non-zero.

### Unleashed - HPCM `0x04`

Already captured in Phase 1 §6.1 (`255,4,0,0` to GM `0x1A`). What was not
known is what the Hub does *around* it. From the platform configuration:

| | Value |
|---|---|
| PL1 when entering Unleashed | 71 W (user range 25-71) |
| Surface temperature limit | 54 °C (user range 44-54) |
| Concurrent TDP | 45 W + offset, at most 65 W (`TppMaxValue`) |
| PL1 the firmware's own profiles use | balanced 55 W, performance 60 W |
| Battery floor | performance needs 10 %, Unleashed 40 % |

The last two lines agree with what `omenctl profile measure` found on Linux
(55.0 W and 60.0 W, `profile-power.md`) - a measurement and HP's own table
reaching the same numbers from opposite ends.

The surface limit is a loop, every 30 s: at or above the limit PL1 drops by
5 W; below it, and falling, it is raised again; at the limit Dynamic Boost is
switched off as well.

### The fan algorithm

Per mode (Default for eco/balanced, Performance, Unleashed), three tables of
nine steps: CPU, GPU and IR. Each step has a temperature to go *up* at and a
lower one to come *down* at, so the tables carry their own hysteresis. The CPU
reading is smoothed first (an exponential average, slow to rise and quick to
fall); the GPU and IR readings are used as they are. Each source moves at most
one step per 5 s cycle, and the fan target is the **largest** of the three.

The Default table keeps the fans stopped until the smoothed CPU reaches 68 °C
or the GPU 54 °C. That is not the 50-90 °C table this project shipped as "OMEN
Gaming Hub's curve" (Phase 1 §6.3): that one is the Hub's *custom curve*
starting point, which only applies once someone turns custom curves on.

## Gaps, and what was done about them

| # | Hub feature | Linux route | Where |
|---|---|---|---|
| 1 | Unleashed mode | `omen-kbd-rgb` `unleashed` (GM1A `0x04`), offered as a fourth profile | omen-kbd-rgb 0.3.0 + omend |
| 1 | CPU/GPU/IR fan tables with hysteresis | `fan.algorithm = "hub"` | omend, omenctl |
| 2 | Surface temperature | `omen-kbd-rgb` hwmon `temp2` (EC `0x48`) | omen-kbd-rgb 0.3.0 + omend |
| 3 | Power plan sync | `amd_pstate` EPP follows the profile when no power-profiles-daemon runs | omend, omenctl |
| 3 | Battery floor for performance / Unleashed | `[power] min_battery_*` | omend, omenctl |
| 3 | Game booster | Feral GameMode: `omenctl gamemode on/off` from `gamemode.ini` | omend, omenctl |
| 4 | PL1 | `omen-kbd-rgb` `cpu_pl1` (GM29 byte 1) | omen-kbd-rgb 0.3.0 + omend |
| 4 | TPP | `omen-kbd-rgb` `gpu_tpp` (GM29 byte 3) | omen-kbd-rgb 0.3.0 + omend |
| 5 | In-game overlay | MangoHud, through `omenctl overlay` | omend, omenctl |
| 5 | Refresh rate per application | `refresh_hz` on application and power rules, applied by `omenctl session` in the desktop session | omend, omenctl |

Not taken, and why:

* **PBO / Curve Optimizer.** `IsPBOSupported` is true but
  `IsSystemSupportedPBO` is false and the Curve Optimizer query errors; HP
  itself does not offer it on this board.
* **Extreme mode.** Locked (`IsExtremeModeUnlock = False`); how it unlocks
  is not known.
* **Network Booster** (Realtek "Fusion" driver), **System Optimizer**
  (Windows service tweaks), **Virtual Audio / Camera / Broadcast**, the game
  library, deals and giveaways: either Windows-specific or not hardware.
* **Accessories** (mice, headsets, monitors): OpenRGB and libratbag already
  do this on Linux.

## Measured on Linux (2026-10-09, kernel 7.2.9, BIOS F.11)

* **The surface sensor.** EC `0x48` read 34 °C at idle and 37 °C a few
  minutes later, well below the CPU. That is plausible for a palm rest, and
  matches the 45 °C the Hub logged under use.
* **PL1 is EC `0x37`.** It read 60 W in performance, HP's own value for that
  profile, and the same as `omenctl profile measure` found before anything
  here wrote PL1.
* **Writing PL1 through GM29 works.** In Unleashed, PL1 read 71 W and the
  package drew a flat **71.0 W** at 3879 MHz under load, up from performance's
  60 W.
* **The firmware does not reset PL1 with the profile.** In the same run,
  balanced and performance also drew 71.0 W. omend restored PL1 only on the
  direct exit from Unleashed, and the run left Unleashed to low-power, which
  had no value to restore. Every firmware profile now gets its PL1 back on
  every change: low-power and balanced 55 W, performance 60 W. Low-power
  shares HPCM `0x30` with balanced; its cap comes from amd-pmf.
* **`platform_profile` reads `performance` while HPCM is `0x04`.** It does
  not fail, so power-profiles-daemon and the desktop see performance, the
  mode Unleashed sits above.
* **The first switch to Unleashed did not stick; the second did.** That
  fits power-profiles-daemon writing back the "performance" that selecting
  Unleashed writes first. That rewrite resets HPCM. omend now puts Unleashed
  back once if the profile drops to performance within 15 s of entering
  it, and logs it. This is a hypothesis until the journal shows the line.
* **The shared limit read 30 W, where the Hub works from 45.** The value
  follows the profile, so performance and Unleashed now use HP's fixed
  numbers (45 W plus the offset, at most 65 W), and the firmware's value is
  put back elsewhere.
* Low-power drew 17.3 W, against 31.7 W in September. power-profiles-daemon
  now keeps EPP in step and sets `power` there, which may explain it. Not
  investigated.
