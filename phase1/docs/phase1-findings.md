# Phase 1 — Protocol Extraction (HP OMEN 16-ap0xxx)

Every finding here comes from decompiling ACPI tables taken from the live
system with `iasl`. Source: `phase1/acpi/DSDT.aml` → `DSDT.dsl` (118,949 bytes
of AML / 829,887 bytes of ASL). Each line cites a `DSDT.dsl` line number, so
all of it is verifiable.

## 0. Hardware identity

| Field | Value |
|---|---|
| Model | HP OMEN Gaming Laptop 16-ap0xxx |
| SKU | C12CPEA#AB8 |
| Board | HP 8D24, rev 43.40 |
| BIOS | AMI F.11 (HPQOEM-1072009), 2025-12-16 |
| CPU | AMD Ryzen AI 9 365 (Strix Point, Radeon 880M) |
| DSDT OEM ID | HPQOEM / 8D24 |

AMD CPU → `amd_pstate` is available in Phase 2.

## 1. WMI interface (`_WDG`)

The DSDT contains three separate `_WDG` blocks. The one that matters for
fan/thermal is the middle block (AML offset 0xA9C8, 14 entries):

| GUID | Object | Type | Note |
|---|---|---|---|
| `5FB7F034-2C63-45E9-BE91-3D44E2C707E4` | **WMAA** | Method | **The main HP BIOS command interface.** Linux `hp-wmi` uses it as `HPWMI_BIOS_GUID` |
| `95F24279-4D7B-4334-9387-ACCDC67EF61C` | `_WED` (0x80) | Event | Hotkey events; `HPWMI_EVENT_GUID` in `hp-wmi` |
| `2B814318-4BE8-4707-9D84-A190A859B5D0` | `_WED` (0xA0) | Event | Second event channel |
| `1F4C91EB-DC5C-460B-951D-C7CB9B4B8D5E` | WMBA | Method | HP BIOS configuration (BCU) |
| `7391A661-223A-47DB-A77A-7BE84C60822D` | WMAC | Method | Belongs to the `_HID = "HPIC0004"` device |
| `2D114B49-…` / `988D08E3-…` / `14EA9746-…` | WQBC/BD/BE | Data | BIOS setting enumeration (93/30/2 instances) |

The other two blocks: `B2526ED4-CB45-49FA-9230-8D2FE8AFB8EC` (WMMK) and
`928B5A30-AD7C-4C36-946A-1300A80CE7E1` (WMCA).

**`HPIC0004` is already defined in the DSDT** (line 19610) — so a DSDT patch is
probably unnecessary in Phase 2.

## 2. The WMAA calling protocol

`WMAA` (line 10202) merely takes a lock and calls `HWMC(Arg1, Arg2)`. The real
dispatcher is `HWMC` (lines 8645–9733).

Input buffer layout (top of `HWMC`, lines 8647–8650):

| Offset | Field | Meaning |
|---|---|---|
| 0x00 | `SGIN` | Signature, must be **`0x55434553`** (`"SECU"`) |
| 0x04 | `COMD` | Command group |
| 0x08 | `CMDT` | Command type (sub-command) |
| 0x0C | `DSZI` | Input data size in bytes |
| 0x10 | data | `DSZI` bytes |

`Arg0` selects the output buffer size: 1→0, 2→4, 3→128, 4→1024, 5→4096 bytes.
Return: `SIOU` (initialised to 0x4C494146 = `"FAIL"`) plus a `RETC` status
code. `RETC = 0` is success; 2/3/4/5 are various errors.

### Command groups (`COMD`)

| COMD | Scope | Sub-commands |
|---|---|---|
| `0x01` | BIOS read (generic HP) | 36 |
| `0x02` | BIOS write (generic HP) | 26 |
| `0x00020002` | CSTA/CACT/CDAC/CAIP | 4 |
| **`0x00020008`** | **Gaming / OMEN — fan, thermal, power profile** | **55 (GM01–GM37)** |
| `0x00020009` | Lighting / RGB (LM01–LM0B) | 11 |
| `0x0002000B` | ACPD | 1 |
| `0x00020000` | GASC | 2 |

Group `0x00020008` is the same as `HPWMI_GM_COMMAND` in the Linux `hp-wmi`
driver.

## 3. Fan and thermal commands (COMD `0x00020008`)

Of the 55 GM methods, 19 actually touch the EC; the rest are empty stubs. The
fan/thermal ones:

| CMDT | Method | EC registers touched | Function |
|---|---|---|---|
| **0x2D** | GM2D | `RB00`–`RB30` (EC 0xB0–0xB3) | **Read fan speed (tachometer)** |
| **0x2E** | GM2E | `SRP1`, `SRP2` (EC 0x34, 0x35) | **Write fan speed (manual control)** |
| **0x26** | GM26 | `REC2` (EC 0xEC bit 2) | **Read max-fan state** |
| **0x27** | GM27 | `FFFS` (EC 0xEC bit 2) | **Toggle max fan** |
| **0x1A** | GM1A | `HPCM` (EC 0x95), `FAMC` (EC 0x51 bit 0) | **Power profile + enable manual fan mode** |
| 0x11 | GM11 | `FMR1/2`, `FSUS`, `FS1H/L`, `FS2H/L` | Read fan info (fan select: input byte 0/1) |
| 0x10 | GM10 | `OMCC` (EC 0x62 bit 0) | Enable OMEN mode (returns a constant 0x02) |
| 0x2A | GM2A | EC 0x37, 0x38, 0x39, 0x58 | Thermal thresholds / policy |
| 0x29 | GM29 | `OSPT`, `OSPL` (EC 0x38, 0x37) | Thermal policy |
| 0x2B | GM2B | EC 0xE2 | — |
| 0x22 | GM22 | `NVDO` (EC 0x90) | dGPU related |
| 0x23 | GM23 | EC 0x48 | — |
| 0x28 | GM28 | EC 0xEA, 0x53 bit 1 | — |
| 0x33 | GM33 | `R455` (EC 0x45 bit 5) | — |
| 0x34 | GM34 | `ETEG` (EC 0x45 bit 6) | — |

Lighting (COMD `0x00020009`): LM02/LM03 → `LRGB`/`BRGB` (keyboard RGB zones),
LM04/LM05 → `LBRT` (brightness), LM03/LM05 → `LCMC`.

### 3.1 Reading fan speed — GM2D (line ~13760, `extract/GM-LM-methods.asl`)

```
fan1_raw = (EC[0xB1] << 8) | EC[0xB0]
fan2_raw = (EC[0xB3] << 8) | EC[0xB2]
out[0] = round(fan1_raw / 100)     // divide by 100, round up when remainder >= 50
out[1] = round(fan2_raw / 100)
```

The output buffer is 128 bytes; only the first two are meaningful.
**Unit: hundreds of RPM.** So `out[0] = 42` → ~4200 RPM.

### 3.2 Writing fan speed — GM2E

```
EC[0x34] (SRP1) = in[0]     // fan 1 target
EC[0x35] (SRP2) = in[1]     // fan 2 target
```

The input buffer is 128 bytes (`DSZI = 0x80`). Being symmetric with GM2D, the
**unit is again hundreds of RPM.** The method first raises an SMI to the BIOS
with `WSMI(0x00020008, 0x2E, 0x80, 0, 0)`, then writes the EC directly.

If `ECON != 1` (EC not ready) the write is silently skipped.

### 3.3 Power profile and manual mode — GM1A

```
EC[0x95] (HPCM) = in[1]        // performance/thermal profile
CMSW(0xE6, in[1])              // SMI to the BIOS
EC[0x51] bit0 (FAMC) = in[2]   // fan manual control
```

`FAMC` = **Fan Manual Control**.

`HPCM`'s valid values do not appear as constants in the DSDT — they were found
by live capture: **48 / 49 / 4**, see §6.1.

The capture also **disproved** an expected assumption: OGH never sets `FAMC` to
1, not even in manual fan mode (`in[2]` is always 0). Manual control is achieved
purely by writing the `0x2E` setpoint repeatedly. See §6.1 and §6.4.

## 4. EC register map

The DSDT has a single `EmbeddedControl` region (line 21578):

```
OperationRegion (ERAM, EmbeddedControl, Zero, 0xFF)
```

So the standard ACPI EC window is **0x00–0xFE**. Full field list:
`phase1/extract/ec-eram-field.asl`

The ones that matter for fan/thermal:

| Address | Name | Width | Meaning |
|---|---|---|---|
| 0x34 | `SRP1` | 8 | **Fan 1 target speed (hundreds of RPM)** |
| 0x35 | `SRP2` | 8 | **Fan 2 target speed (hundreds of RPM)** |
| 0x37 | `OSPL` | 8 | Thermal policy |
| 0x38 | `OSPT` | 8 | Thermal policy |
| 0x39 | `OFPT` | 8 | Thermal policy |
| 0x51 bit 0 | `FAMC` | 1 | **Fan manual control enable** |
| 0x57 | `RTTP` | 8 | Temperature |
| 0x58 | `RTMP` | 8 | Temperature |
| 0x59 | `TRTM` | 8 | Temperature |
| 0x62 bit 0 | `OMCC` | 1 | OMEN mode |
| 0x95 | `HPCM` | 8 | **Power/thermal profile** |
| 0xAF | `GPUT` | 8 | GPU temperature |
| 0xB0–0xB1 | `RPM1`,`RPM2` | 8+8 | **Fan 1 tachometer (LE 16-bit)** |
| 0xB2–0xB3 | `RPM3`,`RPM4` | 8+8 | **Fan 2 tachometer (LE 16-bit)** |
| 0xB7 | `GTMP` | 8 | GPU temperature 2 |
| 0xC9 | `GTM2` | 8 | GPU temperature 3 |
| 0xEC bit 1 | `FFFF` | 1 | Fan full power (flag) |
| 0xEC bit 2 | `FFFS` | 1 | **Max fan toggle** |

### 4.1 Extended EC RAM — the memory-mapped window

On this machine the whole EC RAM is *also* mapped into a 4 KB window at
physical address **`0xFE700000`** (line 21215):

```
OperationRegion (H2RA, SystemMemory, 0xFE700000, 0x1000)
```

The mapping rule, confirmed from the field names (`R290` @0x329, `R400` @0x340,
`RF70` @0x3F7 are all consistent):

```
EC register N  ==  physical 0xFE700000 + 0x300 + N
```

This is the only way to reach registers **beyond** the standard EC window
(0x00–0xFE). The fan curve tables live there:

| H2RA offset | EC address | Name | Meaning |
|---|---|---|---|
| 0x1B7 | — (below 0x300) | `FSUS` | Fan status |
| 0x527 | 0x227 | `FMR1` | Fan 1 max RPM |
| 0x52F | 0x22F | `FMR2` | Fan 2 max RPM |
| 0x530 | 0x230 | `FS1H` | Fan 1 speed, high byte |
| 0x531 | 0x231 | `FS1L` | Fan 1 speed, low byte |
| 0x532 | 0x232 | `FS2H` | Fan 2 speed, high byte |
| 0x533 | 0x233 | `FS2L` | Fan 2 speed, low byte |
| 0x534 | 0x234 | `FAS1` | Fan 1 — |
| 0x535 | 0x235 | `FAS2` | Fan 2 — |

Also `LRGB` (@0xEE3), `BRGB` (@0xEF0) and `LBRT` — keyboard RGB, in the same
window.

Full list: `phase1/extract/ec-h2ra-field.asl`

## 5. The most important conclusion for Phase 2

This machine's fan protocol is **identical to the Victus S manual fan support
already in the upstream Linux `hp-wmi` driver**:

- `hp-wmi`'s `HPWMI_FAN_SPEED_MAX_GET_QUERY = 0x26` / `SET = 0x27` → GM26/GM27 ✓
- Victus S manual fan write query `0x2E` → GM2E ✓ (same `SRP1`/`SRP2` target)
- Fan speed read `0x2D` → GM2D ✓
- Command group `0x20008` ✓, signature `"SECU"` ✓

So Phase 2 most likely needs **no new driver** — it may be enough for `hp-wmi`
to recognise this model (DMI match / board list). Confirming that on Linux is
the first job.

## 6. Live capture — from the OMEN Gaming Hub log

Source: OGH writes the outgoing WMI input bytes into its own log, under
`%LOCALAPPDATA%\Packages\AD2F1837.OMENCommandCenter_v10z8vjag6ke6\LocalCache\Local\HPOMEN\`
as `HPOMEN_*.log` (front end) and `HPOMENBG_*.log` (background service):

```
SetFanModeAsync(), mode = L7
[ExecuteBiosWmiCommandThruDriver] inputData=255,49,0,0,
```

> Note: the `Microsoft-Windows-WMI-Activity/Trace` ETW channel is **not enough**
> for this job — it records which class/method was called but not the argument
> bytes, and it needs administrator rights to enable. The OGH log gives the
> bytes directly, so no ETW trace was needed.

### 6.1 `HPCM` profile values (confirmed)

Each of the four OGH profiles was selected in turn and captured from the log
(2026-09-10 18:48):

| OGH button | Internal name | GM1A payload | **HPCM (EC 0x95)** |
|---|---|---|---|
| ECO | `Eco` | `255,48,0,0` | **48** (0x30) |
| Balanced | `L2` | `255,48,0,0` | **48** (0x30) |
| Performance | `L7` | `255,49,0,0` | **49** (0x31) |
| Unleashed | `L8` | `255,4,0,0` | **4** (0x04) |

The payload layout matches GM1A exactly: `[0]` unused (0xFF), `[1]` → `HPCM`,
`[2]` → `FAMC`.

Three conclusions:

1. **ECO is not a separate firmware profile.** Right after logging
   `RegKeyMode has value=Eco` the log calls `SetFanModeAsync(), mode = L2` and
   sends the same `HPCM = 48`. ECO is implemented at the Windows power plan /
   PL1 level. So the firmware side has **only three thermal profiles: 48, 49,
   4.**
2. **`FAMC` is never set to 1.** Even in manual fan mode `[2] = 0`. OGH does
   manual control by writing the `0x2E` setpoint continuously, not via `FAMC`.
3. The values are not sequential (48/49/4) — this is not a numbered enum.

### 6.2 Max Fan (0x27) — confirmed

The thermal switch in the UI was set to MAX and back to Auto (2026-09-10
18:53–18:54):

```
OnThermalModeClick - mode=Max
  SetFanModeAsync(), mode = L2   -> inputData=255,48,0,0     (HPCM unchanged, resent)
  SetMaxFan(), mode = On         -> inputData=1,             <- GM27
OnThermalModeClick - mode=Auto
  SetFanModeAsync(), mode = L2   -> inputData=255,48,0,0
  SetMaxFan(), mode = Off        -> inputData=0,
```

- `FFFS = in[0]`; **1 = on, 0 = off**.
- The payload is a **single byte** (`DSZI = 1`) — GM27 only reads `WBUF[0]`, so
  this is consistent.
- MAX mode does not touch `FAMC` either.
- **While Max Fan is on, OGH stops the periodic `0x2E` writes entirely.**
  Between 18:53:52 and 18:54:10 there is not a single setpoint write; the first
  one comes at 18:54:11, after returning to Auto. So with `FFFS=1` the EC takes
  over and the software curve is disabled.

### 6.3 Fan unit — experimental confirmation

With the manual slider set to 3800 RPM (the UI showing "System fan (3800 RPM)"),
the `0x2E` payload in the log was:

```
inputData=38,41,0,0,0,0,...   (128 bytes)
```

`38` → 3800 RPM. Raising the slider wrote `44,46` (4400/4600 RPM).
**Unit = hundreds of RPM, definitively.** The second fan is driven a few units
away from the first.

The same conclusion follows from the fan curve table in `profiles.json`: the
speed lists are 18/24/30/33 and the bounds are `Lower=18` / `Upper=48` →
1800–4800 RPM.

### 6.4 The fan curve runs in software

Even in "Auto" thermal mode, the OGH background service writes `0x2E`
periodically (`inputData=21,19,…` / `24,21,…`). So HP's automatic fan curve
runs **entirely in the Windows application, not in the EC**.

→ In Phase 2 the driver alone will not be enough; a userspace daemon that
writes setpoints by temperature is also needed. (`alou-S/omen-fan` and
`arfelious/omen-fan-control` do exactly this.)

### 6.5 Power limit / dGPU (partial)

Profile changes also send these 4-byte payloads:

| Payload | Profile | Interpretation |
|---|---|---|
| `255,255,255,45` | L2 (Balanced) | Consistent with GM29 semantics: `[0..2]=0xFF` → skip, `[3]=45` → `DATP = 45*8` |
| `255,255,255,65` | L8 (Unleashed) | `[3]=65` → `DATP = 65*8` |

GM29 writes that value to `NPCF.DATP`, then does `CMSW(0x2A, …)` and
`Notify(NPCF, 0xC0)` — NPCF being the NVIDIA platform controller, so this is
most likely the **dGPU dynamic boost / TGP limit** (Balanced 45 → Unleashed
65). The exact unit was not confirmed.

Other 4-byte payloads such as `0,1,1,87` and `0,0,1,87` also appear; since
several commands share the 4-byte shape and the log does not print the command
ID, they could not be attributed.

## 7. The graphics mux (added 2026-09-11)

This was missed on the first pass and found later, which is worth recording as
much as the finding itself: **the interface is numeric**, so searching the DSDT
for the word "mux" returns nothing, and the runtime view of a mux machine in
hybrid mode is indistinguishable from a machine that has none — the panel is
wired to the integrated GPU and the NVIDIA card enumerates only HDMI.

The firmware answers the question directly.

### 7.1 System design data — `GM28` (COMD `0x00020008`, CMDT `0x28`)

`GM28` returns a 64-byte buffer, and byte 7 is a bitmask of the mux modes this
machine supports. The DSDT computes it statically, so the answer can be read
without calling anything:

```asl
Local1 = Zero
Local1 |= One        // BIT(0) - UMA
Local1 |= 0x02       // BIT(1) - hybrid
Local1 |= 0x04       // BIT(2) - discrete
DerefOf (Local0 [0x02]) [0x07] = Local1      // = 0x07
```

| Bit | Mode |
|---|---|
| 0 | UMA — integrated only |
| 1 | Hybrid |
| 2 | Discrete |
| 3 | Optimus (advanced, dynamic) — **not set on 8D24** |

Bit 3 being clear is the difference between a *static* mux, which is what this
board has, and Advanced Optimus. The mode is chosen and applied at the next
POST; nothing switches while the machine is running.

Byte 3 of the same buffer is the thermal-profile version, and byte 4 another
capability mask.

### 7.2 Reading and writing the mode — CMDT `0x52`

Unlike the fan commands, this one is not in the gaming group: it is a plain
BIOS read/write, dispatched in `HWMC.asl` as

| COMD | CMDT | Method | Meaning |
|---|---|---|---|
| `0x00000001` | `0x52` | `GDSS` | read the current mode |
| `0x00000002` | `0x52` | `SDSS` | set it |

Both are pass-throughs to the BIOS SMI handler (`WSMI`), which is why the DSDT
alone does not say whether the machine has a mux — every HP command number is
dispatched generically. Byte 0 of the 4-byte payload is the mode, and the top
bit of the value read back is a BIOS status flag rather than part of it.

The mode numbering is the index, not the mask: `0` hybrid, `1` discrete,
`2` optimus, `3` UMA.

> Sending `0x52` to a machine that does not support it has produced ACPI faults
> and kernel panics on other models. `omen-kbd-rgb` reads the design data first
> and does not create the sysfs attributes at all unless a mode is declared.

Implementation: `phase3/kernel/omen-kbd-rgb/omen-kbd-rgb.c`, exposed as
`/sys/devices/platform/omen-kbd-rgb/gpu_mux_{mode,supported}`. Confirmed on the
machine — the firmware answers `uma hybrid discrete`, current `hybrid`.

## 8. Open items

1. **The SSDTs are missing.** Windows' `GetSystemFirmwareTable` API returns
   only the first of 28 SSDTs with the same signature; the other 27 could not be
   retrieved. On Linux `/sys/firmware/acpi/tables/` provides all of them. Not a
   blocker right now, since the fan logic lives in the DSDT.
2. **The units of `FAS1`/`FAS2` and `FMR1`/`FMR2`** were not confirmed (RPM or
   hundreds of RPM).
3. **EC diffing, decompiling OGH and a WMI ETW trace were not done** — the DSDT
   gave the whole fan protocol and the OGH log gave the profile byte values, so
   none of them were needed. Those three steps from the handover note can be
   closed.

## Files

| Path | Contents |
|---|---|
| `phase1/acpi/*.aml` | 17 ACPI tables from the live system |
| `phase1/acpi/DSDT.dsl` | Decompiled DSDT (830 KB) |
| `phase1/extract/ec-eram-field.asl` | EC 0x00–0xFE field map |
| `phase1/extract/ec-h2ra-field.asl` | Memory-mapped extended EC RAM map |
| `phase1/extract/HWMC.asl` | WMI command dispatcher (1089 lines) |
| `phase1/extract/GM-LM-methods.asl` | 55 gaming + 11 lighting methods |
| `tools/iasl.exe` | ACPICA 20260408 |
