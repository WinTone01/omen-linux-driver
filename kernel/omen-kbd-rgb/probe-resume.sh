#!/usr/bin/env bash
# The keyboard after a resume: what the driver, the firmware and the desktop
# each say, and which way of switching it on works.
#
# Run it right after waking the machine, while the keyboard is dark:
#   sudo bash kernel/omen-kbd-rgb/probe-resume.sh | tee resume.txt
# It writes the switch on through three paths, one at a time, and says after
# each whether the firmware took it. Nothing else is changed.

set -u
DEV=/sys/devices/platform/omen-kbd-rgb
BL=/sys/class/leds/omen::kbd_backlight
DBG=/sys/kernel/debug/omen-kbd-rgb
say()  { printf '\n== %s ==\n' "$1"; }
show() { printf '  %-28s %s\n' "$1" "$2"; }

[ "$(id -u)" = 0 ] || { echo "run with sudo: the switch is read through debugfs"; exit 1; }
mountpoint -q /sys/kernel/debug || mount -t debugfs none /sys/kernel/debug

state() {
  show "LED brightness" "$(cat $BL/brightness 2>/dev/null || echo '?')"
  show "backlight_active" "$(cat $DEV/backlight_active 2>/dev/null || echo '?')"
  show "LBRT (firmware switch)" "$(cat $DBG/lbrt 2>/dev/null || echo '?')"
  for i in 0 1 2 3; do
    show "zone$i colour" "$(cat /sys/class/leds/omen:rgb:kbd_backlight_zone$i/multi_intensity 2>/dev/null) x $(cat /sys/class/leds/omen:rgb:kbd_backlight_zone$i/brightness 2>/dev/null)"
  done
  [ -r $DBG/lighting_regs ] && sed 's/^/    EC 0xEE0: /' $DBG/lighting_regs
}

say "The machine"
show "kernel" "$(uname -r)"
show "module" "$(cat /sys/module/omen_kbd_rgb/version 2>/dev/null || echo 'not loaded')"
show "last sleep" "$(cat /sys/power/mem_sleep 2>/dev/null)"

say "Now, before anything is written"
state

say "Who else writes the keyboard"
for p in upowerd powerdevil org_kde_powerdevil gsd-power omend omen-ui; do
  pgrep -x "$p" >/dev/null 2>&1 && show "$p" "running"
done
journalctl -b --no-pager -o short-monotonic 2>/dev/null \
  | grep -iE 'omen.kbd|omen_kbd|kbd_backlight|keyboard (restored|did not)' | tail -15 | sed 's/^/    /'

try() {
  say "$1"
  sh -c "$2" 2>&1 | sed 's/^/    /'
  sleep 1
  state
}
try "1. Through the LED class (what the desktop does)" "echo 100 > $BL/brightness"
try "2. Straight to the firmware switch (LM05 0xE4)" "echo 0xe4 > $DBG/lbrt"
try "3. Colours rewritten, then the switch" \
    "for i in 0 1 2 3; do echo 255 > /sys/class/leds/omen:rgb:kbd_backlight_zone\$i/brightness; done; echo 100 > $BL/brightness"

say "dmesg"
dmesg 2>/dev/null | grep -iE 'omen.kbd|omen_kbd|hp.wmi|PM: suspend|PM: resume' | tail -20 | sed 's/^/    /'
echo
echo "If none of the three lit it, press Fn+F4 once and run it again."
