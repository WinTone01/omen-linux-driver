# Upstream submission

A two-patch series against `torvalds/linux` master, with a cover letter
(`0000-cover-letter.patch`):

1. **`0001-…-Add-OMEN-16-ap0xxx-8D24-board.patch`** adds this machine's
   board to `hp_wmi_feature_boards[]`. Four lines. `checkpatch.pl --strict`
   reports 0 errors and 0 checks. The two remaining warnings are "Unknown
   commit id", which checkpatch gives for any commit reference when run
   outside a kernel tree; both hashes were checked against the real history.
2. **`0002-…-Fix-automatic-fan-mode-on-omen_v….patch`** makes
   `pwm1_enable = 2` hand the fans to the EC on `omen_v1_legacy` boards,
   instead of stopping them for up to two minutes. The setpoint written on
   return to automatic becomes a per-board parameter (`0xff` for these
   boards, the firmware's own value), and the keep-alive keeps running in
   automatic so the thermal profile survives. `checkpatch.pl --strict`:
   clean. The measurements behind it are in
   [`docs/research/ec-handover.md`](../../../docs/research/ec-handover.md).
   This is the upstream form of what `../fix-auto.sh` does to this
   project's own build.

Checked on 2026-10-09: 8D24 is still not in master, and the series applies
to it cleanly.

## Before sending: compile 0002 on the machine

`fix-auto.sh` has been run on this machine, but the upstream form of the
same change had only been compiled in isolation when it was written. Build
and try it first:

```bash
bash kernel/hp-wmi-8d24/check-series.sh          # fetch master, apply, build
bash kernel/hp-wmi-8d24/check-series.sh --load   # also load it and test auto
```

## Before sending: the Signed-off-by needs a real name

```
Signed-off-by: WinTone <mertbay295@gmail.com>
```

The kernel's Developer's Certificate of Origin requires a **real legal
name**, not a handle or a pseudonym — `Documentation/process/submitting-patches.rst`
is explicit about it, and maintainers do bounce patches over this. Edit the
`Signed-off-by:` line and the `From:` header before sending, or the patch
will not be applied no matter how good it is.

## Where it goes

From `MAINTAINERS`, X86 PLATFORM DRIVERS:

| | |
|---|---|
| To | Hans de Goede `<hansg@kernel.org>` |
| To | Ilpo Järvinen `<ilpo.jarvinen@linux.intel.com>` |
| Cc | `platform-driver-x86@vger.kernel.org` |
| Cc | `linux-kernel@vger.kernel.org` |

Run `scripts/get_maintainer.pl` against the patch in a real kernel tree
before sending — the list above was read out of `MAINTAINERS` by hand and
may have moved.

```bash
git send-email --to=hansg@kernel.org \
               --to=ilpo.jarvinen@linux.intel.com \
               --cc=platform-driver-x86@vger.kernel.org \
               --cc=linux-kernel@vger.kernel.org \
               0000-cover-letter.patch 0001-*.patch 0002-*.patch
```

The `Signed-off-by` and `From:` lines in all three files need the real
name, as above.

Its two siblings went in the same way, so the precedent is good:
`0aab31d47c2e` (8D26) and `56b7981c6f21` (8E35).

## Two findings worth reporting separately

Neither belongs in this patch — it is a four-line board addition and should
stay that way — but both affect other people's machines, and neither is
written down anywhere upstream.

### `HP_FAN_SPEED_AUTOMATIC` does not hand the fans back

**Superseded by 0002.** The mechanism has since been measured and the fix
written, so this goes upstream as a patch, not a report. What follows is
kept as the record of what was known before.

A ready-to-send report is in
[`report-pwm1-enable-auto.txt`](report-pwm1-enable-auto.txt): headers, the
measurements, how to reproduce, and the two questions only a sibling board
can answer. Put your real name at the bottom and send it as plain text.

`hp_wmi_fan_speed_reset()` writes a speed of 0 on the way back to automatic,
and the constant's name says that reverts to firmware control. On this board
it does not, at least not promptly: with `pwm1_enable = 2` the fans sat at
**0 RPM for twelve straight seconds** while the CPU climbed 78.6 → 85.5 °C
under load, and in an earlier unattended case 81 → 98 °C in seventy-six
seconds.

There does appear to be a watchdog — the omen-space project writes 120 to EC
`0x63` and warns its users that the handover to the BIOS can take up to two
minutes — so the EC probably does take over eventually. But "eventually" is
longer than it takes to overheat, and a user switching to automatic has no
way to know that.

Whether this is specific to 8D24 or affects every board using
`omen_v1_legacy` is unknown; it needs someone with a sibling board to check.

### The lighting group's brightness command is an on/off switch

Not part of hp-wmi today, but it is the same WMI interface and the mistake is
easy to repeat. Command group `0x20009`, sub-commands `0x04`/`0x05`, look
like a 0-100 brightness: the DSDT method assigns `LBRT = WBUF[0]` and the
read path has a dead `Local1 = 0x64` just before returning it.

It is a switch taking two values, `0xE4` on and `0x64` off. Writing a level
of 100 therefore sends the **off** value. Details and the measurements are in
[`docs/research/rgb-protocol.md`](../../docs/research/rgb-protocol.md) §2.

## Further out: the lighting group and the mux in hp-wmi

`omen-kbd-rgb` is the right shape for this repository and the wrong one for
upstream. It reaches the firmware through the legacy
`wmi_evaluate_method()` and creates a platform device of its own, and a
maintainer would ask why a second driver talks to the GUID hp-wmi already
uses. Moving it to the modern WMI API is not an option either: the
`5FB7F034` WMI device is bound to `hp-bioscfg`, so there is nothing left for
a `wmi_driver` to attach to.

What would be accepted is the same code inside hp-wmi, which already has the
query helper, the Omen board table and the platform device. As a series:

1. `hp-wmi: add the lighting command group` - `HPWMI_LIGHTING` (`0x20009`)
   next to `HPWMI_GM`, and LM01 as the capability check.
2. `hp-wmi: add 4-zone RGB keyboard backlight` - the multicolor LEDs, the
   on/off switch values (`0xE4`/`0x64`), the zone order, resume.
3. `hp-wmi: add the graphics mux` - through the firmware-attributes class
   with `pending_reboot`, the way asus-armoury does `gpu_mux_mode`, rather
   than as a private attribute.
4. `hp-wmi: expose the dGPU temperature` - EC `0xB7` on the Omen boards, as
   a second channel of the hwmon device hp-wmi already registers.

Each is independent of the 8D24 entry above and should follow it, not ride
with it. Until they land, `omen-kbd-rgb` keeps its name and sysfs paths:
renaming it now would move `/sys/devices/platform/omen-kbd-rgb` under
everything that reads it, for a module that is meant to disappear.
