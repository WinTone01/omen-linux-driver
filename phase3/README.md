# Faz 3 — `omend` / `omenctl`

OMEN 16-ap0xxx (board **8D24**) icin fan egrisi servisi ve durum araci.

**Onkosul:** Faz 2'nin `8D24` yamasi uygulanmis olmali. Yama olmadan
`hp-wmi` `pwm1`i acmaz ve `omend` baslamaz — hata mesaji bunu soyler.
Kontrol: `sudo bash ../phase2/scripts/verify.sh`

## Neden bir daemon gerekiyor

Faz 1 §6.4'te saptandi: HP'nin "Auto" fan egrisi EC'de degil, **Windows
uygulamasinda** kosuyor — OGH periyodik olarak WMI `0x2E` setpoint'i yaziyor.
Yani `hp-wmi` tek basina "otomatik fan" vermiyor.

Ama EC'nin kendi bir otomatigi de **var** ve fena degil (Faz 2: 45C'de
fan-stop, 58C'de 2400 RPM). O yuzden `omend` egrinin alt bolgesinde kontrolu
EC'ye birakiyor; yalnizca ondan **fazlasini** istedigi zaman devraliyor.
Rolantideki sessizlik boylece kayboluyor degil.

## Kurulum

```bash
cargo build --release
sudo install -Dm755 target/release/omend   /usr/bin/omend
sudo install -Dm755 target/release/omenctl /usr/bin/omenctl
sudo install -Dm644 packaging/omend.service /etc/systemd/system/omend.service
sudo install -Dm644 packaging/omend.toml    /etc/omen/omend.toml
sudo systemctl enable --now omend
```

Yapilandirma dosyasi zorunlu degil — yoksa gomulu varsayilanlar kullanilir.

## Kullanim

```bash
omenctl status                # donanim, profil, fan, sicakliklar
omenctl curve                 # etkin egri ve guvenlik esikleri
omend --dry-run --once        # hicbir sey yazmadan ne yapacagini goster
journalctl -u omend -f        # canli
```

## Guvenlik

Yanlis EC yazimi fani tamamen durdurabilir ve termal koruma her zaman
devreye girmez. `omend` bes kurala uyar:

1. **Cikista mutlaka otomatige don.** Uc kapi: normal cikis ve panic icin
   `Drop`, SIGKILL icin systemd `ExecStopPost=omend --restore-auto`.
2. **Kritik sigorta.** `critical_c` (varsayilan 97C) asilirsa egri birakilir,
   kontrol EC'ye doner. `recover_delta_c` kadar dusunce geri devreye girer.
   Sigorta egrinin ust ucundan buyuk olmali; degilse daemon baslamaz.
3. **Watchdog.** Sicaklik okunamazsa veya setpoint yazilamazsa otomatige
   dusulur. Bilinmeyen durumda son setpoint'te kalmak en tehlikeli davranis.
4. **Iki katmanli kelepceleme.** Setpoint once `omend`de `min_rpm..max_rpm`
   araligina, sonra cekirdekte fan tablosunun sinirlarina kelepcelenir.
5. **Yazma yetkisi yalnizca daemon'da.** `omenctl` salt okunur.

Egriyi denemeden once ikinci bir terminalde `watch -n1 sensors` acik olsun.

## Yapi

```
crates/omen-core/    sysfs, fan, sicaklik, egri, yapilandirma  (17 test)
crates/omend/        daemon: egri motoru + guvenlik durum makinesi
crates/omenctl/      salt okunur durum araci
packaging/           systemd unit, ornek yapilandirma
```

Kendi sysfs agacimizi icat etmiyoruz: fan `hwmon`, profil `platform_profile`.
Boylece `sensors`, KDE guc ayarlari gibi mevcut araclar bu projeden habersiz
calismaya devam eder.

## Durum

| | |
|---|---|
| M1 fan egrisi + durum araci | **calisiyor**, canli test bekliyor |
| M1b `omenctl` kontrol komutlari (unix socket) | siradaki |
| M2 `omen-kbd-rgb` cekirdek modulu | planlandi |
| M3 Tauri arayuzu | planlandi |
