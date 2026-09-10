#!/usr/bin/env bash
# OMEN 16-ap0xxx (board 8D24) - post-install diagnosis on Linux.
# Read-only: it writes nothing and loads no modules (except ec_sys, read-only).
# Usage:  sudo bash verify.sh   (works without root too; some steps are skipped)

set -u
say()  { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
ok()   { printf '  \033[32mOK\033[0m   %s\n' "$1"; }
no()   { printf '  \033[31mNO\033[0m   %s\n' "$1"; }
info() { printf '       %s\n' "$1"; }

say "1. Hardware identity"
BOARD=$(cat /sys/class/dmi/id/board_name 2>/dev/null || echo '?')
info "board_name   : $BOARD    (expected: 8D24)"
info "product_name : $(cat /sys/class/dmi/id/product_name 2>/dev/null || echo '?')"
info "bios_version : $(cat /sys/class/dmi/id/bios_version 2>/dev/null || echo '?')"
info "kernel       : $(uname -r)"
if [ "$BOARD" = "8D24" ]; then
  ok "You are on the target machine"
else
  no "This board is not 8D24"
  cat <<'BANNER'

       ####################################################################
       #  This is NOT THE TARGET MACHINE. Most of the steps below will come
       #  out meaningless; that is not a bug. Phase 2 can only be tested on
       #  an OMEN 16-ap0xxx (8D24). The script still runs to the end.
       ####################################################################
BANNER
fi

say "2. The hp-wmi module"
if lsmod | grep -q '^hp_wmi'; then ok "hp_wmi is loaded"; else no "hp_wmi is not loaded"; fi
if [ -d /sys/devices/platform/hp-wmi ]; then
  ok "/sys/devices/platform/hp-wmi exists"
  info "contents: $(ls /sys/devices/platform/hp-wmi 2>/dev/null | tr '\n' ' ')"
else
  no "/sys/devices/platform/hp-wmi is missing"
fi
info "--- dmesg ---"
dmesg 2>/dev/null | grep -i 'hp.wmi' | tail -10 | sed 's/^/       /' || info "(could not read dmesg, may need root)"

say "3. Platform profile"
PP=/sys/firmware/acpi/platform_profile
if [ -r "$PP" ]; then
  ok "platform_profile exists"
  info "choices: $(cat ${PP}_choices 2>/dev/null)"
  info "active : $(cat $PP 2>/dev/null)"
else
  no "no platform_profile"
fi

# The profile EXISTING does not mean hp-wmi is driving it. On this machine
# (Strix Point) amd-pmf registers a profile handler too, and the legacy sysfs
# file does not say who registered it. The 6.14+ multi-handler API can tell
# them apart. The distinction matters: if amd-pmf is driving the profile,
# EC 0x95 (HPCM) is never written - that is where the 0 in step 6 comes from.
HP_PP=0
if [ -d /sys/class/platform-profile ]; then
  for h in /sys/class/platform-profile/*/; do
    [ -r "$h/name" ] || continue
    info "handler : $(cat "$h/name") -> $(cat "$h/profile" 2>/dev/null)"
    case "$(cat "$h/name")" in hp-wmi|hp_wmi) HP_PP=1 ;; esac
  done
  if [ "$HP_PP" = "1" ]; then
    ok "hp-wmi is driving the profile"
  else
    no "hp-wmi is NOT driving the profile - expected without the patch (no 8D24 match)"
    info "after patching, a second 'hp-wmi' handler should appear here"
  fi
else
  info "no /sys/class/platform-profile (kernel < 6.14) - handlers cannot be told apart"
fi

say "4. Fan / hwmon"
FOUND=0
for d in /sys/class/hwmon/hwmon*; do
  [ -e "$d/name" ] || continue
  N=$(cat "$d/name")
  printf '       %-14s %s\n' "$N" "$d"
  if [ "$N" = "hp" ] || [ "$N" = "hp_wmi" ]; then
    FOUND=1
    ok "found the hp-wmi hwmon: $d"
    for f in "$d"/fan*_input "$d"/pwm*; do
      [ -e "$f" ] && printf '         %-28s = %s\n' "$(basename $f)" "$(cat $f 2>/dev/null || echo '-')"
    done
  fi
done
[ "$FOUND" = "1" ] || no "no hp-wmi hwmon - expected without the patch (8D24 is not in the DMI table)"

say "5. Board entries in the compiled hp_wmi module"
# Arch/CachyOS do not package the kernel SOURCE, only headers. So instead of
# the source we look at the DMI strings inside the compiled .ko - that works
# on every distribution and answers the question directly.
KO=$(find /lib/modules/$(uname -r) -name 'hp-wmi.ko*' 2>/dev/null | head -1)
if [ -z "$KO" ]; then
  no "hp-wmi.ko not found - hp-wmi may not be built for this kernel"
else
  ok "module: $KO"
  # The .ko may be zst/xz/gz compressed; decompress accordingly.
  case "$KO" in
    *.zst) DUMP="zstd -dcq  $KO" ;;
    *.xz)  DUMP="xz   -dc   $KO" ;;
    *.gz)  DUMP="gzip -dc   $KO" ;;
    *)     DUMP="cat        $KO" ;;
  esac
  BOARDS=$($DUMP 2>/dev/null | strings | grep -xE '8[0-9A-F]{3}' | sort -u | tr '\n' ' ')
  if [ -z "$BOARDS" ]; then
    no "could not extract a board list from the module (are strings/zstd installed?)"
  else
    info "boards present: $BOARDS"
    echo "$BOARDS" | grep -qw 8D24 && ok "8D24 IS PRESENT - no patch needed" \
                                   || no "8D24 is absent - the patch is needed"
    echo "$BOARDS" | grep -qw 8D26 && ok "8D26 (sibling board) is present - the kernel knows the 16-ap0xxx family" \
                                   || no "8D26 is missing too - the kernel is older than expected"
  fi
fi
KV=$(uname -r | cut -d. -f1,2)
info "kernel $KV -> patch shape: $(printf '%s' "$KV" | awk -F. '($1>7)||($1==7&&$2>=3){print "hp_wmi_feature_boards[] + omen_v1_legacy_board_params (7.3+)"; next}{print "victus_s_thermal_profile_boards[] + omen_v1_legacy_thermal_params (7.2)"}')"

say "6. Reading the EC directly (cross-check against Phase 1)"
if [ "$(id -u)" != "0" ]; then
  no "not root, skipping the EC read"
else
  # (a) Is there an ACPI EC device
  if ls /sys/bus/acpi/devices/ 2>/dev/null | grep -q '^PNP0C09'; then
    ok "ACPI EC device present: $(ls /sys/bus/acpi/devices/ | grep '^PNP0C09' | tr '\n' ' ')"
  else
    no "no ACPI EC device (PNP0C09) - normal on desktops"
  fi
  # (b) Is debugfs mounted
  if ! mountpoint -q /sys/kernel/debug 2>/dev/null; then
    info "debugfs is not mounted, mounting it"
    mount -t debugfs none /sys/kernel/debug 2>/dev/null \
      && ok "debugfs mounted" || no "could not mount debugfs"
  fi
  # (c) The ec_sys module - CONFIG_ACPI_EC_DEBUGFS may be disabled
  MPERR=$(modprobe ec_sys write_support=0 2>&1) && MPOK=1 || MPOK=0
  if [ "$MPOK" = "1" ]; then
    lsmod | grep -q '^ec_sys' && ok "ec_sys is loaded" \
                              || info "modprobe did not complain but ec_sys is not in lsmod (may be built in)"
  else
    no "could not load ec_sys: $MPERR"
  fi
  # State the CONFIG directly so nobody has to guess.
  if [ -r /proc/config.gz ]; then
    info "config: $(zgrep -E 'CONFIG_ACPI_EC_DEBUGFS' /proc/config.gz 2>/dev/null || echo 'ACPI_EC_DEBUGFS not found')"
  elif [ -r "/boot/config-$(uname -r)" ]; then
    info "config: $(grep -E 'CONFIG_ACPI_EC_DEBUGFS' /boot/config-$(uname -r) 2>/dev/null || echo 'ACPI_EC_DEBUGFS not found')"
  fi
  # What is actually under debugfs
  if [ -d /sys/kernel/debug/ec ]; then
    info "contents of /sys/kernel/debug/ec: $(ls /sys/kernel/debug/ec 2>/dev/null | tr '\n' ' ')"
  else
    no "/sys/kernel/debug/ec was never created"
    # ec_sys entries only appear if the ACPI EC driver actually bound.
    ECMSG=$(dmesg 2>/dev/null | grep -i 'ACPI: EC' | tail -4)
    if [ -n "$ECMSG" ]; then
      info "ACPI EC lines from dmesg:"
      printf '%s\n' "$ECMSG" | sed 's/^/         /'
    else
      info "no 'ACPI: EC' line in dmesg -> the EC driver never started."
      info "Normal on desktops (PNP0C09 sits in the namespace but there is no functional EC)."
      info "On a laptop, that is where the real problem is."
    fi
  fi
  EC=/sys/kernel/debug/ec/ec0/io
  if [ -r "$EC" ]; then
    ok "EC is readable: $EC"
    HPCM=$(dd if=$EC bs=1 skip=$((0x95)) count=1 2>/dev/null | od -An -tu1 | tr -d ' ')
    S1=$(dd if=$EC bs=1 skip=$((0x34)) count=1 2>/dev/null | od -An -tu1 | tr -d ' ')
    S2=$(dd if=$EC bs=1 skip=$((0x35)) count=1 2>/dev/null | od -An -tu1 | tr -d ' ')
    R=$(dd if=$EC bs=1 skip=$((0xB0)) count=4 2>/dev/null | od -An -tu1)
    set -- $R
    F1=$(( $2 * 256 + $1 )); F2=$(( $4 * 256 + $3 ))
    printf '       0x95 HPCM (profile) = %s   (48=Balanced, 49=Performance, 4=Unleashed)\n' "$HPCM"
    # 0xFF = "no manual setpoint", i.e. the EC itself is driving the fan.
    # Printing 255*100 = 25500 RPM would be misleading.
    for i in 1 2; do
      eval "V=\$S$i"
      case "$V" in
        255) printf '       0x3%s SRP%s (fan%s target) = 255 -> no manual setpoint (the EC is driving)\n' "$((i+3))" "$i" "$i" ;;
        *)   printf '       0x3%s SRP%s (fan%s target) = %s  -> %s RPM\n' "$((i+3))" "$i" "$i" "$V" "$((V*100))" ;;
      esac
    done
    printf '       0xB0 fan1 tachometer = %s RPM\n' "$F1"
    printf '       0xB2 fan2 tachometer = %s RPM\n' "$F2"
    # Tachometer cross-check: EC 0xB0/0xB2 and hwmon should agree. If they do,
    # the EC window and the Phase 1 map are confirmed - whatever HPCM says.
    HWFAN=$(cat /sys/class/hwmon/hwmon*/fan1_input 2>/dev/null | head -1)
    if [ -n "$HWFAN" ] && [ "$F1" -gt 0 ] && [ $((F1 > HWFAN ? F1 - HWFAN : HWFAN - F1)) -lt 150 ]; then
      ok "the EC tachometer agrees with hwmon ($F1 ~ $HWFAN) - the EC map is correct"
    fi
    case "$HPCM" in
      48|49|4) ok "HPCM is one of the values captured in Phase 1" ;;
      0)
        # Only GM1A (WMI 0x1A) writes HPCM. On Windows OGH does it; on Linux
        # the hp-wmi profile handler would - but as step 3 shows, amd-pmf is
        # driving the profile. So 0 means "never written", not a broken map.
        # Read it together with step 3.
        if [ "${HP_PP:-0}" = "1" ]; then
          no "HPCM is 0 - but hp-wmi IS driving the profile, so this is UNEXPECTED"
        else
          ok "HPCM is 0 - expected: hp-wmi is not driving the profile (step 3), so 0x95 was never written"
          info "after patching, change the profile and read this again: you should see 48/49"
        fi
        ;;
      *) no "unexpected HPCM value ($HPCM) - the Phase 1 map should be revisited" ;;
    esac
  else
    no "could not read $EC (is debugfs mounted? CONFIG_ACPI_EC_DEBUGFS?)"
    info "try: mount -t debugfs none /sys/kernel/debug"
  fi
fi

say "7. dGPU power management (out of scope, but the real cause of battery drain)"
for p in /sys/bus/pci/devices/*/power/control; do
  d=$(dirname $(dirname "$p"))
  cls=$(cat "$d/class" 2>/dev/null)
  case "$cls" in 0x030000|0x030200)
    printf '       %s  vendor=%s  power/control=%s  runtime_status=%s\n' \
      "$(basename $d)" "$(cat $d/vendor 2>/dev/null)" "$(cat $p)" "$(cat $d/power/runtime_status 2>/dev/null)"
  ;; esac
done
info "vendor 0x10de = NVIDIA. 'on' means runtime PM is disabled (5-10 W wasted)."

printf '\n\033[1mDone.\033[0m Save the full output with: sudo bash verify.sh 2>&1 | tee verify-out.txt\n\n'
