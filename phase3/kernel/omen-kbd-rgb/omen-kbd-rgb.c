// SPDX-License-Identifier: GPL-2.0-only
/*
 * HP OMEN 16-ap0xxx (board 8D24) 4 bolge RGB klavye aydinlatmasi.
 *
 * Protokol: phase3/docs/rgb-protocol.md - hepsi DSDT'den cikarildi.
 *
 * Bu modul BILEREK yalnizca aydinlatma komut grubunu (0x020009) kullanir.
 * Fan ve termal taraf in-tree hp-wmi'nin isi (0x020008). Ikisi ayni WMI
 * GUID'ini kullanir ama hp-wmi GUID'i SAHIPLENMEZ - wmi_evaluate_method
 * ile cagirir ve kendisi bir platform_driver'dir. Gruplar ayrik oldugu
 * icin iki modul yan yana calisir; hp_wmi'yi blacklist etmek gerekmez.
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
 * LM03: LDAT[0..11] = WBUF[0x19..0x24]. Renkler 128 baytlik veri alaninin
 * BASINDA degil, 25. bayttan itibaren duruyor.
 */
#define ZONE_DATA_OFFSET	0x19
#define STATE_SIZE		128

/*
 * Donanim yuvalari fiziksel sirayla TERS: yuva 0 en SAGDAKI bolge.
 *
 * Makinede olculdu (2026-09-11): zone0..3'e sirayla kirmizi/yesil/mavi/sari
 * yazildiginda klavyede soldan saga sari/mavi/yesil/kirmizi gorundu.
 * Renkler dogruydu, yalnizca sira tersti - yani R/G/B bayt sirasi dogru,
 * cevrilmesi gereken bolge numarasi.
 *
 * Kullanici zone0'in soldaki oldugunu bekler (okuma yonu, ve OMEN Gaming
 * Hub da oyle numaraliyor). Cevrimi burada yapiyoruz ki sysfs adlari
 * sezgisel kalsin.
 */
static const u8 zone_slot[] = { 3, 2, 1, 0 };
/* LM04'teki olu atama (Local1 = 0x64) olcegin 0-100 oldugunu soyluyor. */
#define BRIGHTNESS_MAX		100

static_assert(ARRAY_SIZE(zone_slot) == ZONE_COUNT,
	      "zone_slot ile ZONE_COUNT uyusmuyor");

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
	/* Oku-degistir-yaz dizisini bolunmez tutar. */
	struct mutex lock;
	struct led_classdev kbd_bl;
	struct led_classdev_mc zone[ZONE_COUNT];
	struct mc_subled subled[ZONE_COUNT][COLORS_PER_ZONE];
	char zone_name[ZONE_COUNT][32];
};

/*
 * Arg0 cikis tamponu boyutunu SECER (Faz 1 §2): 1->0, 2->4, 3->128,
 * 4->1024, 5->4096. hp-wmi ile ayni esleme.
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

	/* Firmware her zaman en az 128 baytlik bir veri alani bekliyor. */
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
		pr_warn("sorgu 0x%x gecersiz nesne dondurdu (tur %d)\n",
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
		pr_warn("sorgu 0x%x hata dondurdu 0x%x\n", query, ret);
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
	/* Firmware bekledigimizden az verdiyse kalani sifirla. */
	memset(buffer + actual_outsize, 0, outsize - actual_outsize);

out_free:
	kfree(obj);
	kfree(args);
	return ret;
}

/* --- parlaklik (LBRT) --- */

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

/* --- bolge renkleri (LRGB) --- */

/*
 * Yazma OKU-DEGISTIR-YAZ olmali. 128 baytlik durumun yalnizca 12 bayti
 * bolge renkleri; gerisinin ne tasidigi bilinmiyor, korunmasi gerekiyor.
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

/* Acilista donanimdaki rengi okuyup LED sinifina yansitir. */
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
		 * Bolgenin parlakligi olarak en yuksek bileseni aliyoruz:
		 * multicolor sinifi rengi intensity * brightness / max
		 * olarak hesapliyor, boylece okunan renk aynen geri
		 * yazildiginda degismiyor.
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
	}

	ret = omen_zone_read_initial(rgb);
	if (ret) {
		dev_err(&pdev->dev, "bolge renkleri okunamadi: %d\n", ret);
		return ret;
	}

	for (i = 0; i < ZONE_COUNT; i++) {
		ret = devm_led_classdev_multicolor_register(&pdev->dev,
							    &rgb->zone[i]);
		if (ret)
			return dev_err_probe(&pdev->dev, ret,
					     "bolge %d kaydedilemedi\n", i);
	}

	/*
	 * Genel parlaklik ayri bir LED. Adi bilerek "omen::kbd_backlight" -
	 * masaustu ortamlari ve upower klavye isigini *::kbd_backlight
	 * kalibiyla ariyor, boylece parlaklik tuslari calisiyor.
	 */
	rgb->kbd_bl.name = "omen::kbd_backlight";
	rgb->kbd_bl.max_brightness = BRIGHTNESS_MAX;
	rgb->kbd_bl.brightness_get = omen_bl_get;
	rgb->kbd_bl.brightness_set_blocking = omen_bl_set;
	rgb->kbd_bl.brightness = omen_bl_get(&rgb->kbd_bl);

	ret = devm_led_classdev_register(&pdev->dev, &rgb->kbd_bl);
	if (ret)
		return dev_err_probe(&pdev->dev, ret,
				     "parlaklik LED'i kaydedilemedi\n");

	dev_info(&pdev->dev, "%d bolge RGB klavye hazir\n", ZONE_COUNT);
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
	 * DMI listesi tutmuyoruz - kart basina yama gerektiriyor ve
	 * Faz 2'de basimiza acilan is tam olarak buydu. Onun yerine
	 * yetenegi soruyoruz: parlaklik okunabiliyorsa aydinlatma
	 * grubu bu makinede destekleniyor demektir.
	 */
	ret = omen_wmi_query(LIGHTING_BRIGHT_GET, probe_buf, 0,
			     sizeof(probe_buf));
	if (ret) {
		pr_info("aydinlatma komut grubu desteklenmiyor (%d)\n", ret);
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

MODULE_DESCRIPTION("HP OMEN 16-ap0xxx (8D24) 4 bolge RGB klavye");
MODULE_AUTHOR("WinTone");
MODULE_LICENSE("GPL");
MODULE_ALIAS("wmi:" HPWMI_BIOS_GUID);
