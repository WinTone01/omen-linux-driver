# Faz 2 — Linux Tarafı Planı

Faz 1 çıktısı: [`phase1/docs/phase1-findings.md`](../../phase1/docs/phase1-findings.md)

## 0. Özet karar

**Yeni sürücü yazılmayacak.** Bu makinenin fan/termal protokolü upstream
`hp-wmi` sürücüsünün desteklediğiyle birebir aynı; eksik olan tek şey
**kartın DMI tablosunda kayıtlı olmaması**.

Gereken iş üç parçaya iniyor:

1. `hp-wmi`'ye tek satırlık DMI eklemesi (board `8D24`)
2. Fan eğrisini işletecek bir kullanıcı-alanı daemon'ı
3. dGPU runtime PM'in ayrı ele alınması (bu projenin kapsamı dışında ama
   pil ömrünün asıl sebebi orası)

## 1. Upstream durumu (2026-09-10 itibarıyla, `torvalds/linux` master)

`drivers/platform/x86/hp/hp-wmi.c` içindeki `hp_wmi_feature_boards[]` tablosu
26 kart içeriyor: 8902, 8A3D, 8A44, 8A4D, 8BAA, 8BA9, 8BAB, 8B2F, 8BB3, 8BBE,
8BC2, 8BCA, 8BCD, 8BD4, 8BD5, 8C76, 8C77, 8C78, 8C99, 8C9C, 8D26, 8D41, 8D87,
8D88, 8DD6, 8E35.

**`8D24` dosyanın hiçbir yerinde geçmiyor.**

Ama şu iki commit dikkat çekici (her ikisi de 2026-06-09):

- *"Add support for Omen 16-ap0xxx (**8D26**)"*
- *"Add support for Omen 16-ap0xxx (**8E35**)"*

Yani **bizim model ailesi (16-ap0xxx) zaten destekleniyor**; HP bu aile altında
birden çok kart revizyonu sevk etmiş ve bizimki (8D24) henüz gönderilmemiş.
Bu, işi "protokol çıkarımı"ndan "tabloya bir satır ekleme"ye indiriyor.

### Çekirdek sürümü — hangisi yeter?

Bugünkü durum: mainline **7.3-rc2**, kararlı **7.2.4** (7.2 → 2026-08-16).

`v7.2` etiketindeki dosya doğrudan kontrol edildi:

| | 7.2 | 7.3 (master) |
|---|---|---|
| `HPWMI_VICTUS_S_FAN_SPEED_SET_QUERY = 0x2E` | ✓ var | ✓ var |
| hwmon PWM fan kontrolü | ✓ var | ✓ var |
| `8D26` kaydı (kardeş kart) | ✓ var | ✓ var |
| DMI dizisinin adı | `victus_s_thermal_profile_boards[]` | `hp_wmi_feature_boards[]` |
| `driver_data` | `&omen_v1_legacy_thermal_params` | `&omen_v1_legacy_board_params` |
| `8D24` | ✗ yok | ✗ yok |

**Sonuç: 7.2 zaten yeterli.** 2026-07-09'daki değişiklik fan desteğini
*eklemedi*, mevcut kodu board-parametresi yapısına taşıdı (dizi adı ve
`driver_data` tipi değişti). Yani kararlı 7.2 ile çalışılabilir; yamanın
biçimi sadece sürüme göre farklı yazılır.

### Binary üzerinde doğrulandı (2026-09-10)

Hedef dağıtım **CachyOS, kernel 7.2.3-1-cachyos**. `verify.sh` bu çekirdeğin
`hp-wmi.ko.zst` dosyasındaki DMI string'lerini çıkardı — 76 kart:

```
84DA 84DB 84DC 8572 8573 8574 8575 8600..8607 860A 8746..874A 8786..8788
878A..878C 87B5 886B 886C 88C8 88CB 88D1 88D2 88F4..88F8 88FD..88FF
8900 8901 8902 8912 8917 8918 8949 894A 89EB 8A15 8A25 8A42 8A44 8A4D
8B2F 8BAB 8BAD 8BBE 8BC2 8BCA 8BCD 8BD4 8BD5 8C58 8C76 8C77 8C78 8C99
8C9C 8D26 8D41 8D87 8E35 8E41
```

- **`8D24` yok** → yama gerekiyor (beklenen)
- **`8D26` var** → çekirdek 16-ap0xxx ailesini tanıyor (beklenen)
- 7.3'te bulunan `8BAA`, `8BA9`, `8BB3`, `8DD6`, `8D88` burada yok — bunlar
  2026-07/08'de eklendi, 7.2'de olmamaları tutarlı

Yani analiz artık yalnızca upstream kaynağa değil, **çalıştırılacak binary'ye**
dayanıyor. Uygulanacak biçim: **7.2 formu**.

> Kısıt: `strings` yöntemi modüldeki tüm DMI dizilerini birleştirir; bir kartın
> hangi dizide olduğunu ayırt etmez. 8D24/8D26 sorusu için yeterli, dizi bilgisi
> kaynaktan biliniyor.

## 2. Hangi parametre seti — gerekçelendirilmiş

Upstream'de dört seçenek var. Faz 1'de yakaladığımız değerlerle karşılaştırma:

| | Faz 1 ölçümümüz | `omen_v1_legacy` | `omen_v1` | `omen_v1_no_ec` | `victus_s` |
|---|---|---|---|---|---|
| Balanced | **0x30** (48) | 0x30 ✓ | 0x30 ✓ | 0x30 ✓ | 0x00 ✗ |
| Performance | **0x31** (49) | 0x31 ✓ | 0x31 ✓ | 0x31 ✓ | 0x01 ✗ |
| EC profil register | **0x95** | **0x95 ✓** | 0x59 ✗ | yok ✗ | yok ✗ |

`omen_v1_legacy_thermal_params.ec_tp_offset = HP_OMEN_EC_THERMAL_PROFILE_OFFSET
= 0x95` — DSDT'de `HPCM`'in adresi de tam olarak 0x95. Diğer üçü tutmuyor:
`omen_v1` 0x59'u kullanıyor, bizde 0x59 = `TRTM` (bir sıcaklık register'ı),
profil değil.

→ **`omen_v1_legacy_board_params`**. Kardeş kart **8D26 de aynısını kullanıyor**,
bu da seçimi ayrıca destekliyor.

### Yama

Kernel 7.2 — `victus_s_thermal_profile_boards[]` dizisine:

```c
	{
		.matches = { DMI_MATCH(DMI_BOARD_NAME, "8D24") },
		.driver_data = (void *)&omen_v1_legacy_thermal_params,
	},
```

Kernel 7.3+ — `hp_wmi_feature_boards[]` dizisine:

```c
	{
		.matches = { DMI_MATCH(DMI_BOARD_NAME, "8D24") },
		.driver_data = (void *)&omen_v1_legacy_board_params,
	},
```

İkisini de otomatik tespit edip uygulayan script:
[`phase2/scripts/add-8d24.sh`](../scripts/add-8d24.sh)

Fan hwmon arayüzü bu eşleşmeye bağlı. 7.2'de kapı şu:

```c
if (attr == hwmon_pwm_input && !is_victus_s_thermal_profile())
	return 0;
```

Yani eşleşme olmadan `pwm*` dosyaları görünmüyor; fan kontrolü sessizce
çalışmıyor. Tek satırlık ekleme hem platform profilini hem PWM'i açıyor.

## 3. Bilinen boşluk: "Unleashed"

OGH'de dört profil var ama firmware tarafında üç değer: 48 / 49 / 4.
Upstream `platform_profile` yalnızca performance / balanced / low-power'ı
eşliyor — yani **Unleashed (HPCM = 4) upstream modelde temsil edilmiyor.**

Ayrıca bir tutarsızlık var: upstream'de `HP_OMEN_EC_FLAGS_TURBO = 0x04` sabiti
*flags* register'ı olan **0x62** ile ilişkili, oysa OGH `4` değerini
**0x95**'e (HPCM) yazıyor. İkisi aynı şey olmayabilir.

Bu bir engel değil (Unleashed'siz de fan + üç profil çalışır) ama makinede
`4` yazıp davranışı gözlemleyerek netleştirilmeli. Kapsamı: opsiyonel iyileştirme.

## 4. Doğrulama sırası (Linux'ta, yamadan önce)

Sıra önemli — önce yamasız hâli ölçüyoruz ki yamanın ne değiştirdiği belli olsun.

```bash
# 1. Kart kimliği beklediğimiz gibi mi
sudo dmidecode -s baseboard-product-name        # 8D24 bekleniyor
uname -r

# 2. hp-wmi yüklü mü, ne sunuyor
lsmod | grep hp_wmi
ls /sys/devices/platform/hp-wmi/
dmesg | grep -i 'hp-wmi\|hp_wmi'

# 3. Platform profil desteği var mı
cat /sys/firmware/acpi/platform_profile_choices 2>/dev/null
cat /sys/firmware/acpi/platform_profile 2>/dev/null

# 4. Fan hwmon geldi mi
for d in /sys/class/hwmon/hwmon*; do echo "$d -> $(cat $d/name)"; done
sensors

# 5. Çekirdek kaynağında 8D24 ve refactor var mı
grep -c '8D24' /usr/src/linux*/drivers/platform/x86/hp/hp-wmi.c 2>/dev/null
grep -c 'hp_wmi_feature_boards' /usr/src/linux*/drivers/platform/x86/hp/hp-wmi.c 2>/dev/null
```

Beklenti: platform_profile muhtemelen gelir (legacy yol), **fan hwmon gelmez**
(board eşleşmesi yok).

### EC'yi doğrudan okuma (çapraz kontrol)

```bash
sudo modprobe ec_sys write_support=0
sudo xxd -s 0x95 -l 1 /sys/kernel/debug/ec/ec0/io     # HPCM
sudo xxd -s 0xB0 -l 4 /sys/kernel/debug/ec/ec0/io     # RPM1..RPM4
```

`0x95` değeri OGH'deki profile göre 0x30/0x31/0x04 olmalı — Faz 1 bulgusunu
Linux tarafında bağımsız olarak doğrular. `0xB0-0xB3` iki fanın takometresi
(little-endian 16-bit, ham RPM).

## 5. Dağıtım seçimi ve yamayı uygulama

### Dağıtım

Ryzen AI 9 365 (Strix Point) zaten güncel çekirdek istiyor; `hp-wmi` tarafı için
de en az **7.2** gerekiyor. Bu ikisi aynı yöne işaret ediyor:

- **Fedora** — 7.2 taşıyor, `kernel-devel` paketiyle modül derlemek kolay, DKMS
  düzgün çalışıyor. Bu iş için en az sürtünmeli seçenek.
- **Arch / CachyOS** — en yeni çekirdek, 7.3'e de hızlı geçer.
- **Ubuntu LTS'ten kaçın** — çekirdeği eski, HWE ile bile 7.2'yi bir süre görmez.

Kurulum sırasında `linux-headers` / `kernel-devel` paketini de kur; yamalı
modülü derlemek için gerekiyor.

### Uygulama

1. Kurulumdan sonra **önce yamasız** `verify.sh` çalıştır — böylece yamanın ne
   değiştirdiği ölçülebilir olur.
2. `add-8d24.sh` ile kaydı ekle, `hp_wmi` modülünü tek başına derle
   (`make -C /lib/modules/$(uname -r)/build M=$PWD modules`), `insmod` ile dene.
3. Çalışıyorsa **DKMS**'e al — çekirdek güncellemelerinde hayatta kalır.
4. `verify.sh`'yi tekrar çalıştır, çıktıları karşılaştır.

Çalıştığı doğrulandıktan sonra **upstream'e gönderilmeli** — 8D26 ve 8E35
kayıtları tam olarak bu şekilde girmiş (ikisi de 2026-06-09), kabul edilme
olasılığı yüksek. Gönderirken Faz 1'deki ölçümler (EC 0x95, 0x30/0x31)
gerekçe olarak kullanılabilir.

## 6. Fan eğrisi daemon'ı

Faz 1'de saptandı: HP'nin "Auto" fan eğrisi EC'de değil, **Windows uygulamasında**
koşuyor (OGH periyodik olarak `0x2E` setpoint yazıyor). Dolayısıyla sürücü tek
başına "otomatik fan" vermez.

Seçenekler:
- **`alou-S/omen-fan`** — sıcaklığa göre setpoint yazan servis
- **`arfelious/omen-fan-control`** — fan eğrisi + watchdog + CLI/GUI, en olgunu

İkisi de EC'ye doğrudan yazıyor; bizim EC harita bilgimizle (`SRP1`=0x34,
`SRP2`=0x35, tako `0xB0-0xB3`, birim **yüz RPM**, aralık 18–48) yapılandırılabilir.
Referans eğri olarak OGH'nin kendi tablosu kullanılabilir
(`profiles.json`'dan alındı, Faz 1 §6.3):

| CPU °C | 50 | 55 | 60 | 65 | 70 | 75 | 80 | 85 | 90 |
|---|---|---|---|---|---|---|---|---|---|
| Fan (yüz RPM) | 18 | 18 | 18 | 18 | 24 | 24 | 24 | 24 | 33 |

Sınırlar: alt 18 (1800 RPM), üst 48 (4800 RPM).

## 7. Güvenlik ve kurtarma

- Yanlış EC baytı fanı **tamamen durdurabilir**; termal koruma her zaman
  devreye girmez. Test sırasında ikinci bir terminalde sıcaklık izlensin:
  `watch -n1 sensors`
- EC durumu **soft reboot'ta kalıcı olabilir**. Kurtarma için tam güç kesme
  gerekebilir (şarj çıkar + pil devre dışı / uzun güç tuşu).
- `ec_sys` yazma desteği yalnızca gerektiğinde açılsın
  (`write_support=1`), iş bitince kaldırılsın.
- DSDT yaması **gerekmiyor** (Faz 1: `HPIC0004` DSDT'de zaten tanımlı), yani
  bozuk DSDT ile boot edememe riski yok.

## 8. Kapsam dışı ama pil ömrünün asıl sebebi

Devir notundaki tespit doğru: pil farkının büyük kısmı NVIDIA dGPU'nun runtime
power management'a girmemesinden geliyor (5–10 W). Bu makinede RTX 5060 var.
Bu proje fan/termal tarafını çözüyor; dGPU tarafı ayrı bir iş
(`nvidia.NVreg_DynamicPowerManagement`, `udev` kuralları, PCIe runtime PM).
Karıştırılmamalı.

---

## 9. Sonuç — makinede doğrulandı (2026-09-11)

Ortam: CachyOS, kernel **7.2.4-1-cachyos**, board 8D24, BIOS F.11.

Yama uygulandı (`victus_s_thermal_profile_boards[]` + `omen_v1_legacy_thermal_params`),
modül out-of-tree derlenip DKMS'e alındı. Yamasız/yamalı karşılaştırma:

| Ölçüm | Yamasız | Yamalı |
|---|---|---|
| `hwmon/pwm1` | **yok** | **var** |
| `pwm1_enable` | var (2 = auto) | var (2 = auto) |
| `fan1_input`, `fan2_input` | var | var |
| profil işleyicileri | `amd-pmf` | `amd-pmf` + **`hp-wmi`** |
| EC `0x95` (HPCM) | 0 (hiç yazılmamış) | **48** = Balanced |
| EC `0x34`/`0x35` (SRP) | 255 (dokunulmamış) | 0 = otomatik |

`dmesg`: `hp_wmi: Registered as platform profile handler`

Fan davranışı (otomatik mod): 45.4°C → 0/0 RPM (fan-stop), 58.6°C → 2400/2100 RPM.
Yani `SRP = 0` fanı kapatmıyor, kontrolü EC'ye devrediyor.

**`HPCM = 48` bu fazın en önemli çıktısı.** Faz 1'de Windows'ta OGH log'undan
yakalanan değer, Linux'ta bambaşka bir yoldan (platform_profile → WMI 0x1A → EC)
aynı çıktı. Protokol çıkarımı bağımsız olarak doğrulanmış oldu.

### Yol boyunca çıkan, planda olmayan üç şey

1. **`platform_profile`'ı yamasız hâlde `amd-pmf` sağlıyordu**, `hp-wmi` değil.
   Strix Point'in AMD PMF sürücüsü kendi işleyicisini kaydediyor. §4'teki
   "platform_profile muhtemelen gelir (legacy yol)" beklentisi bu yüzden
   yanıltıcıydı — profil vardı ama `hp-wmi` sürmüyordu, `HPCM` de bu yüzden 0'dı.
   6.14+ çok-işleyici API'si sayesinde ikisi çakışmadan yan yana çalışıyor.

2. **CachyOS çekirdeği clang+LLD ile derlenmiş.** Out-of-tree modül `LLVM=1`
   olmadan derlenmiyor; kbuild clang'a özgü bayrakları gcc'ye geçirip patlıyor.
   `build-module.sh` artık `.config`'e bakıp kendisi karar veriyor.

3. **`SRP = 0` "fan kapalı" değil, "otomatiğe dön" demek** — upstream'de
   `HP_FAN_SPEED_AUTOMATIC 0x00`. Yamasız hâldeki `0xFF` ise "hiç yazılmamış".

### `hp-wmi` GUID'i sahiplenmiyor

`wmi_evaluate_method(HPWMI_BIOS_GUID, ...)` ile çağrı yapıyor; WMI cihazına
`wmi_driver` olarak bağlanmıyor, kendisi bir `platform_driver`. Yani aynı GUID'i
başka bir modül de kullanabilir. Faz 3'te RGB modülünün `hp-wmi` ile yan yana
çalışabilmesinin sebebi bu — `blacklist hp_wmi` gerekmiyor.

### DKMS ve çekirdek yükseltmesi

DKMS paketi `v7.2` etiketinden indirilmiş kaynağı taşıyor. Çekirdek 7.3'e
geçtiğinde AUTOINSTALL bu kaynağı yeni çekirdeğe karşı derlemeye çalışır ve
`victus_s_thermal_profile_boards[]` / `omen_v1_legacy_thermal_params` isimleri
7.3'te değiştiği için **tutmaz**. O gün:

```bash
sudo dkms remove -m hp-wmi-8d24 -v 7.2 --all
bash phase2/scripts/build-module.sh --install
```

Script etiketi çalışan çekirdekten türetip 7.3 biçimini kendi seçer.

### Kalan iş

Yama upstream'e gönderilmeli (`platform-driver-x86` + `linux-hwmon`). Gerekçe
olarak hem Faz 1 ölçümleri hem buradaki Linux doğrulaması kullanılabilir;
8D26 ve 8E35 kayıtları daha az dayanakla kabul edilmişti.
