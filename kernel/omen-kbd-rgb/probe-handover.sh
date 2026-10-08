#!/usr/bin/env bash
# How does this board hand its fans back to the EC? docs/research/ec-handover.md
# says what is known and what this measures:
#
#   A. The fallback. hp-wmi is unloaded while it holds a mid setpoint, so
#      nothing calls GM10 any more and nothing writes a setpoint. Does the EC
#      fall back to its own curve, and after how long?
#   B. fanControlByBios. With hp-wmi in manual mode at the bottom of the
#      range, GM1A's third byte is set - what the Hub calls handing the fans
#      to the BIOS. Do they start following the load at once?
#
# Both run a CPU load, because a fan curve is only visible under one. The
# safety rule is the daemon's: at 90 C, or with both fans stopped at 75 C or
# above, the fans go to full power and the run ends. The service is stopped
# for the duration and started again afterwards.
#
# Usage:  sudo bash probe-handover.sh        (about seven minutes)

set -u
[ "$(id -u)" -eq 0 ] || { echo "run it with sudo" >&2; exit 2; }
cd "$(dirname "$0")" || exit 2

DBG=/sys/kernel/debug/omen-kbd-rgb
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

finish() {
  load_off
  [ -e $DBG/fan_bios_control ] && echo 0 > $DBG/fan_bios_control 2>/dev/null
  modprobe hp_wmi 2>/dev/null
  sleep 2
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

echo "== Loading the module from this tree"
OWNER=$(stat -c %U .)
sudo -u "$OWNER" make -s >/dev/null || { echo "build failed"; exit 1; }
systemctl stop omend
modprobe -r omen_kbd_rgb 2>/dev/null
modprobe -a led-class-multicolor wmi
insmod ./omen-kbd-rgb.ko || exit 1
mountpoint -q /sys/kernel/debug || mount -t debugfs none /sys/kernel/debug
[ -e $DBG/fan_state ] || { echo "no $DBG/fan_state - not 8D24, or an old module"; exit 1; }
HP=$(hwmon hp)
[ -n "$HP" ] || { echo "no hp-wmi hwmon"; exit 1; }
log "board $(cat /sys/class/dmi/id/board_name), BIOS $(cat /sys/class/dmi/id/bios_version), $(uname -r)"
log "at rest: cpu $(cpu_c) C, fans $(fans), $(state)"

log ""
log "== A. hp-wmi unloaded at a mid setpoint: does the EC fall back, and when?"
echo 1 > "$HP/pwm1_enable"; echo 128 > "$HP/pwm1"
sleep 8
log "  manual, pwm 128: fans $(fans), $(state)"
load_on
sleep 4
modprobe -r hp_wmi && log "  hp_wmi unloaded at $(date +%T) - no GM10, no setpoint writes from here"
observe 170
load_off
modprobe hp_wmi; sleep 3; HP=$(hwmon hp)
log "  load off, hp_wmi back"
sleep 30

log ""
log "== B. fanControlByBios: GM1A byte 2 = 1, from the bottom of the range"
# 96/255 of hp-wmi's 4800 is 18 hundred RPM, the bottom of the range; pwm 1
# would round to a setpoint of 0 and stop the fans.
echo 1 > "$HP/pwm1_enable"; echo 96 > "$HP/pwm1"
sleep 8
log "  manual, pwm 96 (1800 RPM): fans $(fans), $(state)"
load_on
sleep 4
echo 1 > $DBG/fan_bios_control && log "  fan_bios_control = 1 at $(date +%T)"
# Under hp-wmi's 90 s keep-alive, which would re-write the setpoint.
observe 80
echo 0 > $DBG/fan_bios_control && log "  fan_bios_control = 0"
observe 16 "(after 0) "
load_off

log ""
log "Done. Nothing was written to the EC directly: the setpoints went through"
log "hp-wmi, FAMC through GM1A."
