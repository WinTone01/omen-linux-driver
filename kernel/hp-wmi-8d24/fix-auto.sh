#!/usr/bin/env bash
# Makes hp-wmi's "automatic" fan mode hand the fans to the EC on 8D24, instead
# of stopping them for two minutes.
#
# Measured (docs/research/ec-handover.md): hp-wmi's PWM_MODE_AUTO renews the
# firmware's user-defined state (WMI 0x10) and then writes a setpoint of 0.
# The EC obeys the 0 - fans stopped - until that state times out 120 s later,
# and when it does it also resets the thermal profile. The firmware's own
# "automatic" setpoint is 0xff: written through the same WMI 0x2E, the EC's
# curve takes over within two seconds, and keeping the state renewed keeps
# the profile.
#
# So on 8D24, and only there, this changes two things:
#   - the setpoint written when returning to automatic is 0xff, not 0;
#   - the keep-alive keeps running in automatic, re-asserting it every 90 s.
# A manual pwm of 0 is untouched: it still means stopped, which is what omend
# uses for a silent idle. hp_wmi.firmware_auto=0 turns the change off.
#
# Works on both shapes of hp-wmi.c the build meets (7.2 and 7.3+): it anchors
# on lines both have, and refuses rather than guessing if one is missing.
#
# Usage: bash fix-auto.sh /path/to/hp-wmi.c
# Exit codes: 0 applied, 2 an anchor is missing, 3 already applied.

set -euo pipefail

SRC="${1:?usage: fix-auto.sh <path to hp-wmi.c>}"
[ -f "$SRC" ] || { echo "ERROR: $SRC not found"; exit 2; }

if grep -q 'hp_wmi_auto_is_ff' "$SRC"; then
  echo "the automatic-mode fix is already in $SRC"
  exit 3
fi

need() {
  local n
  n=$(grep -cF -- "$1" "$SRC" || true)
  [ "$n" = "${2:-1}" ] || {
    echo "ERROR: expected ${2:-1} of '$1' in hp-wmi.c, found $n - this kernel's hp-wmi is not one this was written for"
    exit 2
  }
}

AUTO_DEF='#define HP_FAN_SPEED_AUTOMATIC'
SET_QUERY='ret = hp_wmi_perform_query(HPWMI_VICTUS_S_FAN_SPEED_SET_QUERY, HPWMI_GM,'
RESET_DEF='static int hp_wmi_fan_speed_reset(struct hp_wmi_hwmon_priv *priv)'
MAX_RESET_DEF='static int hp_wmi_fan_speed_max_reset(struct hp_wmi_hwmon_priv *priv)'
AUTO_CANCEL=$'\t\tcancel_delayed_work(&priv->keep_alive_dwork);'

need "$AUTO_DEF"
need "$SET_QUERY"
need "$RESET_DEF"
need "$MAX_RESET_DEF"
need "$AUTO_CANCEL"

TMP=$(mktemp)
awk -v auto_def="$AUTO_DEF" -v set_query="$SET_QUERY" \
    -v reset_def="$RESET_DEF" -v max_reset_def="$MAX_RESET_DEF" \
    -v auto_cancel="$AUTO_CANCEL" '
index($0, auto_def) == 1 {
  print
  print ""
  print "/*"
  print " * omen-linux-driver: on 8D24 the \"automatic\" setpoint of the firmware is"
  print " * 0xff. Written through 0x2E, the curve of the EC takes over within two"
  print " * seconds; 0 instead means stopped until the user-defined state times out."
  print " * Measured: docs/research/ec-handover.md in that project."
  print " */"
  print "#define HP_FAN_SPEED_FIRMWARE_AUTO\t0xff"
  print ""
  print "static bool firmware_auto = true;"
  print "module_param(firmware_auto, bool, 0444);"
  print "MODULE_PARM_DESC(firmware_auto,"
  print "\t\t \"Automatic fan mode hands the fans to the EC (8D24 only; 0 = upstream behaviour)\");"
  print ""
  print "/* Set while the fans are being returned to automatic. */"
  print "static bool hp_wmi_fan_resetting;"
  print ""
  print "static bool hp_wmi_auto_is_ff(void)"
  print "{"
  print "\treturn firmware_auto && dmi_match(DMI_BOARD_NAME, \"8D24\");"
  print "}"
  print ""
  next
}
index($0, set_query) {
  print "\tif (hp_wmi_fan_resetting && hp_wmi_auto_is_ff()) {"
  print "\t\tfan_speed[CPU_FAN] = HP_FAN_SPEED_FIRMWARE_AUTO;"
  print "\t\tfan_speed[GPU_FAN] = HP_FAN_SPEED_FIRMWARE_AUTO;"
  print "\t}"
  print
  next
}
$0 == reset_def {
  print "static int hp_wmi_fan_speed_reset_stock(struct hp_wmi_hwmon_priv *priv)"
  next
}
$0 == max_reset_def {
  print "static int hp_wmi_fan_speed_reset(struct hp_wmi_hwmon_priv *priv)"
  print "{"
  print "\tint ret;"
  print ""
  print "\thp_wmi_fan_resetting = true;"
  print "\tret = hp_wmi_fan_speed_reset_stock(priv);"
  print "\thp_wmi_fan_resetting = false;"
  print "\treturn ret;"
  print "}"
  print ""
  print
  next
}
$0 == auto_cancel {
  print "\t\t/* 8D24: keep the state - and the profile - alive in automatic too. */"
  print "\t\tif (hp_wmi_auto_is_ff())"
  print "\t\t\tmod_delayed_work(system_dfl_wq, &priv->keep_alive_dwork,"
  print "\t\t\t\t\t secs_to_jiffies(KEEP_ALIVE_DELAY_SECS));"
  print "\t\telse"
  print "\t\t\tcancel_delayed_work(&priv->keep_alive_dwork);"
  next
}
{ print }
' "$SRC" > "$TMP"

# Each anchor must have produced its change exactly once.
for marker in 'HP_FAN_SPEED_FIRMWARE_AUTO;' 'hp_wmi_fan_speed_reset_stock(struct' \
              'ret = hp_wmi_fan_speed_reset_stock(priv);' 'if (hp_wmi_auto_is_ff())'; do
  grep -qF -- "$marker" "$TMP" || { echo "ERROR: '$marker' did not land"; rm -f "$TMP"; exit 2; }
done
mv "$TMP" "$SRC"
echo "automatic fan mode: 0xff and a kept-alive state on 8D24 (hp_wmi.firmware_auto)"
