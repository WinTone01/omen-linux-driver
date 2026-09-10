# Faz 3 — Fan eğrisi, RGB ve arayüz

Faz 1: [protokol çıkarımı](../../phase1/docs/phase1-findings.md) ·
Faz 2: [`hp-wmi` 8D24 desteği](../../phase2/docs/phase2-plan.md) — ikisi de tamamlandı.

## 0. Kapsam

Bu makinede (OMEN 16-ap0xxx / 8D24) Windows'taki OMEN Gaming Hub'ın yerini
tutacak kadar işlev:

- **Fan eğrisi** — sıcaklığa göre otomatik setpoint (Faz 1 §6.4: HP'nin "Auto"
  eğrisi EC'de değil, uygulamada koşuyor; sürücü tek başına yetmiyor)
- **Termal profiller** — Balanced / Performance / Unleashed
- **4 bölge RGB klavye** — bu makinede Linux'ta şu an tamamen ölü
  (`/sys/class/leds/` altında klavye yok)
- **CLI + daemon + web arayüzü**

## 1. Mimari kararı

Üç katman, her biri ayrı ayrı kullanılabilir ve ayrı ayrı upstream'e gidebilir:

```
  ┌─ userspace ────────────────────────────────────────────┐
  │  web GUI (127.0.0.1)  ──┐                              │
  │  omenctl (CLI)        ──┼──> omend (daemon, root)      │
  └─────────────────────────┼──────────────────────────────┘
                            │  standart sysfs
  ┌─ çekirdek ──────────────┼──────────────────────────────┐
  │  hp-wmi (in-tree+8D24)  │  omen-kbd-rgb (yeni modül)   │
  │   hwmon pwm1/fan*_input │   leds-multicolor × 4 bölge  │
  │   platform_profile      │                              │
  │   WMI grubu 0x020008    │   WMI grubu 0x020009         │
  └────────────────────────────────────────────────────────┘
```

### Neden monolitik bir out-of-tree sürücü değil

`OmenLinux/omen-rgb-keyboard` fan + RGB'yi tek modülde topluyor ve bu yüzden
`blacklist hp_wmi` göndermek zorunda kalıyor — kendi fan kontrolü `hp-wmi` ile
aynı EC register'larına (`0x34`/`0x35`) yazıyor.

Bizde bu zorunluluk yok. Faz 2'de doğrulandı: `hp-wmi` GUID'i **sahiplenmiyor**,
`wmi_evaluate_method(HPWMI_BIOS_GUID, ...)` ile çağrı yapıp kendisi bir
`platform_driver` olarak kayıt oluyor. Aynı GUID'i başka bir modül de
kullanabilir. Fan grubu (`0x020008`) ile aydınlatma grubu (`0x020009`) ayrık
olduğundan **sadece RGB yapan bir modül `hp-wmi` ile yan yana çalışır.**

Kazanç: fan tarafı in-tree kalır (sıfır bakım, standart `hwmon`), RGB tarafı
küçük ve tek işlevli bir modül olur, userspace her ikisine de standart sysfs
üzerinden konuşur. Çekirdek yükseltmeleri yalnızca RGB modülünü ilgilendirir.

### Standart arayüzlere bağlanma ilkesi

Kendi sysfs ağacımızı icat etmiyoruz. Fan `hwmon`, profil `platform_profile`,
RGB `leds-multicolor` — hepsi çekirdeğin var olan sınıfları. Böylece `sensors`,
`fancontrol`, KDE/GNOME güç ayarları, `upower` gibi mevcut araçlar bizim
projemizden habersiz çalışır. Bizim arayüzümüz tek seçenek değil, en iyi
seçenek olur.

## 2. Bileşenler

### 2.1 `omen-kbd-rgb` — çekirdek modülü

Faz 1 §4.1'den gelen harita:

| Alan | Genişlik | Anlam |
|---|---|---|
| `LRGB` | 96 bit | **12 bayt = 4 bölge × RGB** |
| `BRGB` | 96 bit | ikinci 12 baytlık set |
| `LBRT` | 8 bit | parlaklık |
| `LCMC` | 1 bit | mod bayrağı |

WMI yolu (Faz 1 §3, `GM-LM-methods.asl`): komut grubu `0x020009`,
`LM02` oku / `LM03` yaz (12 bayt, çıkış tamponu ofset `0x19`),
`LM04`/`LM05` parlaklık.

sysfs (standart `leds-multicolor`):

```
/sys/class/leds/omen::kbd_backlight_zone{0..3}/multi_intensity
/sys/class/leds/omen::kbd_backlight/brightness
```

DMI eşleştirmesi **yapılmayacak** — WMI GUID'i ve `_WDG` kaydı varsa bağlanır.
Kart listesi tutmak her yeni model için yama gerektiriyor; `hp-wmi`'nin Faz 2'de
başımıza açtığı iş tam olarak buydu.

### 2.2 `omend` — daemon

Fanın otomatik eğrisini işleten servis. Faz 1 §6.4'te saptandığı gibi bu iş
zorunlu: HP'nin kendi "Auto" modu bile yazılımda koşuyor.

- **Girdi:** `k10temp` Tctl, `amdgpu` edge, EC `0xAF`/`0xB7` (GPU sıcaklığı)
- **Çıktı:** `hwmon/pwm1` (manuel modda), `platform_profile`
- **Eğri:** kullanıcı tanımlı nokta listesi; başlangıç değeri olarak OGH'nin
  kendi tablosu (Faz 1 §6.3) — 50–65°C: 1800 RPM, 70–85°C: 2400, 90°C: 3300
- **Histerezis + minimum bekleme:** fan yalpalamasını (hunting) önlemek için
  düşüş eşiği yükseliş eşiğinden ayrı, ve setpoint değişimleri arası asgari süre
- **Sınırlar:** 18–48 (1800–4800 RPM), Faz 1 §6.3'teki `profiles.json` sınırları

### 2.3 `omenctl` + web arayüzü

`omend` ile aynı binary, alt komut olarak. Web arayüzü daemon'ın `127.0.0.1`
üzerinde sunduğu HTTP + WebSocket'e bağlanır (canlı sıcaklık/RPM akışı).

## 3. Dil seçimi

- **Çekirdek modülü: C.** Seçenek yok.
- **Daemon + CLI: Rust.** Tek statik binary, çalışma zamanı bağımlılığı yok,
  root olarak koşacak bir servis için bellek güvenliği anlamlı, `axum` ile
  HTTP+WS aynı binary'de. Python olsaydı her dağıtımda venv/paket derdi olurdu.
- **Web arayüzü:** derleme adımı olmayan sade HTML+JS. Daemon binary'sine gömülür.

## 4. Güvenlik — pazarlık edilmez

Faz 1 ve 2 boyunca tekrarlanan uyarı: **yanlış EC yazımı fanı tamamen
durdurabilir ve termal koruma her zaman devreye girmez.**

Daemon'ın uyacağı kurallar:

1. **Çıkışta mutlaka otomatiğe dön.** `pwm1_enable = 2`. Normal kapanış,
   panic, SIGKILL sonrası systemd `ExecStopPost` — üç yoldan da.
2. **Sıcaklık sigortası.** Yapılandırılabilir bir eşiğin üstünde (varsayılan
   90°C) eğriyi bırak, otomatiğe düş ve logla. Yazılım hatası fanı düşük
   tutuyorsa donanım kendi eğrisine dönsün.
3. **Watchdog.** Sıcaklık okuması başarısız olursa eğriyi işletme, otomatiğe düş.
   Bilinmeyen durumda sessizce son setpoint'te kalmak en tehlikeli davranış.
4. **Sınır denetimi.** Setpoint 18–48 aralığına kelepçelenir; yapılandırma
   dosyası ne derse desin.
5. **Yazma yetkisi yalnız daemon'da.** CLI ve web arayüzü EC'ye veya sysfs'e
   doğrudan yazmaz; unix socket üzerinden daemon'a istek gönderir.

## 5. Sıra

| # | İş | Neden bu sırada |
|---|---|---|
| M1 | `omend` fan eğrisi + `omenctl` | Faz 2 zaten `pwm1`'i açtı; en çok işe yarayan eksik parça bu |
| M2 | `omen-kbd-rgb` modülü | Harita hazır, ama çekirdek kodu yazmak daha uzun |
| M3 | Web arayüzü | Altındaki iki katman oturduktan sonra |
| M4 | Paketleme (systemd, udev, DKMS, PKGBUILD) | — |
| M5 | Upstream `8D24` yaması | Faz 2'nin kalan işi, diğerlerinden bağımsız |

## 6. `OmenLinux` depolarından ne aldık

Kod değil, bilgi:

- **`0x2F` = `VICTUS_FAN_TABLE_GET`** — Faz 1'de GM2F "boş saplama" sayılmıştı;
  onlar manuel eğri için kullanıyor. Faz 1 belgesi güncellenmeli.
- Onların `omen_wmi.h`'sindeki sabitler (`0x020008`, `0x020009`, `0x1A`, `0x26`,
  `0x27`, `0x2D`, `0x2E`) bizim DSDT'den çıkardıklarımızla birebir aynı —
  Faz 1'in bağımsız doğrulaması.
- Neyi **yapmamamız** gerektiği: `blacklist hp_wmi`. Onların mimarisi gerektiriyor,
  bizimki gerektirmiyor (§1).

Kod kopyalanmadı. Kopyalanırsa GPL-2.0 gereği kaynak ve yazar belirtilmeli;
bu proje de GPL-2.0-only olduğu için lisans uyumlu, ama atıf zorunlu.

Karşılık olarak onlara gidebilecek şey: Faz 1'in `16-ap0xxx` RGB haritası —
destekledikleri modeller arasında bu aile yok.
