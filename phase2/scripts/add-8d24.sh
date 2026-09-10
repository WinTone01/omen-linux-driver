#!/usr/bin/env bash
# hp-wmi.c'ye board 8D24 (OMEN 16-ap0xxx) kaydini ekler.
#
# Cekirdek surumune gore dizi adi ve driver_data bicimi degisiyor:
#   7.2  : victus_s_thermal_profile_boards[] , &omen_v1_legacy_thermal_params
#   7.3+ : hp_wmi_feature_boards[]           , &omen_v1_legacy_board_params
# Script hangisinin oldugunu kendisi tespit eder.
#
# Kardes kart 8D26 ayni parametreleri kullaniyor; kaydi onun hemen ustune ekliyoruz.
#
# Kullanim: bash add-8d24.sh /yol/hp-wmi.c

set -euo pipefail

SRC="${1:?kullanim: add-8d24.sh <hp-wmi.c yolu>}"
[ -f "$SRC" ] || { echo "HATA: $SRC bulunamadi"; exit 1; }

if grep -q '"8D24"' "$SRC"; then
  echo "8D24 zaten kayitli, degisiklik yapilmadi."
  exit 0
fi

grep -q '"8D26"' "$SRC" || { echo "HATA: capa olarak kullanilan 8D26 kaydi bulunamadi."; exit 1; }

if grep -q 'omen_v1_legacy_board_params' "$SRC"; then
  PARAMS='omen_v1_legacy_board_params'          # 7.3+
elif grep -q 'omen_v1_legacy_thermal_params' "$SRC"; then
  PARAMS='omen_v1_legacy_thermal_params'        # 7.2
else
  echo "HATA: omen_v1_legacy_* parametre yapisi bulunamadi. Cekirdek surumu beklenenden farkli."
  exit 1
fi
echo "Tespit edilen parametre yapisi: $PARAMS"

cp -n "$SRC" "$SRC.orig" 2>/dev/null || true

# 8D26 kaydinin bulundugu blogun ilk satirini bul ('{' satiri, DMI_MATCH'ten bir onceki)
LN=$(grep -n 'DMI_BOARD_NAME, "8D26"' "$SRC" | head -1 | cut -d: -f1)
OPEN=$((LN - 1))
sed -n "${OPEN}p" "$SRC" | grep -q '{' || { echo "HATA: 8D26 kaydinin acilis parantezi beklenen yerde degil."; exit 1; }

# Girintiyi 8D26 kaydindan aynen devral
INDENT=$(sed -n "${OPEN}p" "$SRC" | sed 's/[^ \t].*//')

{
  printf '%s{\n'                                                   "$INDENT"
  printf '%s\t.matches = { DMI_MATCH(DMI_BOARD_NAME, "8D24") },\n' "$INDENT"
  printf '%s\t.driver_data = (void *)&%s,\n'                       "$INDENT" "$PARAMS"
  printf '%s},\n'                                                  "$INDENT"
} > /tmp/8d24-entry.$$

sed -i "$((OPEN - 1))r /tmp/8d24-entry.$$" "$SRC"
rm -f /tmp/8d24-entry.$$

echo "Eklendi. Yedek: $SRC.orig"
echo
grep -n -B2 -A4 '"8D24"' "$SRC"
