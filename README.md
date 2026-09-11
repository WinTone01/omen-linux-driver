<div align="center">

# OMEN Control

**Fans, thermals, RGB and graphics switching for the HP OMEN 16-ap0xxx on Linux —
built by reading the firmware, not by guessing.**

[![Board](https://img.shields.io/badge/board-8D24-e81123)](#target-hardware)
[![Interfaces](https://img.shields.io/badge/interfaces-hwmon%20%C2%B7%20platform__profile%20%C2%B7%20leds--multicolor-2dd4bf)](#how-it-fits-together)
[![Built with](https://img.shields.io/badge/rust%20%2B%20C-daemon%20%C2%B7%20CLI%20%C2%B7%20GUI%20%C2%B7%20kernel%20module-a855f7)](#layout)
[![License](https://img.shields.io/badge/license-GPL--2.0--only-lightgrey)](LICENSE)

<img src="phase3/docs/screenshots/vitals.png" width="900" alt="System Vitals: GPU, CPU, RAM and fan gauges above storage and process lists">

</div>

---

Everything here was measured on one machine and is written down with its
evidence. Where the hardware refused to do something, that is recorded too —
this project has been wrong in public twice, and both corrections are in the
git history.

<table>
<tr>
<td width="33%" valign="top">

### 🌀 Fans

A curve service that reproduces OMEN Gaming Hub's own table, taken from the
`profiles.json` it ships. HP runs its curve in software; so do we.

The bottom of the curve stops the fans **while keeping the setpoint** —
handing them back to the EC on this board means they stay stopped while the
machine heats up. Measured: 78 → 85 °C in twelve seconds.

</td>
<td width="33%" valign="top">

### 🛡️ Safety, tested by failing

A critical cutout. A stall detector for fans reading 0 RPM while hot. The
setpoint re-asserted every ten seconds, and read back to catch the times the
hardware did not take it.

Every override forces **full power**, because the alternative was tried and it
did nothing.

</td>
<td width="33%" valign="top">

### ⌨️ RGB

Four zones through `leds-multicolor`, so `brightnessctl` and the desktop's own
keys keep working.

Breathing, wave and spectrum are drawn by the daemon, so they keep running
when the window is closed — and the colours come back after a reboot.

</td>
</tr>
<tr>
<td valign="top">

### 🖥️ Graphics

This board **has a mux** — the firmware's own design data declares UMA, hybrid
and discrete — so the panel can be switched between the integrated and the
discrete GPU.

And the part that actually saves battery: naming the programs keeping the
discrete GPU awake, and the command that keeps one off it.

</td>
<td valign="top">

### 🎮 Automation

Per-application profiles and mains/battery rules, each able to name its own
fan curve. A game gets performance; unplugging gets quiet.

What was there before is restored on exit — and left alone if you changed it
meanwhile.

</td>
<td valign="top">

### 🩺 Diagnosis

Twenty-three checks, each with what to do about it. A diagnostic that reports
`pwm1: missing` and stops has done the easy half.

A check that *could not run* says so instead of reporting a fault — in the
window and in `omenctl doctor`.

</td>
</tr>
</table>

## The window

<table>
<tr>
<td width="50%"><img src="phase3/docs/screenshots/fan.png" alt="Fan Control"><br><b>Fan Control</b><br><sub>The curve, draggable, with presets and a log of every setpoint change.</sub></td>
<td width="50%"><img src="phase3/docs/screenshots/performance.png" alt="Performance Control"><br><b>Performance Control</b><br><sub>The firmware's thermal profile, and what each mode actually does.</sub></td>
</tr>
<tr>
<td><img src="phase3/docs/screenshots/graphics.png" alt="Graphics"><br><b>Graphics</b><br><sub>The mux, the discrete GPU's power state, and what is holding it awake.</sub></td>
<td><img src="phase3/docs/screenshots/automation.png" alt="Game Profiles"><br><b>Game Profiles</b><br><sub>Per-application and per-power-source rules, restored on exit.</sub></td>
</tr>
<tr>
<td><img src="phase3/docs/screenshots/lighting.png" alt="Lighting"><br><b>Lighting</b><br><sub>Four zones, a hue strip, effects, and colours that survive a reboot.</sub></td>
<td><img src="phase3/docs/screenshots/diagnosis.png" alt="Diagnosis"><br><b>Diagnosis</b><br><sub>Named checks with remedies. Also <code>omenctl doctor</code>.</sub></td>
</tr>
<tr>
<td><img src="phase3/docs/screenshots/settings.png" alt="Settings"><br><b>Settings</b><br><sub>Window settings, machine defaults, version skew, firmware through fwupd.</sub></td>
<td valign="top"><br><b>And</b><br><sub>English and Turkish · a tray icon with profile and fan actions ·
one window however many times you click the icon · it reopens on the page you
left it on.</sub></td>
</tr>
</table>

## How it fits together

Three layers, each usable and upstreamable on its own. Nothing here invents a
sysfs tree of its own.

```mermaid
flowchart TD
    subgraph user["Userspace"]
        ui["OMEN Control<br/><sub>window</sub>"]
        ctl["omenctl<br/><sub>CLI</sub>"]
        daemon["omend<br/><sub>curve · safety · automation</sub>"]
    end

    subgraph iface["Kernel class interfaces"]
        hwmon["hwmon<br/><sub>pwm1, fan1_input</sub>"]
        prof["platform_profile"]
        leds["leds-multicolor"]
    end

    subgraph drivers["Kernel modules"]
        hpwmi["hp-wmi<br/><sub>+ the 8D24 entry</sub>"]
        rgb["omen-kbd-rgb<br/><sub>lighting group · graphics mux</sub>"]
    end

    fw["HP WMI 5FB7F034…<br/><sub>SECU · EC 0x34/0x35/0x95</sub>"]

    ui -->|"unix socket"| daemon
    ctl -->|"unix socket"| daemon
    ui -->|"colours"| leds
    daemon --> hwmon
    daemon --> prof
    daemon -->|"effects"| leds
    hwmon --> hpwmi
    prof --> hpwmi
    leds --> rgb
    hpwmi --> fw
    rgb --> fw
```

| Layer | Where | Why there |
|---|---|---|
| Fan + thermal profiles | upstream `hp-wmi` (8D24 patch) | in-tree, zero maintenance, standard `hwmon` |
| RGB keyboard + graphics mux | `omen-kbd-rgb` | coexists with `hp-wmi`, no blacklist needed |
| Curve, automation, CLI, window | userspace | standard sysfs, survives kernel upgrades |

Fans go through `hwmon`, profiles through `platform_profile`, RGB through
`leds-multicolor`. That way `sensors`, the desktop's power settings and
`upower` keep working without knowing this project exists — and our own tools
become the best option rather than the only one.

<details>
<summary><b>Why the fan is arbitrated in one place</b></summary>

<br>

A wrong colour is a wrong colour. A wrong fan setpoint can stop the fans while
thermal protection fails to step in — this board did exactly that — so every
write goes through `omend`, and clamping, the critical cutout and
restore-on-exit are guaranteed there and nowhere else.

```mermaid
flowchart LR
    t["temperature"] --> g{"guard"}
    g -->|"emergency"| max["full power"]
    g -->|"0 RPM while hot"| max
    g -->|"cutout 97 °C"| max
    g -->|"normal"| curve["curve → setpoint"]
    curve --> w["write pwm1"]
    w --> rb{"read back"}
    rb -->|"agrees"| ok["held, re-asserted every 10 s"]
    rb -->|"disagrees"| w
```

</details>

## Install

Three pieces: the kernel patch that makes fan control exist at all, the module
that owns the keyboard and the mux, and the userspace on top.

```bash
# 1. The 8D24 entry for hp-wmi — without it there is no pwm1 and nothing works
bash phase2/scripts/build-module.sh --install

# 2. The RGB + graphics-mux kernel module
cd phase3/kernel/omen-kbd-rgb && makepkg -sfi

# 3. The daemon, the CLI and the window
cd phase3/packaging && makepkg -sfi

sudo systemctl enable --now omend
sudo usermod -aG omen $USER      # then log out and back in
```

| Installs | Gives you |
|---|---|
| `hp-wmi-8d24` (DKMS) | `pwm1`, fan tachometers, `platform_profile` |
| `omen-kbd-rgb-dkms` | four RGB zones, `gpu_mux_mode` |
| `omen-control` | `omend`, `omenctl`, `omen-ui`, the systemd unit and udev rules |

Not on Arch? [`phase3/packaging/install.sh`](phase3/packaging/install.sh)
installs the same files by hand.

## From the terminal

The window is optional. Everything it does has a command behind it.

```console
$ omenctl status
omend
  mode             curve
  driving sensor   cpu/Tctl 52.8 C
  target           1800 RPM
  uptime           788 s

$ omenctl doctor
HARDWARE
  OK   Board                      8D24, the one this is built for
FAN
  OK   Firmware thermal profile   hp-wmi is a platform_profile handler (amd-pmf, hp-wmi)
  OK   Fan tachometers            fan1 1700 RPM, fan2 1500 RPM
THERMAL
  OK   EC write access            ec_sys is loaded read-only, which is what this project expects
```

<details>
<summary><b>The rest of the commands</b></summary>

<br>

```bash
omenctl curve preset quiet     # quiet / default / performance
omenctl curve set 45:0,55:1800,75:2400,92:3600
omenctl set max                # or: curve / manual <RPM> / auto
omenctl clean 20               # fans at full power, to clear dust
omenctl app add cs2 performance curve:performance
omenctl power battery low-power curve:quiet
omenctl effect wave 7          # none / breathing / wave / spectrum
omenctl gpu                    # what is holding the discrete GPU awake
omenctl gpu mux discrete       # which GPU drives the screen, from the next boot
omenctl version                # what is running vs what is installed
omen-ui --tab graphics         # open the window on one page
```

</details>

## What was found

| Phase | Scope | State |
|:--|:--|:--|
| **1** | Protocol extraction from the firmware | ✅ Done |
| **2** | `hp-wmi` 8D24 support | ✅ Verified on the machine |
| **3** | Daemon, RGB driver, GUI, automation | ✅ Working |

<details>
<summary><b>Phase 1 — the protocol was already supported</b></summary>

<br>

The fan and thermal protocol is *identical* to what upstream `hp-wmi` already
speaks. The only thing missing was this board's DMI entry.

| | |
|---|---|
| WMI group | `0x20008`, signature `"SECU"` |
| Fan | `0x2D` read · `0x2E` write (EC `0x34`/`0x35`) · `0x26`/`0x27` max |
| Profile | `0x1A` (EC `0x95`) — `0x30` balanced · `0x31` performance · `0x04` unleashed |
| Fan unit | hundreds of RPM, 18–48 → 1800–4800 RPM |

→ [`phase1/docs/phase1-findings.md`](phase1/docs/phase1-findings.md), with a
source for every claim.

</details>

<details>
<summary><b>Phase 2 — one line, and it worked</b></summary>

<br>

The prediction held: a one-line addition to the DMI table (`8D24` →
`omen_v1_legacy`) made `pwm1` appear, and EC `0x95` read back as **48** —
confirming the Windows measurement through a completely different path.

→ [`phase2/docs/phase2-plan.md`](phase2/docs/phase2-plan.md) ·
the patch is [checkpatch-clean](phase2/patches/) and ready to send upstream.

</details>

<details>
<summary><b>Phase 3 — everything above the driver</b></summary>

<br>

The curve service, the RGB module, the window, the automation and the
diagnosis. → [`phase3/README.md`](phase3/README.md)

</details>

### Two corrections

They are the interesting part, so they are not buried.

> **“Hand the fans to the EC” is not a safe resting state on this board.**
> The critical cutout's only action used to be exactly that, and it did
> nothing while the CPU climbed to 98 °C. Every override forces full power
> now, and the bottom of the curve holds a setpoint of zero rather than
> letting go.

> **“This board has no mux.” It does.**
> The interface is numeric, so grepping the DSDT for `mux` found nothing, and
> in hybrid mode the runtime view is indistinguishable from a machine without
> one. The firmware declares it in its system design data: `GM28` computes
> byte 7 as `BIT(0)|BIT(1)|BIT(2)` — UMA, hybrid, discrete.

## Target hardware

| | |
|---|---|
| Model | HP OMEN Gaming Laptop 16-ap0xxx |
| Board | HP **8D24** rev 43.40 |
| BIOS | AMI F.11 (HPQOEM-1072009) |
| CPU | AMD Ryzen AI 9 365 (Strix Point) |
| dGPU | NVIDIA RTX 5060 Laptop |

> [!WARNING]
> The EC register map and command values here are **specific to this board.**
> Do not use them blindly on another OMEN — a wrong EC write can stop the fans
> entirely, and thermal protection does not always step in. Nothing in this
> project writes to the EC, for exactly that reason.

## Layout

```
phase1/   acpi/      17 ACPI tables from the live system + the decompiled DSDT
          extract/   EC field maps, the WMI dispatcher, GM/LM methods
          docs/      findings, with a source for every claim
phase2/   scripts/   verify.sh, add-8d24.sh, build-module.sh
          patches/   the 8D24 patch, checkpatch-clean
phase3/   crates/    omen-core, omend (daemon), omenctl (CLI)
          kernel/    omen-kbd-rgb — 4 RGB zones and the graphics mux
          ui/        omen-ui, the window
          packaging/ systemd unit, udev rules, PKGBUILD
```

<details>
<summary><b>Reproducing the analysis</b></summary>

<br>

The ACPI tables were pulled from Windows with `GetSystemFirmwareTable` and
decompiled with `iasl` (not included; take it from an ACPICA release). The
profile byte values were captured from OMEN Gaming Hub's own log under
`%LOCALAPPDATA%\Packages\AD2F1837.OMENCommandCenter_*\`, whose lines print the
outgoing WMI input bytes directly.

</details>

<div align="center">
<br>
<sub>GPL-2.0-only — the same license as the kernel code this extends, because
the findings were produced to be submitted upstream.</sub>
</div>
