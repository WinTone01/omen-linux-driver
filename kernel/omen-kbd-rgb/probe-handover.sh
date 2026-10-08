#!/usr/bin/env bash
# How does this board hand its fans back to the EC? docs/research/ec-handover.md
# says what is known and what this measures:
#
#   A. The fallback. hp-wmi is unloaded while it holds a mid setpoint, so
#      nothing calls GM10 any more and nothing writes a setpoint. Does the EC
#      fall back to its own curve, and after how long? (Run 2026-10-08: yes,
#      when EC 0x63 counts down to zero - see the results in the doc.)
#   B. fanControlByBios. With hp-wmi in manual mode at the bottom of the
#      range, GM1A's third byte is set - what the Hub calls handing the fans
#      to the BIOS. Do they start following the load at once?
#   C. The firmware's own "automatic". When the timer runs out the firmware
#      writes 0xFF to both setpoints. Written through GM2E instead, from the
#      bottom of the range: does the EC's curve take over at once?
#
# Each runs a CPU load, because a fan curve is only visible under one. The
# safety rule is the daemon's: at 90 C, or with both fans stopped at 75 C or
# above, the fans go to full power and the run ends. The service is stopped
# for the duration and started again afterwards, and the platform profile -
# which the firmware resets when it falls back - is put back.
#
# Usage:  sudo bash probe-handover.sh [A] [B] [C]   (default: B C, ~4 minutes)

set -u
[ "$(id -u)" -eq 0 ] || { echo "run it with sudo" >&2; exit 2; }
cd "$(dirname "$0")" || exit 2

TESTS="${*:-B C}"
DBG=/sys/kernel/debug/omen-kbd-rgb
PROFILE_FILE=/sys/firmware/acpi/platform_profile
LOG=$(mktemp)
log() { echo "$1" | tee -a "$LOG"; }

LIMIT_C=90
STALL_C=75

hwmon() { dirname "$(grep -lx "$1" /sys/class/hwmon/*/name 2>/dev/null | head -1)"; }
cpu_c() { echo $(( $(cat "$(hwmon k10temp)/temp1_input") / 1000 )); }
# The fast tachometers in EC RAM: they work with hp-wmi unloaded.
fans() { local d; d=$(hwmon omen); echo "$(cat "$d/fan1_input") $(cat "$d/fan2_input")"; }
state() { tr '\n' ' ' < $DBG/fan_state | tr -s ' '; }

LOAD=()
load_on() {
  for _ in $(seq "$(nproc)"); do (while :; do :; done) & LOAD+=($!); done
}
load_off() {
  [ ${#LOAD[@]} -gt 0 ] && kill "${LOAD[@]}" 2>/dev/null
  LOAD=()
}

full_power() {
  modprobe hp_wmi 2>/dev/null
  sleep 2
  local hp; hp=$(hwmon hp)
  [ -n "$hp" ] && echo 0 > "$hp/pwm1_enable"
}

PROFILE=$(cat $PROFILE_FILE 2>/dev/null)

finish() {
  load_off
  [ -e $DBG/fan_bios_control ] && echo 0 > $DBG/fan_bios_control 2>/dev/null
  modprobe hp_wmi 2>/dev/null
  sleep 2
  [ -n "$PROFILE" ] && echo "$PROFILE" > $PROFILE_FILE 2>/dev/null
  systemctl start omend
  echo
  echo "== paste this back =="
  cat "$LOG"
}
trap finish EXIT

# Watches for $1 seconds, one line every two. Returns 1 if it had to step in.
observe() {
  local secs=$1 t=0 c f
  while [ $t -lt "$secs" ]; do
    c=$(cpu_c); f=$(fans)
    log "  +${t}s  cpu ${c} C  fans ${f}  ${2:-}$(state)"
    if [ "$c" -ge $LIMIT_C ] || { [ "$f" = "0 0" ] && [ "$c" -ge $STALL_C ]; }; then
      log "  SAFETY: ${c} C with fans ${f} - full power, stopping this run"
      load_off; full_power
      return 1
    fi
    sleep 2; t=$((t + 2))
  done
}

# hp-wmi back, in manual mode at pwm $1, settled, with the load running.
manual_under_load() {
  modprobe hp_wmi 2>/dev/null; sleep 2; HP=$(hwmon hp)
  echo 1 > "$HP/pwm1_enable"; echo "$1" > "$HP/pwm1"
  sleep 8
  log "  manual, pwm $1: fans $(fans), $(state)"
  load_on
  sleep 4
}

cool_down() {
  load_off
  modprobe hp_wmi 2>/dev/null; sleep 2; HP=$(hwmon hp)
  [ -n "$PROFILE" ] && echo "$PROFILE" > $PROFILE_FILE 2>/dev/null
  echo 1 > "$HP/pwm1_enable"; echo 192 > "$HP/pwm1"
  log "  load off, 3600 RPM for 30 s before the next test"
  sleep 30
}

test_A() {
  log ""
  log "== A. hp-wmi unloaded at a mid setpoint: does the EC fall back, and when?"
  manual_under_load 128
  modprobe -r hp_wmi && log "  hp_wmi unloaded at $(date +%T) - no GM10, no setpoint writes from here"
  observe 170
  cool_down
}

test_B() {
  log ""
  log "== B. fanControlByBios: GM1A byte 2 = 1, from the bottom of the range"
  # 96/255 of hp-wmi's 4800 is 18 hundred RPM, the bottom of the range; pwm 1
  # would round to a setpoint of 0 and stop the fans.
  manual_under_load 96
  echo 1 > $DBG/fan_bios_control && log "  fan_bios_control = 1 at $(date +%T)"
  # Inside hp-wmi's 90 s keep-alive, which would re-write the setpoint.
  observe 60
  echo 0 > $DBG/fan_bios_control && log "  fan_bios_control = 0"
  observe 12 "(after 0) "
  cool_down
}

test_C() {
  log ""
  log "== C. setpoints 0xFF through GM2E, from the bottom of the range"
  manual_under_load 96
  echo 1 > $DBG/fan_setpoint_auto && log "  setpoints 0xFF at $(date +%T)"
  observe 60
  cool_down
}

echo "== Loading the module from this tree"
OWNER=$(stat -c %U .)
sudo -u "$OWNER" make -s >/dev/null || { echo "build failed"; exit 1; }
systemctl stop omend
modprobe -r omen_kbd_rgb 2>/dev/null
modprobe -a led-class-multicolor wmi
insmod ./omen-kbd-rgb.ko || exit 1
mountpoint -q /sys/kernel/debug || mount -t debugfs none /sys/kernel/debug
[ -e $DBG/fan_setpoint_auto ] || { echo "no $DBG/fan_setpoint_auto - not 8D24, or an old module"; exit 1; }
[ -n "$(hwmon hp)" ] || { echo "no hp-wmi hwmon"; exit 1; }
log "board $(cat /sys/class/dmi/id/board_name), BIOS $(cat /sys/class/dmi/id/bios_version), $(uname -r)"
log "profile $PROFILE; at rest: cpu $(cpu_c) C, fans $(fans), $(state)"

for t in $TESTS; do
  case "$t" in
    A|a) test_A ;;
    B|b) test_B ;;
    C|c) test_C ;;
    *) log "unknown test: $t (A, B or C)" ;;
  esac
done

log ""
log "Done. Nothing was written to the EC directly: the setpoints went through"
log "hp-wmi and GM2E, FAMC through GM1A."
