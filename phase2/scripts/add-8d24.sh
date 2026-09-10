#!/usr/bin/env bash
# Adds the board 8D24 (OMEN 16-ap0xxx) entry to hp-wmi.c.
#
# The array name and the driver_data form differ by kernel version:
#   7.2  : victus_s_thermal_profile_boards[] , &omen_v1_legacy_thermal_params
#   7.3+ : hp_wmi_feature_boards[]           , &omen_v1_legacy_board_params
# The script works out which one it is looking at.
#
# The sibling board 8D26 uses the same parameters, so we insert our entry
# immediately above it.
#
# Usage: bash add-8d24.sh /path/to/hp-wmi.c

set -euo pipefail

SRC="${1:?usage: add-8d24.sh <path to hp-wmi.c>}"
[ -f "$SRC" ] || { echo "ERROR: $SRC not found"; exit 1; }

if grep -q '"8D24"' "$SRC"; then
  echo "8D24 is already present, nothing changed."
  exit 0
fi

grep -q '"8D26"' "$SRC" || { echo "ERROR: the 8D26 entry used as an anchor was not found."; exit 1; }

if grep -q 'omen_v1_legacy_board_params' "$SRC"; then
  PARAMS='omen_v1_legacy_board_params'          # 7.3+
elif grep -q 'omen_v1_legacy_thermal_params' "$SRC"; then
  PARAMS='omen_v1_legacy_thermal_params'        # 7.2
else
  echo "ERROR: no omen_v1_legacy_* parameter struct found. The kernel version is not what we expect."
  exit 1
fi
echo "Detected parameter struct: $PARAMS"

cp -n "$SRC" "$SRC.orig" 2>/dev/null || true

# Find the first line of the block holding the 8D26 entry (the '{' line, one
# above the DMI_MATCH).
LN=$(grep -n 'DMI_BOARD_NAME, "8D26"' "$SRC" | head -1 | cut -d: -f1)
OPEN=$((LN - 1))
sed -n "${OPEN}p" "$SRC" | grep -q '{' || { echo "ERROR: the opening brace of the 8D26 entry is not where it should be."; exit 1; }

# Inherit the indentation from the 8D26 entry verbatim.
INDENT=$(sed -n "${OPEN}p" "$SRC" | sed 's/[^ \t].*//')

{
  printf '%s{\n'                                                   "$INDENT"
  printf '%s\t.matches = { DMI_MATCH(DMI_BOARD_NAME, "8D24") },\n' "$INDENT"
  printf '%s\t.driver_data = (void *)&%s,\n'                       "$INDENT" "$PARAMS"
  printf '%s},\n'                                                  "$INDENT"
} > /tmp/8d24-entry.$$

sed -i "$((OPEN - 1))r /tmp/8d24-entry.$$" "$SRC"
rm -f /tmp/8d24-entry.$$

echo "Added. Backup: $SRC.orig"
echo
grep -n -B2 -A4 '"8D24"' "$SRC"
