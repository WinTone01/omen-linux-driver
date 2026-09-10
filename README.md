# omen-linux-driver

Fan, thermal and RGB keyboard support on Linux for the HP OMEN 16-ap0xxx
(board **8D24**).

The goal is to recover the protocol behind OMEN Gaming Hub's fan, thermal and
lighting features on Windows, and provide the equivalent on Linux — using the
kernel's existing interfaces rather than inventing new ones.

## Status

| Phase | Scope | State |
|---|---|---|
| 1 | Protocol extraction (Windows) | **Done** |
| 2 | `hp-wmi` 8D24 support | **Done, verified on the machine** |
| 3 | Fan curve daemon, RGB driver, UI | In progress |

### Phase 1 result

This machine's fan/thermal protocol is **identical** to what the upstream Linux
`hp-wmi` driver already supports. No new driver is needed; the only thing
missing was the board's entry in the DMI table.

- WMI group `0x20008`, signature `"SECU"`
- `0x2D` read fan · `0x2E` write fan (EC 0x34/0x35) · `0x26`/`0x27` max fan ·
  `0x1A` power profile (EC 0x95)
- Fan unit is **hundreds of RPM**, range 18–48 (1800–4800 RPM)
- Profile values: `0x30` Balanced · `0x31` Performance · `0x04` Unleashed

Details, with a source for every finding:
[`phase1/docs/phase1-findings.md`](phase1/docs/phase1-findings.md)

### Phase 2 result

The prediction held: all that was needed was a **one-line addition** to
`hp-wmi`'s DMI table (`8D24` → `omen_v1_legacy`). The patched module was built
and run on this machine on 2026-09-11:

- `pwm1` appeared → manual fan control is possible (it did not exist unpatched)
- `hp-wmi` registered as a platform profile handler, alongside `amd-pmf`
- EC `0x95` read back as **48** → Phase 1's Windows measurement independently
  confirmed on Linux, through a completely different path
- The automatic fan curve works: fan-stop at 45 °C, 2400/2100 RPM at 58 °C
- Made permanent with DKMS; survived a reboot

Details: [`phase2/docs/phase2-plan.md`](phase2/docs/phase2-plan.md)

### Phase 3

Three layers, each usable and upstreamable on its own:

| Layer | Where | Why there |
|---|---|---|
| Fan + thermal profiles | upstream `hp-wmi` (8D24 patch) | in-tree, zero maintenance, standard `hwmon` |
| RGB keyboard | `omen-kbd-rgb`, lighting group only | coexists with `hp-wmi`, no blacklist needed |
| Fan curve, CLI, UI | userspace (`omend`, `omenctl`) | standard sysfs, survives kernel upgrades |

Working today: the `omend` fan curve service, the `omenctl` control tool, and
the 4-zone RGB kernel module. See [`phase3/README.md`](phase3/README.md) and
[`phase3/docs/phase3-plan.md`](phase3/docs/phase3-plan.md).

## Design principle

We do not invent our own sysfs tree. Fans go through `hwmon`, profiles through
`platform_profile`, RGB through `leds-multicolor` — all existing kernel class
interfaces. That way `sensors`, desktop power settings and `upower` keep
working without knowing this project exists, and our own tools become the best
option rather than the only one.

## Target hardware

| | |
|---|---|
| Model | HP OMEN Gaming Laptop 16-ap0xxx |
| Board | HP **8D24** rev 43.40 |
| BIOS | AMI F.11 (HPQOEM-1072009) |
| CPU | AMD Ryzen AI 9 365 (Strix Point) |
| dGPU | NVIDIA RTX 5060 Laptop |

> The EC register map and command values here are **specific to this board.**
> Do not use them blindly on another OMEN — a wrong EC write can stop the fans
> entirely, and thermal protection does not always step in.

## Getting started

On Linux, in order:

```bash
# 1. Diagnose the unpatched state first (read-only, writes nothing)
sudo bash phase2/scripts/verify.sh 2>&1 | tee verify-before.txt

# 2. Add the 8D24 entry to the kernel source (detects the 7.2 vs 7.3+ form)
bash phase2/scripts/add-8d24.sh /path/to/hp-wmi.c

# 3. Build the module, install it via DKMS, then verify again
bash phase2/scripts/build-module.sh --install
sudo bash phase2/scripts/verify.sh 2>&1 | tee verify-after.txt
```

`verify.sh` only reads. `add-8d24.sh` modifies the file you give it, but takes
a `.orig` backup first.

Once `pwm1` exists, the userspace side is in [`phase3/`](phase3/README.md).

## Layout

```
phase1/
  acpi/      17 ACPI tables from the live system + decompiled DSDT
  extract/   EC field maps, WMI command dispatcher, GM/LM methods
  docs/      Phase 1 findings
phase2/
  docs/      Phase 2 plan and verified results
  scripts/   verify.sh, add-8d24.sh, build-module.sh
phase3/
  crates/    omen-core, omend (daemon), omenctl (CLI)
  kernel/    omen-kbd-rgb, the 4-zone RGB module
  packaging/ systemd unit, example config, sysusers
  docs/      Phase 3 plan, RGB protocol
```

## Reproducing the analysis

The ACPI tables were pulled from Windows with `GetSystemFirmwareTable` and
decompiled with `iasl`. `tools/iasl.exe` is not included in the repository; it
can be downloaded from an ACPICA release.

The profile byte values were captured from OMEN Gaming Hub's own log
(`%LOCALAPPDATA%\Packages\AD2F1837.OMENCommandCenter_*\LocalCache\Local\HPOMEN\`),
whose lines print the outgoing WMI input bytes directly.

## License

GPL-2.0-only. These findings were produced to be submitted to the Linux kernel
(`hp-wmi`), so the same license as the kernel was chosen.
