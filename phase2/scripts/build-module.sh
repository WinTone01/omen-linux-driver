#!/usr/bin/env bash
# 8D24 kaydi eklenmis hp-wmi modulunu out-of-tree derler.
#
# Neden out-of-tree: Arch/CachyOS cekirdek KAYNAGINI paketlemez, yalnizca
# header verir. O yuzden hp-wmi.c'yi calisan cekirdegin surumune karsilik
# gelen upstream etiketinden cekip tek modul olarak deriyoruz.
#
# Kullanim:
#   bash build-module.sh              # cek, yamala, derle
#   bash build-module.sh --install    # ustune DKMS'e kaydet (kalici)
#
# Hicbir sey otomatik yuklenmez; sonunda ne yapacagini yazar.

set -euo pipefail
cd "$(dirname "$0")"
HERE=$(pwd)
KVER=$(uname -r)
BUILD=/lib/modules/$KVER/build
WORK=${WORK:-$HERE/../build}

say() { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
die() { printf '\033[31mHATA:\033[0m %s\n' "$1" >&2; exit 1; }

say "1. Onkosullar"
[ -d "$BUILD" ] || die "$BUILD yok. Cekirdek header paketini kur (or. linux-cachyos-headers)."
command -v make >/dev/null || die "make yok. 'base-devel' kur."
command -v curl >/dev/null || die "curl yok."
echo "  kernel : $KVER"
echo "  build  : $BUILD"

# Calisan cekirdegin ana surumune karsilik gelen upstream etiketi.
# 7.2.3-1-cachyos -> v7.2 ; 7.3.0-rc2 -> v7.3
BASE=$(printf '%s' "$KVER" | sed 's/^\([0-9]\+\.[0-9]\+\).*/\1/')
TAG="v$BASE"
echo "  etiket : $TAG"

say "2. hp-wmi.c indiriliyor"
mkdir -p "$WORK"
URL="https://raw.githubusercontent.com/torvalds/linux/$TAG/drivers/platform/x86/hp/hp-wmi.c"
echo "  $URL"
curl -fsSL "$URL" -o "$WORK/hp-wmi.c" || die "indirilemedi. Etiket $TAG dogru mu?"
echo "  $(wc -l < "$WORK/hp-wmi.c") satir indirildi"

# Indirilen kaynak calisan cekirdekle ayni mi? Modulun DMI string'leriyle
# karsilastir - dagitim hp-wmi'yi yamalamis olabilir.
KO=$(find "/lib/modules/$KVER" -name 'hp-wmi.ko*' 2>/dev/null | head -1)
if [ -n "$KO" ] && command -v strings >/dev/null; then
  case "$KO" in
    *.zst) DUMP=(zstd -dcq "$KO") ;;
    *.xz)  DUMP=(xz -dc "$KO")    ;;
    *.gz)  DUMP=(gzip -dc "$KO")  ;;
    *)     DUMP=(cat "$KO")       ;;
  esac
  KO_N=$("${DUMP[@]}" 2>/dev/null | strings | grep -cxE '8[0-9A-F]{3}' || true)
  SRC_N=$(grep -coE 'DMI_BOARD_NAME, "8[0-9A-F]{3}"' "$WORK/hp-wmi.c" || true)
  echo "  calisan modulde $KO_N kart string'i, indirilen kaynakta $SRC_N DMI kaydi"
  echo "  (birebir esit olmasi beklenmez; buyuk fark dagitim yamasina isaret eder)"
fi

say "3. 8D24 kaydi ekleniyor"
bash "$HERE/add-8d24.sh" "$WORK/hp-wmi.c"

say "4. Derleniyor"
cat > "$WORK/Makefile" <<'MK'
obj-m := hp-wmi.o
KDIR  ?= /lib/modules/$(shell uname -r)/build

all:
	$(MAKE) -C $(KDIR) M=$(CURDIR) modules
clean:
	$(MAKE) -C $(KDIR) M=$(CURDIR) clean
MK

if make -C "$BUILD" M="$WORK" modules 2>&1 | tail -25; then
  [ -f "$WORK/hp-wmi.ko" ] || die "derleme bitti ama hp-wmi.ko olusmadi."
else
  die "derleme basarisiz. Ciktiyi yukarida gor."
fi
echo "  -> $WORK/hp-wmi.ko"

say "5. Sirada ne var"
cat <<EOF
  Test (gecici, reboot'ta kaybolur):

    sudo modprobe -r hp_wmi 2>/dev/null
    sudo insmod $WORK/hp-wmi.ko
    sudo bash $HERE/verify.sh

  Beklenen: adim 3'te platform_profile, adim 4'te hp hwmon + pwm dosyalari.

  Geri alma:

    sudo rmmod hp-wmi && sudo modprobe hp_wmi

  Calisirsa kalici hale getir:

    bash $0 --install
EOF

[ "${1:-}" = "--install" ] || exit 0

say "6. DKMS kaydi"
command -v dkms >/dev/null || die "dkms yok. 'sudo pacman -S dkms' ile kur."
PKG=hp-wmi-8d24
VER=$BASE
DEST=/usr/src/$PKG-$VER
sudo rm -rf "$DEST"
sudo mkdir -p "$DEST"
sudo cp "$WORK/hp-wmi.c" "$WORK/Makefile" "$DEST/"
sudo tee "$DEST/dkms.conf" >/dev/null <<EOF
PACKAGE_NAME="$PKG"
PACKAGE_VERSION="$VER"
BUILT_MODULE_NAME[0]="hp-wmi"
DEST_MODULE_LOCATION[0]="/updates"
AUTOINSTALL="yes"
EOF
sudo dkms add    -m "$PKG" -v "$VER"
sudo dkms build  -m "$PKG" -v "$VER"
sudo dkms install -m "$PKG" -v "$VER" --force
echo
echo "  Kayitli. Kaldirmak icin: sudo dkms remove -m $PKG -v $VER --all"
echo "  NOT: DKMS modulu /updates'e koyar, in-tree surumun onune gecer."
echo "  Cekirdek ANA surumu degisirse (or. 7.2 -> 7.3) bu paketi yeniden"
echo "  olustur; indirilen kaynak eski etikete ait kalir."
