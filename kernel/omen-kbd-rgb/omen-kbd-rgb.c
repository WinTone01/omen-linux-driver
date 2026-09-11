// SPDX-License-Identifier: GPL-2.0-only
/*
 * 4-zone RGB keyboard backlight for the HP OMEN 16-ap0xxx (board 8D24).
 *
 * Protocol: docs/research/rgb-protocol.md - all of it extracted from the DSDT.
 *
 * This module deliberately uses only the lighting command group (0x020009).
 * Fans and thermals are in-tree hp-wmi's job (0x020008). Both use the same
 * WMI GUID, but hp-wmi does NOT own it - it calls through
 * wmi_evaluate_method() and registers itself as a platform_driver. Since the
 * groups are disjoint the two modules run side by side; there is no need to
 * blacklist hp_wmi.
 *
 * Copyright (C) 2026 WinTone
 */

#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

#include <linux/acpi.h>
#include <linux/led-class-multicolor.h>
#include <linux/leds.h>
#include <linux/module.h>
#include <linux/mutex.h>
#include <linux/platform_device.h>
#include <linux/wmi.h>

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

/* Set at probe. Zero means no mux, and the attributes are not created. */
static u8 omen_mux_supported;

enum lighting_query {
	LIGHTING_COLOR_GET	= 0x02,	/* LM02 */
	LIGHTING_COLOR_SET	= 0x03,	/* LM03 */
	LIGHTING_BRIGHT_GET	= 0x04,	/* LM04 */
	LIGHTING_BRIGHT_SET	= 0x05,	/* LM05 */
};

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
 * LM04/LM05 are an on/off switch, not a level.
 *
 * The dead assignment in LM04 (Local1 = 0x64) made it look like a 0-100
 * scale, and writing a level there is what kept switching the keyboard off:
 * "brightness 100" sent 0x64, which is the OFF value. Every mysterious
 * blackout today came from that.
 *
 * The two magic values are from hp-omen-extra.c in the omen-space project,
 * which had this right; they also explain the earlier measurements, where
 * LM04 returned 0x64 with the keyboard dark and the raw register read 0xE4
 * while it was lit.
 */
#define LIGHTING_ON		0xE4
#define LIGHTING_OFF		0x64

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
	/* The lighting block of the memory-mapped extended EC RAM, or NULL if
	 * it could not be mapped - everything else still works without it. */
	void __iomem *h2ra;
	/* Keeps the read-modify-write sequence indivisible. */
	struct mutex lock;
	struct led_classdev kbd_bl;
	struct led_classdev_mc zone[ZONE_COUNT];
	struct mc_subled subled[ZONE_COUNT][COLORS_PER_ZONE];
	char zone_name[ZONE_COUNT][32];
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

static int omen_wmi_call(u32 command, int query, void *buffer, int insize,
			 int outsize)
{
	struct acpi_buffer input, output = { ACPI_ALLOCATE_BUFFER, NULL };
	struct bios_return *bios_return;
	union acpi_object *obj = NULL;
	struct bios_args *args = NULL;
	int mid, actual_insize, actual_outsize;
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

	ret = wmi_evaluate_method(HPWMI_BIOS_GUID, 0, mid, &input, &output);
	if (ret)
		goto out_free;

	obj = output.pointer;
	if (!obj) {
		ret = -EINVAL;
		goto out_free;
	}
	if (obj->type != ACPI_TYPE_BUFFER) {
		pr_warn("query 0x%x returned an invalid object (type %d)\n",
			query, obj->type);
		ret = -EINVAL;
		goto out_free;
	}
	if (obj->buffer.length < sizeof(*bios_return)) {
		ret = -EINVAL;
		goto out_free;
	}

	bios_return = (struct bios_return *)obj->buffer.pointer;
	ret = bios_return->return_code;
	if (ret) {
		pr_warn("query 0x%x returned error 0x%x\n", query, ret);
		goto out_free;
	}

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

/* Defined below, next to the zone handling it belongs to; brightness needs it
 * because dimming is applied by rewriting the colours. */
static int omen_write_zones(struct omen_rgb *rgb, u8 global);

/* --- brightness (LBRT) --- */

/*
 * Read once at probe to pick up whatever the firmware was left holding, and
 * not wired to the LED class as a brightness_get.
 *
 * The class caches the value it was last set to, and that is the more honest
 * answer here: LBRT's read-back semantics are murky - dumping the extended EC
 * RAM showed 0xEFC at 0xe4 while the keyboard was lit and 0x00 while dark,
 * neither of which is the 100 that LM04 returns - so reporting it back as the
 * user's setting would be guessing. OmenLinux/omen-rgb-keyboard reaches the
 * same conclusion from the other direction: its brightness_get returns its own
 * variable and never asks the hardware.
 */
static bool omen_backlight_is_on(void)
{
	u32 data = 0;

	if (omen_wmi_query(LIGHTING_BRIGHT_GET, &data, sizeof(data),
			   sizeof(data)))
		return false;
	return data == LIGHTING_ON;
}

static int omen_backlight_set(bool on)
{
	u32 data = on ? LIGHTING_ON : LIGHTING_OFF;

	return omen_wmi_query(LIGHTING_BRIGHT_SET, &data, sizeof(data), 0);
}

static int omen_bl_set(struct led_classdev *cdev, enum led_brightness value)
{
	struct omen_rgb *rgb = dev_get_drvdata(cdev->dev->parent);
	u8 level = min_t(unsigned int, value, BRIGHTNESS_MAX);

	int ret;

	guard(mutex)(&rgb->lock);

	/*
	 * Two separate things, which is what took so long to see: the hardware
	 * switch is on/off only, and the level is ours to apply by scaling the
	 * colours. So 0 means switch the backlight off, and anything else means
	 * switch it on and scale to taste.
	 */
	ret = omen_backlight_set(level > 0);
	if (ret)
		return ret;

	cdev->brightness = level;
	if (level == 0)
		return 0;

	return omen_write_zones(rgb, level);
}

/* --- zone colours (LRGB) --- */

/*
 * Composes all four zones from their intended colours, scaled by the global
 * brightness, and writes them in one go.
 *
 * The scaling is done here rather than left to LBRT because LBRT does not dim
 * this keyboard. Writing it succeeds and reads back correctly, and nothing
 * changes - the same trap as the on/off switch. So brightness is applied the
 * way the colours themselves are: by scaling what we send.
 *
 * The write is READ-MODIFY-WRITE. Only 12 of the 128 state bytes are zone
 * colours; what the rest carries is unknown and has to be preserved.
 */
static int omen_write_zones(struct omen_rgb *rgb, u8 global)
{
	u8 state[STATE_SIZE];
	int ret, i, c;

	ret = omen_wmi_query(LIGHTING_COLOR_GET, state, sizeof(state),
			     sizeof(state));
	if (ret)
		return ret;

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
			slot[c] = mc->subled_info[c].brightness * global /
				  BRIGHTNESS_MAX;
	}

	return omen_wmi_query(LIGHTING_COLOR_SET, state, sizeof(state),
			      sizeof(state));
}

static int omen_zone_set(struct led_classdev *cdev, enum led_brightness brightness)
{
	struct led_classdev_mc *mc = lcdev_to_mccdev(cdev);
	struct omen_rgb *rgb = dev_get_drvdata(cdev->dev->parent);
	int index = mc - rgb->zone;

	if (index < 0 || index >= ZONE_COUNT)
		return -EINVAL;

	guard(mutex)(&rgb->lock);
	/* The class updates this itself, but not necessarily before we run. */
	mc->led_cdev.brightness = brightness;
	return omen_write_zones(rgb, rgb->kbd_bl.brightness);
}

/* Reads the colours out of the hardware at probe and reflects them into the
 * LED class.
 */
static int omen_zone_read_initial(struct omen_rgb *rgb, u8 global)
{
	u8 state[STATE_SIZE];
	int ret, i;

	ret = omen_wmi_query(LIGHTING_COLOR_GET, state, sizeof(state),
			     sizeof(state));
	if (ret)
		return ret;

	for (i = 0; i < ZONE_COUNT; i++) {
		const u8 *slot = state + ZONE_DATA_OFFSET +
				 zone_slot[i] * COLORS_PER_ZONE;
		int c;

		/*
		 * What is on the wire has already been scaled by the global
		 * brightness, so undo that to recover the intended colour.
		 * Without this, reloading the module at 50% would take the
		 * dimmed values as the intent and halve them again.
		 */
		for (c = 0; c < COLORS_PER_ZONE; c++)
			rgb->subled[i][c].intensity =
				global ? min(255, slot[c] * BRIGHTNESS_MAX / global)
				       : slot[c];

		/*
		 * Use the largest component as the zone's brightness: the
		 * multicolor class computes the colour as
		 * intensity * brightness / max, so writing back what we just
		 * read leaves the colour unchanged.
		 */
		rgb->zone[i].led_cdev.brightness = max3(
			rgb->subled[i][0].intensity, rgb->subled[i][1].intensity,
			rgb->subled[i][2].intensity);
	}
	return 0;
}

/*
 * Read-only window onto the lighting block of the memory-mapped extended EC
 * RAM (Phase 1 §4.1: EC register N lives at 0xFE700000 + 0x300 + N).
 *
 * Why this exists: turning the backlight on is not something the driver can
 * do. Writing LRGB and LBRT succeeds and reads back correctly, but if the
 * keyboard is dark it stays dark, and only Fn+F4 brings it up. The switch is
 * not in the standard EC window - KBBL was ruled out, it reads the same
 * either way - and the WMI lighting group has no on/off at all. What is left
 * are the five unnamed bits at 0xEE0, just below LCMC, which sit in this
 * region and cannot be reached from userspace.
 *
 * Reading is all this does. Dump it with the backlight off, then on, and the
 * byte that differs is the switch.
 */
#define H2RA_BASE	0xFE700000
#define H2RA_LIGHTING	0xEE0
#define H2RA_DUMP_LEN	32

/*
 * Offset of the byte that says whether the backlight is actually lit, within
 * the window above.
 *
 * Found by dumping this block with the backlight off and then on, and
 * diffing: everything matched except this byte, which read 0x00 while dark
 * and 0x64 (100 - exactly the brightness we had set) once Fn+F4 brought the
 * lights up. The colours read 0xff throughout, which is why writing them
 * always looked like it had worked.
 *
 * The DSDT does not declare it: the field list defines one byte at 0xEE0 and
 * then jumps straight to 0xEE3, leaving 0xEE1 and 0xEE2 unnamed. That is why
 * three earlier searches - the standard EC window, the WMI lighting group and
 * EC 0x40-0x4F - all came up empty.
 *
 * It holds the brightness in EFFECT, not the brightness requested: with the
 * backlight off it reads 0 even though LBRT had been set to 100. So it
 * answers "is the keyboard lit", which is the question the driver could not
 * answer before.
 */
#define H2RA_ACTIVE_BRIGHTNESS	(0xEE1 - H2RA_LIGHTING)

static ssize_t lighting_regs_show(struct device *dev,
				  struct device_attribute *attr, char *buf)
{
	struct omen_rgb *rgb = dev_get_drvdata(dev);
	int i, n = 0;

	if (!rgb->h2ra)
		return -ENODEV;

	for (i = 0; i < H2RA_DUMP_LEN; i++) {
		n += sysfs_emit_at(buf, n, "%02x", readb(rgb->h2ra + i));
		n += sysfs_emit_at(buf, n, (i % 16 == 15) ? "\n" : " ");
	}
	return n;
}
static DEVICE_ATTR_RO(lighting_regs);

/*
 * 1 when the keyboard is actually lit, 0 when it is dark.
 *
 * Worth having because everything else lies about it: colours and brightness
 * are written, read back correctly, and show nothing at all while the
 * backlight is off. Without this a user writes a colour, sees a dark
 * keyboard, and concludes the driver is broken.
 *
 * Turning it ON is still not ours to do - the switch is Fn+F4 - but at least
 * the state can be reported.
 */
static ssize_t backlight_active_show(struct device *dev,
				     struct device_attribute *attr, char *buf)
{
	return sysfs_emit(buf, "%d\n", omen_backlight_is_on() ? 1 : 0);
}
static DEVICE_ATTR_RO(backlight_active);

/* --- graphics mux --- */

/*
 * Which modes this machine's firmware says it supports.
 *
 * Asked once, at probe. It cannot change while the machine is running - it
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
 * The mode in force, and the one to use from the next boot.
 *
 * Reading gives what the firmware currently has. Writing asks it to change,
 * which takes effect at the next boot: the panel is re-wired by the firmware
 * during POST, not by this driver. Nothing about the running system changes
 * when this is written, which is worth knowing before concluding it did
 * nothing.
 */
static ssize_t gpu_mux_mode_show(struct device *dev,
				 struct device_attribute *attr, char *buf)
{
	u8 mode;
	int ret;

	ret = omen_mux_get(&mode);
	if (ret)
		return ret < 0 ? ret : -EIO;

	if (mode < ARRAY_SIZE(omen_mux_names) && omen_mux_names[mode])
		return sysfs_emit(buf, "%s\n", omen_mux_names[mode]);
	/* A mode we have no name for is still worth reporting as a number
	 * rather than as an error - it is what the firmware said. */
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
		return ret < 0 ? ret : -EIO;

	dev_info(dev, "graphics mux set to %s; it takes effect at the next boot\n",
		 omen_mux_names[mode]);
	return count;
}
static DEVICE_ATTR_RW(gpu_mux_mode);

static struct attribute *omen_rgb_attrs[] = {
	&dev_attr_lighting_regs.attr,
	&dev_attr_backlight_active.attr,
	&dev_attr_gpu_mux_mode.attr,
	&dev_attr_gpu_mux_supported.attr,
	NULL,
};

/* The mux attributes exist only on a machine that has one. */
static umode_t omen_rgb_attr_visible(struct kobject *kobj,
				     struct attribute *attr, int n)
{
	if (attr == &dev_attr_gpu_mux_mode.attr ||
	    attr == &dev_attr_gpu_mux_supported.attr)
		return omen_mux_supported ? attr->mode : 0;

	return attr->mode;
}

static const struct attribute_group omen_rgb_group = {
	.attrs		= omen_rgb_attrs,
	.is_visible	= omen_rgb_attr_visible,
};

static const struct attribute_group *omen_rgb_groups[] = {
	&omen_rgb_group,
	NULL,
};

static int omen_rgb_probe(struct platform_device *pdev)
{
	static const u32 color_ids[COLORS_PER_ZONE] = {
		LED_COLOR_ID_RED, LED_COLOR_ID_GREEN, LED_COLOR_ID_BLUE,
	};
	struct omen_rgb *rgb;
	int i, c, ret;

	rgb = devm_kzalloc(&pdev->dev, sizeof(*rgb), GFP_KERNEL);
	if (!rgb)
		return -ENOMEM;

	rgb->dev = &pdev->dev;
	ret = devm_mutex_init(&pdev->dev, &rgb->lock);
	if (ret)
		return ret;
	platform_set_drvdata(pdev, rgb);

	/* Mapped once rather than per read: the state is polled. A failure is
	 * not fatal - only the two diagnostic attributes need it. */
	rgb->h2ra = devm_ioremap(&pdev->dev, H2RA_BASE + H2RA_LIGHTING,
				 H2RA_DUMP_LEN);
	if (!rgb->h2ra)
		dev_warn(&pdev->dev,
			 "could not map the extended EC window; backlight state will be unavailable\n");

	for (i = 0; i < ZONE_COUNT; i++) {
		for (c = 0; c < COLORS_PER_ZONE; c++)
			rgb->subled[i][c].color_index = color_ids[c];

		rgb->zone[i].subled_info = rgb->subled[i];
		rgb->zone[i].num_colors = COLORS_PER_ZONE;

		scnprintf(rgb->zone_name[i], sizeof(rgb->zone_name[i]),
			  "omen:rgb:kbd_backlight_zone%d", i);
		rgb->zone[i].led_cdev.name = rgb->zone_name[i];
		rgb->zone[i].led_cdev.max_brightness = 255;
		rgb->zone[i].led_cdev.brightness_set_blocking = omen_zone_set;
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
	 * Brightness first: the zone colours on the wire are scaled by it, so
	 * it has to be known before they can be read back as intent.
	 */
	/*
	 * The hardware only remembers on/off, so the level is ours: full
	 * brightness when it is lit, zero when it is not.
	 */
	rgb->kbd_bl.brightness = omen_backlight_is_on() ? BRIGHTNESS_MAX : 0;

	ret = omen_zone_read_initial(rgb, rgb->kbd_bl.brightness);
	if (ret) {
		dev_err(&pdev->dev, "could not read the zone colours: %d\n", ret);
		return ret;
	}

	for (i = 0; i < ZONE_COUNT; i++) {
		ret = devm_led_classdev_multicolor_register(&pdev->dev,
							    &rgb->zone[i]);
		if (ret)
			return dev_err_probe(&pdev->dev, ret,
					     "could not register zone %d\n", i);
	}

	/*
	 * Global brightness is a separate LED. The name "omen::kbd_backlight"
	 * is deliberate - desktop environments and upower look for keyboard
	 * backlights matching *::kbd_backlight, so the brightness keys work.
	 */
	rgb->kbd_bl.name = "omen::kbd_backlight";
	rgb->kbd_bl.max_brightness = BRIGHTNESS_MAX;
	rgb->kbd_bl.brightness_set_blocking = omen_bl_set;
	rgb->kbd_bl.flags |= LED_RETAIN_AT_SHUTDOWN;

	/*
	 * Say so when the keyboard is dark. Writing a colour then shows nothing
	 * and looks like a broken driver, and it is the single most common way
	 * to be misled by this hardware. The state comes from the byte that
	 * actually tracks it rather than from the brightness setting, which
	 * stays at whatever it was told even while the lighting is off.
	 */
	if (rgb->kbd_bl.brightness == 0)
		dev_info(&pdev->dev,
			 "the keyboard backlight is off; turn it on with: echo %d > /sys/class/leds/%s/brightness\n",
			 BRIGHTNESS_MAX, rgb->kbd_bl.name);

	ret = devm_led_classdev_register(&pdev->dev, &rgb->kbd_bl);
	if (ret)
		return dev_err_probe(&pdev->dev, ret,
				     "could not register the brightness LED\n");

	dev_info(&pdev->dev, "%d-zone RGB keyboard ready\n", ZONE_COUNT);
	return 0;
}

static struct platform_driver omen_rgb_driver = {
	.driver = {
		.name = "omen-kbd-rgb",
		.dev_groups = omen_rgb_groups,
	},
};

static struct platform_device *omen_rgb_device;

static int __init omen_rgb_init(void)
{
	u8 probe_buf[4] = { 0 };
	int ret;

	if (!wmi_has_guid(HPWMI_BIOS_GUID))
		return -ENODEV;

	/*
	 * We keep no DMI list. It needs a patch per board, and that is exactly
	 * the work Phase 2 landed us with. We ask about the capability
	 * instead: if the brightness can be read, this machine supports the
	 * lighting group.
	 */
	ret = omen_wmi_query(LIGHTING_BRIGHT_GET, probe_buf, 0,
			     sizeof(probe_buf));
	if (ret) {
		pr_info("the lighting command group is unsupported (%d)\n", ret);
		return -ENODEV;
	}

	/*
	 * Asked before the device is created, because whether the mux
	 * attributes exist is decided when its attribute group is added.
	 */
	omen_mux_supported = omen_mux_read_supported();
	if (omen_mux_supported)
		pr_info("graphics mux: %s%s%s%s\n",
			omen_mux_supported & BIT(0) ? "uma " : "",
			omen_mux_supported & BIT(1) ? "hybrid " : "",
			omen_mux_supported & BIT(2) ? "discrete " : "",
			omen_mux_supported & BIT(3) ? "optimus" : "");

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

MODULE_DESCRIPTION("HP OMEN 16-ap0xxx (8D24) 4-zone RGB keyboard");
MODULE_AUTHOR("WinTone");
MODULE_LICENSE("GPL");
/* So the loaded module can be compared with the installed one - see
 * omenctl version. srcversion answers "is this the same build", the version
 * answers "which release". */
MODULE_VERSION("0.1.0");
MODULE_ALIAS("wmi:" HPWMI_BIOS_GUID);
