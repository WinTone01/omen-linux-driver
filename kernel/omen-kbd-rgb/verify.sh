#!/usr/bin/env bash
# omen-kbd-rgb - check a freshly built module on the machine itself.
#
# Builds the module in this directory, swaps it in for the loaded one, and
# checks each thing it is supposed to do. The keyboard ends up with the
# colours and level it had before; the graphics mux is only read, never set.
#
# Usage:  sudo bash verify.sh
#
# Some of it needs a hand on the keyboard: step 6 asks for Fn+F4 three times.

# A && ok || no is safe here: ok, no and info always succeed.
# shellcheck disable=SC2015
set -u
say()  { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
ok()   { printf '  \033[32mOK\033[0m   %s\n' "$1"; }
no()   { printf '  \033[31mNO\033[0m   %s\n' "$1"; FAILED=1; }
info() { printf '       %s\n' "$1"; }
FAILED=0

[ "$(id -u)" -eq 0 ] || { echo "run it with sudo: it reloads a kernel module" >&2; exit 2; }
cd "$(dirname "$0")" || exit 2

DEV=/sys/devices/platform/omen-kbd-rgb
LEDS=/sys/class/leds
BL=$LEDS/omen::kbd_backlight

say "1. Build"
# As the user who owns the tree, so root does not leave root-owned objects in it.
OWNER=$(stat -c %U .)
if sudo -u "$OWNER" make -s >/dev/null; then
  ok "built $(modinfo -F version ./omen-kbd-rgb.ko)"
else
  no "the build failed"; exit 1
fi

say "2. Swap it in"
BEFORE_LEVEL=$(cat "$BL/brightness" 2>/dev/null || echo 100)
declare -a BEFORE_ZONES
for i in 0 1 2 3; do
  BEFORE_ZONES[i]=$(cat "$LEDS/omen:rgb:kbd_backlight_zone$i/multi_intensity" 2>/dev/null || echo "")
done
# Removed first: modprobe -r also drops dependencies nothing else uses, so
# loading them before this would have them taken away again.
modprobe -r omen_kbd_rgb 2>/dev/null
modprobe -a led-class-multicolor wmi
if insmod ./omen-kbd-rgb.ko; then ok "loaded"; else no "insmod failed"; dmesg | tail -5; exit 1; fi
info "--- dmesg ---"
dmesg | grep -E 'omen[-_]kbd[-_]rgb' | tail -6 | sed 's/^/       /'

say "3. Keyboard (LM01, LEDs)"
if [ -e "$BL" ]; then ok "omen::kbd_backlight is registered - LM01 said 4-zone RGB"; else no "no keyboard LEDs - see dmesg above for what LM01 said"; fi
for i in 0 1 2 3; do
  [ -e "$LEDS/omen:rgb:kbd_backlight_zone$i" ] || no "zone $i is missing"
done
[ -e "$BL/brightness_hw_changed" ] && ok "brightness_hw_changed exists (Fn+F4 is followed)" \
                                   || no "brightness_hw_changed is missing"
info "backlight_active: $(cat $DEV/backlight_active 2>/dev/null || echo '?')"

say "4. Brightness and colours"
echo 100 > "$BL/brightness"
echo 255 > "$LEDS/omen:rgb:kbd_backlight_zone0/brightness"
echo "255 0 0" > "$LEDS/omen:rgb:kbd_backlight_zone0/multi_intensity"
sleep 0.3
[ "$(cat $DEV/backlight_active)" = 1 ] && ok "brightness 100 lit the keyboard" || no "the keyboard is still dark"
echo 30 > "$BL/brightness"; sleep 0.3
[ "$(cat "$BL/brightness")" = 30 ] && ok "level 30 reads back" || no "level reads back as $(cat "$BL/brightness")"
echo 0 > "$BL/brightness"; sleep 0.3
[ "$(cat $DEV/backlight_active)" = 0 ] && ok "brightness 0 switched it off" || no "brightness 0 left it lit"

say "5. Coalesced writes"
echo 100 > "$BL/brightness"
start=$(date +%s%N)
for n in $(seq 1 20); do
  for i in 0 1 2 3; do echo "$((n * 12)) 0 $((255 - n * 12))" > "$LEDS/omen:rgb:kbd_backlight_zone$i/multi_intensity"; done
done
sleep 0.3
ms=$(( ($(date +%s%N) - start) / 1000000 ))
ok "80 zone writes in ${ms} ms"
read -r -p "       Is the whole keyboard now one colour, mostly red? [y/n] " a
[ "$a" = y ] && ok "the last write won on every zone" || no "zones disagree after a burst"

say "6. Fn+F4"
# The firmware's cycle, measured with probe-brightness.sh: bright -> dim
# (its own 50 %) -> off -> bright. What the LED reports is our level times
# the firmware's, so at 60 the steps read 30, 0, 60.
echo 60 > "$BL/brightness"; sleep 0.5
read -r -p "       Press Fn+F4 once (the keyboard should DIM), then Enter. " _
sleep 2.5
[ "$(cat "$BL/brightness_hw_changed" 2>/dev/null)" = 30 ] && ok "the dim step was noticed (60 x 50 % = 30)" || no "brightness_hw_changed reads $(cat "$BL/brightness_hw_changed" 2>/dev/null), not 30"
[ "$(cat $DEV/backlight_active)" = 1 ] && ok "dim counts as lit" || no "dim was taken for off"
read -r -p "       Press Fn+F4 again (the keyboard should go DARK), then Enter. " _
sleep 2.5
[ "$(cat "$BL/brightness_hw_changed" 2>/dev/null)" = 0 ] && ok "the switch-off was noticed" || no "brightness_hw_changed reads $(cat "$BL/brightness_hw_changed" 2>/dev/null), not 0"
# The bug this version fixes: a colour set while dark was stored as black,
# and Fn+F4 then lit a black keyboard.
for i in 0 1 2 3; do
  echo 255 > "$LEDS/omen:rgb:kbd_backlight_zone$i/brightness"
  echo "0 0 255" > "$LEDS/omen:rgb:kbd_backlight_zone$i/multi_intensity"
done
sleep 0.3
read -r -p "       Press Fn+F4 a third time (it should light again), then Enter. " _
sleep 2.5
[ "$(cat "$BL/brightness_hw_changed" 2>/dev/null)" = 60 ] && ok "the switch-on came back at 60" || no "brightness_hw_changed reads $(cat "$BL/brightness_hw_changed" 2>/dev/null), not 60"
read -r -p "       Is the keyboard BLUE (set while it was dark), not black? [y/n] " a
[ "$a" = y ] && ok "a colour set while dark survived Fn+F4" || no "the colour set while dark was lost"

say "7. Graphics mux"
if [ -e $DEV/gpu_mux_mode ]; then
  ok "mode $(cat $DEV/gpu_mux_mode), supports: $(cat $DEV/gpu_mux_supported)"
  [ "$(cat $DEV/gpu_mux_pending_reboot)" = 0 ] && ok "no switch pending" || info "a switch is pending: $(cat $DEV/gpu_mux_pending_reboot)"
else
  no "no mux attributes"
fi

say "8. dGPU temperature"
HW=$(grep -lx omen /sys/class/hwmon/*/name 2>/dev/null | head -1)
if [ -n "$HW" ]; then
  d=$(dirname "$HW")
  t=$(cat "$d/temp1_input" 2>/dev/null) && ok "$(cat "$d/temp1_label"): $((t / 1000)) C" \
                                        || info "temp1_input has no reading (GPU asleep?)"
  command -v nvidia-smi >/dev/null && info "nvidia-smi: $(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null || echo asleep)"
else
  no "no 'omen' hwmon device"
fi

say "8b. GPU power (cTGP, Dynamic Boost)"
if [ -e $DEV/gpu_ppab ]; then
  ok "cTGP $(cat $DEV/gpu_ctgp), Dynamic Boost $(cat $DEV/gpu_ppab) - read from GM21"
  info "setting them is left to omend (omenctl gpu boost), which follows the profile"
  pgrep -x nvidia-powerd >/dev/null && ok "nvidia-powerd is running" \
                                   || info "nvidia-powerd is not running - Dynamic Boost will do nothing"
else
  no "no gpu_ctgp / gpu_ppab - GM21 did not answer, or no NVIDIA GPU was found"
fi

say "8c. Surface temperature and power limits (0.3.0)"
if [ -n "$HW" ] && [ -e "$(dirname "$HW")/temp2_input" ]; then
  d=$(dirname "$HW")
  t=$(cat "$d/temp2_input" 2>/dev/null) && ok "$(cat "$d/temp2_label"): $((t / 1000)) C (EC 0x48)" \
                                        || no "temp2_input has no reading"
  info "a palm rest reads in the 30s to 40s at idle; well below the CPU"
else
  no "no surface temperature - dmesg says what EC 0x48 read"
fi
if [ -e $DEV/cpu_pl1 ]; then
  PL1=$(cat $DEV/cpu_pl1)
  ok "PL1 $PL1 W, Unleashed $(cat $DEV/unleashed)"
  # The same value back: proves the write path without changing anything.
  if echo "$PL1" > $DEV/cpu_pl1 && [ "$(cat $DEV/cpu_pl1)" = "$PL1" ]; then
    ok "PL1 written back through GM29 and read back the same"
  else
    no "writing PL1 back through GM29 failed"
  fi
  [ -e $DEV/gpu_tpp ] && ok "shared CPU+GPU limit $(cat $DEV/gpu_tpp) W (GM2A)" \
                      || info "no gpu_tpp - the firmware reports no shared limit"
else
  no "no cpu_pl1 / unleashed - not 8D24, or not an OMEN by DMI"
fi

say "9. debugfs"
mountpoint -q /sys/kernel/debug || mount -t debugfs none /sys/kernel/debug
if [ -r /sys/kernel/debug/omen-kbd-rgb/lighting_regs ]; then
  ok "lighting_regs:"; sed 's/^/       /' /sys/kernel/debug/omen-kbd-rgb/lighting_regs
else
  info "no lighting_regs (expected everywhere but 8D24)"
fi
[ -e $DEV/lighting_regs ] && no "lighting_regs is still in sysfs"
if [ -r /sys/kernel/debug/omen-kbd-rgb/fan_state ]; then
  ok "fan_state (read only; probe-handover.sh is what uses it):"
  sed 's/^/       /' /sys/kernel/debug/omen-kbd-rgb/fan_state
fi

say "10. Suspend (optional)"
info "To check resume: systemctl suspend, wake it, and the colours should be"
info "the ones from before - without omend: sudo systemctl stop omend first."

say "Putting the keyboard back"
for i in 0 1 2 3; do
  [ -n "${BEFORE_ZONES[i]}" ] || continue
  echo 255 > "$LEDS/omen:rgb:kbd_backlight_zone$i/brightness"
  echo "${BEFORE_ZONES[i]}" > "$LEDS/omen:rgb:kbd_backlight_zone$i/multi_intensity"
done
echo "$BEFORE_LEVEL" > "$BL/brightness"
info "The module from this tree stays loaded until reboot; the installed one"
info "comes back then. To install this one: ./install.sh"

echo
[ "$FAILED" = 0 ] && echo "All checks passed." || echo "Some checks FAILED - see above."
exit "$FAILED"
