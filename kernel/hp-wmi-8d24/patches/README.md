# Upstream submission

`0001-platform-x86-hp-wmi-Add-OMEN-16-ap0xxx-8D24-board.patch` adds this
machine's board to `hp_wmi_feature_boards[]`. It is four lines, generated
against `torvalds/linux` master, and `checkpatch.pl --strict` reports **0
errors and 0 checks**. The two remaining warnings are "Unknown commit id",
which is what checkpatch says about any commit reference when it is run
outside a kernel tree; both hashes were verified against the real history.

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
               0001-platform-x86-hp-wmi-Add-OMEN-16-ap0xxx-8D24-board.patch
```

Its two siblings went in the same way, so the precedent is good:
`0aab31d47c2e` (8D26) and `56b7981c6f21` (8E35).

## Two findings worth reporting separately

Neither belongs in this patch — it is a four-line board addition and should
stay that way — but both affect other people's machines, and neither is
written down anywhere upstream.

### `HP_FAN_SPEED_AUTOMATIC` does not hand the fans back

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
