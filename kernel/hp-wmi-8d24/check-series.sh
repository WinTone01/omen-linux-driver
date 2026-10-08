#!/usr/bin/env bash
# Builds mainline hp-wmi.c with the upstream series in patches/ applied, so
# the series is compiled - and, with --load, tried - before it is sent.
#
# Mainline is newer than the running kernel, so a build failure can be the
# series or an API the running kernel's headers do not have yet; the error
# says which file and line, and only a line the series touched is the
# series' fault.
#
# Usage:  bash check-series.sh            fetch, apply, build
#         bash check-series.sh --load     also swap it in and test automatic
#                                         mode under load (needs sudo, ~1 min)

set -euo pipefail
cd "$(dirname "$0")"
HERE=$(pwd)
LOAD=0
[ "${1:-}" = --load ] && LOAD=1
KVER=$(uname -r)
BUILD=/lib/modules/$KVER/build
WORK=$HERE/build-series

say() { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
die() { printf '\033[31mERROR:\033[0m %s\n' "$1" >&2; exit 1; }

[ -d "$BUILD" ] || die "$BUILD is missing - install the kernel headers"
LLVM_ARGS=()
grep -q '^CONFIG_CC_IS_CLANG=y' "$BUILD/.config" 2>/dev/null && LLVM_ARGS=(LLVM=1)

say "1. Mainline hp-wmi.c, with the series applied"
rm -rf "$WORK"
mkdir -p "$WORK/drivers/platform/x86/hp"
curl -fsSL -o "$WORK/drivers/platform/x86/hp/hp-wmi.c" \
  https://raw.githubusercontent.com/torvalds/linux/master/drivers/platform/x86/hp/hp-wmi.c ||
  die "download failed"
for p in patches/0001-*.patch patches/0002-*.patch; do
  patch -d "$WORK" -p1 --quiet < "$p" || die "$p does not apply to master any more"
  echo "  applied $(basename "$p")"
done

say "2. Building against $KVER"
mv "$WORK/drivers/platform/x86/hp/hp-wmi.c" "$WORK/hp-wmi.c"
printf 'obj-m := hp-wmi.o\n' > "$WORK/Makefile"
if make -C "$BUILD" M="$WORK" "${LLVM_ARGS[@]}" W=1 modules 2>&1 | tee "$WORK/build.log" | tail -20 &&
   [ -f "$WORK/hp-wmi.ko" ]; then
  if grep -q 'warning:' "$WORK/build.log"; then
    echo "  built, with warnings - see $WORK/build.log"
  else
    echo "  built cleanly (W=1)"
  fi
else
  die "the build failed - see $WORK/build.log"
fi

[ "$LOAD" = 1 ] || { echo; echo "  To try it on the machine: bash $0 --load"; exit 0; }

say "3. Swapping it in"
hwmon() { dirname "$(grep -lx "$1" /sys/class/hwmon/*/name 2>/dev/null | head -1)"; }
cpu_c() { echo $(( $(cat "$(hwmon k10temp)/temp1_input") / 1000 )); }
fans() { local d; d=$(hwmon omen); echo "$(cat "$d/fan1_input") $(cat "$d/fan2_input")"; }
LOADPIDS=()
restore() {
  [ ${#LOADPIDS[@]} -gt 0 ] && kill "${LOADPIDS[@]}" 2>/dev/null
  sudo rmmod hp_wmi 2>/dev/null
  sudo modprobe hp_wmi
  sudo systemctl start omend
  echo "  the installed hp-wmi and omend are back"
}
trap restore EXIT
sudo systemctl stop omend
sudo modprobe -r hp_wmi
sudo modprobe -a sparse-keymap rfkill wmi platform_profile
sudo insmod "$WORK/hp-wmi.ko"
sleep 2
HP=$(hwmon hp)
[ -n "$HP" ] || die "the series' hp-wmi registered no hwmon device"

say "4. Automatic mode under load"
echo 1 | sudo tee "$HP/pwm1_enable" >/dev/null
echo 96 | sudo tee "$HP/pwm1" >/dev/null
sleep 6
echo "  manual at 1800 RPM: fans $(fans), cpu $(cpu_c) C"
for _ in $(seq "$(nproc)"); do (while :; do :; done) & LOADPIDS+=($!); done
sleep 4
echo 2 | sudo tee "$HP/pwm1_enable" >/dev/null
echo "  pwm1_enable = 2"
for t in 2 4 6 8 10 12 14 16 18 20; do
  sleep 2
  f=$(fans); c=$(cpu_c)
  echo "  +${t}s  fans $f  cpu $c C  profile $(cat /sys/firmware/acpi/platform_profile)"
  if [ "$f" = "0 0" ] && [ "$c" -ge 75 ]; then
    echo "  the fans stopped at $c C - full power, and the series is not fixed"
    echo 0 | sudo tee "$HP/pwm1_enable" >/dev/null
    exit 1
  fi
done
echo
echo "  Expected: the fans leave 1800 RPM within a few seconds and follow the"
echo "  load, and the profile stays where it was."
