#!/usr/bin/env bash
# Builds an out-of-tree hp-wmi module with this machine's board entry added.
#
# Why out-of-tree: Arch/CachyOS do not package the kernel SOURCE, only the
# headers. So we fetch hp-wmi.c from the upstream tag matching the running
# kernel and build it as a single module.
#
# Usage:
#   bash build-module.sh                 # fetch, patch, build
#   bash build-module.sh --install       # also register it with DKMS
#   bash build-module.sh --board 8BCA    # a board other than this machine's
#
# The board defaults to the one this machine reports. It was 8D24 while there
# was only one machine; hard-coding it meant every other OMEN and Victus got a
# module identical to the stock one, which is to say nothing at all.
#
# Nothing is loaded automatically; it tells you what to do at the end.

BOARD=auto
INSTALL=0
while [ $# -gt 0 ]; do
  case $1 in
    --install)  INSTALL=1 ;;
    --board)    BOARD=${2:?--board expects a board name}; shift ;;
    --board=*)  BOARD=${1#--board=} ;;
    -h|--help)  sed -n '2,14p' "$0" | sed 's/^# \?//'; exit 0 ;;
    *)          echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

set -euo pipefail
cd "$(dirname "$0")"
HERE=$(pwd)
KVER=$(uname -r)
BUILD=/lib/modules/$KVER/build
WORK=${WORK:-$HERE/build}

say() { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
die() { printf '\033[31mERROR:\033[0m %s\n' "$1" >&2; exit 1; }

say "1. Prerequisites"
[ -d "$BUILD" ] || die "$BUILD is missing. Install the kernel headers package (e.g. linux-cachyos-headers)."
command -v make >/dev/null || die "make is missing. Install 'base-devel'."
command -v curl >/dev/null || die "curl is missing."
echo "  kernel : $KVER"
echo "  build  : $BUILD"

# Which compiler was the kernel built with? CachyOS uses clang+LLD; if you try
# to build with gcc, kbuild hands it clang-only flags (-mllvm,
# -mretpoline-external-thunk, ...) and the build dies on the very first file.
# The module has to be produced with the same compiler as the kernel.
LLVM_ARGS=()
if grep -q '^CONFIG_CC_IS_CLANG=y' "$BUILD/.config" 2>/dev/null; then
  command -v clang  >/dev/null || die "the kernel was built with clang but clang is missing. Install it: 'sudo pacman -S clang lld llvm'."
  command -v ld.lld >/dev/null || die "the kernel was linked with LLD but ld.lld is missing. Install it: 'sudo pacman -S lld'."
  LLVM_ARGS=(LLVM=1)
  KCC=$(sed -n 's/^CONFIG_CC_VERSION_TEXT="\(.*\)"$/\1/p' "$BUILD/.config")
  MYCC=$(clang --version | head -1)
  echo "  toolchain : clang (LLVM=1)"
  echo "    kernel : $KCC"
  echo "    local  : $MYCC"
  # A version mismatch is not fatal but can cause trouble at load time.
  KMAJ=$(printf '%s' "$KCC"  | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  MMAJ=$(printf '%s' "$MYCC" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  [ "$KMAJ" = "$MMAJ" ] || echo "    WARNING: versions differ ($KMAJ vs $MMAJ). Building anyway."
else
  echo "  toolchain : gcc"
fi

# The upstream tag matching the running kernel's major version.
# 7.2.3-1-cachyos -> v7.2 ; 7.3.0-rc2 -> v7.3
BASE=$(printf '%s' "$KVER" | sed 's/^\([0-9]\+\.[0-9]\+\).*/\1/')
TAG="v$BASE"
echo "  tag    : $TAG"

say "2. Downloading hp-wmi.c"
mkdir -p "$WORK"
URL="https://raw.githubusercontent.com/torvalds/linux/$TAG/drivers/platform/x86/hp/hp-wmi.c"
echo "  $URL"
curl -fsSL "$URL" -o "$WORK/hp-wmi.c" || die "download failed. Is the tag $TAG correct?"
echo "  $(wc -l < "$WORK/hp-wmi.c") lines downloaded"

# Is the downloaded source the same as the running kernel's? Compare against
# the module's DMI strings - the distribution may have patched hp-wmi.
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
  echo "  $KO_N board strings in the running module, $SRC_N DMI entries in the download"
  echo "  (they are not expected to match exactly; a large gap suggests a distro patch)"
fi

say "3. Adding the board entry"
ADD_RC=0
bash "$HERE/add-board.sh" "$WORK/hp-wmi.c" "$BOARD" || ADD_RC=$?
case $ADD_RC in
  0) ;;
  3)
    # The stock driver already has this board. Building a module identical to
    # the one already loaded, and then keeping it alive through DKMS for every
    # future kernel, is maintenance for nothing - except on 8D24, where the
    # automatic-mode fix below is still worth a module of its own.
    if [ "$(cat /sys/class/dmi/id/board_name 2>/dev/null)" = 8D24 ]; then
      echo "  The kernel's own hp-wmi covers this board; building anyway for the"
      echo "  automatic-mode fix (step 3b)."
    else
      echo
      echo "  Nothing to patch: the kernel's own hp-wmi already covers this board."
      echo "  If fan control still does not work, the module may simply need loading:"
      echo "      sudo modprobe hp_wmi   # then: omenctl doctor"
      exit 3
    fi
    ;;
  *) die "the board entry could not be added" ;;
esac

say "3b. Automatic fan mode"
# On 8D24 hp-wmi's "automatic" stops the fans for two minutes; this makes it
# hand them to the EC instead (docs/research/ec-handover.md). The change is
# guarded by the board at run time, so building it for another board leaves
# that board's behaviour as upstream has it.
FIX_RC=0
bash "$HERE/fix-auto.sh" "$WORK/hp-wmi.c" || FIX_RC=$?
case $FIX_RC in
  0|3) ;;
  *) echo "  WARNING: the automatic-mode fix did not apply to this hp-wmi.c; building without it" ;;
esac

say "4. Building"
cat > "$WORK/Makefile" <<MK
obj-m := hp-wmi.o
KDIR  ?= /lib/modules/\$(shell uname -r)/build
LLVM_FLAG ?= ${LLVM_ARGS[*]:-}

all:
	\$(MAKE) -C \$(KDIR) M=\$(CURDIR) \$(LLVM_FLAG) modules
clean:
	\$(MAKE) -C \$(KDIR) M=\$(CURDIR) \$(LLVM_FLAG) clean
MK

if make -C "$BUILD" M="$WORK" "${LLVM_ARGS[@]}" modules 2>&1 | tail -25; then
  [ -f "$WORK/hp-wmi.ko" ] || die "the build finished but hp-wmi.ko was not produced."
else
  die "build failed. See the output above."
fi
echo "  -> $WORK/hp-wmi.ko"

say "5. What next"
cat <<EOF
  Try it out (temporary, gone after a reboot):

    sudo modprobe -r hp_wmi 2>/dev/null
    sudo modprobe -a sparse-keymap rfkill wmi   # insmod does not resolve deps
    sudo insmod $WORK/hp-wmi.ko
    sudo bash $HERE/verify.sh

  NOTE: if you get 'insmod: Unknown symbol in module', the line you skipped is
  the modprobe above. insmod does not look at modules.dep; the dependencies
  (sparse_keymap, rfkill, wmi) have to be loaded by hand.

  Expected: a platform_profile in step 3, an hp hwmon with pwm files in step 4.

  To undo:

    sudo rmmod hp-wmi && sudo modprobe hp_wmi

  If it works, make it permanent:

    bash $0 --install
EOF

[ "$INSTALL" = 1 ] || exit 0

say "6. DKMS registration"
command -v dkms >/dev/null || die "dkms is missing. Install it: 'sudo pacman -S dkms'."
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
# dkms.conf is sourced as shell, so let it decide about LLVM=1 against the
# kernel actually being built for - if a gcc-built kernel shows up later,
# AUTOINSTALL still uses the right flag.
_llvm=\$(grep -q '^CONFIG_CC_IS_CLANG=y' "\${kernel_source_dir}/.config" 2>/dev/null && echo LLVM=1)
MAKE[0]="make -C \${kernel_source_dir} M=\${dkms_tree}/$PKG/$VER/build \${_llvm} modules"
DEST_MODULE_LOCATION[0]="/updates"
AUTOINSTALL="yes"
EOF
# Re-running the installer is the normal case - a new kernel, a new build of
# this project, a second attempt after something else failed - and 'dkms add'
# refuses a name/version combination it already has. Dropping the old
# registration first makes the second run behave like the first, instead of
# failing the whole install on the one step that had already succeeded.
if dkms status -m "$PKG" -v "$VER" 2>/dev/null | grep -q .; then
    echo "  already registered - removing the old entry first"
    sudo dkms remove -m "$PKG" -v "$VER" --all >/dev/null 2>&1 || true
fi

sudo dkms add    -m "$PKG" -v "$VER"
sudo dkms build  -m "$PKG" -v "$VER"
sudo dkms install -m "$PKG" -v "$VER" --force
echo
echo "  Registered. To remove: sudo dkms remove -m $PKG -v $VER --all"
echo "  NOTE: DKMS puts the module in /updates, ahead of the in-tree version."
echo "  If the kernel's MAJOR version changes (7.2 -> 7.3), rebuild this"
echo "  package; the downloaded source still belongs to the old tag."
