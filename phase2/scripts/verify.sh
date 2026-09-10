#!/usr/bin/env bash
# OMEN 16-ap0xxx (board 8D24) — Linux kurulum sonrasi durum tespiti.
# Salt okunur: hicbir sey yazmaz, hicbir modul yuklemez (ec_sys haric, o da read-only).
# Kullanim:  sudo bash verify.sh   (root olmadan da calisir, bazi adimlar atlanir)

set -u
say()  { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
ok()   { printf '  \033[32mOK\033[0m   %s\n' "$1"; }
no()   { printf '  \033[31mYOK\033[0m  %s\n' "$1"; }
info() { printf '       %s\n' "$1"; }

say "1. Donanim kimligi"
BOARD=$(cat /sys/class/dmi/id/board_name 2>/dev/null || echo '?')
info "board_name   : $BOARD    (beklenen: 8D24)"
info "product_name : $(cat /sys/class/dmi/id/product_name 2>/dev/null || echo '?')"
info "bios_version : $(cat /sys/class/dmi/id/bios_version 2>/dev/null || echo '?')"
info "kernel       : $(uname -r)"
[ "$BOARD" = "8D24" ] && ok "Kart bekledigimiz gibi" || no "Kart 8D24 degil - Faz 1 bulgulari bu makineye ait olmayabilir"

say "2. hp-wmi modulu"
if lsmod | grep -q '^hp_wmi'; then ok "hp_wmi yuklu"; else no "hp_wmi yuklu degil"; fi
if [ -d /sys/devices/platform/hp-wmi ]; then
  ok "/sys/devices/platform/hp-wmi var"
  info "icerik: $(ls /sys/devices/platform/hp-wmi 2>/dev/null | tr '\n' ' ')"
else
  no "/sys/devices/platform/hp-wmi yok"
fi
info "--- dmesg ---"
dmesg 2>/dev/null | grep -i 'hp.wmi' | tail -10 | sed 's/^/       /' || info "(dmesg okunamadi, root gerekebilir)"

say "3. Platform profil"
PP=/sys/firmware/acpi/platform_profile
if [ -r "$PP" ]; then
  ok "platform_profile var"
  info "secenekler: $(cat ${PP}_choices 2>/dev/null)"
  info "aktif     : $(cat $PP 2>/dev/null)"
else
  no "platform_profile yok"
fi

say "4. Fan / hwmon"
FOUND=0
for d in /sys/class/hwmon/hwmon*; do
  [ -e "$d/name" ] || continue
  N=$(cat "$d/name")
  printf '       %-14s %s\n' "$N" "$d"
  if [ "$N" = "hp" ] || [ "$N" = "hp_wmi" ]; then
    FOUND=1
    ok "hp-wmi hwmon bulundu: $d"
    for f in "$d"/fan*_input "$d"/pwm*; do
      [ -e "$f" ] && printf '         %-28s = %s\n' "$(basename $f)" "$(cat $f 2>/dev/null || echo '-')"
    done
  fi
done
[ "$FOUND" = "1" ] || no "hp-wmi hwmon YOK - beklenen durum (8D24 DMI tablosunda kayitli degil)"

say "5. Cekirdek kaynaginda hp-wmi destegi"
SRC=""
for c in /usr/src/linux-headers-$(uname -r)/drivers/platform/x86/hp/hp-wmi.c \
         /usr/src/linux-$(uname -r)/drivers/platform/x86/hp/hp-wmi.c \
         /lib/modules/$(uname -r)/build/drivers/platform/x86/hp/hp-wmi.c; do
  [ -f "$c" ] && SRC="$c" && break
done
if [ -n "$SRC" ]; then
  ok "kaynak: $SRC"
  grep -q 'hp_wmi_feature_boards'        "$SRC" && info "dizi: hp_wmi_feature_boards (7.3+ refactor sonrasi)"
  grep -q 'victus_s_thermal_profile_boards' "$SRC" && info "dizi: victus_s_thermal_profile_boards (7.2 bicimi)"
  grep -q '"8D24"' "$SRC" && ok "8D24 zaten kayitli - yama gerekmeyebilir" || no "8D24 kayitli degil - yama gerekiyor"
else
  no "cekirdek kaynagi bulunamadi (linux-headers / kernel-devel kurulu mu?)"
  info "Bilgi icin: dizi adi 7.2'de victus_s_thermal_profile_boards, 7.3+'ta hp_wmi_feature_boards"
fi

say "6. EC dogrudan okuma (Faz 1 caprazlamasi)"
if [ "$(id -u)" != "0" ]; then
  no "root degilsin, EC okumasi atlandi"
else
  modprobe ec_sys write_support=0 2>/dev/null
  EC=/sys/kernel/debug/ec/ec0/io
  if [ -r "$EC" ]; then
    ok "EC erisilebilir: $EC"
    HPCM=$(dd if=$EC bs=1 skip=$((0x95)) count=1 2>/dev/null | od -An -tu1 | tr -d ' ')
    S1=$(dd if=$EC bs=1 skip=$((0x34)) count=1 2>/dev/null | od -An -tu1 | tr -d ' ')
    S2=$(dd if=$EC bs=1 skip=$((0x35)) count=1 2>/dev/null | od -An -tu1 | tr -d ' ')
    R=$(dd if=$EC bs=1 skip=$((0xB0)) count=4 2>/dev/null | od -An -tu1)
    set -- $R
    F1=$(( $2 * 256 + $1 )); F2=$(( $4 * 256 + $3 ))
    printf '       0x95 HPCM (profil)  = %s   (48=Balanced, 49=Performance, 4=Unleashed)\n' "$HPCM"
    printf '       0x34 SRP1 (fan1 hedef) = %s  -> %s RPM\n' "$S1" "$((S1*100))"
    printf '       0x35 SRP2 (fan2 hedef) = %s  -> %s RPM\n' "$S2" "$((S2*100))"
    printf '       0xB0 fan1 takometre = %s RPM\n' "$F1"
    printf '       0xB2 fan2 takometre = %s RPM\n' "$F2"
    case "$HPCM" in
      48|49|4) ok "HPCM Faz 1'de yakalanan degerlerden biri" ;;
      *)       no "HPCM beklenmeyen deger ($HPCM) - Faz 1 haritasi gozden gecirilmeli" ;;
    esac
  else
    no "$EC okunamadi (debugfs mount edili mi? CONFIG_ACPI_EC_DEBUGFS?)"
    info "dene: mount -t debugfs none /sys/kernel/debug"
  fi
fi

say "7. dGPU guc yonetimi (kapsam disi ama pil omrunun asil sebebi)"
for p in /sys/bus/pci/devices/*/power/control; do
  d=$(dirname $(dirname "$p"))
  cls=$(cat "$d/class" 2>/dev/null)
  case "$cls" in 0x030000|0x030200)
    printf '       %s  vendor=%s  power/control=%s  runtime_status=%s\n' \
      "$(basename $d)" "$(cat $d/vendor 2>/dev/null)" "$(cat $p)" "$(cat $d/power/runtime_status 2>/dev/null)"
  ;; esac
done
info "vendor 0x10de = NVIDIA. 'on' ise runtime PM kapali demektir (5-10W kayip)."

printf '\n\033[1mBitti.\033[0m Ciktinin tamamini kaydet: sudo bash verify.sh 2>&1 | tee verify-out.txt\n\n'
