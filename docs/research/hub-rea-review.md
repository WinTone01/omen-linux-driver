# OMEN Gaming Hub, read end to end (8D24, October 2026)

[hub-gap.md](hub-gap.md) took what the Hub's logs said and filled the gaps
they showed. This pass went the other way: every BIOS WMI call site in the
Hub's assemblies, every byte it sends, and every number in the platform
configuration it loads for this board, checked against what this project
sends. Same machine, same Hub (1101.2609.3.0), BIOS F.11.

As before, nothing of HP's code is reproduced here or in the tree. The facts
taken from it are command numbers, byte layouts, constants and the shape of
the decisions around them.

## How

* **REA 6.7.0** (`rea-agents`) for the inventory: `inspect-managed-members`
  over 37 of the Hub's assemblies - types, methods, call edges and the
  string literals each method loads. That is what found where the WMI calls
  are (`HP.Omen.Core.Common.OmenHsaClient`) and which classes matter.
* **ILSpy 11.1** (`ilspycmd`) for the method bodies, which REA's managed
  provider does not decompile; REA takes it as a bring-your-own
  reconstruction. Command numbers are integer constants in the IL, so this
  is where the table below comes from.
* **Ghidra 12.1.4 through REA** for the one native piece on the WMI path,
  `HpReadHWData.sys` (below).
* **The Hub's logs** for what actually ran on this machine:
  `%LOCALAPPDATA%\Packages\AD2F1837.OMENCommandCenter_v10z8vjag6ke6\LocalCache\Local\HPOMEN\`.
* **The registry**: the Hub caches the firmware's system design data in
  `HKCU\Software\HP\OMEN Ally\Settings\SystemDesignData`.

| Artifact | SHA-256 (prefix) | REA Evidence |
|---|---|---|
| `HP.Omen.Core.Model.Device.dll` | `feb984522d08b627` | `ev_b05142a0…819e` |
| `HP.Omen.Core.Common.dll` | `50de558636ed95de` | `ev_8bb2fa4d…08dc` |
| `HP.Omen.Background.PerformanceControl.dll` | `cb10cb067f219cab` | `ev_399d400f…4b8c` |
| `PerformanceControl.dll` | `0308e96a2623f0dc` | `ev_b9799d2d…52ec` |
| `HP.Omen.Background.FourZone.dll` | `77e387d307e89192` | `ev_4f02c7f2…b87b` |
| `HP.Omen.GraphicsSwitcherModule.dll` | `8cfe4715384e8159` | `ev_16f9bc54…bd3e` |
| `HpReadHWData.sys` (Ghidra) | `efe69719bf55ccdc` | `ev_c89c95d0…a183`, `ev_4d28fb8f…bea1` |

## The path to the firmware is the same one Linux uses

Every BIOS WMI call in the Hub goes through
`OmenHsaClient.ExecuteBiosWmiCommandThruDriver`. It builds the familiar
buffer - `"SECU"`, command, command type, input size rounded up to
4/128/1024/4096, the data - and hands it to its own kernel driver,
`HpReadHWData.sys`, through an IOCTL its wrapper calls `Rdmsr`. Only if that
fails does it fall back to WMI from user space.

Ghidra, through REA, shows what the driver does with it: `IoWMIOpenBlock` on
the GUID at `0x14000a080` - bytes `34 f0 b7 5f 63 2c e9 45 be 91 3d 44 e2 c7
07 e4`, that is **`5FB7F034-2C63-45E9-BE91-3D44E2C707E4`** - then
`IoWMIExecuteMethod` on instance `ACPI\PNP0C14\0_0` with the method ID the
output size selects. That is `WMAA`, the method hp-wmi and omen-kbd-rgb call
with `wmi_evaluate_method()`. No extra EC writes ride along. (The same driver
also reads and writes MSRs and I/O ports and runs an Intel watchdog; none of
that is on the WMI path, and none of it is used on AMD.)

So any difference between the Hub and this project is in *what* is sent,
never in how it gets there.

## Every command the Hub sends

All call sites, with what they are and what this project does about each.
`GM` is group `0x20008`, `LM` `0x20009`, BIOS read/write are commands 1 and 2.

| Command | Hub's name | Here |
|---|---|---|
| GM 0x01 | platform support (light bar bit) | - |
| GM 0x10 | `GetNumOfFan`, the 30 s heartbeat; byte 1 is BIOS protection (bit 0 OCP, bit 1 OTP) | hp-wmi calls it as the keep-alive; byte 1 unused |
| GM 0x18 / 0x19 | memory overclocking | logged "not support any Memory OC" on 8D24 |
| GM 0x1A | `SetFanMode` {FF, mode, fanControlByBios, 0} | hp-wmi, omen-kbd-rgb `unleashed` - **same bytes** |
| GM 0x21 / 0x22 | GPU status / `SetTgpPpab` | omen-kbd-rgb `gpu_ctgp`, `gpu_ppab` - **bytes 2-3 differed, fixed** |
| GM 0x23 | `GetSensorValue(index)`; 0 = IR | omen-kbd-rgb reads the same EC 0x48 directly |
| GM 0x26 / 0x27 | max fan get / set, one byte | hp-wmi `pwm1_enable = 0` - same |
| GM 0x28 | system design data | omen-kbd-rgb reads byte 7 (mux); the rest below |
| GM 0x29 | `SetPowerLimit` {PL2, PL1, FF, TPP} | omen-kbd-rgb - **same bytes** (PL2 = PL1 on AMD, see below) |
| GM 0x2A | `GetPowerData` | omen-kbd-rgb `gpu_tpp` - same byte 7 |
| GM 0x2C | `GetFanType` | - (byte 8 is reverse-fan capability: 0 here) |
| GM 0x2D | `GetFanLevel` | omen-kbd-rgb reads the same values from EC RAM |
| GM 0x2E | `SetSwFanControlLevel` {fan 1, fan 2} | hp-wmi `pwm1` - **fan 2 differs, see below** |
| GM 0x2F | `GetFanTable` | omen-kbd-rgb `fan_table` (new) |
| GM 0x31 | `SetIdleCommandOnOff`, from the power options module | - |
| GM 0x32 | `DtSetFanLevel` | desktops only |
| GM 0x33 / 0x34 | "easter egg" mode | - |
| GM 0x35 / 0x36 / 0x37 | OC capability / load line, IccMax, Curve Optimizer, two-byte PL4 | none of it offered on this board (`IsSystemSupportedPBO` false, design data byte 9 = 0) |
| LM 0x01-0x05 | lighting caps, colour, brightness | omen-kbd-rgb - **same bytes** (offset 25, 228 on / 100 off) |
| LM 0x06 / 0x07 | firmware LED animation | empty stubs in this DSDT; software effects are right |
| BIOS R 0x0F | smart adapter status (`GSAS`) | - see gaps |
| BIOS R/W 0x2C | "Clean Creek" (legacy reverse-fan scheduling) | - not on this board |
| BIOS R/W 0x52 | graphics mux | omen-kbd-rgb, and upstream hp-wmi since 2026-07 - **same bytes** |
| 0x2000B 0x01 | USB-C scenario | one desktop SKU only |

## The design data, decoded

The Hub reads GM 0x28 once and caches it. On this machine:

```
E6 00 2D 01 0B 00 01 07 2D 00 00 00 ...
```

| Byte | Value | The Hub reads it as |
|---|---|---|
| 0-1 | `0x00E6` = 230 | shipping adapter, watts (`IsEnableTgpPpab` wants ≥ 280 *or* the platform's `PpabOnInPerformanceMode`, which is true here) |
| 3 | 1 | thermal policy V1: Eco/Balanced → L2 (0x30), Performance → L7 (0x31), Cool → L4 (0x50) |
| 4 | `0x0B` | bit 0 software fan control, bit 1 Extreme mode, bit 2 Extreme *unlocked* (clear), bit 3 "DT BIOS control", bit 4 two-byte PL4 (clear) |
| 5 | 0 | default PL4 (none) |
| 6 | 1 | BIOS-defined OC: performance PL1 bound uses the "WithOC" value - also 60 here |
| 7 | `0x07` | mux: UMA, hybrid, discrete |
| 8 | `0x2D` = 45 | **default concurrent TDP** - the 45 W TPP base |
| 9 | 0 | load line levels / default |
| 10 | 0 | IR sensor is the IR sensor (not the board), no PCH, no VR sensor |
| 11 | 0 | no Fn+P / Fn+F1 hotkeys |

The Hub logged the same bytes, `IsEnableTgpPpab(), power = 230` and
`DefaultConcurrentTdpNoCache = 45`. The TPP base omend uses (`TPP_MIN_W =
45`) is therefore this byte, not a constant; it matches on 8D24, and would
not on a board whose byte 8 differs.

Cool mode (L4, 0x50) is supported by the BIOS (`IsBiosCoolModeSupported =
True` in every log), but the Hub's mode list for a board with software fan
control and Unleashed is Eco, Balanced, Performance, Unleashed - Cool is never
offered or sent here. Low-power staying on HPCM 0x30 is the Hub's behaviour,
not an omission.

## What was the same

Checked byte for byte, and left alone:

* **GM 0x1A**: `{0xFF, HPCM, 0, 0}`; the third byte (`fanControlByBios`) is 0
  in every call the Hub makes on this board.
* **GM 0x29**: `{PL2, PL1, 0xFF, 0xFF}` for PL1, `{0xFF, 0xFF, 0xFF, TPP}` for
  the shared limit. On AMD, when no separate PL2 is given, the Hub copies PL1
  into byte 0; the platform configuration for this board has no PL2 key, so
  that is what it sends. So does omen-kbd-rgb.
* **The fan algorithm** (`SwFanControl`): three tables of nine steps with
  separate up and down edges, the CPU smoothed with the per-mode weights, the
  palm-rest table looked up without hysteresis, one step per five-second
  cycle, the largest of the three. omend's `hubfan.rs` matches it, including
  the placement of the first step and the inclusive edges.
* **Lighting**: colours at offset 25 in the 128-byte block, brightness 228
  for on with the firmware's level, 100 for off.
* **Mux**: mode index in byte 0 of BIOS write 0x52; bit 7 means "takes
  effect without a reboot", which this static mux does not use.
* **Per-mode cTGP and Dynamic Boost**: Performance and Unleashed on, on;
  Balanced off, on; Eco off, off on mains. omen-core's `boost::for_profile`
  is the same.

## What differed, and what was done

### 1. GM 0x22's last two bytes

The Hub sends `{cTGP, PPAB, 1, 87}` every time: D-state 1 (full power) and a
GPU slowdown temperature of 87 °C (`GpsMaxTemperature`). It moves them only
inside its palm-rest loop, between 75 and 87, to throttle the GPU.

omen-kbd-rgb read all four bytes back from GM 0x21 and wrote the last two
unchanged. That does not round-trip: GM 0x21 takes the D-state from EC 0x91
(ECDO), GM 0x22 writes it to EC 0x90 (NVDO), and whatever the low nibble of
0x91 holds is sent as a notify of `0xD0 | nibble` - `0xD0` itself if it is 0,
a value the Hub never sends.

**Fixed** in omen-kbd-rgb 0.4.0: bytes 2 and 3 are now 1 and 87.

### 2. The second fan

The Hub never gives both fans the same setpoint. It sends fan 1's and works
out fan 2's from the firmware's fan table (GM 0x2F): the last row whose fan-1
speed is not above the target, and that row's difference. On 8D24 the table
is

| fan 1 | 18 | 21 | 24 | 26 | 28 | 29 | 33 | 36 | 42 | 45 | 48 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| fan 2 | 16 | 19 | 21 | 24 | 26 | 32 | 35 | 39 | 44 | 47 | 51 |

(hundreds of RPM) so fan 2 runs two or three steps *below* fan 1 at the
bottom and two or three *above* from 2900 RPM up. The Hub's log agrees:
`38,41`, `44,46`, `21,19`, `24,21`.

hp-wmi up to 7.2 applies the first row's difference everywhere: fan 2 is
always 200 RPM under fan 1. Under load that is 400-500 RPM less on the GPU
side than the Hub runs (3800 → 3600 instead of 4100).

From 7.3 (`b461a88f2ee8`, "Add dual-channel PWM fan control") hp-wmi has
`pwm2`, and `pwm1` no longer moves fan 2 at all.

**Done**: omen-kbd-rgb 0.4.0 exposes the table as `fan_table` (read on first
use - the method starts with an SMI). omen-core writes `pwm2` wherever it
exists, with the Hub's lookup (`fan::second_fan_rpm`); `omenctl doctor` says
which. On 7.2 nothing changes - there is no way to set fan 2 separately
there.

### 3. Unleashed's surface limit

Two details of the Hub's loop (`CheckIfHandledByIrSensorV1` and the Unleashed
branch around it) that `SurfaceGuard` had differently:

* **The floor** is the balanced entry of `NbPL1LowerBound` - 30 W on this
  platform - or the configured PL1 if lower, not the slider's 25 W.
* **At the release point** the Hub stops handling the surface, and on its
  next one-second pass the Unleashed branch writes the configured PL1 back,
  all at once. `SurfaceGuard` gave it back 5 W per 30-second cycle.

**Fixed** in omen-core: `SURFACE_PL1_FLOOR_W = 30`, and the configured PL1
comes back at once.

## Gaps left open

In rough order of what they would be worth:

1. **The palm-rest loop outside Unleashed.** The Hub runs it in every mode on
   mains, with per-mode thresholds from the platform configuration
   (`IrOverheatThreshold` / `IrPl1Threshold` / `IrReleaseThreshold`, indexed
   by mode: Balanced 52/49/43 °C, Performance 54/50/44 °C). Between the PL1
   threshold and the overheat one, while the surface is still rising, it
   takes 5 W per degree of rise (at most 15) off PL1. omend runs the loop in
   Unleashed only. Three days of Hub logs never saw the surface above 45 °C,
   so this has not mattered yet.
2. **Fan stop at idle on 7.3.** hp-wmi 7.3 clamps every `pwm1`/`pwm2` write
   to the table's lowest speed. omend's "fans off" (and the Hub's own idle
   state, which sends 0/0) becomes 1800 RPM there. Only a kernel change can
   restore it - an upstream question for after the 8D24 series.
3. **Adapter status** (BIOS read 0x0F, `GSAS`): byte 0 is 1 meets the
   requirement / 2 below it / 4 on battery / 5 USB-C, byte 3 the rating in
   5 W steps. The Hub uses it to switch to Eco on a weak USB-C charger. A
   read-only attribute would be cheap; nothing here uses it yet.
4. **GM 0x10's BIOS protection byte** (over-current, over-temperature): a
   diagnostic the Hub logs whenever it changes.
5. **The TPP base from design data byte 8**, for boards other than 8D24
   (TPP is 8D24-only here today).
6. **Two mux interfaces.** Upstream hp-wmi gained `gpu_mux_mode` on its
   platform device in 2026-07; omen-kbd-rgb has its own. Both send the same
   command. Once a kernel with it is common, omen-core should prefer
   hp-wmi's and omen-kbd-rgb could stop offering one.

## Not on this machine

* **Reverse fans ("Clean Creek")**: GM 0x2C byte 8 is 0, and the platform
  configuration has no clean-creek temperatures. `IsCleanCreekSupport` was
  logged false.
* **Firmware lighting animation**: LM 0x06/0x07 are stubs.
* **Extreme mode**: supported but locked (design data byte 4 bit 2 clear);
  how it unlocks is still not known.
* **PBO / Curve Optimizer / memory OC / load line**: the Hub does not offer
  them here.
* **Desktop-only paths** (`DtSetFanLevel`, `IsDTBiosControl` handling,
  USB-C scenario): the code is there, gated on desktop SKUs.
