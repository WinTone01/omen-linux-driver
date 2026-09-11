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

## The discrete GPU is read through the EC

The NVIDIA driver registers **no hwmon** on this machine: `nvidia-smi` reports
a temperature while `/sys/class/hwmon` has nothing for it. A curve driven from
hwmon alone therefore never reacts to the GPU heating up — which, on a laptop
with an RTX 5060, is most of the thermal load a game produces. The symptom is
the worst kind: fans that stay quiet while the machine cooks.

So the dGPU is read from the EC instead, one byte at `0xB7` (Phase 1 §4:
`GTMP`). The omen-space project reads the same register on the same family,
which is an independent confirmation of the Phase 1 map — and the reading
itself was checked against the vendor tool:

```
dgpu/ec      65.0 C
nvidia-smi   65
```

That needs the `ec_sys` module, loaded **read-only** — omend only ever reads
temperatures, and everything that writes goes through hp-wmi's hwmon
interface where the kernel clamps the values. The packaging installs a
`modules-load.d` entry and a `modprobe.d` option for it. Without it the daemon
still runs, follows the CPU alone, and says so at startup.

## The fan curve is HP's own

The default curve is not invented, it is OMEN Gaming Hub's, reproduced point
for point from the `profiles.json` it ships (Phase 1 §6.3):

| CPU °C | 50 | 55 | 60 | 65 | 70 | 75 | 80 | 85 | 90 |
|---|---|---|---|---|---|---|---|---|---|
| hundreds of RPM | 18 | 18 | 18 | 18 | 24 | 24 | 24 | 24 | 33 |

It is a **lookup table at 5 °C granularity, not a continuous curve**, so it is
read that way: each entry is held until the next one. That detail matters. At
75 °C the table says 2400 RPM; interpolating between the 70 and 80 entries
would say 2100 — quieter than stock, which is the opposite of matching it. Set
`interpolation = "linear"` if you would rather have the ramp.

Two entries are ours, because HP's table does not cover them:

- **Below 50 °C** the fans are left alone. Silent at idle, which is what the
  machine does from the factory (measured in Phase 2: 0 RPM at 45 °C).
- **Above 90 °C** the 3300 RPM entry is held. HP lets the CPU throttle rather
  than spinning faster; the critical cutout at 97 °C is what catches a genuine
  runaway.

## Install

```bash
cargo build --release
sudo install -Dm755 target/release/omend   /usr/bin/omend
sudo install -Dm755 target/release/omenctl /usr/bin/omenctl
sudo install -Dm644 packaging/omend.service /etc/systemd/system/omend.service
sudo install -Dm644 packaging/omend.toml    /etc/omen/omend.toml
sudo install -Dm644 packaging/omen-sysusers.conf /usr/lib/sysusers.d/omen.conf
sudo install -Dm644 packaging/omen-modules.conf  /usr/lib/modules-load.d/omen.conf
sudo install -Dm644 packaging/omen-modprobe.conf /usr/lib/modprobe.d/omen.conf
sudo systemd-sysusers
sudo modprobe ec_sys write_support=0
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

omenctl set curve             # automatic: the curve drives (default)
omenctl set manual 2400       # fixed target
omenctl set max               # full speed
omenctl set auto              # advanced: hand the fans to the EC (see below)
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

1. **Always leave the fans in a safe state on exit.** Three gates: `Drop` for
   normal exit and for panics, and systemd `ExecStopPost=omend --restore-auto`
   for SIGKILL. Above `stall_temp_c` that state is *full power*, not
   automatic — see the incident below.
2. **Critical cutout.** Above `critical_c` (97 °C by default) normal driving is
   suspended and the fans are forced to **full power**; it resumes once the
   temperature drops by `recover_delta_c`. The cutout must be *above* the top
   of the curve, otherwise the daemon refuses to start.
3. **Stall detector.** Fans reading 0 RPM above `stall_temp_c` (75 °C) for
   `stall_grace_secs` means cooling has failed, whatever the reason. Full
   power, immediately. This check is about behaviour rather than about a
   particular mode, so it catches causes nobody predicted.
4. **Watchdog.** If a temperature cannot be read, or a setpoint cannot be
   written, force full power. Staying at the last setpoint in an unknown state
   is the most dangerous behaviour available.
5. **Two layers of clamping.** The setpoint is clamped to `min_rpm..max_rpm` in
   `omend`, and again to the fan table's limits in the kernel.
6. **Only the daemon writes.** `omenctl` sends a request over the socket
   instead of touching the fan. That way clamping, the cutout and the exit
   behaviour are guaranteed in one place — including in manual mode. The
   overrides beat the user's request too.

### On the fan modes, and what "Auto" is not

The modes are named for what they do for you, not for how they work inside:

| UI | Protocol | What it does |
|---|---|---|
| Automatic | `curve` | The daemon drives the fans from the curve. The normal mode. |
| Manual | `manual` | A fixed target. |
| Max | `max` | Full power. |
| *EC default* | `auto` | Hands the fans to the EC and stops managing them. |

`Automatic` is the equivalent of what OMEN Gaming Hub calls Auto. That is not
a loose analogy: Phase 1 §6.4 found HP's Auto runs the curve **in the Windows
application**, writing setpoints continuously, exactly as this daemon does.
Nobody's "automatic" hands the fans to the EC.

`EC default` does hand them over, which is why it is set apart in the UI. It is
there for comparing against stock behaviour, not for daily use - on this
machine the EC does not take the fans at all (see below). The earlier naming
had this backwards: `Curve` sounded like the advanced option and `Auto` like
the safe default, when the opposite is true.

### The incident that rewrote rules 1 to 4 (2026-09-11)

`Auto` mode was selected while the machine was under load at about 81 °C.
Seventy-six seconds later the CPU was at 98 °C. The critical cutout fired —
and did nothing, because its only action at the time was *hand control to the
EC*, and the fan was already there.

Measured afterwards, deliberately and with a hard revert: with
`pwm1_enable = 2` the fans sat at **0 RPM** for twelve straight seconds while
the CPU climbed 78.6 → 85.5 °C under load.

> **Refined on 2026-09-11.** The conclusion drawn at the time — "the EC never
> takes them" — was measured over twelve seconds and stated too strongly. The
> omen-space project writes `0x78` (120) to EC `0x63`, a watchdog timer, and
> warns its users that handing the fans to the BIOS *"can take up to 120
> seconds"*. So the EC most likely does take over, eventually.
>
> That does not change anything about the safety decision. The incident went
> from 81 °C to 98 °C in seventy-six seconds; two minutes at 0 RPM under load
> is not a handover, it is an overheat. The fans still get forced to full.

Two mistakes, both ours:

- **The claim that `SRP = 0` means "revert to automatic" was wrong** on this
  board. It came from upstream's `HP_FAN_SPEED_AUTOMATIC` comment and from one
  measurement taken minutes after the module first loaded. It does not hold
  once the driver has been in manual mode. The Phase 2 document now carries
  that correction.
- **A safety net whose action is to hand the problem back to whatever caused
  it is not a safety net.** Every override now forces full power, which is the
  one state that is unambiguously safe at these temperatures.

Selecting `Auto` no longer risks this. The full cycle, measured on the machine
under load:

```
02:32:38  mode: curve -> auto
02:32:50  EMERGENCY: cpu/Tctl 77.5C with both fans stopped for 8s - forcing full power
02:32:50  auto mode is not cooling this machine - switching to the curve
02:33:10  leaving emergency
02:33:10  cpu/Tctl 75.9C -> 2200 RPM
```

Twelve seconds from the fans stopping to full power, the peak at 82.6 °C
rather than 98 °C, and back on the curve twenty seconds later without needing
the machine to cool down first.

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
| Ctrl+C (SIGINT) | `Drop` | fans left in a safe state |
| `omend --restore-auto` | direct | same |
| `pkill -9` (SIGKILL) | systemd `ExecStopPost` | same |

The last one matters most: on SIGKILL `Drop` does **not** run, and only systemd
can recover the fan. The test was done while the daemon was in manual mode,
otherwise it would have proven nothing.

At the time all three returned `pwm1_enable` to 2. That is still what happens
on a cool machine; above `stall_temp_c` they now leave the fans at full power
instead, for the reason in the incident above.

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

> **The backlight switch is on/off, and the level is the driver's.** `LM04`/
> `LM05` look like a 0-100 brightness in the DSDT but are a switch taking two
> magic values, `0xE4` on and `0x64` off. Writing a level there sends `0x64`
> for "100" — the off value — which is why setting full brightness used to
> switch the keyboard off. Every level in between is produced by scaling the
> colours. See [`docs/rgb-protocol.md`](docs/rgb-protocol.md) §2 and §6.

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
