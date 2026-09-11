# Phase 2 — The Linux Side

Phase 1 output: [`phase1/docs/phase1-findings.md`](../../phase1/docs/phase1-findings.md)

## 0. The decision, in short

**No new driver will be written.** This machine's fan/thermal protocol is
identical to what the upstream `hp-wmi` driver already supports; the only thing
missing is **the board's entry in the DMI table**.

That reduces the work to three pieces:

1. A one-line DMI addition to `hp-wmi` (board `8D24`)
2. A userspace daemon to run the fan curve
3. dGPU runtime PM, handled separately (out of scope here, but it is the real
   reason for the battery life gap)

## 1. Upstream state (as of 2026-09-10, `torvalds/linux` master)

The `hp_wmi_feature_boards[]` table in
`drivers/platform/x86/hp/hp-wmi.c` holds 26 boards: 8902, 8A3D, 8A44, 8A4D,
8BAA, 8BA9, 8BAB, 8B2F, 8BB3, 8BBE, 8BC2, 8BCA, 8BCD, 8BD4, 8BD5, 8C76, 8C77,
8C78, 8C99, 8C9C, 8D26, 8D41, 8D87, 8D88, 8DD6, 8E35.

**`8D24` does not appear anywhere in the file.**

But two commits stand out, both from 2026-06-09:

- *"Add support for Omen 16-ap0xxx (**8D26**)"*
- *"Add support for Omen 16-ap0xxx (**8E35**)"*

So **our model family (16-ap0xxx) is already supported**; HP shipped several
board revisions under it and ours (8D24) has not been submitted yet. That turns
the job from "protocol extraction" into "add one line to a table".

### Which kernel version is enough?

At the time: mainline **7.3-rc2**, stable **7.2.4** (7.2 released 2026-08-16).

The file at tag `v7.2` was checked directly:

| | 7.2 | 7.3 (master) |
|---|---|---|
| `HPWMI_VICTUS_S_FAN_SPEED_SET_QUERY = 0x2E` | present | present |
| hwmon PWM fan control | present | present |
| `8D26` (sibling board) | present | present |
| Name of the DMI array | `victus_s_thermal_profile_boards[]` | `hp_wmi_feature_boards[]` |
| `driver_data` | `&omen_v1_legacy_thermal_params` | `&omen_v1_legacy_board_params` |
| `8D24` | absent | absent |

**So 7.2 is already enough.** The 2026-07-09 change did not *add* fan support;
it moved existing code into a board-parameter structure (the array name and the
`driver_data` type changed). Stable 7.2 works; only the shape of the patch
differs by version.

### Verified against the binary (2026-09-10)

Target distribution: **CachyOS, kernel 7.2.3-1-cachyos**. `verify.sh` extracted
the DMI strings from that kernel's `hp-wmi.ko.zst` — 76 boards:

```
84DA 84DB 84DC 8572 8573 8574 8575 8600..8607 860A 8746..874A 8786..8788
878A..878C 87B5 886B 886C 88C8 88CB 88D1 88D2 88F4..88F8 88FD..88FF
8900 8901 8902 8912 8917 8918 8949 894A 89EB 8A15 8A25 8A42 8A44 8A4D
8B2F 8BAB 8BAD 8BBE 8BC2 8BCA 8BCD 8BD4 8BD5 8C58 8C76 8C77 8C78 8C99
8C9C 8D26 8D41 8D87 8E35 8E41
```

- **`8D24` absent** → the patch is needed (as expected)
- **`8D26` present** → the kernel does know the 16-ap0xxx family (as expected)
- `8BAA`, `8BA9`, `8BB3`, `8DD6`, `8D88` from 7.3 are missing here — they were
  added in 2026-07/08, so their absence in 7.2 is consistent

The analysis therefore rests on **the binary that will actually run**, not just
on upstream source. Patch shape to apply: **the 7.2 form**.

> Caveat: the `strings` method merges every DMI array in the module and cannot
> tell which array a board belongs to. Sufficient for the 8D24/8D26 question;
> the array membership is known from the source.

## 2. Which parameter set, and why

Upstream offers four. Compared against what Phase 1 captured:

| | Phase 1 measurement | `omen_v1_legacy` | `omen_v1` | `omen_v1_no_ec` | `victus_s` |
|---|---|---|---|---|---|
| Balanced | **0x30** (48) | 0x30 ✓ | 0x30 ✓ | 0x30 ✓ | 0x00 ✗ |
| Performance | **0x31** (49) | 0x31 ✓ | 0x31 ✓ | 0x31 ✓ | 0x01 ✗ |
| EC profile register | **0x95** | **0x95 ✓** | 0x59 ✗ | none ✗ | none ✗ |

`omen_v1_legacy_thermal_params.ec_tp_offset = HP_OMEN_EC_THERMAL_PROFILE_OFFSET
= 0x95` — and `HPCM`'s address in the DSDT is exactly 0x95. The other three do
not match: `omen_v1` uses 0x59, which on this board is `TRTM`, a temperature
register, not a profile.

→ **`omen_v1_legacy_board_params`**. The sibling board **8D26 uses the same
one**, which supports the choice independently.

### The patch

Kernel 7.2 — into `victus_s_thermal_profile_boards[]`:

```c
	{
		.matches = { DMI_MATCH(DMI_BOARD_NAME, "8D24") },
		.driver_data = (void *)&omen_v1_legacy_thermal_params,
	},
```

Kernel 7.3+ — into `hp_wmi_feature_boards[]`:

```c
	{
		.matches = { DMI_MATCH(DMI_BOARD_NAME, "8D24") },
		.driver_data = (void *)&omen_v1_legacy_board_params,
	},
```

A script that detects and applies either form:
[`phase2/scripts/add-8d24.sh`](../scripts/add-8d24.sh)

The fan hwmon interface hangs off this match. In 7.2 the gate is:

```c
if (attr == hwmon_pwm_input && !is_victus_s_thermal_profile())
	return 0;
```

Without the match the `pwm*` files never appear, so fan control silently does
not work. The one-line addition opens both the platform profile and the PWM.

## 3. A known gap: "Unleashed"

OGH offers four profiles but the firmware side has three values: 48 / 49 / 4.
Upstream `platform_profile` only maps performance / balanced / low-power — so
**Unleashed (HPCM = 4) is not represented in the upstream model.**

There is also an inconsistency: upstream's `HP_OMEN_EC_FLAGS_TURBO = 0x04` is
associated with the *flags* register at **0x62**, whereas OGH writes the value
`4` to **0x95** (HPCM). They may not be the same thing.

This is not a blocker (fans plus three profiles work without Unleashed), but it
should be settled by writing `4` on the machine and observing. Scope: optional
improvement.

## 4. Verification order (on Linux, before patching)

Order matters — measure the unpatched state first so the patch's effect is
visible.

```bash
# 1. Is the board what we think it is
sudo dmidecode -s baseboard-product-name        # expect 8D24
uname -r

# 2. Is hp-wmi loaded, what does it offer
lsmod | grep hp_wmi
ls /sys/devices/platform/hp-wmi/
dmesg | grep -i 'hp-wmi\|hp_wmi'

# 3. Platform profile support
cat /sys/firmware/acpi/platform_profile_choices 2>/dev/null
cat /sys/firmware/acpi/platform_profile 2>/dev/null

# 4. Did a fan hwmon appear
for d in /sys/class/hwmon/hwmon*; do echo "$d -> $(cat $d/name)"; done
sensors

# 5. Does the kernel source have 8D24 and the refactor
grep -c '8D24' /usr/src/linux*/drivers/platform/x86/hp/hp-wmi.c 2>/dev/null
grep -c 'hp_wmi_feature_boards' /usr/src/linux*/drivers/platform/x86/hp/hp-wmi.c 2>/dev/null
```

Expectation: platform_profile probably appears (legacy path), **fan hwmon does
not** (no board match).

### Reading the EC directly (cross-check)

```bash
sudo modprobe ec_sys write_support=0
sudo xxd -s 0x95 -l 1 /sys/kernel/debug/ec/ec0/io     # HPCM
sudo xxd -s 0xB0 -l 4 /sys/kernel/debug/ec/ec0/io     # RPM1..RPM4
```

`0x95` should be 0x30/0x31/0x04 according to the profile set in OGH — an
independent confirmation of the Phase 1 finding from the Linux side.
`0xB0-0xB3` are the two fan tachometers (little-endian 16-bit, raw RPM).

## 5. Distribution choice and applying the patch

### Distribution

Ryzen AI 9 365 (Strix Point) wants a recent kernel anyway, and the `hp-wmi`
side needs at least **7.2**. Both point the same way:

- **Fedora** — ships 7.2, building modules with `kernel-devel` is easy, DKMS
  works properly. Lowest friction for this job.
- **Arch / CachyOS** — newest kernel, moves to 7.3 quickly.
- **Avoid Ubuntu LTS** — its kernel is old; even with HWE it will not see 7.2
  for a while.

Install `linux-headers` / `kernel-devel` as well; it is needed to build the
patched module.

### Applying

1. Run `verify.sh` **before** patching, so the patch's effect is measurable.
2. Add the entry with `add-8d24.sh`, build `hp_wmi` on its own
   (`make -C /lib/modules/$(uname -r)/build M=$PWD modules`), try it with
   `insmod`.
3. If it works, move it into **DKMS** so it survives kernel updates.
4. Run `verify.sh` again and compare.

Once verified it **should be submitted upstream** — the 8D26 and 8E35 entries
went in exactly this way (both on 2026-06-09), so acceptance is likely. The
Phase 1 measurements (EC 0x95, 0x30/0x31) serve as the justification.

## 6. The fan curve daemon

Established in Phase 1: HP's "Auto" fan curve does not live in the EC, it runs
**in the Windows application** (OGH periodically writes the `0x2E` setpoint).
So the driver alone does not give you automatic fan control.

Options:
- **`alou-S/omen-fan`** — a service that writes setpoints by temperature
- **`arfelious/omen-fan-control`** — fan curve, watchdog, CLI/GUI; the most
  mature of the two

Both write to the EC directly and can be configured with our EC map (`SRP1` =
0x34, `SRP2` = 0x35, tach at `0xB0-0xB3`, unit **hundreds of RPM**, range
18–48). OGH's own table can serve as a reference curve (from `profiles.json`,
Phase 1 §6.3):

| CPU °C | 50 | 55 | 60 | 65 | 70 | 75 | 80 | 85 | 90 |
|---|---|---|---|---|---|---|---|---|---|
| Fan (hundreds of RPM) | 18 | 18 | 18 | 18 | 24 | 24 | 24 | 24 | 33 |

Bounds: 18 (1800 RPM) low, 48 (4800 RPM) high.

> In the end we wrote our own daemon instead — see [Phase 3](../../phase3/README.md).

## 7. Safety and recovery

- A wrong EC byte can **stop the fans entirely**; thermal protection does not
  always step in. Watch temperatures in a second terminal while testing:
  `watch -n1 sensors`
- EC state **can survive a soft reboot**. Recovery may need a full power cycle
  (unplug the charger, disable the battery, or hold the power button).
- Only enable `ec_sys` write support when it is actually needed
  (`write_support=1`), and remove it afterwards.
- A DSDT patch is **not required** (Phase 1: `HPIC0004` is already defined in
  the DSDT), so there is no risk of an unbootable machine from a broken DSDT.

## 8. Out of scope, but the real cause of the battery gap

The handover note was right: most of the battery difference comes from the
NVIDIA dGPU never entering runtime power management (5–10 W). This machine has
an RTX 5060. This project solves the fan/thermal side; the dGPU side is
separate work (`nvidia.NVreg_DynamicPowerManagement`, `udev` rules, PCIe
runtime PM). The two should not be conflated.

---

## 9. Result — verified on the machine (2026-09-11)

Environment: CachyOS, kernel **7.2.4-1-cachyos**, board 8D24, BIOS F.11.

The patch was applied (`victus_s_thermal_profile_boards[]` +
`omen_v1_legacy_thermal_params`), the module built out-of-tree and installed
via DKMS. Unpatched vs patched:

| Measurement | Unpatched | Patched |
|---|---|---|
| `hwmon/pwm1` | **absent** | **present** |
| `pwm1_enable` | present (2 = auto) | present (2 = auto) |
| `fan1_input`, `fan2_input` | present | present |
| profile handlers | `amd-pmf` | `amd-pmf` + **`hp-wmi`** |
| EC `0x95` (HPCM) | 0 (never written) | **48** = Balanced |
| EC `0x34`/`0x35` (SRP) | 255 (untouched) | 0 = automatic |

`dmesg`: `hp_wmi: Registered as platform profile handler`

Fan behaviour in automatic mode, right after the module was loaded:
45.4 °C → 0/0 RPM (fan-stop), 58.6 °C → 2400/2100 RPM.

> **Corrected on 2026-09-11 — do not rely on the paragraph that used to be
> here.** From that measurement it was concluded that `SRP = 0` does not
> switch the fans off but hands control back to the EC, matching upstream's
> `HP_FAN_SPEED_AUTOMATIC` comment. That conclusion does not hold.
>
> Measured later, after the daemon had been driving manual setpoints: with
> `pwm1_enable = 2` the fans stayed at **0 RPM for the whole observation**
> while the CPU climbed 78.6 → 85.5 °C in twelve seconds under load. The EC
> did not take the fans back at any point.
>
> So the reading above was of a *fresh* state - a module that had only just
> registered and had never been in manual mode. It is not a general rule.
> Once the driver has taken manual control, "automatic" leaves the fans
> stopped, and handing control to the EC is **not** a safe resting state on
> this board.
>
> Refined later: there appears to be a watchdog. The omen-space project writes
> 120 to EC `0x63` and tells its users the handover to the BIOS can take up to
> two minutes. The EC probably does take over in the end - but the CPU went
> from 81 to 98 °C in seventy-six seconds, so waiting for it is not an option.
>
> What that cost, and what was done about it, is in
> [`phase3/README.md`](../../phase3/README.md#safety).

**`HPCM = 48` is this phase's most important result.** The value captured from
the OGH log on Windows in Phase 1 came out identical on Linux through a
completely different path (platform_profile → WMI 0x1A → EC). The protocol
extraction is now independently confirmed.

### Three things that came up along the way, none of them in the plan

1. **Unpatched, `platform_profile` was provided by `amd-pmf`**, not `hp-wmi`.
   Strix Point's AMD PMF driver registers its own handler. The §4 expectation
   ("platform_profile probably appears via the legacy path") was therefore
   misleading — the profile existed but `hp-wmi` was not driving it, which is
   also why `HPCM` read 0. Thanks to the multi-handler API in 6.14+, the two
   coexist without conflict.

2. **The CachyOS kernel is built with clang+LLD.** An out-of-tree module will
   not build without `LLVM=1`; kbuild passes clang-specific flags to gcc and it
   fails on the first file. `build-module.sh` now checks `.config` and decides
   for itself.

3. **`SRP = 0` does not mean "fans off", it means "revert to automatic"** —
   upstream's `HP_FAN_SPEED_AUTOMATIC 0x00`. The `0xFF` seen unpatched means
   "never written".

### `hp-wmi` does not own the GUID

It calls through `wmi_evaluate_method(HPWMI_BIOS_GUID, ...)` rather than
binding to the WMI device as a `wmi_driver`; it is itself a `platform_driver`.
So another module may use the same GUID. This is why the Phase 3 RGB module can
run alongside `hp-wmi` — no `blacklist hp_wmi` needed.

### DKMS and kernel upgrades

The DKMS package carries source downloaded from the `v7.2` tag. When the kernel
moves to 7.3, AUTOINSTALL will try to build that source against the new kernel
and **fail**, because `victus_s_thermal_profile_boards[]` /
`omen_v1_legacy_thermal_params` were renamed in 7.3. When that day comes:

```bash
sudo dkms remove -m hp-wmi-8d24 -v 7.2 --all
bash phase2/scripts/build-module.sh --install
```

The script derives the tag from the running kernel and picks the 7.3 form
itself.

### Remaining work

The patch should be submitted upstream (`platform-driver-x86` +
`linux-hwmon`). Both the Phase 1 measurements and the Linux verification here
can serve as justification; the 8D26 and 8E35 entries were accepted with less.
