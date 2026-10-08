# Handing the fans back to the EC (8D24)

Why does "automatic" leave this board's fans stopped, and what would hand
them back properly? Worked out 2026-10-08 from the DSDT, mainline hp-wmi and
the decompiled OMEN Gaming Hub (the same sources as `hub-gap.md`). Nothing
here has been measured yet. `kernel/omen-kbd-rgb/probe-handover.sh` measures
it; the results go at the end.

## What was known

`kernel/hp-wmi-8d24/patches/report-pwm1-enable-auto.txt`, and the incident in
`usage.md`, give the symptom:

* `pwm1_enable = 2` leaves the fans at 0 RPM under load. The CPU went from
  78 to 85 °C in twelve seconds, and in another case from 81 to 98 °C.
* The firmware seems to take over eventually. omen-space writes 120 to EC
  `0x63` and warns that the handover can take two minutes.

The report ended with two open questions. Both now have answers below.

## The mechanism

Three firmware commands are involved, all in group `0x20008`.

**GM `0x10` keeps software in charge.** In the DSDT it does one thing: it sets
`OMCC` (EC `0x62` bit 0) and returns 2, the fan count. Mainline hp-wmi
describes the effect in a comment:

> calling [it] also enables and/or maintains the laptop in user defined
> thermal and fan states, instead of using a fallback state. After a 120
> seconds timeout however, the laptop goes back to its fallback state.

The vendor software treats it the same way. The Hub's `RunHeartbeatLoop`
calls it (`GetNumOfFan`) every 30 s, on a highest-priority thread, from login
until logout. hp-wmi calls it every 90 s (`KEEP_ALIVE_DELAY_SECS`), but only
in manual and max modes.

EC `0x63` is not declared anywhere in the DSDT. Whatever counts down the 120
seconds lives inside the EC firmware.

**GM `0x2E` writes the setpoint.** It writes `SRP1`/`SRP2` (EC `0x34`/`0x35`),
in hundreds of RPM. While software is in charge, the EC drives exactly that
value. A setpoint of 0 means stopped.

**GM `0x1A`, byte 2, hands the fans to the firmware.** Phase 1 named the bit
behind it, `FAMC` (EC `0x51` bit 0), "fan manual control", and so expected
1 to mean manual. The Hub's own code says the opposite. Its `SetFanMode`
builds:

```
{ 0xFF, mode, Convert.ToByte(fanControlByBios), 0 }
```

So 1 means "the BIOS drives the fans". The Hub sends 0 every time it sets a
mode. It sends 1 in only one case: on battery, in Auto, on a platform whose
configuration says `IsBiosAutoFanControlInDcSupport`. On 8D24 its log says
`IsBiosAutoFanControlInDcSupport = False`. On this board, then, the Hub never
hands the fans to the BIOS. Its software curve runs the whole time, which
matches Phase 1 §6.4.

## Why "automatic" stops the fans

hp-wmi's `PWM_MODE_AUTO` does three things, in this order:

1. calls GM `0x10`, which **renews** the user-defined state;
2. switches max fan off;
3. writes setpoint **0, 0**.

Then it cancels its keep-alive. The EC is left in the user-defined state with
a setpoint of zero, and it obeys: 0 RPM. Its own curve only takes over 120
seconds after step 1, when the user-defined state times out. That is the two
minutes omen-space describes, and the twelve seconds of stopped fans were
simply inside that window.

So the EC is not refusing to take control. hp-wmi tells it to keep stopped
fans for another two minutes.

## Corrections to earlier notes

* **`FAMC` is "fan control by BIOS", not "fan manual control".** Phase 1 §3.3
  and §6.1 read it the other way round. The observation there still holds:
  the Hub always sends 0. The meaning of that 0 is "software is in control".
* **GM `0x2F` is a speed-to-noise table, not the EC's curve.** `P1F1`/`P1F2`/
  `P1DB` hold fan 1 speed, fan 2 speed and dB, 11 entries each: 1800-4800
  RPM, 22-50 dB. hp-wmi already reads it when it probes `omen_v1_legacy`
  boards, and that is where its 1800-4800 RPM range comes from. The Hub uses
  it to pick fan 2's speed for a given fan 1 speed. The method asks for 17
  entries from 11-byte buffers. This is not an error: storing into a named
  buffer keeps the target's size and zero-fills, and hp-wmi stops at the
  first all-zero row.

## What would hand the fans back properly

Two candidates, depending on what the measurement says.

**(a) Stop renewing, and do not write zero.** Leave the last real setpoint
in place, stop calling GM `0x10`, and let the user-defined state time out.
The fans never stop: they hold the last speed until the EC's curve takes
over. Within hp-wmi this would mean `PWM_MODE_AUTO` skips the GM `0x10`
call and the 0,0 write. That is a small, upstreamable change, but the
handover is up to 120 s late.

**(b) Ask the firmware directly.** GM `0x1A` with the profile in force and
byte 2 set to 1, the call the Hub makes on platforms where it does this. If
8D24's EC honours it, the handover is immediate. The Hub not using it here
is the reason to measure before trusting it.

For omend the order is the same either way. Its exit path keeps forcing
full power when the machine is hot. A real handover would replace pwm 0 /
full power on exit only once it has been measured to work.

## The measurement

`sudo bash kernel/omen-kbd-rgb/probe-handover.sh`, about seven minutes, with
a CPU load running throughout. It is stopped at 90 °C, or when both fans
read zero at 75 °C or above.

* **A** unloads hp-wmi while it holds 2400 RPM: no GM `0x10`, no setpoint
  writes. If the fans change speed with the load inside 120 s, that is the
  fallback curve, and the time is the timeout.
* **B** holds 1800 RPM through hp-wmi, then sets `fan_bios_control` (GM `0x1A`
  byte 2). If the fans rise with the load straight away, (b) works.

Both print omen-kbd-rgb's new `fan_state` (debugfs, read only) every two
seconds: `FAMC`, `OMCC`, the raw `0x63`, both setpoints, `HPCM`, and the max
fan flags. If `0x63` counts down, that is the timer.

### Results

*Not yet run.*
