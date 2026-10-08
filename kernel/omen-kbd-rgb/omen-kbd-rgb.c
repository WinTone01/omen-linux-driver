// SPDX-License-Identifier: GPL-2.0-only
/*
 * HP OMEN extras that in-tree hp-wmi does not cover: the 4-zone RGB keyboard,
 * the graphics mux, the discrete GPU's temperature, the surface temperature,
 * and the power controls the vendor software uses beyond the three thermal
 * profiles - Unleashed, PL1 and the CPU+GPU shared limit. Measured on the
 * OMEN 16-ap0xxx (board 8D24).
 *
 * Protocol: docs/research/rgb-protocol.md - all of it extracted from the DSDT.
 *
 * Fans and thermals are hp-wmi's job (0x020008); this module uses the
 * lighting command group (0x020009) plus two mux commands. Both drivers talk
 * to the same WMI GUID through the legacy wmi_evaluate_method() interface,
 * and neither can do otherwise: the GUID's WMI device is bound to hp-bioscfg,
 * so there is no device left for a wmi_driver to attach to. That is also why
 * this module creates its own platform device instead of being probed by the
 * WMI bus. The groups are disjoint, so the modules run side by side and
 * hp_wmi does not need blacklisting.
 *
 * Copyright (C) 2026 WinTone
 */

#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

#include <linux/acpi.h>
#include <linux/debugfs.h>
#include <linux/dmi.h>
#include <linux/hwmon.h>
#include <linux/ktime.h>
#include <linux/led-class-multicolor.h>
#include <linux/leds.h>
#include <linux/module.h>
#include <linux/mutex.h>
#include <linux/pci.h>
#include <linux/platform_device.h>
#include <linux/pm.h>
#include <linux/seq_file.h>
#include <linux/wmi.h>
#include <linux/workqueue.h>

#define HPWMI_BIOS_GUID		"5FB7F034-2C63-45e9-BE91-3D44E2C707E4"
#define HPWMI_SIGNATURE		0x55434553	/* "SECU" */
#define HPWMI_LIGHTING		0x00020009

/*
 * The graphics mux.
 *
 * Three command groups are involved, which is why the helper takes the group
 * rather than assuming lighting:
 *
 *   0x00020008 / 0x28  - system design data. 64 bytes; byte 7 is a bitmask of
 *                        the mux modes this machine supports. On 8D24 the
 *                        firmware computes it as BIT(0)|BIT(1)|BIT(2) - UMA,
 *                        hybrid and discrete - which is visible in the DSDT's
 *                        GM28 method, so the answer is known before asking.
 *   0x00000001 / 0x52  - read the current mode (BIOS read, GDSS).
 *   0x00000002 / 0x52  - set it (BIOS write, SDSS). The firmware re-wires the
 *                        panel at the next boot; nothing changes until then.
 */
#define HPWMI_GAMING		0x00020008
#define HPWMI_BIOS_READ		0x00000001
#define HPWMI_BIOS_WRITE	0x00000002
#define OMEN_DESIGN_DATA	0x28
#define OMEN_GRAPHICS_MUX	0x52
#define DESIGN_DATA_LEN		64
#define DESIGN_MUX_BYTE		7

/*
 * Mode numbering as the firmware uses it, and as OMEN Gaming Hub writes it.
 * The bit in the supported mask and the value written are different things:
 * the mask is a bitmask, the value is this index.
 */
enum omen_mux_mode {
	OMEN_MUX_HYBRID		= 0,
	OMEN_MUX_DISCRETE	= 1,
	OMEN_MUX_OPTIMUS	= 2,
	OMEN_MUX_UMA		= 3,
};

static const char * const omen_mux_names[] = {
	[OMEN_MUX_HYBRID]	= "hybrid",
	[OMEN_MUX_DISCRETE]	= "discrete",
	[OMEN_MUX_OPTIMUS]	= "optimus",
	[OMEN_MUX_UMA]		= "uma",
};

/* Which bit of the supported mask belongs to each mode above. */
static const u8 omen_mux_bit[] = {
	[OMEN_MUX_HYBRID]	= BIT(1),
	[OMEN_MUX_DISCRETE]	= BIT(2),
	[OMEN_MUX_OPTIMUS]	= BIT(3),
	[OMEN_MUX_UMA]		= BIT(0),
};

/*
 * What this machine has, decided in module init before the device exists,
 * because the attribute group's visibility is settled when it is added.
 */
static bool omen_has_lighting;
/* Zero means no mux, and the mux attributes are not created. */
static u8 omen_mux_supported;
/* The mode the firmware reported when the module loaded; -1 if unknown. */
static int omen_mux_at_load = -1;
static bool omen_has_dgpu_temp;
/* GM21/GM22 answer and there is an NVIDIA GPU for them to be about. */
static bool omen_has_gpu_power;
/* EC 0x48 holds a believable skin temperature - see omen_surface_detect. */
static bool omen_has_surface_temp;
/* Unleashed and PL1: 8D24, whose DSDT these were read out of. */
static bool omen_has_power_limits;
/* The shared CPU+GPU limit: as above, and the firmware reports one. */
static bool omen_has_tpp;

enum lighting_query {
	LIGHTING_CAPS		= 0x01,	/* LM01 */
	LIGHTING_COLOR_GET	= 0x02,	/* LM02 */
	LIGHTING_COLOR_SET	= 0x03,	/* LM03 */
	LIGHTING_BRIGHT_GET	= 0x04,	/* LM04 */
	LIGHTING_BRIGHT_SET	= 0x05,	/* LM05 */
};

/*
 * LM01 answers what kind of keyboard lighting the machine has, in byte 0:
 * bit 0 says there is a backlight at all (the firmware derives it from EC
 * RE20), and the bits above it are the keyboard type. 8D24's firmware
 * reports type 3, the one LM02/LM03 implement as four zones of RGB.
 *
 * Asked rather than assumed: the module keeps no board list, and a machine of
 * the same family with a single-colour or unlit keyboard answers the rest of
 * the lighting group too. Presenting four RGB zones there would be a lie.
 */
#define LIGHTING_CAPS_PRESENT	BIT(0)
#define LIGHTING_CAPS_TYPE(b)	((b) >> 1)
#define KBD_TYPE_FOUR_ZONE	3

#define ZONE_COUNT		4
#define COLORS_PER_ZONE		3
/*
 * LM03: LDAT[0..11] = WBUF[0x19..0x24]. The colours sit 25 bytes into the
 * 128-byte data area, not at its start.
 */
#define ZONE_DATA_OFFSET	0x19
#define STATE_SIZE		128
/* Software brightness, applied by scaling the colours. */
#define BRIGHTNESS_MAX		100

/*
 * LBRT, read by LM04 and written by LM05: bit 7 is on/off, bits 0-6 a level.
 *
 * Measured on 8D24 (2026-09-28) by stepping Fn+F4 and reading it back:
 *
 *   0xE4 = on | 100   bright     (EC 0xEE1 = 0x64)
 *   0xB2 = on |  50   dim        (EC 0xEE1 = 0x32)
 *   0x00              off        (EC 0xEE1 = 0x00)
 *
 * and round again. The level is the firmware's own, though: written through
 * LM05, only bit 7 takes effect. 0xB2, 0x94 and 0x80 all read back as
 * written and all light the keyboard at full, with 0xEE1 staying at 0x64. So
 * this driver writes on or off and dims by scaling the colours, and reads the
 * level only to know what Fn+F4 has done.
 *
 * Treating the byte as the two values 0xE4 and 0x64 - which is what this
 * driver did until the measurement - took Fn+F4's dim step for "off".
 */
#define LBRT_ON			BIT(7)
#define LBRT_LEVEL		GENMASK(6, 0)
#define LIGHTING_ON		(LBRT_ON | 100)
#define LIGHTING_OFF		100

/*
 * sysfs zone number -> hardware slot.
 *
 * The slot order is neither the same as nor the reverse of the physical
 * order; it is scrambled. Measured by lighting one zone at a time
 * (2026-09-11):
 *
 *   slot 0 (offset 25) -> numpad, rightmost
 *   slot 1 (offset 28) -> centre-right (JKL / Enter side)
 *   slot 2 (offset 31) -> LEFTMOST     (Esc / Tab / Caps column)
 *   slot 3 (offset 34) -> WASD
 *
 * Users expect zone0 to be the left-hand one (reading order), and a UI that
 * draws a keyboard needs the numbers to follow physical order. Hence the
 * translation here:
 *
 *   zone0 = leftmost, zone1 = WASD, zone2 = centre-right, zone3 = numpad
 */
static const u8 zone_slot[] = { 2, 3, 1, 0 };

static_assert(ARRAY_SIZE(zone_slot) == ZONE_COUNT,
	      "zone_slot does not match ZONE_COUNT");

/*
 * How often to look for Fn+F4.
 *
 * The firmware steps the backlight through bright, dim and off on that key
 * by itself (see LBRT above). Any WMI
 * event it raises goes to hp-wmi, which owns the event GUID and drops
 * HPWMI_BACKLIT_KB_BRIGHTNESS, so this driver cannot hear it. Asking LM04 is
 * one EC read, cheap enough at this rate, and it is what lets the LED class
 * report the change through brightness_hw_changed so the desktop's OSD
 * follows.
 */
static unsigned int poll_ms = 2000;
module_param(poll_ms, uint, 0444);
MODULE_PARM_DESC(poll_ms,
		 "How often to check whether Fn+F4 switched the backlight, in ms (0 = never)");

struct bios_args {
	u32 signature;
	u32 command;
	u32 commandtype;
	u32 datasize;
	u8 data[];
};

struct bios_return {
	u32 sigpass;
	u32 return_code;
};

struct omen_rgb {
	struct device *dev;
	/* Guards the fields below and keeps each WMI sequence indivisible. */
	struct mutex lock;
	/*
	 * LM02's answer, read once at probe and used as the template for every
	 * LM03. The DSDT shows the firmware fills nothing but byte 0 (the
	 * keyboard type) and the 12 colour bytes, and that LM03 ignores all but
	 * the colours, so the colours are all that ever change - there is no
	 * need to read the block back before every write.
	 */
	u8 state[STATE_SIZE];
	/*
	 * The dimming, 1-100. Kept while the backlight is off, so that switching
	 * it back on - from here or with Fn+F4 - returns to the same level.
	 */
	u8 level;
	/*
	 * The firmware's own level as last seen: 0 when off, 100 normally, 50
	 * after Fn+F4's dim step. What the keyboard shows is level * hw / 100.
	 */
	u8 hw;
	struct led_classdev kbd_bl;
	struct led_classdev_mc zone[ZONE_COUNT];
	struct mc_subled subled[ZONE_COUNT][COLORS_PER_ZONE];
	char zone_name[ZONE_COUNT][32];
	/* Zone writes, coalesced - see omen_zone_set(). */
	struct delayed_work zone_work;
	/*
	 * How many LM03 calls there have been, and how long they took - for
	 * finding out what frame rate the firmware can actually take (debugfs
	 * zone_stats). Under the lock, like the writes they measure.
	 */
	u64 zone_writes;
	u64 zone_ns_total;
	u64 zone_ns_max;
	struct delayed_work poll_work;
	/* The extended EC RAM lighting block, 8D24 only - see debugfs below. */
	void __iomem *h2ra;
	/* The fan tachometers in the same RAM, 8D24 only - see omen_hwmon_read. */
	void __iomem *fans;
	struct dentry *debugfs;
};

/*
 * Arg0 SELECTS the output buffer size (Phase 1 §2): 1->0, 2->4, 3->128,
 * 4->1024, 5->4096. Same mapping as hp-wmi.
 */
static int encode_outsize_for_pvsz(int outsize)
{
	if (outsize > 4096)
		return -EINVAL;
	if (outsize > 1024)
		return 5;
	if (outsize > 128)
		return 4;
	if (outsize > 4)
		return 3;
	if (outsize > 0)
		return 2;
	return 1;
}

/*
 * Returns 0 or a negative errno - never the firmware's own code, which is
 * positive and would otherwise leak to callers that pass it on as if it were
 * an errno. The firmware's code is logged at debug level: this runs at load
 * on every HP whose firmware has the GUID, and on most of those the answer
 * is a perfectly normal "not supported".
 */
static int omen_wmi_call(u32 command, int query, void *buffer, int insize,
			 int outsize)
{
	struct acpi_buffer input, output = { ACPI_ALLOCATE_BUFFER, NULL };
	struct bios_return *bios_return;
	union acpi_object *obj = NULL;
	struct bios_args *args = NULL;
	int mid, actual_insize, actual_outsize;
	acpi_status status;
	size_t args_size;
	int ret;

	mid = encode_outsize_for_pvsz(outsize);
	if (mid < 0)
		return mid;

	/* The firmware always expects a data area of at least 128 bytes. */
	actual_insize = max(insize, 128);
	args_size = struct_size(args, data, actual_insize);
	args = kzalloc(args_size, GFP_KERNEL);
	if (!args)
		return -ENOMEM;

	input.length = args_size;
	input.pointer = args;

	args->signature = HPWMI_SIGNATURE;
	args->command = command;
	args->commandtype = query;
	args->datasize = insize;
	if (insize)
		memcpy(args->data, buffer, insize);

	status = wmi_evaluate_method(HPWMI_BIOS_GUID, 0, mid, &input, &output);
	if (ACPI_FAILURE(status)) {
		pr_debug("command 0x%x query 0x%x: %s\n", command, query,
			 acpi_format_exception(status));
		ret = -EIO;
		goto out_free;
	}

	obj = output.pointer;
	if (!obj) {
		ret = -EINVAL;
		goto out_free;
	}
	if (obj->type != ACPI_TYPE_BUFFER) {
		pr_warn_ratelimited("query 0x%x returned an invalid object (type %d)\n",
				    query, obj->type);
		ret = -EINVAL;
		goto out_free;
	}
	if (obj->buffer.length < sizeof(*bios_return)) {
		ret = -EINVAL;
		goto out_free;
	}

	bios_return = (struct bios_return *)obj->buffer.pointer;
	if (bios_return->return_code) {
		pr_debug("command 0x%x query 0x%x returned error 0x%x\n",
			 command, query, bios_return->return_code);
		ret = -EIO;
		goto out_free;
	}
	ret = 0;

	if (!outsize)
		goto out_free;

	actual_outsize = min_t(int, outsize,
			       (int)(obj->buffer.length - sizeof(*bios_return)));
	if (actual_outsize < 0) {
		ret = -EINVAL;
		goto out_free;
	}
	memcpy(buffer, obj->buffer.pointer + sizeof(*bios_return),
	       actual_outsize);
	/* If the firmware gave us less than expected, zero the remainder. */
	memset(buffer + actual_outsize, 0, outsize - actual_outsize);

out_free:
	kfree(obj);
	kfree(args);
	return ret;
}

/* The lighting group, which is what most of this module uses. */
static int omen_wmi_query(int query, void *buffer, int insize, int outsize)
{
	return omen_wmi_call(HPWMI_LIGHTING, query, buffer, insize, outsize);
}

/* --- the backlight switch (LBRT) --- */

/* The firmware's level, 0-100, from LBRT: 0 whenever the switch is off. */
static int omen_backlight_read(u8 *hw)
{
	u32 data = 0;
	u8 level;
	int ret;

	ret = omen_wmi_query(LIGHTING_BRIGHT_GET, &data, sizeof(data),
			     sizeof(data));
	if (ret)
		return ret;
	if (!(data & LBRT_ON)) {
		*hw = 0;
		return 0;
	}
	/* On with no level lights at full - seen when 0x80 was written. */
	level = data & LBRT_LEVEL;
	*hw = level ? min_t(u8, level, BRIGHTNESS_MAX) : BRIGHTNESS_MAX;
	return 0;
}

/* What the keyboard shows, 0-100: our scaling times the firmware's. */
static unsigned int omen_shown(const struct omen_rgb *rgb)
{
	return rgb->level * rgb->hw / BRIGHTNESS_MAX;
}

static int omen_backlight_set(bool on)
{
	u32 data = on ? LIGHTING_ON : LIGHTING_OFF;

	return omen_wmi_query(LIGHTING_BRIGHT_SET, &data, sizeof(data), 0);
}

/* --- zone colours (LRGB) --- */

/*
 * Composes all four zones from their intended colours, scaled by the
 * remembered level, and writes them in one go.
 *
 * The scaling is done here rather than left to LBRT because LBRT does not dim
 * this keyboard - it is the on/off switch above. So brightness is applied the
 * way the colours themselves are: by scaling what we send.
 *
 * The level is used even while the backlight is off. Scaling by 0 there would
 * store black in the firmware, and the next Fn+F4 would light a black
 * keyboard; the switch is what keeps it dark, not the colours.
 */
static int omen_write_zones(struct omen_rgb *rgb)
{
	u8 state[STATE_SIZE];
	int i, c;

	lockdep_assert_held(&rgb->lock);

	memcpy(state, rgb->state, sizeof(state));
	for (i = 0; i < ZONE_COUNT; i++) {
		struct led_classdev_mc *mc = &rgb->zone[i];
		u8 *slot = state + ZONE_DATA_OFFSET +
			   zone_slot[i] * COLORS_PER_ZONE;

		/*
		 * Scaling always starts from the stored intensity, never from
		 * what is currently on the wire - otherwise dimming twice in a
		 * row would compound and the colour would drift towards black.
		 */
		led_mc_calc_color_components(mc, mc->led_cdev.brightness);
		for (c = 0; c < COLORS_PER_ZONE; c++)
			slot[c] = mc->subled_info[c].brightness * rgb->level /
				  BRIGHTNESS_MAX;
	}

	return omen_wmi_query(LIGHTING_COLOR_SET, state, sizeof(state),
			      sizeof(state));
}

static void omen_zone_work(struct work_struct *work)
{
	struct omen_rgb *rgb = container_of(to_delayed_work(work),
					    struct omen_rgb, zone_work);
	u64 took;
	ktime_t t0;
	int ret;

	guard(mutex)(&rgb->lock);
	t0 = ktime_get();
	ret = omen_write_zones(rgb);
	took = ktime_to_ns(ktime_sub(ktime_get(), t0));
	rgb->zone_writes++;
	rgb->zone_ns_total += took;
	rgb->zone_ns_max = max(rgb->zone_ns_max, took);
	if (ret)
		dev_warn_ratelimited(rgb->dev, "could not write the zone colours: %d\n",
				     ret);
}

/*
 * How long a change waits for the rest of its frame.
 *
 * One LM03 carries all four zones, but the LED class delivers them one zone
 * at a time. Started at once, the write went out with the first zone of a
 * frame, a second followed with the rest, and for that moment the keyboard
 * showed half of one frame and half of the last - visible in an effect as a
 * stutter. Four zones written back to back arrive well inside this, and a
 * few milliseconds of latency are invisible on a keyboard.
 */
#define ZONE_FRAME_MS		4

/*
 * Queues the write rather than doing it.
 *
 * Every change that arrives while the write is pending is folded into the
 * same LM03 (see ZONE_FRAME_MS). Nothing is lost by not being synchronous:
 * the LED class already defers brightness_set_blocking to a work item and
 * drops its errors, so the only difference is that four zones share one.
 */
static void omen_zone_set(struct led_classdev *cdev, enum led_brightness brightness)
{
	struct omen_rgb *rgb = dev_get_drvdata(cdev->dev->parent);

	/*
	 * The class has already stored the new brightness; the work reads it.
	 * Not re-armed while pending, so the window opens with the first zone
	 * of a frame and closes a fixed time later.
	 */
	schedule_delayed_work(&rgb->zone_work, msecs_to_jiffies(ZONE_FRAME_MS));
}

/* --- global brightness --- */

static int omen_bl_set(struct led_classdev *cdev, enum led_brightness value)
{
	struct omen_rgb *rgb = container_of(cdev, struct omen_rgb, kbd_bl);
	u8 level = min_t(unsigned int, value, BRIGHTNESS_MAX);
	int ret;

	guard(mutex)(&rgb->lock);

	/*
	 * Two separate things: the hardware switch is on/off only, and the
	 * level is ours to apply by scaling the colours. So 0 means switch the
	 * backlight off, and anything else means scale the colours and switch
	 * it on - in that order, so it does not come up at the old level first.
	 */
	if (level) {
		rgb->level = level;
		ret = omen_write_zones(rgb);
		if (ret)
			return ret;
	}

	ret = omen_backlight_set(level > 0);
	if (ret)
		return ret;
	/* Switching on through LM05 always comes up at the firmware's full. */
	rgb->hw = level ? BRIGHTNESS_MAX : 0;
	return 0;
}

/*
 * What the keyboard shows, from what this driver knows - no WMI call. Fn+F4
 * is caught by the poll below, so this is at most poll_ms out of date.
 */
static enum led_brightness omen_bl_get(struct led_classdev *cdev)
{
	struct omen_rgb *rgb = container_of(cdev, struct omen_rgb, kbd_bl);

	guard(mutex)(&rgb->lock);
	return omen_shown(rgb);
}

static void omen_poll_work(struct work_struct *work)
{
	struct omen_rgb *rgb = container_of(to_delayed_work(work),
					    struct omen_rgb, poll_work);
	unsigned int now = 0;
	bool changed = false;
	u8 hw = 0;

	/* Any step of Fn+F4's cycle, the dim one included. */
	scoped_guard(mutex, &rgb->lock) {
		if (!omen_backlight_read(&hw) && hw != rgb->hw) {
			rgb->hw = hw;
			now = omen_shown(rgb);
			changed = true;
		}
	}

	if (changed)
		led_classdev_notify_brightness_hw_changed(&rgb->kbd_bl, now);

	schedule_delayed_work(&rgb->poll_work, msecs_to_jiffies(poll_ms));
}

/*
 * Reads the colours out of the hardware at probe and reflects them into the
 * LED class.
 *
 * They are taken as the intended colours at full level. The level they were
 * written at is not recoverable - the firmware stores only the scaled bytes
 * and an on/off switch - so after a reload at 50 % the colours read back at
 * half and are kept that way. omend puts the remembered colours and level
 * back when it starts, which is where that knowledge lives.
 */
static int omen_zone_read_initial(struct omen_rgb *rgb)
{
	int ret, i, c;

	ret = omen_wmi_query(LIGHTING_COLOR_GET, rgb->state, sizeof(rgb->state),
			     sizeof(rgb->state));
	if (ret)
		return ret;

	for (i = 0; i < ZONE_COUNT; i++) {
		const u8 *slot = rgb->state + ZONE_DATA_OFFSET +
				 zone_slot[i] * COLORS_PER_ZONE;

		for (c = 0; c < COLORS_PER_ZONE; c++)
			rgb->subled[i][c].intensity = slot[c];

		/*
		 * Use the largest component as the zone's brightness: the
		 * multicolor class computes the colour as
		 * intensity * brightness / max, so writing back what we just
		 * read leaves the colour unchanged.
		 */
		rgb->zone[i].led_cdev.brightness =
			max3(rgb->subled[i][0].intensity,
			     rgb->subled[i][1].intensity,
			     rgb->subled[i][2].intensity);
	}
	return 0;
}

/*
 * 1 when the keyboard is actually lit, 0 when it is dark. Asks the firmware
 * rather than the cache, so it is right even between two polls.
 */
static ssize_t backlight_active_show(struct device *dev,
				     struct device_attribute *attr, char *buf)
{
	u8 hw;
	int ret;

	ret = omen_backlight_read(&hw);
	if (ret)
		return ret;
	return sysfs_emit(buf, "%d\n", hw > 0);
}
static DEVICE_ATTR_RO(backlight_active);

/* --- graphics mux --- */

/*
 * Which modes this machine's firmware says it supports.
 *
 * Asked once, at load. It cannot change while the machine is running - it
 * describes how the panel is wired - and the query is not free.
 */
static u8 omen_mux_read_supported(void)
{
	u8 buffer[DESIGN_DATA_LEN] = {};
	int ret;

	ret = omen_wmi_call(HPWMI_GAMING, OMEN_DESIGN_DATA, buffer, 0,
			    sizeof(buffer));
	if (ret) {
		pr_debug("system design data unavailable (%d)\n", ret);
		return 0;
	}
	return buffer[DESIGN_MUX_BYTE];
}

static int omen_mux_get(u8 *mode)
{
	u8 buffer[4] = {};
	int ret;

	ret = omen_wmi_call(HPWMI_BIOS_READ, OMEN_GRAPHICS_MUX, buffer,
			    sizeof(buffer), sizeof(buffer));
	if (ret)
		return ret;

	/* The top bit is a BIOS status flag rather than part of the mode. */
	*mode = buffer[0] & GENMASK(6, 0);
	return 0;
}

static int omen_mux_set(u8 mode)
{
	u8 buffer[4] = { mode, 0, 0, 0 };

	return omen_wmi_call(HPWMI_BIOS_WRITE, OMEN_GRAPHICS_MUX, buffer,
			     sizeof(buffer), sizeof(buffer));
}

static ssize_t gpu_mux_supported_show(struct device *dev,
				      struct device_attribute *attr, char *buf)
{
	int i, n = 0;

	for (i = 0; i < ARRAY_SIZE(omen_mux_names); i++) {
		if (omen_mux_supported & omen_mux_bit[i])
			n += sysfs_emit_at(buf, n, "%s%s", n ? " " : "",
					   omen_mux_names[i]);
	}
	return n + sysfs_emit_at(buf, n, "\n");
}
static DEVICE_ATTR_RO(gpu_mux_supported);

/*
 * The mode the firmware is set to - the one the next boot will use.
 *
 * Writing asks it to change, which takes effect at the next boot: the panel
 * is re-wired by the firmware during POST, not by this driver. Nothing about
 * the running system changes when this is written; gpu_mux_pending_reboot
 * says so.
 */
static ssize_t gpu_mux_mode_show(struct device *dev,
				 struct device_attribute *attr, char *buf)
{
	u8 mode;
	int ret;

	ret = omen_mux_get(&mode);
	if (ret)
		return ret;

	if (mode < ARRAY_SIZE(omen_mux_names) && omen_mux_names[mode])
		return sysfs_emit(buf, "%s\n", omen_mux_names[mode]);
	/*
	 * A mode we have no name for is still worth reporting as a number
	 * rather than as an error - it is what the firmware said.
	 */
	return sysfs_emit(buf, "%u\n", mode);
}

static ssize_t gpu_mux_mode_store(struct device *dev,
				  struct device_attribute *attr,
				  const char *buf, size_t count)
{
	int mode, ret;

	mode = sysfs_match_string(omen_mux_names, buf);
	if (mode < 0)
		return mode;

	/*
	 * Refused rather than attempted when the firmware did not declare it.
	 * Sending a mux command to a machine that has no mux is how other
	 * drivers have produced ACPI faults, and there is nothing to gain by
	 * finding out the hard way.
	 */
	if (!(omen_mux_supported & omen_mux_bit[mode]))
		return -EOPNOTSUPP;

	ret = omen_mux_set(mode);
	if (ret)
		return ret;

	dev_info(dev, "graphics mux set to %s; it takes effect at the next boot\n",
		 omen_mux_names[mode]);
	return count;
}
static DEVICE_ATTR_RW(gpu_mux_mode);

/*
 * 1 when the mode the firmware is set to differs from the one it reported
 * when this module loaded - that is, a switch is waiting for a reboot.
 *
 * The same idea as pending_reboot in the firmware-attributes class. The
 * firmware only stores the next mode, not the one in force, so the module's
 * load is the reference point: it loads at boot, and if it is reloaded after
 * a switch the pending state is forgotten rather than guessed.
 */
static ssize_t gpu_mux_pending_reboot_show(struct device *dev,
					   struct device_attribute *attr,
					   char *buf)
{
	u8 mode;
	int ret;

	if (omen_mux_at_load < 0)
		return -ENODATA;

	ret = omen_mux_get(&mode);
	if (ret)
		return ret;
	return sysfs_emit(buf, "%d\n", mode != omen_mux_at_load);
}
static DEVICE_ATTR_RO(gpu_mux_pending_reboot);

/* --- discrete GPU power: cTGP and Dynamic Boost --- */

/*
 * The four bytes GM21 returns and GM22 takes, in the layout hp-wmi uses for
 * the Victus S boards (struct victus_gpu_power_modes) - and the one this
 * board's DSDT implements:
 *
 *   byte 0  cTGP       GM21 returns WMID.CTGP; GM22 stores it there
 *   byte 1  PPAB       Dynamic Boost: GM22 writes NPCF.DBAC = !byte1 and
 *                      notifies the NVIDIA platform controller (NPCF, 0xC0)
 *   byte 2  D-state    GM21 reads EC R910; GM22 notifies the GPU with
 *                      0xD0 | byte2 (1 = full power, 2 = 50 %, ...)
 *   byte 3  slowdown   GPST, the GPU's slowdown temperature
 *
 * Only the first two are offered. The other two are read back and written
 * unchanged, as hp-wmi does: a D-state or slowdown temperature nobody asked
 * for would be a way to throttle the GPU by accident.
 *
 * What cTGP does on 8D24 is not visible from here. GM22 stores it in a name
 * that nothing else in the DSDT reads; if the NVIDIA platform controller
 * consumes it, that happens in an SSDT this repository does not have. It is
 * offered because the vendor software and hp-wmi both set it with the
 * profile, not because its effect has been measured.
 */
#define OMEN_GPU_POWER_GET	0x21
#define OMEN_GPU_POWER_SET	0x22
#define GPU_POWER_LEN		4
#define GPU_POWER_CTGP		0
#define GPU_POWER_PPAB		1

static DEFINE_MUTEX(omen_gpu_power_lock);

static int omen_gpu_power_get(u8 modes[GPU_POWER_LEN])
{
	return omen_wmi_call(HPWMI_GAMING, OMEN_GPU_POWER_GET, modes, 0,
			     GPU_POWER_LEN);
}

static int omen_gpu_power_set_one(int byte, bool on)
{
	u8 modes[GPU_POWER_LEN];
	int ret;

	guard(mutex)(&omen_gpu_power_lock);

	/* Read-modify-write: only the byte asked about changes. */
	ret = omen_gpu_power_get(modes);
	if (ret)
		return ret;
	modes[byte] = on;
	return omen_wmi_call(HPWMI_GAMING, OMEN_GPU_POWER_SET, modes,
			     GPU_POWER_LEN, 0);
}

static ssize_t omen_gpu_power_show(int byte, char *buf)
{
	u8 modes[GPU_POWER_LEN];
	int ret;

	ret = omen_gpu_power_get(modes);
	if (ret)
		return ret;
	return sysfs_emit(buf, "%d\n", !!modes[byte]);
}

static ssize_t omen_gpu_power_store(int byte, const char *buf, size_t count)
{
	bool on;
	int ret;

	ret = kstrtobool(buf, &on);
	if (ret)
		return ret;
	ret = omen_gpu_power_set_one(byte, on);
	return ret ? ret : count;
}

static ssize_t gpu_ctgp_show(struct device *dev,
			     struct device_attribute *attr, char *buf)
{
	return omen_gpu_power_show(GPU_POWER_CTGP, buf);
}

static ssize_t gpu_ctgp_store(struct device *dev,
			      struct device_attribute *attr,
			      const char *buf, size_t count)
{
	return omen_gpu_power_store(GPU_POWER_CTGP, buf, count);
}
static DEVICE_ATTR_RW(gpu_ctgp);

/*
 * Dynamic Boost: the GPU may borrow power the CPU is not using. The driver
 * side of it is nvidia-powerd; without that daemon running, this switch is
 * accepted and changes nothing.
 */
static ssize_t gpu_ppab_show(struct device *dev,
			     struct device_attribute *attr, char *buf)
{
	return omen_gpu_power_show(GPU_POWER_PPAB, buf);
}

static ssize_t gpu_ppab_store(struct device *dev,
			      struct device_attribute *attr,
			      const char *buf, size_t count)
{
	return omen_gpu_power_store(GPU_POWER_PPAB, buf, count);
}
static DEVICE_ATTR_RW(gpu_ppab);

/*
 * GM21's reply cannot tell "cTGP off" from "no NVIDIA GPU" - both are zeros -
 * so the GPU is looked for on the PCI bus instead.
 */
static bool omen_nvidia_gpu_present(void)
{
	struct pci_dev *pdev = NULL;

	while ((pdev = pci_get_device(PCI_VENDOR_ID_NVIDIA, PCI_ANY_ID, pdev))) {
		if ((pdev->class >> 16) == PCI_BASE_CLASS_DISPLAY) {
			pci_dev_put(pdev);
			return true;
		}
	}
	return false;
}

/* --- power: Unleashed, PL1 and the shared CPU+GPU limit --- */

/*
 * What OMEN Gaming Hub does around its fourth mode, read out of its logs and
 * the platform configuration it ships for this board
 * (docs/research/hub-gap.md):
 *
 *   GM1A  {0xFF, HPCM, 0, 0}   the thermal profile. HPCM 0x04 is Unleashed,
 *                              which hp-wmi's platform_profile has no name
 *                              for - so it is offered here, on its own.
 *   GM29  {PL2, PL1, PL4, TDP} power limits in watts, 0xFF = leave alone.
 *                              Byte 1 lands in OSPL (EC 0x37), byte 0 in
 *                              OSPT (EC 0x38), byte 3 in NPCF.DATP (x8) with
 *                              a notify to the NVIDIA platform controller.
 *   GM2A                       reads them back: byte 7 is NPCF.ATPP / 8,
 *                              the shared limit in force.
 *
 * The Hub sends PL1 in both of the first two bytes on AMD - "60,60,255,255"
 * is its performance default - so this does too.
 *
 * Writes go through the firmware's own methods; the EC is only read. 8D24
 * only: the registers behind these commands are this board's DSDT, and
 * omen-space keeps 8D24 on its list of boards where a wrong EC access ends
 * in a Caps Lock panic.
 */
#define OMEN_THERMAL_PROFILE	0x1A
#define OMEN_POWER_LIMITS_SET	0x29
#define OMEN_POWER_DATA_GET	0x2A
#define POWER_LIMITS_LEN	4
#define POWER_DATA_LEN		128
#define POWER_DATA_TDP		7
#define POWER_KEEP		0xFF

#define EC_PL1			0x37
#define EC_THERMAL_PROFILE	0x95
#define HPCM_PERFORMANCE	0x31
#define HPCM_UNLEASHED		0x04

/*
 * The range the kernel accepts. Wider than HP's own (PL1 25-71 W, shared
 * limit 45-65 W on this board), which omend enforces: this is the line past
 * which a number is a mistake rather than a preference.
 */
#define PL1_MIN_W		10
#define PL1_MAX_W		95
#define TDP_MIN_W		10
#define TDP_MAX_W		100

static DEFINE_MUTEX(omen_power_lock);

static int omen_power_limits_set(u8 pl1, u8 tdp)
{
	u8 limits[POWER_LIMITS_LEN] = { pl1, pl1, POWER_KEEP, tdp };

	guard(mutex)(&omen_power_lock);
	return omen_wmi_call(HPWMI_GAMING, OMEN_POWER_LIMITS_SET, limits,
			     sizeof(limits), 0);
}

/* The shared limit in force, in watts; 0 when the firmware reports none. */
static int omen_tdp_get(u8 *watts)
{
	u8 *data;
	int ret;

	data = kzalloc(POWER_DATA_LEN, GFP_KERNEL);
	if (!data)
		return -ENOMEM;
	ret = omen_wmi_call(HPWMI_GAMING, OMEN_POWER_DATA_GET, data, 0,
			    POWER_DATA_LEN);
	if (!ret)
		*watts = data[POWER_DATA_TDP];
	kfree(data);
	return ret;
}

static ssize_t omen_watts_store(const char *buf, size_t count, u8 min, u8 max,
				bool tdp)
{
	u8 watts;
	int ret;

	ret = kstrtou8(buf, 0, &watts);
	if (ret)
		return ret;
	if (watts < min || watts > max)
		return -ERANGE;
	ret = tdp ? omen_power_limits_set(POWER_KEEP, watts) :
		    omen_power_limits_set(watts, POWER_KEEP);
	return ret ? ret : count;
}

/* PL1, the sustained CPU package limit, in watts. */
static ssize_t cpu_pl1_show(struct device *dev,
			    struct device_attribute *attr, char *buf)
{
	u8 watts;
	int ret;

	ret = ec_read(EC_PL1, &watts);
	if (ret)
		return ret;
	return sysfs_emit(buf, "%u\n", watts);
}

static ssize_t cpu_pl1_store(struct device *dev,
			     struct device_attribute *attr,
			     const char *buf, size_t count)
{
	return omen_watts_store(buf, count, PL1_MIN_W, PL1_MAX_W, false);
}
static DEVICE_ATTR_RW(cpu_pl1);

/*
 * What the Hub calls TPP and its code "concurrent TDP": the power the CPU and
 * the GPU may draw together, in watts.
 */
static ssize_t gpu_tpp_show(struct device *dev,
			    struct device_attribute *attr, char *buf)
{
	u8 watts;
	int ret;

	ret = omen_tdp_get(&watts);
	if (ret)
		return ret;
	return sysfs_emit(buf, "%u\n", watts);
}

static ssize_t gpu_tpp_store(struct device *dev,
			     struct device_attribute *attr,
			     const char *buf, size_t count)
{
	return omen_watts_store(buf, count, TDP_MIN_W, TDP_MAX_W, true);
}
static DEVICE_ATTR_RW(gpu_tpp);

/*
 * Unleashed: 1 while HPCM reads 0x04. Writing 0 puts the performance profile
 * back, which is the mode Unleashed sits above; anything else is for
 * platform_profile to choose, and writing it there ends Unleashed too.
 */
static ssize_t unleashed_show(struct device *dev,
			      struct device_attribute *attr, char *buf)
{
	u8 hpcm;
	int ret;

	ret = ec_read(EC_THERMAL_PROFILE, &hpcm);
	if (ret)
		return ret;
	return sysfs_emit(buf, "%d\n", hpcm == HPCM_UNLEASHED);
}

static ssize_t unleashed_store(struct device *dev,
			       struct device_attribute *attr,
			       const char *buf, size_t count)
{
	u8 mode[POWER_LIMITS_LEN] = { POWER_KEEP, HPCM_PERFORMANCE, 0, 0 };
	bool on;
	int ret;

	ret = kstrtobool(buf, &on);
	if (ret)
		return ret;
	if (on)
		mode[1] = HPCM_UNLEASHED;

	guard(mutex)(&omen_power_lock);
	ret = omen_wmi_call(HPWMI_GAMING, OMEN_THERMAL_PROFILE, mode,
			    sizeof(mode), 0);
	return ret ? ret : count;
}
static DEVICE_ATTR_RW(unleashed);

static struct attribute *omen_rgb_attrs[] = {
	&dev_attr_backlight_active.attr,
	&dev_attr_gpu_mux_mode.attr,
	&dev_attr_gpu_mux_supported.attr,
	&dev_attr_gpu_mux_pending_reboot.attr,
	&dev_attr_gpu_ctgp.attr,
	&dev_attr_gpu_ppab.attr,
	&dev_attr_cpu_pl1.attr,
	&dev_attr_gpu_tpp.attr,
	&dev_attr_unleashed.attr,
	NULL,
};

static umode_t omen_rgb_attr_visible(struct kobject *kobj,
				     struct attribute *attr, int n)
{
	if (attr == &dev_attr_backlight_active.attr)
		return omen_has_lighting ? attr->mode : 0;
	if (attr == &dev_attr_gpu_ctgp.attr || attr == &dev_attr_gpu_ppab.attr)
		return omen_has_gpu_power ? attr->mode : 0;
	if (attr == &dev_attr_cpu_pl1.attr || attr == &dev_attr_unleashed.attr)
		return omen_has_power_limits ? attr->mode : 0;
	if (attr == &dev_attr_gpu_tpp.attr)
		return omen_has_tpp ? attr->mode : 0;

	/* The mux attributes exist only on a machine that has one. */
	return omen_mux_supported ? attr->mode : 0;
}

static const struct attribute_group omen_rgb_group = {
	.attrs		= omen_rgb_attrs,
	.is_visible	= omen_rgb_attr_visible,
};

static const struct attribute_group *omen_rgb_groups[] = {
	&omen_rgb_group,
	NULL,
};

/* --- discrete GPU temperature --- */

/*
 * EC register 0xB7 (GTMP in the Phase 1 map): the discrete GPU's temperature
 * in whole degrees. The NVIDIA driver registers no hwmon on this machine, so
 * without this a fan curve - or `sensors` - never sees most of the heat a
 * game produces. omen-space reads the same register across the OMEN and
 * Victus family, which is the independent confirmation, and why it is read
 * only on those.
 *
 * ec_read() goes through the ACPI EC driver's own locking, so this needs
 * neither ec_sys nor debugfs.
 */
#define EC_GPU_TEMP		0xB7

/*
 * EC register 0x48: the surface - what OMEN Gaming Hub calls the IR sensor.
 * The Hub reads it as sensor 0 of WMI command 0x23 (GetIRSensorValue), and on
 * 8D24 the DSDT's GM23 answers that with this register and nothing else, so
 * reading it here is the same number without the trip through ACPI. The Hub
 * caps PL1 and shapes its fan tables on it; a palm rest is what it measures.
 *
 * 8D24 only, for the same reason as the fans: the address is that board's.
 */
#define EC_SURFACE_TEMP		0x48

/* The channels, in the order HWMON_CHANNEL_INFO lists them below. */
enum omen_temp_channel {
	OMEN_TEMP_DGPU,
	OMEN_TEMP_SURFACE,
};

/*
 * The two fan tachometers: FS1H/FS1L and FS2H/FS2L, big-endian RPM, at
 * 0x530-0x533 of the memory-mapped extended EC RAM (DSDT OperationRegion
 * H2RA, 0xFE700000).
 *
 * hp-wmi reads the same numbers through WMI command 0x2D, whose method
 * (GM2D) starts with an SMI and waits for it: 264 ms per read, measured on
 * 8D24, and while it runs no other ACPI method can. omend read three of them
 * every two seconds, and every keyboard frame that arrived meanwhile waited
 * - that was the stutter in the effects. Read from the RAM they are a
 * handful of bus cycles. GM11, the other WMI command that returns them,
 * reads them from here too, which is the evidence that these are the same
 * values.
 */
#define H2RA_FANS	0x530
#define H2RA_FANS_LEN	4

static int omen_hwmon_read(struct device *dev, enum hwmon_sensor_types type,
			   u32 attr, int channel, long *val)
{
	struct omen_rgb *rgb = dev_get_drvdata(dev);
	u8 raw;
	int ret;

	if (type == hwmon_fan) {
		const void __iomem *at = rgb->fans + channel * 2;

		*val = (readb(at) << 8) | readb(at + 1);
		return 0;
	}

	ret = ec_read(channel == OMEN_TEMP_SURFACE ? EC_SURFACE_TEMP : EC_GPU_TEMP,
		      &raw);
	if (ret)
		return ret;
	/*
	 * 0 is what the EC holds when it has no reading, and never a
	 * temperature a running laptop has; reporting it as 0 °C would drag
	 * down anything that takes a maximum.
	 */
	if (!raw)
		return -ENODATA;
	*val = raw * 1000L;
	return 0;
}

static int omen_hwmon_read_string(struct device *dev,
				  enum hwmon_sensor_types type, u32 attr,
				  int channel, const char **str)
{
	*str = channel == OMEN_TEMP_SURFACE ? "Surface" : "dGPU";
	return 0;
}

/*
 * A callback rather than .visible, which only newer kernels have - and
 * needed anyway: the temperature is there on the whole family, the fans only
 * where their address is known.
 */
static umode_t omen_hwmon_is_visible(const void *data,
				     enum hwmon_sensor_types type, u32 attr,
				     int channel)
{
	const struct omen_rgb *rgb = data;

	if (type == hwmon_fan)
		return rgb->fans ? 0444 : 0;
	if (channel == OMEN_TEMP_SURFACE)
		return omen_has_surface_temp ? 0444 : 0;
	return omen_has_dgpu_temp ? 0444 : 0;
}

static const struct hwmon_ops omen_hwmon_ops = {
	.is_visible	= omen_hwmon_is_visible,
	.read		= omen_hwmon_read,
	.read_string	= omen_hwmon_read_string,
};

static const struct hwmon_channel_info * const omen_hwmon_info[] = {
	HWMON_CHANNEL_INFO(temp, HWMON_T_INPUT | HWMON_T_LABEL,
			   HWMON_T_INPUT | HWMON_T_LABEL),
	HWMON_CHANNEL_INFO(fan, HWMON_F_INPUT, HWMON_F_INPUT),
	NULL,
};

static const struct hwmon_chip_info omen_hwmon_chip = {
	.ops	= &omen_hwmon_ops,
	.info	= omen_hwmon_info,
};

static const struct dmi_system_id omen_family[] = {
	{ .matches = { DMI_MATCH(DMI_SYS_VENDOR, "HP"),
		       DMI_MATCH(DMI_PRODUCT_NAME, "OMEN") } },
	{ .matches = { DMI_MATCH(DMI_SYS_VENDOR, "HP"),
		       DMI_MATCH(DMI_PRODUCT_NAME, "Victus") } },
	{ }
};

/* --- debugfs: the raw lighting block --- */

/*
 * Read-only window onto the lighting block of the memory-mapped extended EC
 * RAM (Phase 1 §4.1: EC register N lives at 0xFE700000 + 0x300 + N).
 *
 * A research tool, kept because it is how the backlight switch was found
 * (rgb-protocol.md §5): dump it with the backlight off, then on, and diff.
 * It lives in debugfs because nothing depends on it, and only on 8D24
 * because the address is that board's DSDT (OperationRegion H2RA); on
 * another board the same address is someone else's registers.
 */
#define H2RA_BASE	0xFE700000
#define H2RA_LIGHTING	0xEE0
#define H2RA_DUMP_LEN	32

static const struct dmi_system_id omen_h2ra_boards[] = {
	{ .matches = { DMI_MATCH(DMI_BOARD_VENDOR, "HP"),
		       DMI_EXACT_MATCH(DMI_BOARD_NAME, "8D24") } },
	{ }
};

static int lighting_regs_show(struct seq_file *s, void *unused)
{
	struct omen_rgb *rgb = s->private;
	int i;

	for (i = 0; i < H2RA_DUMP_LEN; i++)
		seq_printf(s, "%02x%c", readb(rgb->h2ra + i),
			   (i % 16 == 15) ? '\n' : ' ');
	return 0;
}
DEFINE_SHOW_ATTRIBUTE(lighting_regs);

static void omen_debugfs_remove(void *data)
{
	debugfs_remove_recursive(data);
}

/*
 * The raw LBRT byte, as LM04 reads it and LM05 writes it.
 *
 * For working out what the byte means. The driver treats it as 0xE4 on and
 * 0x64 off, but Fn+F4 steps through more states than that - it dims before
 * it switches off - and 0xE4 is 0x80 | 100, which reads like an on bit over
 * a 0-100 level. Writing here bypasses the LED class; the poll reports what
 * it finds on its next pass.
 */
static int lbrt_get(void *data, u64 *val)
{
	u32 raw = 0;
	int ret;

	ret = omen_wmi_query(LIGHTING_BRIGHT_GET, &raw, sizeof(raw), sizeof(raw));
	if (ret)
		return ret;
	*val = raw & 0xff;
	return 0;
}

static int lbrt_set(void *data, u64 val)
{
	u32 raw = val;

	if (val > 0xff)
		return -EINVAL;
	return omen_wmi_query(LIGHTING_BRIGHT_SET, &raw, sizeof(raw), 0);
}
DEFINE_DEBUGFS_ATTRIBUTE(lbrt_fops, lbrt_get, lbrt_set, "0x%02llx\n");

/*
 * LM03 calls since the last reset, and how long they took. Writing anything
 * resets the counters. Read after an effect has run for a known time, the
 * count says how many frames actually reached the firmware and the times say
 * whether the firmware is what limits them.
 */
static int zone_stats_show(struct seq_file *s, void *unused)
{
	struct omen_rgb *rgb = s->private;

	guard(mutex)(&rgb->lock);
	seq_printf(s, "writes %llu\nmean_us %llu\nmax_us %llu\n",
		   rgb->zone_writes,
		   rgb->zone_writes ?
			div64_u64(rgb->zone_ns_total, rgb->zone_writes) / 1000 : 0,
		   div64_u64(rgb->zone_ns_max, 1000));
	return 0;
}

static int zone_stats_open(struct inode *inode, struct file *file)
{
	return single_open(file, zone_stats_show, inode->i_private);
}

static ssize_t zone_stats_write(struct file *file, const char __user *buf,
				size_t count, loff_t *ppos)
{
	struct omen_rgb *rgb = ((struct seq_file *)file->private_data)->private;

	guard(mutex)(&rgb->lock);
	rgb->zone_writes = 0;
	rgb->zone_ns_total = 0;
	rgb->zone_ns_max = 0;
	return count;
}

static const struct file_operations zone_stats_fops = {
	.owner		= THIS_MODULE,
	.open		= zone_stats_open,
	.read		= seq_read,
	.write		= zone_stats_write,
	.llseek		= seq_lseek,
	.release	= single_release,
};

static void omen_debugfs_init(struct omen_rgb *rgb)
{
	if (!omen_has_lighting && !dmi_check_system(omen_h2ra_boards))
		return;

	/* Spelt out: KBUILD_MODNAME is omen_kbd_rgb, with underscores. */
	rgb->debugfs = debugfs_create_dir("omen-kbd-rgb", NULL);
	devm_add_action_or_reset(rgb->dev, omen_debugfs_remove, rgb->debugfs);

	if (omen_has_lighting) {
		debugfs_create_file_unsafe("lbrt", 0600, rgb->debugfs, rgb,
					   &lbrt_fops);
		debugfs_create_file("zone_stats", 0600, rgb->debugfs, rgb,
				    &zone_stats_fops);
	}

	if (!dmi_check_system(omen_h2ra_boards))
		return;
	rgb->h2ra = devm_ioremap(rgb->dev, H2RA_BASE + H2RA_LIGHTING,
				 H2RA_DUMP_LEN);
	if (rgb->h2ra)
		debugfs_create_file("lighting_regs", 0400, rgb->debugfs, rgb,
				    &lighting_regs_fops);
}

/* --- probe --- */

static void omen_cancel_poll(void *data)
{
	struct omen_rgb *rgb = data;

	cancel_delayed_work_sync(&rgb->poll_work);
}

static void omen_cancel_work(void *data)
{
	struct omen_rgb *rgb = data;

	cancel_delayed_work_sync(&rgb->poll_work);
	cancel_delayed_work_sync(&rgb->zone_work);
}

static int omen_lighting_probe(struct omen_rgb *rgb)
{
	static const u32 color_ids[COLORS_PER_ZONE] = {
		LED_COLOR_ID_RED, LED_COLOR_ID_GREEN, LED_COLOR_ID_BLUE,
	};
	struct device *dev = rgb->dev;
	int i, c, ret;

	INIT_DELAYED_WORK(&rgb->zone_work, omen_zone_work);
	INIT_DELAYED_WORK(&rgb->poll_work, omen_poll_work);
	/*
	 * Registered before the LEDs, so it runs after they are unregistered:
	 * nothing can queue work once this has cancelled it.
	 */
	ret = devm_add_action_or_reset(dev, omen_cancel_work, rgb);
	if (ret)
		return ret;

	for (i = 0; i < ZONE_COUNT; i++) {
		for (c = 0; c < COLORS_PER_ZONE; c++)
			rgb->subled[i][c].color_index = color_ids[c];

		rgb->zone[i].subled_info = rgb->subled[i];
		rgb->zone[i].num_colors = COLORS_PER_ZONE;

		scnprintf(rgb->zone_name[i], sizeof(rgb->zone_name[i]),
			  "omen:rgb:kbd_backlight_zone%d", i);
		rgb->zone[i].led_cdev.name = rgb->zone_name[i];
		rgb->zone[i].led_cdev.max_brightness = 255;
		rgb->zone[i].led_cdev.brightness_set = omen_zone_set;
		/*
		 * The LED class switches a LED off when it is unregistered
		 * (led_classdev_unregister -> led_set_brightness(LED_OFF)).
		 * Wrong for a keyboard backlight: 'rmmod' or a shutdown must
		 * not darken the keyboard, and the colour the user chose
		 * should stay. Seen on the machine (2026-09-11): after rmmod
		 * LBRT went to 0 and the keyboard went completely dark.
		 */
		rgb->zone[i].led_cdev.flags |= LED_RETAIN_AT_SHUTDOWN;
	}

	/*
	 * The hardware only remembers on/off, so the level starts at full; see
	 * omen_zone_read_initial() for why nothing better can be recovered.
	 */
	rgb->level = BRIGHTNESS_MAX;
	if (omen_backlight_read(&rgb->hw))
		rgb->hw = 0;

	ret = omen_zone_read_initial(rgb);
	if (ret)
		return dev_err_probe(dev, ret, "could not read the zone colours\n");

	for (i = 0; i < ZONE_COUNT; i++) {
		ret = devm_led_classdev_multicolor_register(dev, &rgb->zone[i]);
		if (ret)
			return dev_err_probe(dev, ret,
					     "could not register zone %d\n", i);
	}

	/*
	 * Global brightness is a separate LED. The name "omen::kbd_backlight"
	 * is deliberate - desktop environments and upower look for keyboard
	 * backlights matching *::kbd_backlight, so the brightness keys work.
	 */
	rgb->kbd_bl.name = "omen::kbd_backlight";
	rgb->kbd_bl.max_brightness = BRIGHTNESS_MAX;
	rgb->kbd_bl.brightness = omen_shown(rgb);
	rgb->kbd_bl.brightness_set_blocking = omen_bl_set;
	rgb->kbd_bl.brightness_get = omen_bl_get;
	rgb->kbd_bl.flags |= LED_RETAIN_AT_SHUTDOWN;
	if (poll_ms)
		rgb->kbd_bl.flags |= LED_BRIGHT_HW_CHANGED;

	/*
	 * Say so when the keyboard is dark. Writing a colour then shows nothing
	 * and looks like a broken driver, and it is the single most common way
	 * to be misled by this hardware.
	 */
	if (!rgb->hw)
		dev_info(dev,
			 "the keyboard backlight is off; turn it on with: echo %d > /sys/class/leds/%s/brightness\n",
			 BRIGHTNESS_MAX, rgb->kbd_bl.name);

	ret = devm_led_classdev_register(dev, &rgb->kbd_bl);
	if (ret)
		return dev_err_probe(dev, ret,
				     "could not register the brightness LED\n");

	/*
	 * And stopped before that LED goes away, which the action above is too
	 * late for: the poll reports through it.
	 */
	ret = devm_add_action_or_reset(dev, omen_cancel_poll, rgb);
	if (ret)
		return ret;

	if (poll_ms)
		schedule_delayed_work(&rgb->poll_work, msecs_to_jiffies(poll_ms));

	dev_info(dev, "%d-zone RGB keyboard ready\n", ZONE_COUNT);
	return 0;
}

static int omen_rgb_probe(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	struct omen_rgb *rgb;
	int ret;

	rgb = devm_kzalloc(dev, sizeof(*rgb), GFP_KERNEL);
	if (!rgb)
		return -ENOMEM;

	rgb->dev = dev;
	ret = devm_mutex_init(dev, &rgb->lock);
	if (ret)
		return ret;
	platform_set_drvdata(pdev, rgb);

	if (dmi_check_system(omen_h2ra_boards))
		rgb->fans = devm_ioremap(dev, H2RA_BASE + H2RA_FANS,
					 H2RA_FANS_LEN);

	if (omen_has_dgpu_temp || omen_has_surface_temp || rgb->fans) {
		struct device *hwmon;

		/* Not fatal: the keyboard and the mux do not need it. */
		hwmon = devm_hwmon_device_register_with_info(dev, "omen", rgb,
							     &omen_hwmon_chip,
							     NULL);
		if (IS_ERR(hwmon))
			dev_warn(dev, "could not register the hwmon device: %ld\n",
				 PTR_ERR(hwmon));
	}

	omen_debugfs_init(rgb);

	if (omen_has_lighting)
		return omen_lighting_probe(rgb);
	return 0;
}

/* --- suspend / resume --- */

static int omen_rgb_suspend(struct device *dev)
{
	struct omen_rgb *rgb = dev_get_drvdata(dev);

	if (!omen_has_lighting)
		return 0;

	cancel_delayed_work_sync(&rgb->poll_work);
	flush_delayed_work(&rgb->zone_work);
	return 0;
}

/*
 * Puts the colours back after sleep.
 *
 * The firmware is free to reinitialise the EC across a suspend or a
 * hibernation, and the colours were only ever in the EC. Writing them from
 * here means the keyboard comes back right with or without the daemon. The
 * switch is left alone - whether the keyboard should be lit after resume is
 * the firmware's call, and the poll reports what it decided.
 */
static int omen_rgb_resume(struct device *dev)
{
	struct omen_rgb *rgb = dev_get_drvdata(dev);
	int ret;

	if (!omen_has_lighting)
		return 0;

	scoped_guard(mutex, &rgb->lock) {
		ret = omen_write_zones(rgb);
		if (ret)
			dev_warn(dev, "could not restore the zone colours: %d\n", ret);
	}

	if (poll_ms)
		schedule_delayed_work(&rgb->poll_work, 0);
	return 0;
}

static DEFINE_SIMPLE_DEV_PM_OPS(omen_rgb_pm, omen_rgb_suspend, omen_rgb_resume);

static struct platform_driver omen_rgb_driver = {
	.driver = {
		.name = "omen-kbd-rgb",
		.dev_groups = omen_rgb_groups,
		.pm = pm_sleep_ptr(&omen_rgb_pm),
	},
};

static struct platform_device *omen_rgb_device;

/*
 * Whether the lighting group is here, and is the 4-zone kind.
 *
 * We keep no DMI list. It needs a patch per board, and that is exactly the
 * work Phase 2 landed us with. The firmware is asked instead.
 */
static bool omen_lighting_detect(void)
{
	u8 caps[4] = {};
	int ret;

	ret = omen_wmi_query(LIGHTING_CAPS, caps, 0, sizeof(caps));
	if (ret) {
		pr_debug("the lighting command group is unsupported (%d)\n", ret);
		return false;
	}

	if (!(caps[0] & LIGHTING_CAPS_PRESENT)) {
		pr_info("the firmware reports no keyboard backlight\n");
		return false;
	}
	if (LIGHTING_CAPS_TYPE(caps[0]) != KBD_TYPE_FOUR_ZONE) {
		pr_info("keyboard lighting type %u is not the 4-zone type this driver knows; leaving it alone\n",
			LIGHTING_CAPS_TYPE(caps[0]));
		return false;
	}
	return true;
}

/*
 * Whether EC 0x48 is a temperature. Zero is the EC's "no reading", and a
 * running laptop's palm rest is neither below 10 °C nor above 100.
 */
static bool omen_surface_detect(void)
{
	u8 raw;

	if (ec_read(EC_SURFACE_TEMP, &raw))
		return false;
	if (raw < 10 || raw > 100) {
		pr_info("EC 0x48 reads %u, not a surface temperature; not publishing it\n",
			raw);
		return false;
	}
	return true;
}

static int __init omen_rgb_init(void)
{
	bool family;
	u8 mode;

	if (!wmi_has_guid(HPWMI_BIOS_GUID))
		return -ENODEV;

	family = dmi_check_system(omen_family);
	omen_has_lighting = omen_lighting_detect();
	omen_has_dgpu_temp = family;

	/*
	 * Only asked of machines that are plausibly OMEN or Victus: the module
	 * loads on any HP with this GUID, and the design-data query belongs to
	 * the gaming group, which an office laptop has no reason to implement.
	 */
	if (family || omen_has_lighting)
		omen_mux_supported = omen_mux_read_supported();
	if (omen_mux_supported) {
		pr_info("graphics mux: %s%s%s%s\n",
			omen_mux_supported & BIT(0) ? "uma " : "",
			omen_mux_supported & BIT(1) ? "hybrid " : "",
			omen_mux_supported & BIT(2) ? "discrete " : "",
			omen_mux_supported & BIT(3) ? "optimus" : "");
		if (!omen_mux_get(&mode))
			omen_mux_at_load = mode;
	}

	if (family && omen_nvidia_gpu_present()) {
		u8 modes[GPU_POWER_LEN];

		omen_has_gpu_power = !omen_gpu_power_get(modes);
		if (omen_has_gpu_power)
			pr_info("GPU power: cTGP %s, Dynamic Boost %s\n",
				modes[GPU_POWER_CTGP] ? "on" : "off",
				modes[GPU_POWER_PPAB] ? "on" : "off");
	}

	if (family && dmi_check_system(omen_h2ra_boards)) {
		u8 tdp = 0;

		omen_has_surface_temp = omen_surface_detect();
		omen_has_power_limits = true;
		/* The Hub's test too: no shared limit reported, no control. */
		omen_has_tpp = omen_has_gpu_power && !omen_tdp_get(&tdp) && tdp;
		pr_info("power: Unleashed, PL1%s%s\n",
			omen_has_tpp ? ", shared CPU+GPU limit" : "",
			omen_has_surface_temp ? ", surface temperature" : "");
	}

	if (!omen_has_lighting && !omen_mux_supported && !omen_has_dgpu_temp &&
	    !omen_has_gpu_power && !omen_has_power_limits)
		return -ENODEV;

	omen_rgb_device = platform_create_bundle(&omen_rgb_driver,
						 omen_rgb_probe, NULL, 0,
						 NULL, 0);
	return PTR_ERR_OR_ZERO(omen_rgb_device);
}

static void __exit omen_rgb_exit(void)
{
	platform_device_unregister(omen_rgb_device);
	platform_driver_unregister(&omen_rgb_driver);
}

module_init(omen_rgb_init);
module_exit(omen_rgb_exit);

#ifndef OMEN_KBD_RGB_VERSION
#define OMEN_KBD_RGB_VERSION "unknown"
#endif

MODULE_DESCRIPTION("HP OMEN 4-zone RGB keyboard, graphics mux, temperatures and power limits");
MODULE_AUTHOR("WinTone");
MODULE_LICENSE("GPL");
/*
 * So the loaded module can be compared with the installed one - see
 * omenctl version. srcversion answers "is this the same build", the version
 * answers "which release". The number comes from dkms.conf, through Kbuild.
 */
MODULE_VERSION(OMEN_KBD_RGB_VERSION);
MODULE_ALIAS("wmi:" HPWMI_BIOS_GUID);
