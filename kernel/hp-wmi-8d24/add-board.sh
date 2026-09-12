#!/usr/bin/env bash
# Adds a board entry to hp-wmi.c's OMEN table.
#
# Written for 8D24 (OMEN 16-ap0xxx) and generalised afterwards, because the
# table is the only thing standing between most of this family and working fan
# control: hp-wmi exposes pwm1 only for boards it has an entry for, and HP
# ships new ones faster than they reach the kernel. The entry is one line of
# DMI match against parameters the rest of the family already uses.
#
# What this does NOT claim: that the board has been tested. The fan protocol
# (WMI 0x2E setpoint, the thermal profile) is shared across OMEN and Victus
# models and upstream gives nearly all of them the same parameters, which is
# why adding one is reasonable - but "reasonable" is not "measured", and the
# caller is expected to say so to the user.
#
# The array name and the driver_data form differ by kernel version:
#   7.2  : victus_s_thermal_profile_boards[] , &omen_v1_legacy_thermal_params
#   7.3+ : hp_wmi_feature_boards[]           , &omen_v1_legacy_board_params
# The script works out which one it is looking at.
#
# Usage: bash add-board.sh /path/to/hp-wmi.c [BOARD|auto]
#        BOARD defaults to 8D24, which reproduces the patch in patches/.
#        'auto' reads the board name of the machine it is running on.
#
# Exit codes: 0 added, 2 an error, 3 nothing to do (already present).

set -euo pipefail

SRC="${1:?usage: add-board.sh <path to hp-wmi.c> [BOARD|auto]}"
BOARD="${2:-8D24}"
[ -f "$SRC" ] || { echo "ERROR: $SRC not found"; exit 2; }

if [ "$BOARD" = auto ]; then
  BOARD=$(cat /sys/class/dmi/id/board_name 2>/dev/null || true)
  MODEL=$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)
  [ -n "$BOARD" ] || { echo "ERROR: this machine does not report a board name."; exit 2; }

  # Only for the family the parameters belong to. On something else this
  # would hand an unrelated machine's fans to a protocol written for HP's.
  case "${MODEL,,}" in
    *omen*|*victus*) ;;
    *)
      echo "ERROR: $MODEL is not an OMEN or a Victus; refusing to add $BOARD."
      exit 2
      ;;
  esac
  echo "This machine: $MODEL, board $BOARD"
fi

# A board name is a short alphanumeric id (8D24, 8BCA, 89C6). Anything else
# is a mistake, and this string is about to be written into C source.
case "$BOARD" in
  *[!A-Za-z0-9_-]*|"")
    echo "ERROR: ${BOARD:-<empty>} does not look like a board name."
    exit 2
    ;;
esac

if grep -q "\"$BOARD\"" "$SRC"; then
  echo "$BOARD is already in the table - the stock driver covers this board."
  exit 3
fi

if grep -q 'omen_v1_legacy_board_params' "$SRC"; then
  PARAMS='omen_v1_legacy_board_params'          # 7.3+
elif grep -q 'omen_v1_legacy_thermal_params' "$SRC"; then
  PARAMS='omen_v1_legacy_thermal_params'        # 7.2
else
  echo "ERROR: no omen_v1_legacy_* parameter struct found. The kernel version is not what we expect."
  exit 2
fi
echo "Detected parameter struct: $PARAMS"

# Somewhere to insert. 8D26 is the sibling this was written against; on a
# kernel that does not have it, any entry in the same table will do - they
# all carry the same parameters.
ANCHOR=8D26
grep -q '"8D26"' "$SRC" || {
  ANCHOR=$(grep -o 'DMI_BOARD_NAME, "[A-Za-z0-9_-]*"' "$SRC" | head -1 |
           sed 's/.*"\(.*\)"/\1/')
  [ -n "$ANCHOR" ] || { echo "ERROR: no board table to insert into."; exit 2; }
  echo "8D26 is not in this source; inserting next to $ANCHOR instead."
}

cp -n "$SRC" "$SRC.orig" 2>/dev/null || true

# mktemp rather than $$: predictable names in a world-writable directory are
# how a script that runs near root gets used against its owner.
ENTRY=$(mktemp)
trap 'rm -f "$ENTRY"' EXIT

# Find the first line of the block holding the 8D26 entry (the '{' line, one
# above the DMI_MATCH).
LN=$(grep -n "DMI_BOARD_NAME, \"$ANCHOR\"" "$SRC" | head -1 | cut -d: -f1)
OPEN=$((LN - 1))
sed -n "${OPEN}p" "$SRC" | grep -q '{' || { echo "ERROR: the opening brace of the $ANCHOR entry is not where it should be."; exit 2; }

# Inherit the indentation from the anchor entry verbatim.
INDENT=$(sed -n "${OPEN}p" "$SRC" | sed 's/[^ \t].*//')

{
  printf '%s{\n'                                                   "$INDENT"
  printf '%s\t.matches = { DMI_MATCH(DMI_BOARD_NAME, "%s") },\n'   "$INDENT" "$BOARD"
  printf '%s\t.driver_data = (void *)&%s,\n'                       "$INDENT" "$PARAMS"
  printf '%s},\n'                                                  "$INDENT"
} > "$ENTRY"

sed -i "$((OPEN - 1))r $ENTRY" "$SRC"

echo "Added $BOARD. Backup: $SRC.orig"
echo
grep -n -B2 -A4 "\"$BOARD\"" "$SRC"
