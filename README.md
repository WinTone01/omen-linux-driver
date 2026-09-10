# omen-linux-driver

HP OMEN 16-ap0xxx (board **8D24**) için Linux fan ve termal kontrol desteği.

Windows'taki OMEN Gaming Hub'ın fan/termal işlevlerinin protokolünü çıkarıp
Linux'ta karşılığını sağlamayı hedefler.

## Durum

| Faz | Kapsam | Durum |
|---|---|---|
| 1 | Protokol çıkarımı (Windows) | **Tamamlandı** |
| 2 | `hp-wmi` 8D24 desteği | **Tamamlandı, makinede doğrulandı** |
| 3 | Fan eğrisi + RGB + arayüz | Devam ediyor |

### Faz 1 sonucu

Bu makinenin fan/termal protokolü, upstream Linux `hp-wmi` sürücüsünün
desteklediğiyle **birebir aynı**. Yeni sürücü yazmaya gerek yok; eksik olan tek
şey kartın DMI tablosunda kayıtlı olmaması.

- WMI grubu `0x20008`, imza `"SECU"`
- `0x2D` fan oku · `0x2E` fan yaz (EC 0x34/0x35) · `0x26`/`0x27` maks fan ·
  `0x1A` güç profili (EC 0x95)
- Fan birimi **yüz RPM**, aralık 18–48 (1800–4800 RPM)
- Profil değerleri: `0x30` Balanced · `0x31` Performance · `0x04` Unleashed

Ayrıntı ve her bulgunun kaynağı: [`phase1/docs/phase1-findings.md`](phase1/docs/phase1-findings.md)

### Faz 2 sonucu

Tahmin doğrulandı: gereken tek şey `hp-wmi`'nin DMI tablosuna **tek satırlık
bir ekleme**ydi (`8D24` → `omen_v1_legacy`). Yamalı modül 2026-09-11'de bu
makinede derlenip çalıştırıldı:

- `pwm1` açıldı → manuel fan kontrolü mümkün (yamasız hâlde yoktu)
- `hp-wmi` platform profil işleyicisi olarak kaydoldu, `amd-pmf` ile çakışmadan
- EC `0x95` = **48** okundu → Faz 1'in Windows ölçümü Linux'ta bağımsız doğrulandı
- Otomatik fan eğrisi çalışıyor: 45°C'de fan-stop, 58°C'de 2400/2100 RPM
- DKMS ile kalıcı, reboot'ta hayatta kaldı

Ayrıntı: [`phase2/docs/phase2-plan.md`](phase2/docs/phase2-plan.md)

### Faz 3

Fan eğrisi daemon'ı, 4 bölge RGB klavye sürücüsü ve web arayüzü.

Ayrıntı: [`phase3/docs/phase3-plan.md`](phase3/docs/phase3-plan.md)

## Hedef donanım

| | |
|---|---|
| Model | HP OMEN Gaming Laptop 16-ap0xxx |
| Anakart | HP **8D24** rev 43.40 |
| BIOS | AMI F.11 (HPQOEM-1072009) |
| CPU | AMD Ryzen AI 9 365 (Strix Point) |
| dGPU | NVIDIA RTX 5060 Laptop |

> Buradaki EC register haritası ve komut değerleri **bu karta özgüdür.**
> Başka bir OMEN'de körlemesine kullanmayın — yanlış EC yazımı fanı tamamen
> durdurabilir ve termal koruma her zaman devreye girmez.

## Kullanım

Linux tarafında, sırayla:

```bash
# 1. Once yamasiz durum tespiti (salt okunur, hicbir sey yazmaz)
sudo bash phase2/scripts/verify.sh 2>&1 | tee verify-before.txt

# 2. Cekirdek kaynagina 8D24 kaydini ekle (7.2 ve 7.3+ bicimini kendi tespit eder)
bash phase2/scripts/add-8d24.sh /yol/hp-wmi.c

# 3. Modulu derle, dene, sonra tekrar dogrula
sudo bash phase2/scripts/verify.sh 2>&1 | tee verify-after.txt
```

`verify.sh` yalnızca okur. `add-8d24.sh` verilen dosyayı değiştirir ama önce
`.orig` yedeği alır.

## Dizin yapısı

```
phase1/
  acpi/      Canli sistemden alinan 17 ACPI tablosu + cozulmus DSDT
  extract/   EC alan haritalari, WMI komut dagiticisi, GM/LM metotlari
  docs/      Faz 1 bulgular belgesi
phase2/
  docs/      Faz 2 plani
  scripts/   verify.sh, add-8d24.sh
```

## Yeniden üretme

ACPI tabloları Windows'tan `GetSystemFirmwareTable` ile alındı, `iasl` ile
çözüldü. `tools/iasl.exe` repoya dahil değil; ACPICA sürümlerinden indirilebilir.

Profil bayt değerleri OMEN Gaming Hub'ın kendi log'undan yakalandı
(`%LOCALAPPDATA%\Packages\AD2F1837.OMENCommandCenter_*\LocalCache\Local\HPOMEN\`),
log satırları giden WMI giriş baytlarını doğrudan yazıyor.

## Lisans

GPL-2.0-only. Buradaki bulgular Linux çekirdeğine (`hp-wmi`) gönderilmek üzere
üretildiği için çekirdekle aynı lisans seçildi.
