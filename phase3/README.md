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
sudo install -Dm644 packaging/omen-sysusers.conf /usr/lib/sysusers.d/omen.conf
sudo systemd-sysusers
sudo systemctl enable --now omend
```

Yapilandirma dosyasi zorunlu degil — yoksa gomulu varsayilanlar kullanilir.

Kontrol komutlarini sudo'suz kullanmak icin `omen` grubuna katil:

```bash
sudo usermod -aG omen $USER      # sonra yeniden oturum ac
```

## Kullanim

```bash
omenctl status                # daemon + donanim durumu
omenctl curve                 # etkin egri ve guvenlik esikleri

omenctl set curve             # egri sursun (varsayilan)
omenctl set manual 2400       # sabit hedef
omenctl set auto              # kontrolu EC'ye birak
omenctl set max               # tam guc
omenctl profile performance   # balanced / performance / low-power
omenctl reload                # yapilandirmayi yeniden okut

omend --dry-run --once        # hicbir sey yazmadan ne yapacagini goster
journalctl -u omend -f        # canli
```

`omenctl` fana **dogrudan yazmaz**; kontrol komutlari unix socket uzerinden
daemon'a gider. `status` daemon calismiyorken sysfs'ten okumaya duser, yani
tanilama araci olarak her durumda ise yarar.

Ikinci bir ornek calistirmak veya root olmadan denemek icin socket yolu
`OMEND_SOCKET` ile degistirilebilir.

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
5. **Yazma yetkisi yalnizca daemon'da.** `omenctl` fana dogrudan yazmaz;
   istegini socket uzerinden iletir. Boylece kelepceleme, kritik sigorta ve
   cikista otomatige donme tek bir yerde garanti altinda — manuel modda bile.
   Kritik sigorta kullanici istegini de gecersiz kilar.

Egriyi denemeden once ikinci bir terminalde `watch -n1 sensors` acik olsun.

### Dogrulama (2026-09-11, 7.2.4-1-cachyos)

Kural 1'in uc kapisi da makinede denendi:

| Cikis yolu | Mekanizma | Sonuc |
|---|---|---|
| Ctrl+C (SIGINT) | `Drop` | `pwm1_enable` 2'ye dondu |
| `omend --restore-auto` | dogrudan | 2'ye dondu |
| `pkill -9` (SIGKILL) | systemd `ExecStopPost` | 2'ye dondu |

Sonuncusu onemli: SIGKILL'de `Drop` CALISMAZ, fani yalnizca systemd
kurtarabilir. Test daemon manuel moddayken (`pwm1_enable = 1`) yapildi,
yoksa bir sey kanitlamazdi.

## Yapi

```
crates/omen-core/    sysfs, fan, sicaklik, egri, yapilandirma, IPC  (19 test)
crates/omend/        daemon: egri motoru + guvenlik durum makinesi + socket
crates/omenctl/      durum araci ve daemon istemcisi
kernel/omen-kbd-rgb/ 4 bolge RGB klavye modulu (leds-multicolor)
packaging/           systemd unit, ornek yapilandirma, sysusers
docs/                faz plani, RGB protokolu
```

### RGB modulu

```bash
cd kernel/omen-kbd-rgb && make
sudo modprobe -a led-class-multicolor wmi  # insmod bagimlilik cozmez
sudo insmod omen-kbd-rgb.ko

# 4 bolge + genel parlaklik
ls /sys/class/leds/ | grep omen
echo 255       | sudo tee /sys/class/leds/omen:rgb:kbd_backlight_zone0/brightness
echo "255 0 0" | sudo tee /sys/class/leds/omen:rgb:kbd_backlight_zone0/multi_intensity
echo 60        | sudo tee /sys/class/leds/omen::kbd_backlight/brightness
```

Yalnizca aydinlatma komut grubunu (`0x020009`) kullanir, `hp-wmi` ile yan
yana calisir — `blacklist hp_wmi` gerekmez. Protokol:
[`docs/rgb-protocol.md`](docs/rgb-protocol.md)

Genel parlaklik LED'inin adi bilerek `omen::kbd_backlight`: masaustu
ortamlari ve `upower` klavye isigini `*::kbd_backlight` kalibiyla ariyor.

Kendi sysfs agacimizi icat etmiyoruz: fan `hwmon`, profil `platform_profile`.
Boylece `sensors`, KDE guc ayarlari gibi mevcut araclar bu projeden habersiz
calismaya devam eder.

## Durum

| | |
|---|---|
| M1 fan egrisi + durum araci | **calisiyor**, servis olarak dogrulandi |
| M1b `omenctl` kontrol komutlari (unix socket) | **calisiyor** |
| M2 `omen-kbd-rgb` cekirdek modulu | **derlendi**, donanim testi bekliyor |
| M3 Tauri arayuzu | planlandi |
