# 4 Bölge RGB Klavye Protokolü (8D24)

Kaynak: `phase1/extract/GM-LM-methods.asl` ve `HWMC.asl` — hepsi DSDT'den.
Her satır doğrulanabilir.

## 1. Taşıma

`hp-wmi` ile **aynı** WMI arayüzü, farklı komut grubu:

| | Fan/termal | Aydınlatma |
|---|---|---|
| GUID | `5FB7F034-2C63-45E9-BE91-3D44E2C707E4` | aynı |
| `COMD` | `0x00020008` | **`0x00020009`** |
| İmza | `0x55434553` (`"SECU"`) | aynı |

Giriş tamponu (`HWMC` başı):

```
0x00  SGIN  imza, 0x55434553
0x04  COMD  komut grubu
0x08  CMDT  alt komut
0x0C  DSZI  veri boyutu
0x10  veri  <- DSZI bayt
```

`CreateField(Arg1, 0x80, DSZI*8, DAIN)` — `0x80` **bit** ofseti, yani veri
alanı `0x10`'dan başlıyor. `DSZI <= 0x80` iken `WBUF = DAIN`, yani metotların
gördüğü `WBUF[n]` giriş tamponunda `0x10 + n`.

## 2. Alt komutlar

| `CMDT` | Metot | İşlev |
|---|---|---|
| `0x02` | LM02 | Bölge renklerini oku |
| `0x03` | LM03 | Bölge renklerini yaz |
| `0x04` | LM04 | Parlaklık oku |
| `0x05` | LM05 | Parlaklık yaz |

### LM03 — renk yazma

```
LDAT[0..11] = WBUF[0x19 .. 0x24]        // 12 bayt
LRGB = LDAT ; Stall(15µs)
BRGB = LDAT ; Stall(15µs)
LCMC = One                               // commit
```

Üç nokta dikkat çekiyor:

1. **Veri `WBUF[0x19]`'dan başlıyor** — yani 128 baytlık veri alanının
   25. baytından. Baştan değil.
2. **İki register'a da aynı 12 bayt yazılıyor** (`LRGB` ve `BRGB`), aralarda
   15 µs bekleme var.
3. **`LCMC = 1` bir commit bayrağı** — yazma tek başına yetmiyor.

`Local2 = 0x03` alt komutu ezip sabitliyor, yani firmware `WBUF[0]`'ı
yok sayıp her zaman 12 baytlık bölge yazması yapıyor.

### LM05 — parlaklık yazma

```
LBRT = WBUF[0]
LCMC = One
```

Tek bayt. LM04'teki `Local1 = 0x64` ölü atama, ölçeğin **0–100** olduğunu
ele veriyor.

## 3. EC alanları

`phase1/extract/ec-h2ra-field.asl` — belleğe eşlenmiş genişletilmiş EC RAM
(`0xFE700000`, bkz. Faz 1 §4.1). Standart EC penceresinin (`0x00–0xFE`)
**dışında**, yani `ec_sys` ile okunamaz:

| Alan | Genişlik | Anlam |
|---|---|---|
| `LRGB` | 96 bit | 12 bayt = 4 bölge × 3 |
| `BRGB` | 96 bit | ikinci kopya |
| `LBRT` | 8 bit | parlaklık, 0–100 |
| `LCMC` | 1 bit | commit bayrağı |

## 4. DSDT'nin söylemediği: bayt sırası

DSDT baytları yalnızca kopyalıyor; 3 baytın hangisi kırmızı, bölgelerin
hangi sırada olduğu oradan çıkmıyor. Bu iki bilgi
[`OmenLinux/omen-rgb-keyboard`](https://github.com/OmenLinux/omen-rgb-keyboard)
(GPL-2.0, `src/zones/omen_zones.c`) okunarak doğrulandı — kod kopyalanmadı,
yalnızca protokol bilgisi alındı:

```
offset = 25 + zone * 3
state[offset + 0] = red
state[offset + 1] = green
state[offset + 2] = blue
```

`25` bizim DSDT'den çıkardığımız `0x19` ile birebir aynı — iki bağımsız
kaynak aynı yeri gösteriyor.

### Bölge sırası — makinede ölçüldü (2026-09-11)

Bayt sırası doğrulandı ama **yuva sırası fiziksel sırayla ters çıktı.**
Dört bölgeye sırayla kırmızı / yeşil / mavi / sarı yazıldığında klavyede
soldan sağa **sarı / mavi / yeşil / kırmızı** göründü:

| sysfs `zone` | Donanım yuvası | Veri ofseti | Fiziksel konum |
|---|---|---|---|
| 0 | 3 | 25 + 9 = 34 | en sol |
| 1 | 2 | 25 + 6 = 31 | sol orta |
| 2 | 1 | 25 + 3 = 28 | sağ orta |
| 3 | 0 | 25 + 0 = 25 | en sağ |

Renkler doğru çıktığı için R/G/B sırası kesin; çevrilmesi gereken yalnızca
bölge numarası. Modül bu çevrimi kendi yapıyor (`zone_slot[]`), böylece
`zone0` kullanıcının beklediği gibi soldaki bölge oluyor.

Ayrıca oradan öğrenilen bir davranış: yazma **oku-değiştir-yaz** olmalı.
Önce `0x02` ile 128 baytlık durum okunuyor, yalnızca ilgili 3 bayt
değiştirilip `0x03` ile geri yazılıyor. 12 baytın dışındaki alanın ne
taşıdığı bilinmiyor; korumak doğrusu.

## 5. Açma/kapama firmware'in — makinede ölçüldü (2026-09-11)

`LRGB`/`LBRT` yazmak aydınlatmayı **açmıyor.** Klavye kapalıyken renkler
register'lara yazılıyor, geri okuma da doğru değeri veriyor, ama ışık yanmıyor.
`Fn+F4`'e basılınca ışıklar bizim yazdığımız renklerle geliyor.

Aday register elendi: `KBBL` (EC `0x42` bit 4) ışıklar **açıkken de** sıfır
okundu (`0x42 = 0x04`), yani aydınlatma durumunu takip etmiyor.

WMI aydınlatma grubunda da açma/kapama yok — `LM06`–`LM0B` boş saplama,
`Return (Package { Zero, Zero })`. `LCMC`'den önceki 5 bit (`0xEE0` bit 0–4)
isimsiz; biri olabilir ama DSDT söylemiyor ve orası H2RA'da
(`0xFE700000 + 0xEE0`), yani kullanıcı alanından okunamıyor.

**Sonuç:** master anahtar EC'nin kendi iç durumu ve `Fn+F4` ile yönetiliyor.
Sürücü rengi ve parlaklığı kontrol ediyor; açıp kapamayı firmware yapıyor.
Bu bir eksiklik değil, donanımın sınırı — ama kullanıcıya söylenmeli, yoksa
"renk yazıyorum bir şey olmuyor" diye sürücüyü suçlar.

## 6. `hp-wmi` ile çakışma yok

Faz 2'de saptandı: `hp-wmi` GUID'i sahiplenmiyor, `wmi_evaluate_method` ile
çağırıyor ve kendisi bir `platform_driver`. Aydınlatma grubu (`0x020009`)
fan grubundan (`0x020008`) ayrık, farklı EC alanlarına dokunuyor.

Dolayısıyla bu modül `hp-wmi` ile **yan yana çalışır**; `blacklist hp_wmi`
gerekmiyor.
