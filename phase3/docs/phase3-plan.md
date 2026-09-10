# Phase 3 — Fan Curve, RGB and UI

Phase 1: [protocol extraction](../../phase1/docs/phase1-findings.md) ·
Phase 2: [`hp-wmi` 8D24 support](../../phase2/docs/phase2-plan.md) — both done.

## 0. Scope

Enough function to replace what OMEN Gaming Hub does on Windows, on this
machine (OMEN 16-ap0xxx / 8D24):

- **Fan curve** — automatic setpoints driven by temperature. Phase 1 §6.4
  showed HP's own "Auto" curve runs in the application, not the EC, so the
  driver alone does not provide it.
- **Thermal profiles** — Balanced / Performance / Unleashed
- **4-zone RGB keyboard** — completely dead on Linux today on this machine
  (nothing under `/sys/class/leds/` for the keyboard)
- **CLI, daemon and UI**

## 1. Architecture

Three layers, each usable on its own and each upstreamable on its own:

```
  +- userspace -------------------------------------------+
  |  Tauri UI  --+                                         |
  |  omenctl   --+--> omend (daemon, root)                 |
  +--------------|-----------------------------------------+
                 |  standard sysfs
  +- kernel -----|-----------------------------------------+
  |  hp-wmi (in-tree + 8D24)   omen-kbd-rgb (new module)   |
  |   hwmon pwm1/fan*_input     leds-multicolor x 4 zones  |
  |   platform_profile                                     |
  |   WMI group 0x020008        WMI group 0x020009         |
  +--------------------------------------------------------+
```

### Why not one monolithic out-of-tree driver

`OmenLinux/omen-rgb-keyboard` puts fan and RGB in a single module, and
therefore has to ship `blacklist hp_wmi` — its own fan control writes the same
EC registers (`0x34`/`0x35`) that `hp-wmi` uses.

We are not forced into that. Phase 2 established that `hp-wmi` does **not own**
the GUID: it calls `wmi_evaluate_method(HPWMI_BIOS_GUID, ...)` and registers
itself as a `platform_driver`. Another module may use the same GUID. Since the
fan group (`0x020008`) and the lighting group (`0x020009`) are disjoint, **a
module that only does RGB coexists with `hp-wmi`.**

What that buys: the fan side stays in-tree (zero maintenance, standard
`hwmon`), the RGB side is a small single-purpose module, and userspace talks to
both through standard sysfs. Kernel upgrades only concern the RGB module.

### Binding to standard interfaces

We do not invent our own sysfs tree. Fans go through `hwmon`, profiles through
`platform_profile`, RGB through `leds-multicolor` — all existing kernel
classes. That way `sensors`, `fancontrol`, KDE/GNOME power settings and
`upower` keep working without knowing this project exists. Our UI becomes the
best option rather than the only one.

## 2. Components

### 2.1 `omen-kbd-rgb` — kernel module

The map from Phase 1 §4.1:

| Field | Width | Meaning |
|---|---|---|
| `LRGB` | 96 bits | **12 bytes = 4 zones × RGB** |
| `BRGB` | 96 bits | second 12-byte copy |
| `LBRT` | 8 bits | brightness |
| `LCMC` | 1 bit | commit flag |

WMI path (Phase 1 §3, `GM-LM-methods.asl`): command group `0x020009`,
`LM02` read / `LM03` write (12 bytes at data offset `0x19`), `LM04`/`LM05`
brightness.

sysfs (standard `leds-multicolor`):

```
/sys/class/leds/omen:rgb:kbd_backlight_zone{0..3}/multi_intensity
/sys/class/leds/omen::kbd_backlight/brightness
```

**No DMI matching.** It binds if the WMI GUID and the `_WDG` entry are present,
and probes by capability instead. Keeping a board list means a patch for every
new model — which is exactly the work Phase 2 landed us with.

Full protocol, including what had to be measured rather than read out of the
DSDT: [`rgb-protocol.md`](rgb-protocol.md)

### 2.2 `omend` — daemon

The service that runs the fan curve. Phase 1 §6.4 makes this mandatory: even
HP's own "Auto" mode runs in software.

- **Input:** `k10temp` Tctl, `amdgpu` edge (EC `0xAF`/`0xB7` for dGPU
  temperature is possible later)
- **Output:** `hwmon/pwm1` in manual mode, `platform_profile`
- **Curve:** user-defined point list; the default is OGH's own table
  (Phase 1 §6.3)
- **Hysteresis and minimum dwell:** raising the setpoint is immediate,
  lowering requires both a temperature drop and a minimum elapsed time, so the
  fan does not hunt around a threshold
- **Quantisation:** setpoints are rounded up to 100 RPM, the EC's real
  resolution (Phase 1 §3.2). Writing finer produces WMI calls that change
  nothing.
- **Limits:** 18–48 (1800–4800 RPM), from the `profiles.json` bounds in
  Phase 1 §6.3

### 2.3 `omenctl` and the Tauri UI

`omenctl` began as a read-only status tool; control commands now go to the
daemon over a unix socket. The CLI does not write to sysfs, so write authority
stays in one place.

The desktop UI will be built with **Tauri**. Chosen over Electron because it is
already Rust — the same language as the daemon, and `omen-core` can be used
directly; the resulting binary is a few MB rather than ~150 MB; and it uses the
system WebView instead of shipping a Chromium. The UI connects to the daemon's
socket.

## 3. Language choice

- **Kernel module: C.** No choice.
- **Daemon and CLI: Rust.** One static binary, no runtime dependencies, memory
  safety matters for a service running as root, and Tauri shares the language.
- **UI: Tauri** with a plain HTML/JS front end, no build step.

## 4. Safety — non-negotiable

The warning repeated throughout Phases 1 and 2: **a wrong EC write can stop the
fans entirely, and thermal protection does not always step in.**

Rules the daemon follows:

1. **Always return to automatic on exit.** `pwm1_enable = 2`, via all three
   paths: normal shutdown, panic, and systemd `ExecStopPost` after SIGKILL.
2. **Critical cutout.** Above a configurable threshold (97 °C by default),
   abandon the curve, fall back to automatic and log it. If a software bug is
   holding the fans low, let the hardware take its own curve back. The cutout
   must sit above the top of the curve, or the curve's most aggressive region
   is unreachable — the config check enforces this.
3. **Watchdog.** If a temperature read fails, do not run the curve; fall back.
   Silently staying at the last setpoint in an unknown state is the most
   dangerous option.
4. **Bounds checking.** Setpoints are clamped to 18–48 whatever the config
   says — and again by the kernel.
5. **Only the daemon writes.** The CLI and the UI never touch the EC or sysfs
   directly; they send a request over the unix socket. The critical cutout
   overrides user requests too.

## 5. Order

| # | Work | Why here | State |
|---|---|---|---|
| M1 | `omend` fan curve + `omenctl` | Phase 2 already exposed `pwm1`; this is the most useful missing piece | done |
| M1b | control socket, `omenctl` commands | control has to go through the daemon | done |
| M2 | `omen-kbd-rgb` module | map was ready, kernel code takes longer | done |
| M3 | Tauri UI | after the two layers underneath are solid | next |
| M4 | Packaging (systemd, udev, DKMS, PKGBUILD) | — | partial |
| M5 | Upstream `8D24` patch | Phase 2's remaining work, independent of the rest | pending |

## 6. What we took from the `OmenLinux` repositories

Knowledge, not code:

- **`0x2F` = `VICTUS_FAN_TABLE_GET`** — Phase 1 had written GM2F off as an
  empty stub; they use it for the manual curve. Worth revisiting.
- The constants in their `omen_wmi.h` (`0x020008`, `0x020009`, `0x1A`, `0x26`,
  `0x27`, `0x2D`, `0x2E`) match what we extracted from the DSDT exactly — an
  independent confirmation of Phase 1.
- The RGB byte order and the read-modify-write requirement (see
  [`rgb-protocol.md`](rgb-protocol.md) §4).
- What **not** to do: `blacklist hp_wmi`. Their architecture requires it; ours
  does not (§1).

No code was copied. If any is, GPL-2.0 requires naming the source and author;
this project is GPL-2.0-only too, so the licences are compatible, but
attribution is still mandatory.

What could go back to them: the `16-ap0xxx` RGB map from Phase 1 — that family
is not in their supported list.
