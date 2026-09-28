# 4-Zone RGB Keyboard Protocol (8D24)

Source: `docs/acpi/extract/GM-LM-methods.asl` and `HWMC.asl` — all of it from the
DSDT. Every line here is verifiable against those files.

## 1. Transport

The **same** WMI interface as `hp-wmi`, a different command group:

| | Fan / thermal | Lighting |
|---|---|---|
| GUID | `5FB7F034-2C63-45E9-BE91-3D44E2C707E4` | same |
| `COMD` | `0x00020008` | **`0x00020009`** |
| Signature | `0x55434553` (`"SECU"`) | same |

Input buffer layout (top of `HWMC`):

```
0x00  SGIN  signature, 0x55434553
0x04  COMD  command group
0x08  CMDT  sub-command
0x0C  DSZI  data size
0x10  data  <- DSZI bytes
```

`CreateField(Arg1, 0x80, DSZI*8, DAIN)` — `0x80` is a **bit** offset, so the
data area starts at `0x10`. While `DSZI <= 0x80` the firmware does
`WBUF = DAIN`, meaning the `WBUF[n]` the methods see is input buffer
`0x10 + n`.

## 2. Sub-commands

| `CMDT` | Method | Function |
|---|---|---|
| `0x01` | LM01 | what lighting the keyboard has |
| `0x02` | LM02 | read zone colours |
| `0x03` | LM03 | write zone colours |
| `0x04` | LM04 | read backlight **on/off** |
| `0x05` | LM05 | write backlight **on/off** |

### LM01 — what the keyboard has

```
byte0 = Local1 | (Local2 << 1)
        Local1 = 1 if EC RE20 is 1 or 2, else 0     // a backlight at all
        Local2 = 3                                   // keyboard type
byte1 = EC R570                                      // meaning unknown
```

`omen-kbd-rgb` asks this at load and drives the lighting only when bit 0 is
set and the type is 3, the one LM02/LM03 implement as four RGB zones. The
module keeps no board list, so this is what stops it presenting four RGB
zones on a sibling with an unlit or single-colour keyboard.

### LM02 — reading colours

`byte0 = 3`, the 12 colour bytes at `0x19..0x24`, and zeros everywhere else.
Since LM03 reads nothing but the colours either, the driver reads the block
once at load and uses it as the template for every write, rather than
reading it back each time.

### LM03 — writing colours

```
LDAT[0..11] = WBUF[0x19 .. 0x24]        // 12 bytes
LRGB = LDAT ; Stall(15us)
BRGB = LDAT ; Stall(15us)
LCMC = One                               // commit
```

Three things stand out:

1. **The data starts at `WBUF[0x19]`** — byte 25 of the 128-byte data area,
   not at the beginning.
2. **The same 12 bytes go to two registers** (`LRGB` and `BRGB`), with a 15 µs
   stall between them.
3. **`LCMC = 1` is a commit flag** — the write alone is not enough.

`Local2 = 0x03` overrides the sub-command and pins it, so the firmware ignores
`WBUF[0]` and always performs the 12-byte zone write.

### LM04 / LM05 — an on bit over a level, of which we may only set the bit

**Corrected on 2026-09-28.** This section said the pair took two magic values,
`0xE4` on and `0x64` off. Those are the right values to *write*. As a
description of the byte they were wrong, and the mistake showed up as Fn+F4's
dim step being read as "off".

`LBRT` is bit 7 on/off plus a 0-100 level in bits 0-6: `0xE4` is
`0x80 | 100`, and `0x64` is `100` with the on bit clear. Measured by stepping
Fn+F4 and reading it back (`kernel/omen-kbd-rgb/probe-brightness.sh`, which
reads the byte through the module's debugfs file `lbrt`):

| | LBRT | EC `0xEE1` | Keyboard |
|---|---|---|---|
| start | `0xE4` | `0x64` | bright |
| Fn+F4 | `0xB2` = on \| 50 | `0x32` | dim |
| Fn+F4 | `0x00` | `0x00` | off |
| Fn+F4 | `0xE4` | `0x64` | bright |

Fn+F4 cycles bright → dim → off. The level is the firmware's own, though:

| Written with LM05 | Reads back | `0xEE1` | Keyboard |
|---|---|---|---|
| `0xE4` | `0xE4` | `0x64` | bright |
| `0xB2` | `0xB2` | `0x64` | **bright** |
| `0x94` | `0x94` | `0x64` | **bright** |
| `0x80` | `0x80` | `0x64` | **bright** |
| `0x32` | `0x32` | `0x00` | off |

A write takes effect through bit 7 alone. The level bits are stored and read
back, but they change nothing. The dim step exists, but only on the
firmware's own Fn+F4 path. `0xEE1`, not `LBRT`, is the level in force.

So the driver:

* writes `0xE4` or `0x64`, as before. Switching on through LM05 always comes
  up at the firmware's full level;
* dims by scaling the colours (§6), because the firmware's level cannot be
  set from here;
* reads the on bit as "lit" and the level as the firmware's contribution.
  After Fn+F4's dim step the keyboard shows the driver's level times 50 %,
  and that product is what the LED class reports.

The DSDT invites the wrong reading in the other direction as well. `LM05`
assigns `LBRT = WBUF[0]` and `LM04` has a dead `Local1 = 0x64`, which looks
like "a 0-100 scale". Writing a plain level there sends a value with bit 7
clear, which is off. That cost an evening on 2026-09-11. Credit for the two
write values: `hp-omen-extra.c` in the omen-space project.

## 3. EC fields

From `docs/acpi/extract/ec-h2ra-field.asl` — the memory-mapped extended EC RAM at
`0xFE700000` (Phase 1 §4.1). These are **outside** the standard EC window
(`0x00–0xFE`), so they cannot be read with `ec_sys`:

| Field | Width | Meaning |
|---|---|---|
| `LRGB` | 96 bits | 12 bytes = 4 zones × 3 |
| `BRGB` | 96 bits | second copy |
| `LBRT` | 8 bits | brightness, 0–100 |
| `LCMC` | 1 bit | commit flag |

## 4. What the DSDT does not say: byte order

The DSDT only copies bytes; which of the three is red, and what order the zones
are in, is not derivable from it. Both were established empirically.

The byte order was confirmed against
[`OmenLinux/omen-rgb-keyboard`](https://github.com/OmenLinux/omen-rgb-keyboard)
(GPL-2.0, `src/zones/omen_zones.c`) — no code was copied, only protocol
knowledge:

```
offset = 25 + zone * 3
state[offset + 0] = red
state[offset + 1] = green
state[offset + 2] = blue
```

That `25` is exactly the `0x19` we derived from the DSDT — two independent
sources pointing at the same place.

One behaviour also learned there: the write must be **read-modify-write**. The
128-byte state is first read with `0x02`, only the relevant 3 bytes are
changed, and it is written back with `0x03`. What the rest of the buffer
carries is unknown, so preserving it is the correct thing to do.

### Zone order — measured on the machine (2026-09-11)

Because the colours came out correct, the R/G/B byte order is settled. But the
**slot order is neither the same as nor the reverse of the physical order — it
is scrambled.** Determined by lighting one zone at a time:

| Hardware slot | Data offset | Physical zone |
|---|---|---|
| 0 | 25 | numpad (rightmost) |
| 1 | 28 | centre-right (JKL / Enter side) |
| 2 | 31 | **leftmost** (Esc / Tab / Caps column) |
| 3 | 34 | WASD |

At first glance it looks like a plain reversal, because slot 0 lands on the far
right and slot 3 near the left — but the middle two are swapped as well. That
first impression was misleading and a straight reversal (`{3,2,1,0}`) turned
out to be wrong; the truth only came out by lighting a single zone.

The module translates with `zone_slot[] = {2, 3, 1, 0}`, so the sysfs numbers
follow physical order:

| sysfs `zone` | Physical zone |
|---|---|
| `zone0` | leftmost |
| `zone1` | WASD |
| `zone2` | centre-right |
| `zone3` | numpad |

Left-to-right numbering also matters for the UI: something drawing a keyboard
must be able to walk the zones in order.

## 5. Turning the lighting on — LM05, once it is read correctly

**Corrected on 2026-09-11.** This section used to conclude that switching the
backlight on was firmware's business and out of the driver's reach, and that
`Fn+F4` was the only way. That was wrong, and the reasoning behind it is worth
keeping because the mistake was subtle.

The search had ruled out, correctly:

* `KBBL` (EC `0x42` bit 4) — reads the same either way
* a byte-by-byte diff of EC `0x40-0x4F` — identical in both states
* `LM06`-`LM0B` — empty stubs returning `Package { Zero, Zero }`

What it never questioned was `LM05` itself, because the DSDT made it look like
a brightness level and we were already "using" it. The switch had been in hand
the whole time; it was being sent the wrong values. See §2.

With that fixed, the driver turns the backlight on and off on its own, and
`Fn+F4` is no longer required — so the desktop's keyboard-light keys and
`brightnessctl` work too.

### The state is also visible in the extended EC RAM — `0xEE1`

Found while hunting for the switch, and still useful as an independent check.
Dumping the lighting block of the extended EC RAM with the backlight off and
then on gave exactly one difference:

```
off:  00 00 00 | ff ff ff ff ff ff ff ff ff ff ff ff | 00 ...
on:   00 64 00 | ff ff ff ff ff ff ff ff ff ff ff ff | 00 ...
         ^^ 0xEE1
```

`0xEE1` reads non-zero while the keyboard is lit and `0x00` while it is dark.
It is the level in force: `0x64` bright, `0x32` after Fn+F4's dim step
(§2).
The colours read `0xff` throughout, which is precisely why writing them always
looked like it had worked.

**The DSDT does not declare this byte.** The field list defines one byte at
`0xEE0` and then jumps straight to `0xEE3`, leaving `0xEE1` and `0xEE2`
unnamed. Every search above looked at declared fields; this one lives in the
gap between them.

`omen-kbd-rgb` maps the block read-only and exposes it in debugfs as
`/sys/kernel/debug/omen-kbd-rgb/lighting_regs` - on 8D24 only, because the
address is this board's `OperationRegion H2RA`, and on another board the same
address belongs to something else. The logical state comes from LM04, which
needs no `ioremap` and is the more portable of the two.

### Fn+F4

The firmware flips the switch on Fn+F4 by itself. If it raises a WMI event
for it, that goes to `hp-wmi`, which owns the event GUID and has a case for
`0x0D` (`HPWMI_BACKLIT_KB_BRIGHTNESS`) that does nothing - whether this
machine sends it at all has not been measured. Either way this module cannot
listen for it.
Instead it asks LM04 every two seconds (module parameter `poll_ms`) and
reports a change through the LED class's `brightness_hw_changed`, which is
what desktop on-screen indicators follow.

## 6. Brightness is the driver's, not the hardware's

The hardware switch is binary, so every level in between is produced by
scaling the colours before they are written:

```
slot = intensity * level / 100
```

`OmenLinux/omen-rgb-keyboard` does the same, and its `brightness_get` returns
its own variable rather than asking the hardware — which is the only honest
answer when the hardware does not store a level.

Two details matter:

* Scaling always starts from the **stored** intensity, never from what is
  currently on the wire — otherwise dimming twice in a row would compound and
  the colour would drift towards black.
* The level is applied even while the switch is off. Scaling by 0 would store
  black in the firmware, and the next Fn+F4 would light a black keyboard.
* The level cannot be recovered at load. The firmware holds the scaled bytes
  and an on/off switch, nothing else, so after a reload at 50 % the colours
  read back at half and are taken as they are. An earlier version claimed to
  scale them back up, but it divided by the level it had just assumed to be
  100, which changes nothing. omend remembers the level with the colours and
  restores both when it starts.

Level 0 is not "scale everything to black": it switches the backlight off with
LM05, which is what the user means and what leaves the machine in the state
the firmware understands.


## 7. No conflict with `hp-wmi`

Phase 2 established that `hp-wmi` does not *own* the GUID: it calls through
`wmi_evaluate_method` and registers itself as a `platform_driver`. The lighting
group (`0x020009`) is disjoint from the fan group (`0x020008`) and touches
different EC fields.

So this module runs **alongside** `hp-wmi`; no `blacklist hp_wmi` is required.
