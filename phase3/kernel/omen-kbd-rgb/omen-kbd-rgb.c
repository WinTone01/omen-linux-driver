// SPDX-License-Identifier: GPL-2.0-only
/*
 * 4-zone RGB keyboard backlight for the HP OMEN 16-ap0xxx (board 8D24).
 *
 * Protocol: phase3/docs/rgb-protocol.md - all of it extracted from the DSDT.
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
/* The dead assignment in LM04 (Local1 = 0x64) says the scale is 0-100. */
#define BRIGHTNESS_MAX		100

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

static int omen_wmi_query(int query, void *buffer, int insize, int outsize)
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
	args->command = HPWMI_LIGHTING;
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

/* --- brightness (LBRT) --- */

static enum led_brightness omen_bl_get(struct led_classdev *cdev)
{
	u8 buf[4] = { 0 };

	if (omen_wmi_query(LIGHTING_BRIGHT_GET, buf, 0, sizeof(buf)))
		return 0;
	return min_t(u8, buf[0], BRIGHTNESS_MAX);
}

static int omen_bl_set(struct led_classdev *cdev, enum led_brightness value)
{
	u8 level = min_t(unsigned int, value, BRIGHTNESS_MAX);

	return omen_wmi_query(LIGHTING_BRIGHT_SET, &level, sizeof(level), 0);
}

/* --- zone colours (LRGB) --- */

/*
 * The write has to be READ-MODIFY-WRITE. Only 12 of the 128 state bytes are
 * zone colours; what the rest carries is unknown and has to be preserved.
 */
static int omen_zone_set(struct led_classdev *cdev, enum led_brightness brightness)
{
	struct led_classdev_mc *mc = lcdev_to_mccdev(cdev);
	struct omen_rgb *rgb = dev_get_drvdata(cdev->dev->parent);
	int index = mc - rgb->zone;
	u8 state[STATE_SIZE];
	u8 *slot;
	int ret;

	if (index < 0 || index >= ZONE_COUNT)
		return -EINVAL;

	led_mc_calc_color_components(mc, brightness);

	guard(mutex)(&rgb->lock);

	ret = omen_wmi_query(LIGHTING_COLOR_GET, state, sizeof(state),
			     sizeof(state));
	if (ret)
		return ret;

	slot = state + ZONE_DATA_OFFSET + zone_slot[index] * COLORS_PER_ZONE;
	slot[0] = mc->subled_info[0].brightness;	/* R */
	slot[1] = mc->subled_info[1].brightness;	/* G */
	slot[2] = mc->subled_info[2].brightness;	/* B */

	return omen_wmi_query(LIGHTING_COLOR_SET, state, sizeof(state),
			      sizeof(state));
}

/* Reads the colours out of the hardware at probe and reflects them into the
 * LED class.
 */
static int omen_zone_read_initial(struct omen_rgb *rgb)
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

		for (c = 0; c < COLORS_PER_ZONE; c++)
			rgb->subled[i][c].intensity = slot[c];

		/*
		 * Use the largest component as the zone's brightness: the
		 * multicolor class computes the colour as
		 * intensity * brightness / max, so writing back what we just
		 * read leaves the colour unchanged.
		 */
		rgb->zone[i].led_cdev.brightness =
			max3(slot[0], slot[1], slot[2]);
	}
	return 0;
}

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

	ret = omen_zone_read_initial(rgb);
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
	rgb->kbd_bl.brightness_get = omen_bl_get;
	rgb->kbd_bl.brightness_set_blocking = omen_bl_set;
	rgb->kbd_bl.flags |= LED_RETAIN_AT_SHUTDOWN;
	rgb->kbd_bl.brightness = omen_bl_get(&rgb->kbd_bl);

	/*
	 * If the keyboard is off when the module loads (an older version
	 * switching it off at rmmod, or simply the user's choice), writing a
	 * colour shows nothing and looks like a broken driver. We do not fix
	 * it silently - it may well be deliberate - but we make it visible.
	 */
	if (rgb->kbd_bl.brightness == 0)
		dev_info(&pdev->dev,
			 "keyboard backlight is off; turn it on with: echo %d > /sys/class/leds/%s/brightness\n",
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
MODULE_ALIAS("wmi:" HPWMI_BIOS_GUID);
