#!/usr/bin/env bash
# What frame rate can the keyboard actually show? Runs the spectrum effect at
# several rates, counts the frames that reached the firmware and times each
# one (debugfs zone_stats), and asks what it looked like. Needs root.
#
# Usage:  sudo bash probe-fps.sh

set -u
[ "$(id -u)" -eq 0 ] || { echo "run it with sudo" >&2; exit 2; }
cd "$(dirname "$0")" || exit 2

CONF=/etc/omen/omend.toml
STATS=/sys/kernel/debug/omen-kbd-rgb/zone_stats
LOG=$(mktemp)
log() { echo "$1" | tee -a "$LOG"; }

# What to put back afterwards.
EFFECT=$(sed -n 's/^effect = "\(.*\)"/\1/p' $CONF)
FPS=$(sed -n 's/^fps = //p' $CONF)
SPEED=$(sed -n 's/^speed = //p' $CONF)

echo "== Loading the module from this tree"
OWNER=$(stat -c %U .)
sudo -u "$OWNER" make -s >/dev/null || { echo "build failed"; exit 1; }
modprobe -r omen_kbd_rgb 2>/dev/null
modprobe -a led-class-multicolor wmi
insmod ./omen-kbd-rgb.ko || exit 1
mountpoint -q /sys/kernel/debug || mount -t debugfs none /sys/kernel/debug
[ -e $STATS ] || { echo "no $STATS - wrong module?"; exit 1; }
# The fast tachometer must say what hp-wmi says, or the daemon would be
# driving the fans from a wrong number.
OMEN_HW=$(dirname "$(grep -lx omen /sys/class/hwmon/*/name | head -1)")
HP_HW=$(dirname "$(grep -lx hp /sys/class/hwmon/*/name | head -1)")
for i in 1 2; do
  fast=$(cat "$OMEN_HW/fan${i}_input" 2>/dev/null || echo "?")
  t0=$(date +%s%N); slow=$(cat "$HP_HW/fan${i}_input"); t1=$(date +%s%N)
  log "fan$i: EC RAM $fast RPM, hp-wmi $slow RPM (hp-wmi took $(( (t1 - t0) / 1000000 )) ms)"
done

# The daemon found the LEDs and the fans before the reload; make it look again.
systemctl restart omend; sleep 3

omenctl effect spectrum 5 >/dev/null
for fps in 15 20 30 60; do
  omenctl effect fps $fps >/dev/null
  sleep 2
  echo reset > $STATS
  sleep 10
  w=$(sed -n 's/^writes //p' $STATS)
  log "$fps fps asked: $((w / 10)) writes/s reached the firmware, mean $(sed -n 's/^mean_us //p' $STATS) us, max $(sed -n 's/^max_us //p' $STATS) us"
  read -r -p "  How did the $fps fps spectrum look? (smooth / slightly steppy / steppy) " a
  log "  user: $a"
done

echo "== Putting it back"
omenctl effect fps "${FPS:-30}" >/dev/null
omenctl effect "${EFFECT:-none}" "${SPEED:-5}" >/dev/null
echo
echo "== paste this back =="
cat "$LOG"
