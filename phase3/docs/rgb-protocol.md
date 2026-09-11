# 4-Zone RGB Keyboard Protocol (8D24)

Source: `phase1/extract/GM-LM-methods.asl` and `HWMC.asl` — all of it from the
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
| `0x02` | LM02 | read zone colours |
| `0x03` | LM03 | write zone colours |
| `0x04` | LM04 | read brightness |
| `0x05` | LM05 | write brightness |

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

### LM05 — writing brightness

```
LBRT = WBUF[0]
LCMC = One
```

A single byte. The dead assignment in LM04 (`Local1 = 0x64`) gives away that
the scale is **0–100**.

## 3. EC fields

From `phase1/extract/ec-h2ra-field.asl` — the memory-mapped extended EC RAM at
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

## 5. Turning the lighting on belongs to the firmware — measured (2026-09-11)

Writing `LRGB`/`LBRT` does **not** switch the lighting on. With the keyboard
dark, the colours still land in the registers and read back correctly, but
nothing lights up. Pressing `Fn+F4` brings the lights up showing exactly the
colours we wrote.

One candidate was ruled out: `KBBL` (EC `0x42` bit 4) read back as zero **while
the lights were on** (`0x42 = 0x04`), so it does not track the backlight state.

The WMI lighting group has no on/off either — `LM06`–`LM0B` are empty stubs
returning `Package { Zero, Zero }`. The five bits before `LCMC` (`0xEE0` bits
0–4) are unnamed; one of them might be it, but the DSDT does not say, and that
region is in H2RA (`0xFE700000 + 0xEE0`), unreachable from userspace.

**Conclusion:** the master switch is internal EC state, driven by `Fn+F4`. The
driver controls colour and brightness; the firmware controls on/off. This is a
hardware limit rather than a gap in the driver — but it has to be stated, or a
user will write a colour, see nothing, and blame the driver.

### The state is visible after all — `0xEE1`

Dumping the lighting block of the extended EC RAM with the backlight off and
then on, and diffing, gave exactly one difference:

```
off:  00 00 00 | ff ff ff ff ff ff ff ff ff ff ff ff | 00 ...
on:   00 64 00 | ff ff ff ff ff ff ff ff ff ff ff ff | 00 ...
         ^^ 0xEE1
```

`0xEE1` reads `0x64` (100 — exactly the brightness that had been set) while the
keyboard is lit, and `0x00` while it is dark. The colours read `0xff`
throughout, which is precisely why writing them always looked like it had
worked.

**The DSDT does not declare this byte.** The field list defines one byte at
`0xEE0` and then jumps straight to `0xEE3`, leaving `0xEE1` and `0xEE2`
unnamed. That is why three earlier searches came up empty — the standard EC
window, the WMI lighting group, and a byte-by-byte diff of EC `0x40-0x4F`.
All of them looked at declared fields; this one lives in the gap between them.

It holds the brightness **in effect**, not the brightness requested: with the
backlight off it reads 0 even though `LBRT` had been set to 100. The EC zeroes
it while the lighting is off and applies the stored value when it comes back.

So the driver can now answer "is the keyboard actually lit", which it could not
before. `omen-kbd-rgb` exposes it as
`/sys/devices/platform/omen-kbd-rgb/backlight_active`, and the UI says so
instead of guessing from brightness. Turning it *on* is still `Fn+F4`; writing
to this byte has not been attempted.

## 6. Brightness is applied in software, not by `LBRT`

`LBRT` does not dim this keyboard. Writing it succeeds and reads back
correctly, and nothing changes — the same trap as the on/off switch.

`OmenLinux/omen-rgb-keyboard` confirms it by omission: its brightness path never
writes `LBRT` at all. It scales the stored colours by `level / 100` and rewrites
the zones, and its `brightness_get` returns its own variable rather than the
hardware. A driver that works across several OMEN models having taken that
route is strong evidence that `LBRT` is inert for dimming.

`omen-kbd-rgb` does the same: changing brightness rewrites all four zones as
`intensity * global / 100`. Two details matter:

* Scaling always starts from the **stored** intensity, never from what is
  currently on the wire — otherwise dimming twice in a row would compound and
  the colour would drift towards black.
* At probe the colours on the wire are already scaled, so brightness is read
  first and the colours are scaled back up to recover the intent. Without that,
  reloading the module at 50 % would halve them again.

`LBRT` is still written, because it is the firmware's own field and OMEN Gaming
Hub sets it. If a board ever turns up where it does dim, that combination would
over-dim, and this is where to look.


## 7. No conflict with `hp-wmi`

Phase 2 established that `hp-wmi` does not *own* the GUID: it calls through
`wmi_evaluate_method` and registers itself as a `platform_driver`. The lighting
group (`0x020009`) is disjoint from the fan group (`0x020008`) and touches
different EC fields.

So this module runs **alongside** `hp-wmi`; no `blacklist hp_wmi` is required.
