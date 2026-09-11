#!/usr/bin/env bash
# Installs the userspace side: omend, omenctl, the desktop app and their
# configuration. Run from phase3/.
#
# The kernel side is separate and deliberately so:
#   hp-wmi with the 8D24 entry -> ../phase2/scripts/build-module.sh --install
#   omen-kbd-rgb (RGB keyboard) -> kernel/omen-kbd-rgb, see its PKGBUILD
#
# On Arch and CachyOS, prefer the PKGBUILD next to this script - it does the
# same thing but the package manager can then remove it again.

set -euo pipefail
cd "$(dirname "$0")/.."
HERE=$(pwd)

say() { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
die() { printf '\033[31mERROR:\033[0m %s\n' "$1" >&2; exit 1; }

[ "$(id -u)" = 0 ] || die "run with sudo"
command -v cargo >/dev/null || die "cargo is missing. Install rust."

say "1. Building"
cargo build --release

say "2. Binaries"
install -Dm755 target/release/omend   /usr/bin/omend
install -Dm755 target/release/omenctl /usr/bin/omenctl
install -Dm755 target/release/omen-ui /usr/bin/omen-ui
echo "  omend, omenctl, omen-ui -> /usr/bin"

say "3. Configuration"
# -b keeps a backup: the fan curve is the one file a user is likely to have
# edited, and silently overwriting it would be rude.
install -Dm644 -b packaging/omend.toml        /etc/omen/omend.toml
install -Dm644 packaging/omend.service        /etc/systemd/system/omend.service
install -Dm644 packaging/omen-sysusers.conf   /usr/lib/sysusers.d/omen.conf
install -Dm644 packaging/omen-modules.conf    /usr/lib/modules-load.d/omen.conf
install -Dm644 packaging/omen-modprobe.conf   /usr/lib/modprobe.d/omen.conf
install -Dm644 packaging/99-omen-leds.rules   /etc/udev/rules.d/99-omen-leds.rules
install -Dm644 packaging/omen-control.desktop /usr/share/applications/omen-control.desktop
install -Dm644 ui/src-tauri/icons/icon.png    /usr/share/icons/hicolor/512x512/apps/omen-control.png
install -Dm644 ui/src-tauri/icons/128x128.png /usr/share/icons/hicolor/128x128/apps/omen-control.png
install -Dm644 ui/src-tauri/icons/32x32.png   /usr/share/icons/hicolor/32x32/apps/omen-control.png

say "4. Activating"
systemd-sysusers
systemctl daemon-reload
udevadm control --reload
udevadm trigger -s leds
modprobe ec_sys write_support=0 2>/dev/null || echo "  (ec_sys unavailable - the dGPU temperature will not be read)"
gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
systemctl enable --now omend

say "5. One thing left for you"
TARGET_USER=${SUDO_USER:-}
cat <<TXT
  Join the 'omen' group so the UI can reach the daemon and the LEDs without
  sudo, then log out and back in - an open session keeps the group list it
  started with:

    sudo usermod -aG omen ${TARGET_USER:-\$USER}

  Then check everything with:

    omenctl status

  The 8D24 hp-wmi patch is not installed by this script. Without it there is
  no pwm1 and omend will not start:

    bash $HERE/../phase2/scripts/build-module.sh --install
TXT
