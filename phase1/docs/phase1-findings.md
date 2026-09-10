# Faz 1 — Protokol Çıkarımı (HP OMEN 16-ap0xxx)

Tüm bulgular canlı sistemden alınan ACPI tablolarının `iasl` ile çözülmesinden gelir.
Kaynak: `phase1/acpi/DSDT.aml` → `DSDT.dsl` (118.949 bayt AML / 829.887 bayt ASL).
Her satırda `DSDT.dsl` satır numarası verilmiştir — hepsi doğrulanabilir.

## 0. Donanım kimliği

| Alan | Değer |
|---|---|
| Model | HP OMEN Gaming Laptop 16-ap0xxx |
| SKU | C12CPEA#AB8 |
| Anakart | HP 8D24, rev 43.40 |
| BIOS | AMI F.11 (HPQOEM-1072009), 2025-12-16 |
| CPU | AMD Ryzen AI 9 365 (Strix Point, Radeon 880M) |
| DSDT OEM ID | HPQOEM / 8D24 |

AMD işlemci → Faz 2'de `amd_pstate` kullanılabilir.

## 1. WMI arayüzü (`_WDG`)

DSDT'de üç ayrı `_WDG` bloğu var. Fan/termal için önemli olan orta bloktur (AML ofset 0xA9C8, 14 kayıt):

| GUID | Nesne | Tür | Not |
|---|---|---|---|
| `5FB7F034-2C63-45E9-BE91-3D44E2C707E4` | **WMAA** | Method | **Ana HP BIOS komut arayüzü.** Linux `hp-wmi` bunu `HPWMI_BIOS_GUID` olarak kullanır |
| `95F24279-4D7B-4334-9387-ACCDC67EF61C` | `_WED` (0x80) | Event | Hotkey olayları; `hp-wmi`'deki `HPWMI_EVENT_GUID` |
| `2B814318-4BE8-4707-9D84-A190A859B5D0` | `_WED` (0xA0) | Event | İkinci olay kanalı |
| `1F4C91EB-DC5C-460B-951D-C7CB9B4B8D5E` | WMBA | Method | HP BIOS yapılandırma (BCU) |
| `7391A661-223A-47DB-A77A-7BE84C60822D` | WMAC | Method | `_HID = "HPIC0004"` cihazına ait |
| `2D114B49-…` / `988D08E3-…` / `14EA9746-…` | WQBC/BD/BE | Data | BIOS ayar numaralandırması (93/30/2 örnek) |

Diğer iki blok: `B2526ED4-CB45-49FA-9230-8D2FE8AFB8EC` (WMMK) ve
`928B5A30-AD7C-4C36-946A-1300A80CE7E1` (WMCA).

**`HPIC0004` DSDT'de zaten tanımlı** (satır 19610) — Faz 2'de DSDT yamasına
muhtemelen gerek yok.

## 2. WMAA çağrı protokolü

`WMAA` (satır 10202) sadece kilit alıp `HWMC(Arg1, Arg2)` çağırır.
Asıl dağıtıcı `HWMC` (satır 8645–9733).

Giriş tamponu düzeni (`HWMC` başı, satır 8647–8650):

| Ofset | Alan | Anlam |
|---|---|---|
| 0x00 | `SGIN` | İmza, **`0x55434553`** (`"SECU"`) olmalı |
| 0x04 | `COMD` | Komut grubu |
| 0x08 | `CMDT` | Komut tipi (alt komut) |
| 0x0C | `DSZI` | Giriş verisi boyutu (bayt) |
| 0x10 | veri | `DSZI` kadar veri |

`Arg0` çıkış tampon boyutunu seçer: 1→0, 2→4, 3→128, 4→1024, 5→4096 bayt.
Dönüş: `SIOU` (0x4C494146 = `"FAIL"` başlangıç değeri) + `RETC` durum kodu.
`RETC = 0` başarı; 2/3/4/5 çeşitli hata durumları.

### Komut grupları (`COMD`)

| COMD | Kapsam | Alt komut sayısı |
|---|---|---|
| `0x01` | BIOS okuma (genel HP) | 36 |
| `0x02` | BIOS yazma (genel HP) | 26 |
| `0x00020002` | CSTA/CACT/CDAC/CAIP | 4 |
| **`0x00020008`** | **Gaming / OMEN — fan, termal, güç profili** | **55 (GM01–GM37)** |
| `0x00020009` | Aydınlatma / RGB (LM01–LM0B) | 11 |
| `0x0002000B` | ACPD | 1 |
| `0x00020000` | GASC | 2 |

`0x00020008` grubu, Linux `hp-wmi` sürücüsündeki `HPWMI_GM_COMMAND` ile aynıdır.

## 3. Fan ve termal komutları (COMD `0x00020008`)

GM metotlarının 55'inden 19'u gerçek EC erişimi yapar; kalanı boş saplama.
Fan/termal ile ilgili olanlar:

| CMDT | Metot | Dokunduğu EC register | İşlev |
|---|---|---|---|
| **0x2D** | GM2D | `RB00`–`RB30` (EC 0xB0–0xB3) | **Fan hızı oku (takometre)** |
| **0x2E** | GM2E | `SRP1`, `SRP2` (EC 0x34, 0x35) | **Fan hızı yaz (manuel kontrol)** |
| **0x26** | GM26 | `REC2` (EC 0xEC bit 2) | **Maks. fan durumu oku** |
| **0x27** | GM27 | `FFFS` (EC 0xEC bit 2) | **Maks. fan aç/kapat** |
| **0x1A** | GM1A | `HPCM` (EC 0x95), `FAMC` (EC 0x51 bit 0) | **Güç profili + fan manuel modu aç** |
| 0x11 | GM11 | `FMR1/2`, `FSUS`, `FS1H/L`, `FS2H/L` | Fan bilgisi oku (fan seçimi: giriş baytı 0/1) |
| 0x10 | GM10 | `OMCC` (EC 0x62 bit 0) | OMEN modu etkinleştir (sabit 0x02 döner) |
| 0x2A | GM2A | EC 0x37, 0x38, 0x39, 0x58 | Termal eşik/politika |
| 0x29 | GM29 | `OSPT`, `OSPL` (EC 0x38, 0x37) | Termal politika |
| 0x2B | GM2B | EC 0xE2 | — |
| 0x22 | GM22 | `NVDO` (EC 0x90) | dGPU ile ilgili |
| 0x23 | GM23 | EC 0x48 | — |
| 0x28 | GM28 | EC 0xEA, 0x53 bit 1 | — |
| 0x33 | GM33 | `R455` (EC 0x45 bit 5) | — |
| 0x34 | GM34 | `ETEG` (EC 0x45 bit 6) | — |

Aydınlatma (COMD `0x00020009`): LM02/LM03 → `LRGB`/`BRGB` (klavye RGB bölgeleri),
LM04/LM05 → `LBRT` (parlaklık), LM03/LM05 → `LCMC`.

### 3.1 Fan hızı okuma — GM2D (satır ~13760, `extract/GM-LM-methods.asl`)

```
fan1_ham = (EC[0xB1] << 8) | EC[0xB0]
fan2_ham = (EC[0xB3] << 8) | EC[0xB2]
cikti[0] = round(fan1_ham / 100)     // 100'e böl, kalan >= 50 ise yukarı yuvarla
cikti[1] = round(fan2_ham / 100)
```

Çıkış tamponu 128 bayt; ilk iki bayt anlamlı.
**Birim: yüz RPM.** Yani `cikti[0] = 42` → ~4200 RPM.

### 3.2 Fan hızı yazma — GM2E

```
EC[0x34] (SRP1) = giris[0]     // fan 1 hedefi
EC[0x35] (SRP2) = giris[1]     // fan 2 hedefi
```

Giriş tamponu 128 bayt (`DSZI = 0x80`). GM2D ile simetrik olduğundan
**birim yine yüz RPM.** Metot önce `WSMI(0x00020008, 0x2E, 0x80, 0, 0)`
ile BIOS'a SMI atar, sonra EC'ye doğrudan yazar.

`ECON == 1` (EC hazır) değilse yazma sessizce atlanır.

### 3.3 Güç profili ve manuel mod — GM1A

```
EC[0x95] (HPCM) = giris[1]     // performans/termal profil
CMSW(0xE6, giris[1])           // BIOS'a SMI
EC[0x51] bit0 (FAMC) = giris[2]  // fan manuel kontrol
```

`FAMC` = **Fan Manual Control**.

`HPCM`'in geçerli değerleri DSDT'de sabit olarak görünmüyor — bunlar canlı
yakalamayla tespit edildi: **48 / 49 / 4**, bkz. bölüm 6.1.

Yakalama ayrıca beklenen bir varsayımı **çürüttü**: OGH manuel fan modunda bile
`FAMC`'yi hiç 1 yapmıyor (`giriş[2]` hep 0). Manuel kontrol yalnızca `0x2E`
setpoint'ini sürekli yazarak sağlanıyor. Bkz. bölüm 6.1 ve 6.4.

## 4. EC register haritası

DSDT'de tek bir `EmbeddedControl` bölgesi var (satır 21578):

```
OperationRegion (ERAM, EmbeddedControl, Zero, 0xFF)
```

Yani standart ACPI EC penceresi **0x00–0xFE**. Tam alan listesi:
`phase1/extract/ec-eram-field.asl`

Fan/termal açısından önemli olanlar:

| Adres | Ad | Genişlik | Anlam |
|---|---|---|---|
| 0x34 | `SRP1` | 8 | **Fan 1 hedef hızı (yüz RPM)** |
| 0x35 | `SRP2` | 8 | **Fan 2 hedef hızı (yüz RPM)** |
| 0x37 | `OSPL` | 8 | Termal politika |
| 0x38 | `OSPT` | 8 | Termal politika |
| 0x39 | `OFPT` | 8 | Termal politika |
| 0x51 bit 0 | `FAMC` | 1 | **Fan manuel kontrol etkin** |
| 0x57 | `RTTP` | 8 | Sıcaklık |
| 0x58 | `RTMP` | 8 | Sıcaklık |
| 0x59 | `TRTM` | 8 | Sıcaklık |
| 0x62 bit 0 | `OMCC` | 1 | OMEN modu |
| 0x95 | `HPCM` | 8 | **Güç/termal profil** |
| 0xAF | `GPUT` | 8 | GPU sıcaklığı |
| 0xB0–0xB1 | `RPM1`,`RPM2` | 8+8 | **Fan 1 takometre (LE 16-bit)** |
| 0xB2–0xB3 | `RPM3`,`RPM4` | 8+8 | **Fan 2 takometre (LE 16-bit)** |
| 0xB7 | `GTMP` | 8 | GPU sıcaklığı 2 |
| 0xC9 | `GTM2` | 8 | GPU sıcaklığı 3 |
| 0xEC bit 1 | `FFFF` | 1 | Fan tam güç (bayrak) |
| 0xEC bit 2 | `FFFS` | 1 | **Maks. fan aç/kapat** |

### 4.1 Genişletilmiş EC RAM — belleğe eşlenmiş pencere

Bu makinede EC RAM'in tamamı ayrıca **fiziksel `0xFE700000` adresinde 4 KB'lık
bir pencereye** eşlenmiş (satır 21215):

```
OperationRegion (H2RA, SystemMemory, 0xFE700000, 0x1000)
```

Eşleme kuralı — alan adlarından doğrulandı (`R290` @0x329, `R400` @0x340,
`RF70` @0x3F7 hepsi tutarlı):

```
EC register N  ==  fiziksel 0xFE700000 + 0x300 + N
```

Bu, standart EC penceresinin (0x00–0xFE) **ötesindeki** register'lara erişimin
tek yolu. Fan eğrisi tabloları orada:

| H2RA ofseti | EC adresi | Ad | Anlam |
|---|---|---|---|
| 0x1B7 | — (0x300 altı) | `FSUS` | Fan durumu |
| 0x527 | 0x227 | `FMR1` | Fan 1 maks. RPM |
| 0x52F | 0x22F | `FMR2` | Fan 2 maks. RPM |
| 0x530 | 0x230 | `FS1H` | Fan 1 hız, yüksek bayt |
| 0x531 | 0x231 | `FS1L` | Fan 1 hız, düşük bayt |
| 0x532 | 0x232 | `FS2H` | Fan 2 hız, yüksek bayt |
| 0x533 | 0x233 | `FS2L` | Fan 2 hız, düşük bayt |
| 0x534 | 0x234 | `FAS1` | Fan 1 — |
| 0x535 | 0x235 | `FAS2` | Fan 2 — |

Ayrıca `LRGB` (@0xEE3), `BRGB` (@0xEF0), `LBRT` — klavye RGB, aynı pencerede.

Tam liste: `phase1/extract/ec-h2ra-field.asl`

## 5. Faz 2 için en önemli sonuç

Bu makinenin fan protokolü, **upstream Linux `hp-wmi` sürücüsündeki Victus S
manuel fan desteğiyle bire bir aynı**:

- `hp-wmi`'nin `HPWMI_FAN_SPEED_MAX_GET_QUERY = 0x26` / `SET = 0x27` → GM26/GM27 ✓
- Victus S manuel fan yazma sorgusu `0x2E` → GM2E ✓ (aynı `SRP1`/`SRP2` hedefi)
- Fan hızı okuma `0x2D` → GM2D ✓
- Komut grubu `0x20008` ✓, imza `"SECU"` ✓

Dolayısıyla Faz 2'de büyük olasılıkla **yeni sürücü yazmaya gerek yok** —
`hp-wmi`'nin bu modeli tanıması (DMI eşleşmesi / model listesi) yeterli olabilir.
İlk iş bunu Linux'ta doğrulamak.

## 6. Canlı yakalama — OMEN Gaming Hub log'undan

Kaynak: OGH kendi log'una giden WMI giriş baytlarını yazıyor.
`%LOCALAPPDATA%\Packages\AD2F1837.OMENCommandCenter_v10z8vjag6ke6\LocalCache\Local\HPOMEN\`
altında `HPOMEN_*.log` (ön yüz) ve `HPOMENBG_*.log` (arka plan servisi):

```
SetFanModeAsync(), mode = L7
[ExecuteBiosWmiCommandThruDriver] inputData=255,49,0,0,
```

> Not: `Microsoft-Windows-WMI-Activity/Trace` ETW kanalı bu iş için **yetersiz** —
> yalnızca hangi sınıf/metodun çağrıldığını kaydeder, argüman baytlarını kaydetmez,
> üstelik açmak için yönetici gerekir. OGH log'u doğrudan baytları verdiği için
> ETW trace'ine gerek kalmadı.

### 6.1 `HPCM` profil değerleri (doğrulandı)

OGH'de dört profil tek tek seçilip log'dan yakalandı (2026-09-10 18:48):

| OGH düğmesi | İç ad | GM1A payload | **HPCM (EC 0x95)** |
|---|---|---|---|
| ECO | `Eco` | `255,48,0,0` | **48** (0x30) |
| Balanced | `L2` | `255,48,0,0` | **48** (0x30) |
| Performance | `L7` | `255,49,0,0` | **49** (0x31) |
| Unleashed | `L8` | `255,4,0,0` | **4** (0x04) |

Payload düzeni GM1A ile birebir uyuyor: `[0]` kullanılmıyor (0xFF),
`[1]` → `HPCM`, `[2]` → `FAMC`.

Üç önemli sonuç:

1. **ECO ayrı bir firmware profili değil.** Log'da `RegKeyMode has value=Eco`
   yazdıktan hemen sonra `SetFanModeAsync(), mode = L2` çağrılıyor ve aynı
   `HPCM = 48` gönderiliyor. ECO, Windows güç planı / PL1 seviyesinde
   uygulanıyor. Yani firmware tarafında **yalnızca üç termal profil var: 48, 49, 4.**
2. **`FAMC` hiçbir zaman 1 yapılmıyor.** Manuel fan modunda bile `[2] = 0`.
   OGH manuel kontrolü `FAMC` ile değil, `0x2E` setpoint'ini sürekli yazarak
   yapıyor.
3. Değerler ardışık değil (48/49/4) — sırayla numaralandırılmış bir enum değil.

### 6.2 Max Fan (0x27) — doğrulandı

Arayüzdeki termal anahtar MAX'a alınıp Auto'ya döndürüldü (2026-09-10 18:53–18:54):

```
OnThermalModeClick - mode=Max
  SetFanModeAsync(), mode = L2   -> inputData=255,48,0,0     (HPCM degismiyor, tekrar gonderiliyor)
  SetMaxFan(), mode = On         -> inputData=1,             <- GM27
OnThermalModeClick - mode=Auto
  SetFanModeAsync(), mode = L2   -> inputData=255,48,0,0
  SetMaxFan(), mode = Off        -> inputData=0,
```

- `FFFS = giriş[0]`; **1 = açık, 0 = kapalı**.
- Payload **tek bayt** (`DSZI = 1`) — GM27 yalnızca `WBUF[0]`'ı okuyor, uyumlu.
- MAX modu da `FAMC`'ye dokunmuyor.
- **Max Fan açıkken OGH periyodik `0x2E` yazımlarını tamamen durduruyor.**
  18:53:52 ile 18:54:10 arasında tek bir setpoint yazımı yok; ilki Auto'ya
  dönüldükten sonra 18:54:11'de geliyor. Yani `FFFS=1` iken kontrolü EC
  devralıyor ve yazılım eğrisi devre dışı kalıyor.

### 6.3 Fan birimi — deneysel doğrulama

Manuel modda kaydırıcı 3800 RPM'e getirildiğinde (arayüzde "System fan (3800 RPM)"),
log'a düşen 0x2E payload'u:

```
inputData=38,41,0,0,0,0,...   (128 bayt)
```

`38` → 3800 RPM. Kaydırıcı yükseltilince `44,46` (4400/4600 RPM) yazıldı.
**Birim = yüz RPM, kesin.** İkinci fan birinciden birkaç birim farklı sürülüyor.

Aynı sonuç `profiles.json`'daki fan eğrisi tablosundan da geliyor:
hız listeleri 18/24/30/33, sınırlar `Lower=18` / `Upper=48` → 1800–4800 RPM.

### 6.4 Fan eğrisi yazılımda işletiliyor

"Auto" termal modda bile OGH arka plan servisi periyodik olarak `0x2E` yazıyor
(`inputData=21,19,…` / `24,21,…`). Yani HP'nin otomatik fan eğrisi **tamamen
EC'de değil, Windows uygulamasında** koşuyor.

→ Faz 2'de yalnızca sürücü yetmez; sıcaklığa göre setpoint yazan bir
kullanıcı-alanı daemon'ı da gerekecek. (`alou-S/omen-fan` ve
`arfelious/omen-fan-control` tam olarak bunu yapıyor.)

### 6.5 Güç limiti / dGPU (kısmi)

Profil değişimlerinde 4 baytlık şu payload'lar da gidiyor:

| Payload | Profil | Yorum |
|---|---|---|
| `255,255,255,45` | L2 (Balanced) | GM29 semantiğiyle uyumlu: `[0..2]=0xFF` → atla, `[3]=45` → `DATP = 45*8` |
| `255,255,255,65` | L8 (Unleashed) | `[3]=65` → `DATP = 65*8` |

GM29 bu değeri `NPCF.DATP`'ye yazıp `CMSW(0x2A, …)` + `Notify(NPCF, 0xC0)`
yapıyor — NPCF = NVIDIA platform denetleyicisi, yani bu büyük olasılıkla
**dGPU dinamik boost / TGP limiti** (Balanced 45 → Unleashed 65).
Kesin birim doğrulanmadı.

`0,1,1,87` ve `0,0,1,87` gibi başka 4 baytlık payload'lar da var; 4 baytlık
şekli birden çok komut paylaştığı için bunlar komut ID'sine bağlanamadı
(log komut ID'sini yazmıyor).

## 7. Açık kalanlar

1. **SSDT'ler eksik.** Windows'un `GetSystemFirmwareTable` API'si aynı imzalı
   28 SSDT'nin yalnızca ilkini veriyor; kalan 27'si alınamadı. Linux'ta
   `/sys/firmware/acpi/tables/` hepsini verir. Fan mantığı DSDT'de olduğu için
   bu şu an engel değil.
2. **`FAS1`/`FAS2` ve `FMR1`/`FMR2` birimleri** doğrulanmadı (RPM mi, yüz RPM mi).
3. **EC diff, OGH decompile ve WMI ETW trace adımları yapılmadı** — DSDT fan
   protokolünün tamamını, OGH log'u da profil bayt değerlerini verdiği için
   hiçbirine gerek kalmadı. Devir notundaki bu üç adım kapatılabilir.

## Dosyalar

| Yol | İçerik |
|---|---|
| `phase1/acpi/*.aml` | Canlı sistemden alınan 17 ACPI tablosu |
| `phase1/acpi/DSDT.dsl` | Çözülmüş DSDT (830 KB) |
| `phase1/extract/ec-eram-field.asl` | EC 0x00–0xFE alan haritası |
| `phase1/extract/ec-h2ra-field.asl` | Belleğe eşlenmiş genişletilmiş EC RAM haritası |
| `phase1/extract/HWMC.asl` | WMI komut dağıtıcısı (1089 satır) |
| `phase1/extract/GM-LM-methods.asl` | 55 gaming + 11 aydınlatma metodu |
| `tools/iasl.exe` | ACPICA 20260408 |
