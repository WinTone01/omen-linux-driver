# Phase 3 — `omend` / `omenctl` / `omen-kbd-rgb`

Fan curve service, control tool and 4-zone RGB keyboard driver for the
HP OMEN 16-ap0xxx (board **8D24**).

**Prerequisite:** the Phase 2 `8D24` patch must be applied. Without it `hp-wmi`
does not expose `pwm1` and `omend` refuses to start — the error message says
so. Check with `sudo bash ../kernel/hp-wmi-8d24/verify.sh`.

## Why a daemon is needed at all

Phase 1 §6.4 established that HP's "Auto" fan curve does not live in the EC —
it runs **in the Windows application**, which periodically writes the WMI
`0x2E` setpoint. So `hp-wmi` alone does not give you automatic fan control.

But the EC *does* have an automatic mode of its own, and it is not bad
(measured in Phase 2: fan-stop at 45 °C, 2400 RPM at 58 °C). So `omend` leaves
the lower part of the curve to the EC and only takes over when it wants
**more** than the EC is providing. Idle silence is preserved rather than
traded away.

## This project never writes the EC, and on this board that is not optional

Everything that changes fan behaviour here goes through `hp-wmi`'s hwmon
interface, where the kernel clamps the values. The EC is only ever **read**,
for the dGPU temperature - by `omen-kbd-rgb` through the kernel's own EC
driver, or with an older module through `ec_sys`, which is why the packaging
ships `options ec_sys write_support=0`.

That was a caution when it was written. It turns out to be a requirement.
The omen-space project keeps a list of machines where direct EC writes are
blocked outright:

```rust
const UNSAFE_MODELS: &[&str] = &["16t-ah0", "16-ah0", "16-ap0", ...];
const UNSAFE_BOARDS: &[&str] = &["8c58", "8d24"];

warn!("UNSAFE MODEL DETECTED! Legacy EC writes will be blocked to
       prevent Caps Lock panic.");
```

**Both this board (8D24) and this model family (16-ap0xxx) are on it.** A
Caps Lock panic is HP firmware's hardware-fault signal — a blinking Caps Lock
LED and a machine that needs a full power cycle. Their `write_byte` returns
false before touching anything on these boards.

So the answer to "why does EC default not cool, and how does the other
project fix it" is that it does not. Its EC-handover path writes `0x62`
(BIOS control), `0x63` (a 120-second watchdog), `0xF4` and the fan setpoints
— and every one of those writes is refused on 8D24. On this machine their
`ec` mode is `pwm1_enable = 2` plus a notification saying the handover can
take up to two minutes, which is exactly what ours does, minus the stall
detector that forces full power when the fans stop while hot.

Why the handover takes two minutes is now understood, and fixed:

* **The cause.** hp-wmi's "automatic" first renews the firmware's "software
  is in charge" state (WMI `0x10`), then writes a setpoint of 0. The EC
  obeys that 0 until the state times out 120 s later.
* **What was measured.** The firmware's own "automatic" setpoint is `0xff`.
  Written through the same WMI call, the EC's curve takes over within two
  seconds.
* **The fix.** The hp-wmi this project builds (`fix-auto.sh`, 8D24 only,
  turned off with `hp_wmi.firmware_auto=0`) writes `0xff` and keeps the state
  renewed, so the thermal profile survives too. `omenctl doctor` says which
  hp-wmi is loaded.

Every step goes through firmware methods rather than raw EC writes. The
details are in [ec-handover.md](research/ec-handover.md).

## Living with power-profiles-daemon

KDE's power profile switcher, and GNOME's, go through
`power-profiles-daemon`, which writes the same
`/sys/firmware/acpi/platform_profile` this project does. That sounds like a
fight, and it is not one. Measured:

```
start                     PPD=balanced     sysfs=balanced
omenctl profile performance
  immediately             PPD=balanced     sysfs=performance
  after five seconds      PPD=performance  sysfs=performance
PPD set to balanced       PPD=balanced     sysfs=balanced
```

PPD watches the file rather than owning it: an external change is adopted,
not reverted. So the desktop's widget catches up with a change made here
within a few seconds, and a change made in the widget shows up here on the
next poll. Both directions work, and nothing has to be disabled.

Two things can still surprise you, and neither is a bug:

* PPD applies policies of its own — dropping to power-saver on a low
  battery, for instance. When it does, the profile shown here changes on its
  own, because it genuinely did change.
* An application can ask PPD to *hold* a profile for its lifetime. While a
  hold is active PPD may re-assert its choice over one made here.

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

`omen-kbd-rgb` reads it in the kernel, with `ec_read()`, and publishes it as
an hwmon device named `omen` (`temp1_input`, labelled `dGPU`) on OMEN and
Victus machines. So `sensors` shows it, omend needs no root-only debugfs file
for it, and `ec_sys` is no longer loaded at boot. A 0 in the register is
reported as "no data" rather than as 0 °C.

With a module older than 0.2.0, omend falls back to reading the same byte
through `ec_sys`, loaded **read-only** — the packaging keeps the
`options ec_sys write_support=0` line for that case, and everything that
writes still goes through hp-wmi's hwmon interface where the kernel clamps
the values. With neither, the daemon
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

### Arch / CachyOS

```bash
cd packaging               && makepkg -si    # omen-control: daemon, CLI, app
cd ../kernel/omen-kbd-rgb  && makepkg -si    # omen-kbd-rgb-dkms: RGB keyboard
bash kernel/hp-wmi-8d24/build-module.sh --install   # the 8D24 patch
```

The 8D24 patch is not a package: `build-module.sh` fetches `hp-wmi.c` from the
upstream tag matching the running kernel, and a `PKGBUILD` that downloads
source at build time would be a bad package. It registers itself with DKMS all
the same, so it survives kernel updates.

If you installed by hand first — as anyone following this project's own
earlier instructions did — `pacman` will refuse the package rather than
overwrite files it does not own:

```
error: failed to commit transaction (conflicting files)
omen-control: /usr/bin/omend exists in filesystem
```

Clear the hand-installed copies first:

```bash
sudo systemctl stop omend
sudo rm -f /usr/bin/omend /usr/bin/omenctl \
           /usr/lib/{modprobe.d,modules-load.d,sysusers.d}/omen.conf \
           /etc/systemd/system/omend.service \
           /etc/udev/rules.d/99-omen-leds.rules
sudo mv -n /etc/omen/omend.toml /etc/omen/omend.toml.manual
```

The last two removals are not in the conflict list but matter more than the
ones that are: the package puts the unit and the udev rule under
`/usr/lib/`, and `/etc/` always shadows `/usr/lib/`. Leaving them means the
system keeps using the hand-installed copies even after an upgrade — silent,
and unpleasant to track down.

### Anything else

```bash
sudo bash install.sh
```

Builds the workspace and installs the binaries, the unit, the config, the udev
rule, the desktop entry and the icons. The kernel side is still the two
commands above.

### The one manual step

```bash
sudo usermod -aG omen $USER      # then log out and back in
```

A fresh group membership only applies to sessions started **after** it is
granted, so a window opened from the current session is still refused. This is
also why the desktop entry matters: launched from the menu it inherits your
login session's groups, whereas a binary started from a terminal that predates
the `usermod` does not. If the UI says it is not in the group, that is what it
means.

Check with `omenctl status`.

## The discrete GPU is the first render node

Worth knowing before wondering why programs use it: on this machine
`/dev/dri/renderD128` is the NVIDIA card and `renderD129` is the integrated
one. A program that opens "a render node" without choosing, or that enumerates
all of them to see what is available, lands on the discrete GPU and keeps it
awake for as long as it runs — with no intention of rendering anything there.

Measured: Firefox's decoder process and a Qt shell each held `renderD128` and
`/dev/nvidia0` while everything else on the system sat on `renderD129`.

`omenctl gpu` names the holders and the files each one has open, and prints
the environment that leaves a program with no NVIDIA driver to find. That is
stronger than `DRI_PRIME`, which the proprietary driver ignores.

## Usage

The window follows the desktop's language where it has a translation (English
and Turkish); Settings has an explicit choice. Everything the daemon says -
its replies, the diagnosis findings, the journal - stays English, because that
is also what goes into a bug report.

```bash
omenctl status                # daemon + hardware state
omenctl curve                 # active curve and safety thresholds
omenctl curve set 45:0,55:1800,75:2400,92:3600
                              # replace it (temperature:RPM; rpm 0 = fans off,
                              # only valid at the bottom)
omenctl curve preset quiet    # quiet / default / performance
omenctl curve reset           # back to the built-in OMEN Gaming Hub table
omenctl clean 20              # fans at full power for 20s, to clear dust

omenctl set curve             # automatic: the curve drives (default)
omenctl set manual 2400       # fixed target
omenctl set max               # full speed
omenctl set auto              # advanced: hand the fans to the EC (see below)
omenctl effect wave 7         # keyboard: none / breathing / wave / spectrum /
                              #   pulse / chase / gradient
omenctl effect breathing 4 '#00a0ff'
                              # speed 1-10, colour for breathing, pulse, chase
omenctl effect gradient '#e81123' '#006eff'
                              # a still blend, left colour to right colour
omenctl effect fps 60         # frames a second, 1-60 (default 30)
omenctl app                   # per-application profiles
omenctl app add cs2 performance curve:performance
                              # or a fixed target: omenctl app add cs2 3000
omenctl app remove cs2
omenctl app running           # what you are running, by the name to match
omenctl trigger               # rules that follow the machine's own state
omenctl trigger add temp-above 88 performance
omenctl trigger add idle 30 low-power curve:quiet
omenctl trigger add lid-closed low-power
omenctl trigger add time-between 23:00 07:00 low-power curve:quiet
omenctl trigger add wifi-ssid Office balanced curve:quiet
omenctl trigger remove idle
omen-ui --tab graphics        # open the window on one page
omenctl gpu mux               # which GPU drives the screen (hybrid/discrete/uma)
omenctl gpu mux discrete      # from the next boot
omenctl gpu                   # discrete GPU state, and what holds it awake
omenctl gpu on                # stop it suspending (costs battery)
omenctl profile performance   # balanced / performance / low-power
omenctl power                 # what happens on mains and on battery
omenctl power battery low-power curve
omenctl profile startup balanced
                              # which profile to start the machine on
omenctl battery               # charge, and the limit if this kernel has one
omenctl battery 80            # stop charging at 80% (see below)
omenctl curve code            # the running curve as one line, to share
omenctl curve import omen1:…  # load one somebody sent you
omenctl calibrate --yes       # measure what the fans really do at each setpoint
omenctl caps                  # what this machine can be asked to do, and why
omenctl version               # what is running vs what is installed
omenctl doctor                # check the whole installation, with remedies
omenctl doctor --text         # the same, to paste into a bug report
omenctl report                # one file with everything a bug report needs
omenctl reload                # re-read the config

omend --dry-run --once        # show what it would do, writing nothing
journalctl -u omend -f        # follow
```

`omenctl` never writes to the fan **directly**; control commands go to the
daemon over a unix socket. `status` falls back to reading sysfs when the daemon
is not running, so it stays useful as a diagnostic tool either way.

Set `OMEND_SOCKET` to run a second instance, or to try things without root.

### The OMEN key

The key above the keyboard reaches Linux as `KEY_PROG2`, delivered through the
input device `hp-wmi` creates ("HP WMI hotkeys"). Most desktops have nothing
bound to it, so out of the box it does nothing at all.

`omend` watches that device and, by default, **opens the window**. That is
what the key does on Windows, so it is what someone pressing it expects.

The daemon cannot raise the window itself. The service is sandboxed:
`ProtectHome=yes` hides `/run/user`, and root with an empty capability set
could not enter a user's runtime directory anyway. So the daemon counts the
presses, and the window asks for that count four times a second over the
daemon's socket, showing itself when it goes up. Nothing needs loosening, and
no `input` group is needed. It does mean the window has to be running for the
key to open it. With *Start with the session* and *Start hidden in the tray*
on in Settings, it always is.

A first version had the daemon connect to the window's own socket under
`/run/user`. It seemed to work only because the daemon under test ran as the
user. The installed service could never reach that socket, and it said so
only in a debug message.

```bash
omenctl key            # what it is bound to now
omenctl key profile    # step through the performance profiles instead
omenctl key both
omenctl key none
```

Setting it to `profile` is worth knowing about: stepping the performance
profile needs no window, no desktop and no session, so it keeps working from a
text console.

### Rules, in order of precedence

Three things can decide the profile and how the fan is driven, and they are
resolved most-specific-first:

| | Answers | Example |
|---|---|---|
| Application profiles | what is running | `omenctl app add cs2 performance` |
| Triggers | what state the machine is in | `omenctl trigger add lid-closed low-power` |
| Power rules | what it is plugged into | `omenctl power battery low-power` |

Each of them applies its settings once, when it starts, and puts back what was
there when it ends — unless you have changed things in the meantime, in which
case your change is newer and stands.

The conditions are `temp_above`, `battery_below`, `idle`, `lid_closed`,
`time_between` (a window that may wrap past midnight) and `wifi_ssid` - the
network being the only thing on a laptop that knows where it is. The clock and
the network name are the only readings here that cost a process to find out,
so they are looked up only when a trigger asks for them and the answer is kept
for a minute.

`idle` is measured from CPU time in `/proc/stat`, not from the keyboard: the
daemon runs as root outside any login session and cannot see input without
becoming a D-Bus client of whichever session happens to be current. A machine
compiling something unattended is not idle; one sitting at a login screen is.

### The battery charge limit

`omenctl battery 80` writes the kernel's own `charge_control_end_threshold`,
the same file GNOME's battery-preservation switch uses, and `omend` puts it
back after a suspend or a driver reload.

**This board does not have that file.** HP keeps the setting in firmware
instead — BIOS setup, "Battery Health Manager", F10 at boot — so on the
16-ap0xxx the command reports exactly that rather than pretending. It is
implemented because the same code is right on every machine whose driver does
expose the threshold, and because "the kernel offers no control here" is a
more useful answer than silence.

### How the last session ended

A thermal cutout is the one failure this project exists to prevent, and the
one nobody has evidence of afterwards: the machine goes off, it comes back,
and nothing says why. `omenctl doctor` reads the previous boot's journal and
says - and `omenctl report` carries it, along with the setpoints the daemon
chose before it happened.

It judges by the trail a shutdown leaves (services stopped, filesystems
unmounted) rather than by systemd's last word, because the journal is stopped
before the end and that last line usually never reaches the disk. Looking for
it reports every clean shutdown as a crash, which is what the first version of
this check did on this very machine.

"It stopped" and "it was hot" are kept separate. The second is only claimed
when the kernel said so, and then its own line is quoted.

### Naming the process a profile should match

The one thing people get wrong about application profiles: the name has to be
what the kernel calls the program, which is usually not what the launcher is
called. Rather than guess from an installed-games list - Steam's manifests
name the game, not the binary - start the game and look:

```console
$ omenctl app running
your running programs  (52 of them)

  * steam
    cs2
    Discord
```

Programs from a home directory, `/opt`, a Steam library or a flatpak are
listed first, the desktop's own plumbing after. The window offers the same
list as completions on the process box.

### The things that need root, and how it asks

Almost nothing here does. The daemon holds the privileges, `omenctl` and the
window reach it through a socket owned by the `omen` group, and the LEDs are
reachable through a udev rule. What is left is the plumbing around it, and
each piece is a named action rather than a command to copy:

```console
$ omenctl fix
what needs root here

  restart-daemon     Restart the service
                     An upgrade leaves the old daemon running until it is restarted.
                     $ systemctl restart omend

  How it will ask: your desktop's own password dialog (polkit)
  To run one:      omenctl fix restart-daemon
```

`omenctl fix` on its own lists what this machine is actually out of step on -
a clean machine lists nothing. Running one asks for a password through polkit
on a desktop, through `sudo` on a terminal, and on a machine with neither it
prints the command for you to run yourself. The window shows the same list on
the Diagnosis page, with the command next to each button.

What may be run is a closed list, written in `crates/omen-core/src/elevate.rs`.
Nothing accepts a command from a caller, a config file or the window: an API
that runs a string as root is a root shell with extra steps.

### Other OMEN and Victus machines

`hp-wmi` exposes `pwm1` only for boards it has a DMI entry for, and HP ships
boards faster than they reach the kernel. The installer handles both cases:

* **The kernel already covers your board.** Nothing is patched and no DKMS
  package is installed - the in-tree driver is doing the job, and an
  out-of-tree copy of it would be maintenance for nothing.
* **It does not.** `kernel/hp-wmi-8d24/add-board.sh` adds *your* board to the
  same table, against the parameters the rest of the family uses, and the
  module is built and registered with DKMS.

It refuses to do that on anything that is not an OMEN or a Victus, and a board
name that is not a short alphanumeric id is rejected before it reaches the C
source.

This is reasonable rather than verified: the fan protocol (the WMI 0x2E
setpoint, the thermal profile) is shared across the family and upstream gives
nearly all of these boards the same parameters. What it is not is measured on
your machine - so `omenctl doctor` says the RPM range came off 8D24, and
`omenctl calibrate` measures yours.

### Machines that can only do part of this

`omenctl caps` asks each interface separately — fan setpoint, tachometers,
platform profile, sensors, lighting, mux, charge threshold — and reports a
level:

| Level | Means |
|---|---|
| `full` | fan control and profiles both work |
| `profile-only` | profiles work, `pwm1` is absent — usually a board missing from hp-wmi's DMI table |
| `telemetry-only` | it can be watched but not driven |
| `unsupported` | no interface of ours is present |

The daemon starts at whatever level it finds rather than refusing to run
without a fan: on an unverified OMEN the profiles, the automation, the
lighting and the diagnosis all still work, and withholding them over a missing
line in a DMI table would help nobody. What it cannot do, it says it cannot
do — the status reports no fan mode, and a fan request is answered with the
reason and the remedy instead of being queued.

### `pwm1` reads back the speed, not the setpoint

Worth knowing before building anything on this interface. Writing `pwm1` sets
the fan target; reading it returns the fan's **current speed** converted back
through the same scale, not the target that was written:

```console
$ cat pwm1 fan1_input        # setpoint 1800 RPM
90
1700                         # 90/255 x 4800 = 1694
$ cat pwm1 fan1_input        # a moment later, still ramping
122
2300                         # 122/255 x 4800 = 2296
```

So a readback check written as "did the number we wrote come back" disagrees
on every ramp and most of the steady state. `omend` asks the two questions
that are actually answerable instead: is `pwm1_enable` still manual (the fan
is still ours), and are the fans turning at something like what was asked for,
for long enough that they cannot still be on their way.

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

`EC default` does hand them over, which is why it is set apart in the UI.
With stock hp-wmi it is there for comparing against stock behaviour, not for
daily use: the EC does not drive the fans for up to two minutes (see below).
With the hp-wmi this project builds, the handover is real. The EC's curve
takes over within two seconds, and the daemon also uses it when it stops,
even on a hot machine. The earlier naming had this backwards: `Curve`
sounded like the advanced option and `Auto` like the safe default, when the
opposite is true.

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
kernel/omen-kbd-rgb/ keyboard (leds-multicolor), graphics mux, dGPU hwmon
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
`*::kbd_backlight`, so the brightness keys work. Fn+F4 is followed too. The
firmware steps the keyboard through bright, dim (its own 50 %) and off without
telling anyone, so the module checks every two seconds (`poll_ms` module
parameter; 0 turns it off). It reports each step through
`brightness_hw_changed`, which is what the desktop's on-screen indicator
listens to. The value it reports is what the keyboard shows: the level set
here times the firmware's. The firmware's dim level cannot be set from
software; only Fn+F4 reaches it. See research/rgb-protocol.md §2.

What else the module does on its own:

* **Colours survive sleep.** They live in the EC, which the firmware may
  reinitialise; the module writes them back on resume, daemon or not.
* **Writes are folded.** One firmware call carries all four zones, and
  changes that arrive together — a whole keyboard, or an effect frame — go
  out as one.
* **It asks before it lights anything.** `LM01` says whether there is a
  backlight and which kind; anything but the 4-zone type is left alone,
  rather than dressed up as four RGB zones.

Module files, under `/sys/devices/platform/omen-kbd-rgb/`:

| | |
|---|---|
| `backlight_active` | 1 while the keyboard is lit, asked of the firmware |
| `gpu_mux_mode` | the mode the next boot uses; write `hybrid`, `discrete` or `uma` |
| `gpu_mux_supported` | what the firmware declares |
| `gpu_mux_pending_reboot` | 1 when the mode differs from the one in force at load |

The raw lighting block of the extended EC RAM that the research used is in
debugfs now, on 8D24 only: `/sys/kernel/debug/omen-kbd-rgb/lighting_regs`.

## Status

| | |
|---|---|
| M1 fan curve + status tool | **working**, verified as a systemd service |
| M1b `omenctl` control commands (unix socket) | **working** |
| M2 `omen-kbd-rgb` kernel module | **working**, verified on the machine |
| M3 Tauri UI | planned |

## GPU power allowance: cTGP and Dynamic Boost

```bash
omenctl gpu boost              # what the firmware has now
omenctl gpu boost profile      # follow the profile (the default)
omenctl gpu boost leave        # leave them to the firmware
```

The firmware has two switches for the discrete GPU's power, read with WMI
command `0x21` and set with `0x22`: **cTGP** (configurable TGP) and **Dynamic
Boost**, which lets the GPU borrow power the CPU is not using. The vendor
software sets both with every profile change. hp-wmi does the same on the
Victus S boards, but not on `omen_v1_legacy` boards like 8D24. omen-kbd-rgb
0.2.0 exposes them as `gpu_ctgp` and `gpu_ppab`, and omend follows hp-wmi's
mapping:

| Profile | cTGP | Dynamic Boost |
|---|---|---|
| performance | on | on |
| balanced | off | on |
| low-power | off | off |

Dynamic Boost has a second half, **nvidia-powerd**, which does the shifting
at run time. Without it the switch is accepted and does nothing, and
`omenctl doctor` says so.

## What each profile allows

```bash
omenctl profile measure
```

Loads every core, switches through the profiles, and prints what the CPU
package draws once the firmware's limits settle. It also prints the clock and
the GPU power limit the NVIDIA driver is enforcing. It takes about a minute
and a half and puts the profile back afterwards. On 8D24, on mains:

| Profile | CPU | Clock | GPU limit |
|---|---|---|---|
| low-power | 31.7 W | 1992 MHz | 80 W |
| balanced | 55.0 W | 3479 MHz | 80 W |
| performance | 60.0 W | 3552 MHz | 100 W |

Method and what the numbers mean: [research/profile-power.md](research/profile-power.md).

## GPU load on the vitals page

NVIDIA publishes the GPU's load, power and clock only through NVML, and
opening the GPU to ask counts as using it. Asking every two seconds would keep
it awake forever, which is the problem the Graphics page exists to catch. So
the window asks through `nvidia-smi` only while the GPU is already awake **and**
a program other than a query tool is rendering on it (`/dev/nvidiaN` open).
The rest of the time the GPU ring shows the temperature, as before.

## Keys that send the wrong thing

```bash
omenctl keys check     # needs the 'input' group, or sudo
omenctl keys reset
```

Some HP boards send the wrong key for Print Screen or F1, and other projects
fix that with an hwdb rule for every HP laptop. A rule like that breaks the same
keys on a board where they were right. So this one measures instead: it names
a key, you press it, and it reads the scancode and the keycode from the
keyboard itself. Everything one key sends is collected, not just the first
event: on 8D24 some keys send a combination, and a first version that stopped
at the first event wrote a rule turning the Super key into F1. Top-row keys
are asked for twice, on their own and with Fn, because which half is the
default is a BIOS setting. A key counts as broken only if neither way sends it.
A modifier (Ctrl, Shift, Alt, Super, Fn) is never remapped.

On 8D24, **Fn+F12 is the Windows-key lock**. The firmware handles it, so the
toggle sends no event, and while the lock is on the Windows key sends nothing
at all. A Windows key that looks dead is usually this. The check says so when
the Windows key sends nothing. The rule covers
only keys that came out wrong, only for this board (`rn8D24`), and goes to
`/etc/udev/hwdb.d/90-omen-keyboard.hwdb`. Run
without root, it saves the rule in `~/.config/omen-control/keyboard.hwdb` and
prints the commands that install it.

## Notifications

With *Warn me* on in Settings, the window raises a desktop notification in
these cases, once each:

* the fans are forced to full power;
* the service tries a hardware command and the firmware refuses it (a profile,
  the GPU settings, the fans' mode). The service keeps the last twenty;
  `omenctl status` shows the most recent three;
* the fans stop doing what they were told;
* the service stops responding, which leaves the fans to the firmware.

## Smooth effects

The effects stuttered at any frame rate, and the frame rate was not the
cause. Measured with `kernel/omen-kbd-rgb/probe-fps.sh`, which counts the
writes that reach the firmware and times each one (debugfs `zone_stats`):

| | Frames reaching the firmware | Mean write | Longest write |
|---|---|---|---|
| before | 70-80 % of those asked for | 8-23 ms | ~270 ms |
| after | all of them | 0.7 ms | 15-21 ms |

**The cause was the fan tachometer.** hp-wmi reads the fan speeds on this
board through WMI command `0x2D`. Its firmware method (`GM2D`) starts with an
SMI and waits for it, which takes 264 ms per read. While it runs, no other
ACPI method can run, and that includes a keyboard frame. omend read three of
them every two seconds (fan1, fan2 and `pwm1`, which on this board reads back
the measured speed). The same two numbers sit in the EC's memory-mapped RAM
(`FS1H/FS1L`, `FS2H/FS2L` at `0x530`), where `GM11` reads them without an SMI.
omen-kbd-rgb now exposes them as `fan1_input`/`fan2_input` on its `omen`
hwmon device, on 8D24 only, and omend reads those. They agree with hp-wmi
(2313 against 2300 RPM, since hp-wmi rounds to 100). hp-wmi stays the
fallback, and the only path for writing. This also takes most of a second of
ACPI time off every daemon tick.

With that fixed, 30 fps looked smooth and 60 fps no better, so 30 is the
default. Three smaller things were fixed along the way:

* **Half-written frames.** The LED class hands the driver one zone at a time.
  The driver now waits 4 ms for the rest of the frame and writes all four
  zones in one call. A frame writes colours only, four writes instead of eight.
* **Frame pacing.** Frames are placed on a fixed grid, so the time a draw
  takes does not stretch every frame.
* **Linear breathing.** LED output is linear and the eye is not, so breathing
  is gamma-corrected (2.2).

`omenctl effect fps` and Smoothness on the Lighting page set the rate, 1-60.

## What OMEN Gaming Hub did that this did not

Surveyed on Windows, from the Hub's logs, the platform configuration it ships
for this board, and its decompiled assemblies. The protocol and every number
used below are in [hub-gap.md](research/hub-gap.md). Everything in this
section needs **omen-kbd-rgb 0.3.0** on board 8D24, and none of it has been
measured on Linux yet. The list at the end of hub-gap.md says what to check.

### Unleashed

```bash
omenctl profile unleashed
```

This is the Hub's fourth mode: firmware profile `0x04`. platform_profile has
no name for it, so `omen-kbd-rgb` exposes it as `unleashed`, and this project
offers it as a fourth profile. That means the window, the OMEN key's cycle,
application rules and power rules all list it. It is selected through
performance, the mode it sits above. While it holds, omend does what the Hub
does:

* **PL1 goes to 71 W.** The setting is `power.unleashed_pl1_w`, range
  25-71 W. The firmware's own profiles hold 55 W (balanced) and 60 W
  (performance). Those values come back when Unleashed ends.
* **The shared CPU+GPU limit goes up 20 W**, on mains only
  (`power.unleashed_tpp_offset_w`).
* **The palm rest is held under 54 °C** (`power.unleashed_surface_c`, 44-54).
  Every 30 s: at the limit, PL1 drops 5 W and Dynamic Boost goes off. Below
  the limit and cooling, PL1 is given back.

On battery, Unleashed needs 40 % charge and performance needs 10 %. Below
that, the mode steps down by itself (`power.min_battery_*`, 0 turns a floor
off). A request for a mode the battery would immediately take back is refused
with the reason.

### The surface temperature

`sensors` now shows a second `omen` channel, **Surface**. It is EC register
`0x48`, the sensor the Hub calls IR and reads through WMI `0x23`. It shows in
the window under the performance tiles and in `omenctl status`. It never
drives the curve: the palm rest trails the load by minutes.

### PL1 and the shared limit, by hand

```bash
omenctl power limits             # what is in force, and the settings
omenctl power pl1 60             # Unleashed's PL1
omenctl power tpp performance 10 # +10 W shared limit in performance
```

The raw controls are `cpu_pl1` and `gpu_tpp` under
`/sys/devices/platform/omen-kbd-rgb/`, in watts. They go through WMI `0x29`,
the same call the Hub makes; the EC is only read.

### The Hub's own fan tables

```bash
omenctl curve hub                # or: omenctl curve algorithm curve
```

The curve this project ships is the Hub's *custom curve* table. What the Hub
actually runs in Auto is different:

* Three tables per mode: CPU, GPU and the palm rest. The fans follow
  whichever asks for most.
* Each step has a temperature to go up at and a lower one to come down at.
* The CPU reading is smoothed first, so a two-second spike does not move the
  fans.

Balanced keeps the fans stopped until the smoothed CPU reaches 68 °C.
Performance never stops them. One rule is added on top of HP's tables: at
`safety.stall_temp_c`, the fans are never left stopped while the average
catches up. Otherwise the stall detector would fire, and it would be right
to.

### EPP follows the profile

On Windows the Hub switches the power plan with the mode. The Linux
equivalent is the `amd_pstate` EPP hint:

* low-power → `power`
* balanced → `balance_performance`
* performance and Unleashed → `performance`

omend sets the hint only while nothing else does. If power-profiles-daemon,
tuned or auto-cpufreq is running, it is left alone, because they already
set it. Turn it off with `omenctl power epp off`.

### GameMode

```bash
omenctl gamemode setup           # prints the two lines for gamemode.ini
omenctl gamemode rule performance curve:performance
```

Feral GameMode runs `omenctl gamemode on` and `off`. While a game is running,
the rule applies, and it is put back afterwards, the same way an application
profile is. An application profile that names the game wins over it.

### Refresh rate per application or power source

```bash
omenctl app add cs2 performance 165hz
omenctl power battery low-power 60hz
systemctl --user enable --now omen-session
```

A refresh rate belongs to the compositor, so the system service only says
which rate is wanted. `omenctl session` runs as you and applies it, then puts
the old rate back when no rule asks any more. It works with KDE
(`kscreen-doctor`), Hyprland (`hyprctl`), sway and other wlroots compositors
(`wlr-randr`), and X11 (`xrandr`). GNOME has no command-line way to change
the rate, so it is not supported.

### In-game overlay

```bash
MANGOHUD_CONFIGFILE=/usr/share/omen-control/mangohud-omen.conf mangohud %command%
```

MangoHud shows one OMEN line from `omenctl overlay`: the profile, both fans,
the CPU, GPU and surface temperatures, and PL1.

### In the window, and in `omenctl doctor`

The Game Profiles page has all of this as well:

* a refresh rate next to each application and power rule
* a GameMode card, with the lines to add to `gamemode.ini`

The History graph on System Vitals draws the surface temperature as a dashed
line, on machines that report it.

`omenctl doctor` and the Diagnosis page have a **Power** section. It checks:

* that the loaded omen-kbd-rgb is new enough for Unleashed and PL1
* that the surface sensor answered
* that EPP matches the profile, or names whatever else is managing it
* when a rule asks for a refresh rate, that `omen-session` is running to
  apply it
* when GameMode has a rule, that `gamemode.ini` actually calls omenctl
