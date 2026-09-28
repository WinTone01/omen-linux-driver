#!/usr/bin/env bash
# What does the LBRT byte mean? Records it at every Fn+F4 step, then writes
# candidate values and asks what the keyboard does. Needs root (debugfs).
#
# Usage:  sudo bash probe-brightness.sh
#
# Background: the driver treats LBRT as a switch (0xE4 on, 0x64 off), but
# Fn+F4 steps through more than two states on 8D24 - it dims before it goes
# off - and 0xE4 = 0x80 | 100 reads like an "on" bit over a 0-100 level.

set -u
[ "$(id -u)" -eq 0 ] || { echo "run it with sudo" >&2; exit 2; }
cd "$(dirname "$0")" || exit 2

L=/sys/class/leds
BL=$L/omen::kbd_backlight
DBG=/sys/kernel/debug/omen-kbd-rgb
LOG=$(mktemp)
say() { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
log() { echo "$1" | tee -a "$LOG"; }

say "1. Loading the module from this tree"
OWNER=$(stat -c %U .)
sudo -u "$OWNER" make -s >/dev/null || { echo "build failed"; exit 1; }
# Removed first: modprobe -r also drops dependencies nothing else uses, so
# loading them before this would have them taken away again.
modprobe -r omen_kbd_rgb 2>/dev/null
modprobe -a led-class-multicolor wmi
insmod ./omen-kbd-rgb.ko || exit 1
mountpoint -q /sys/kernel/debug || mount -t debugfs none /sys/kernel/debug
[ -e $DBG/lbrt ] || { echo "no $DBG/lbrt - wrong module?"; exit 1; }
regs() { [ -r $DBG/lighting_regs ] && head -1 $DBG/lighting_regs | cut -c1-8 || echo "-"; }

say "2. Fn+F4, one press at a time"
for i in 0 1 2 3; do
  echo 255 > $L/omen:rgb:kbd_backlight_zone$i/brightness
  echo "255 255 255" > $L/omen:rgb:kbd_backlight_zone$i/multi_intensity
done
echo 100 > $BL/brightness; sleep 1
log "start (white, brightness 100): lbrt=$(cat $DBG/lbrt) regs[ee0..]=$(regs)"
for n in 1 2 3 4; do
  read -r -p "  Press Fn+F4 ONCE, then Enter. " _
  sleep 1
  read -r -p "  How does it look? (bright / dim / off / other) " a
  log "Fn+F4 #$n: lbrt=$(cat $DBG/lbrt) regs[ee0..]=$(regs)  user: $a"
done

say "3. Writing values directly"
echo "  Make sure the keyboard is lit before this part (Fn+F4 until it is)."
read -r -p "  Enter when lit. " _
for v in 0xe4 0xb2 0x94 0x8a 0x80 0xe4 0x32 0xe4; do
  echo "$v" > $DBG/lbrt; sleep 1
  read -r -p "  wrote $v: how does it look? (bright / dim / dimmer / off / other) " a
  log "wrote $v: read back $(cat $DBG/lbrt) regs[ee0..]=$(regs)  user: $a"
done

say "Putting it back"
echo 0xe4 > $DBG/lbrt
echo 100 > $BL/brightness
echo
echo "== paste this back =="
cat "$LOG"
