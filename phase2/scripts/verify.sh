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
if [ "$BOARD" = "8D24" ]; then
  ok "Hedef makinedesin"
else
  no "Kart 8D24 degil"
  cat <<'BANNER'

       ####################################################################
       #  Bu HEDEF MAKINE DEGIL. Asagidaki adimlarin cogu anlamsiz cikacak;
       #  bu bir hata degil. Faz 2 yalnizca OMEN 16-ap0xxx (8D24) uzerinde
       #  test edilebilir. Script'in kendisi yine de bastan sona kosacak.
       ####################################################################
BANNER
fi

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

say "5. Derlenmis hp_wmi modulunde kart kayitlari"
# Arch/CachyOS cekirdek KAYNAGINI paketlemez, sadece header verir. O yuzden
# kaynak yerine derlenmis .ko icindeki DMI string'lerine bakiyoruz - bu her
# dagitimda calisir ve sorulan seye dogrudan cevap verir.
KO=$(find /lib/modules/$(uname -r) -name 'hp-wmi.ko*' 2>/dev/null | head -1)
if [ -z "$KO" ]; then
  no "hp-wmi.ko bulunamadi - bu cekirdekte hp-wmi derlenmemis olabilir"
else
  ok "modul: $KO"
  # .ko .zst/.xz/.gz sikistirilmis olabilir; uygun sekilde ac
  case "$KO" in
    *.zst) DUMP="zstd -dcq  $KO" ;;
    *.xz)  DUMP="xz   -dc   $KO" ;;
    *.gz)  DUMP="gzip -dc   $KO" ;;
    *)     DUMP="cat        $KO" ;;
  esac
  BOARDS=$($DUMP 2>/dev/null | strings | grep -xE '8[0-9A-F]{3}' | sort -u | tr '\n' ' ')
  if [ -z "$BOARDS" ]; then
    no "modulden kart listesi cikarilamadi (strings/zstd kurulu mu?)"
  else
    info "kayitli kartlar: $BOARDS"
    echo "$BOARDS" | grep -qw 8D24 && ok "8D24 KAYITLI - yama gerekmiyor" \
                                   || no "8D24 kayitli degil - yama gerekiyor"
    echo "$BOARDS" | grep -qw 8D26 && ok "8D26 (kardes kart) kayitli - cekirdek 16-ap0xxx ailesini taniyor" \
                                   || no "8D26 de yok - cekirdek bekledigimizden eski"
  fi
fi
KV=$(uname -r | cut -d. -f1,2)
info "cekirdek $KV -> yama bicimi: $(printf '%s' "$KV" | awk -F. '($1>7)||($1==7&&$2>=3){print "hp_wmi_feature_boards[] + omen_v1_legacy_board_params (7.3+)"; next}{print "victus_s_thermal_profile_boards[] + omen_v1_legacy_thermal_params (7.2)"}')"

say "6. EC dogrudan okuma (Faz 1 caprazlamasi)"
if [ "$(id -u)" != "0" ]; then
  no "root degilsin, EC okumasi atlandi"
else
  # (a) ACPI EC cihazi var mi
  if ls /sys/bus/acpi/devices/ 2>/dev/null | grep -q '^PNP0C09'; then
    ok "ACPI EC cihazi var: $(ls /sys/bus/acpi/devices/ | grep '^PNP0C09' | tr '\n' ' ')"
  else
    no "ACPI EC cihazi (PNP0C09) yok - masaustu makinelerde normal"
  fi
  # (b) debugfs mount edili mi
  if ! mountpoint -q /sys/kernel/debug 2>/dev/null; then
    info "debugfs mount edili degil, mount ediliyor"
    mount -t debugfs none /sys/kernel/debug 2>/dev/null \
      && ok "debugfs mount edildi" || no "debugfs mount edilemedi"
  fi
  # (c) ec_sys modulu - CONFIG_ACPI_EC_DEBUGFS kapali olabilir
  MPERR=$(modprobe ec_sys write_support=0 2>&1) && MPOK=1 || MPOK=0
  if [ "$MPOK" = "1" ]; then
    lsmod | grep -q '^ec_sys' && ok "ec_sys yuklu" \
                              || info "modprobe hata vermedi ama ec_sys lsmod'da yok (builtin olabilir)"
  else
    no "ec_sys yuklenemedi: $MPERR"
  fi
  # CONFIG durumunu dogrudan soyle - tahmine gerek kalmasin
  if [ -r /proc/config.gz ]; then
    info "config: $(zgrep -E 'CONFIG_ACPI_EC_DEBUGFS' /proc/config.gz 2>/dev/null || echo 'ACPI_EC_DEBUGFS bulunamadi')"
  elif [ -r "/boot/config-$(uname -r)" ]; then
    info "config: $(grep -E 'CONFIG_ACPI_EC_DEBUGFS' /boot/config-$(uname -r) 2>/dev/null || echo 'ACPI_EC_DEBUGFS bulunamadi')"
  fi
  # debugfs altinda gercekte ne var
  if [ -d /sys/kernel/debug/ec ]; then
    info "/sys/kernel/debug/ec icerigi: $(ls /sys/kernel/debug/ec 2>/dev/null | tr '\n' ' ')"
  else
    no "/sys/kernel/debug/ec dizini hic olusmamis"
  fi
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
