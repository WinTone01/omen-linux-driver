# Phase 3 — `omend` / `omenctl` / `omen-kbd-rgb`

Fan curve service, control tool and 4-zone RGB keyboard driver for the
HP OMEN 16-ap0xxx (board **8D24**).

**Prerequisite:** the Phase 2 `8D24` patch must be applied. Without it `hp-wmi`
does not expose `pwm1` and `omend` refuses to start — the error message says
so. Check with `sudo bash ../phase2/scripts/verify.sh`.

## Why a daemon is needed at all

Phase 1 §6.4 established that HP's "Auto" fan curve does not live in the EC —
it runs **in the Windows application**, which periodically writes the WMI
`0x2E` setpoint. So `hp-wmi` alone does not give you automatic fan control.

But the EC *does* have an automatic mode of its own, and it is not bad
(measured in Phase 2: fan-stop at 45 °C, 2400 RPM at 58 °C). So `omend` leaves
the lower part of the curve to the EC and only takes over when it wants
**more** than the EC is providing. Idle silence is preserved rather than
traded away.

## Install

```bash
cargo build --release
sudo install -Dm755 target/release/omend   /usr/bin/omend
sudo install -Dm755 target/release/omenctl /usr/bin/omenctl
sudo install -Dm644 packaging/omend.service /etc/systemd/system/omend.service
sudo install -Dm644 packaging/omend.toml    /etc/omen/omend.toml
sudo install -Dm644 packaging/omen-sysusers.conf /usr/lib/sysusers.d/omen.conf
sudo systemd-sysusers
sudo systemctl enable --now omend
```

The config file is optional — without it the built-in defaults are used.

To use the control commands without `sudo`, join the `omen` group:

```bash
sudo usermod -aG omen $USER      # then log out and back in
```

## Usage

```bash
omenctl status                # daemon + hardware state
omenctl curve                 # active curve and safety thresholds

omenctl set curve             # let the curve drive (default)
omenctl set manual 2400       # fixed target
omenctl set auto              # hand control back to the EC
omenctl set max               # full speed
omenctl profile performance   # balanced / performance / low-power
omenctl reload                # re-read the config

omend --dry-run --once        # show what it would do, writing nothing
journalctl -u omend -f        # follow
```

`omenctl` never writes to the fan **directly**; control commands go to the
daemon over a unix socket. `status` falls back to reading sysfs when the daemon
is not running, so it stays useful as a diagnostic tool either way.

Set `OMEND_SOCKET` to run a second instance, or to try things without root.

## Safety

A wrong EC write can stop the fans entirely, and thermal protection does not
always step in. `omend` follows five rules:

1. **Always hand control back on exit.** Three gates: `Drop` for normal exit
   and for panics, and systemd `ExecStopPost=omend --restore-auto` for SIGKILL.
2. **Critical cutout.** Above `critical_c` (97 °C by default) the curve is
   abandoned and control returns to the EC; it re-engages once the temperature
   drops by `recover_delta_c`. The cutout must be *above* the top of the curve,
   otherwise the daemon refuses to start — see below.
3. **Watchdog.** If a temperature cannot be read, or a setpoint cannot be
   written, fall back to automatic. Staying at the last setpoint in an unknown
   state is the most dangerous behaviour available.
4. **Two layers of clamping.** The setpoint is clamped to `min_rpm..max_rpm` in
   `omend`, and again to the fan table's limits in the kernel.
5. **Only the daemon writes.** `omenctl` sends a request over the socket
   instead of touching the fan. That way clamping, the critical cutout and
   restore-on-exit are guaranteed in one place — including in manual mode. The
   cutout overrides the user's request too.

Rule 2 is not a formality: the first version defaulted the cutout to 90 °C
while the curve ran to 4800 RPM at 95 °C, which made the most aggressive part
of the curve dead code — the cutout fired before the temperature ever got
there. The config check now rejects that combination.

Keep `watch -n1 sensors` open in a second terminal the first time you try a
curve.

### Verification (2026-09-11, kernel 7.2.4-1-cachyos)

All three gates of rule 1 were exercised on the machine:

| Exit path | Mechanism | Result |
|---|---|---|
| Ctrl+C (SIGINT) | `Drop` | `pwm1_enable` returned to 2 |
| `omend --restore-auto` | direct | returned to 2 |
| `pkill -9` (SIGKILL) | systemd `ExecStopPost` | returned to 2 |

The last one matters most: on SIGKILL `Drop` does **not** run, and only systemd
can recover the fan. The test was done while the daemon was in manual mode
(`pwm1_enable = 1`), otherwise it would have proven nothing.

## Layout

```
crates/omen-core/    sysfs, fan, thermal, curve, config, IPC   (19 tests)
crates/omend/        daemon: curve engine + safety state machine + socket
crates/omenctl/      status tool and daemon client
kernel/omen-kbd-rgb/ 4-zone RGB keyboard module (leds-multicolor)
packaging/           systemd unit, example config, sysusers
docs/                phase plan, RGB protocol
```

## RGB module

```bash
cd kernel/omen-kbd-rgb && make
sudo modprobe -a led-class-multicolor wmi  # insmod does not resolve deps
sudo insmod omen-kbd-rgb.ko

# 4 zones + global brightness
ls /sys/class/leds/ | grep omen
echo 255       | sudo tee /sys/class/leds/omen:rgb:kbd_backlight_zone0/brightness
echo "255 0 0" | sudo tee /sys/class/leds/omen:rgb:kbd_backlight_zone0/multi_intensity
echo 60        | sudo tee /sys/class/leds/omen::kbd_backlight/brightness
```

Zones are numbered left to right: `zone0` leftmost, `zone1` WASD, `zone2`
centre-right, `zone3` numpad. The hardware slots are **not** in that order; the
module translates — see the protocol document.

> **Turning the backlight on is not the driver's job.** Writing `LRGB`/`LBRT`
> does **not** switch the lighting on. The colours land in the registers and
> read back correctly, but if the keyboard is dark it stays dark. The master
> switch is internal EC state, driven by **`Fn+F4`**. If you write a colour and
> see nothing, press that first.

The module uses only the lighting command group (`0x020009`), so it runs
alongside `hp-wmi` — no `blacklist hp_wmi` needed. Protocol:
[`docs/rgb-protocol.md`](docs/rgb-protocol.md)

The global brightness LED is deliberately named `omen::kbd_backlight`: desktop
environments and `upower` look for keyboard backlights matching
`*::kbd_backlight`, so the brightness keys work.

## Status

| | |
|---|---|
| M1 fan curve + status tool | **working**, verified as a systemd service |
| M1b `omenctl` control commands (unix socket) | **working** |
| M2 `omen-kbd-rgb` kernel module | **working**, verified on the machine |
| M3 Tauri UI | planned |
