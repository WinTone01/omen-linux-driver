#!/usr/bin/env bash
#
# OMEN Control installer.
#
#   ./install.sh              install everything
#   ./install.sh --uninstall  take it all back out
#   ./install.sh --check      look at the machine and stop
#
# The three pieces are installed in the order they depend on each other: the
# hp-wmi board entry, which is what makes fan control exist at all; the module
# that owns the keyboard and the graphics mux; and the userspace on top.
#
# Nothing here writes to the EC, and nothing is installed before the machine
# has been identified - see check_hardware.

set -uo pipefail

readonly REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VERSION="0.1.0"

# ── output ───────────────────────────────────────────────────────────
#
# Colour only when someone is watching. A log file or a pipe gets the same
# text without the escape codes.

if [[ -t 1 ]]; then
    readonly C_RED=$'\e[31m'   C_GREEN=$'\e[32m'  C_AMBER=$'\e[33m'
    readonly C_BLUE=$'\e[34m'  C_DIM=$'\e[2m'     C_BOLD=$'\e[1m'
    readonly C_OFF=$'\e[0m'
else
    readonly C_RED='' C_GREEN='' C_AMBER='' C_BLUE='' C_DIM='' C_BOLD='' C_OFF=''
fi

step_n=0
step()  { step_n=$((step_n + 1)); printf '\n%s[%d/%d]%s %s%s%s\n' \
              "$C_BLUE" "$step_n" "$STEPS" "$C_OFF" "$C_BOLD" "$1" "$C_OFF"; }
ok()    { printf '  %s✓%s %s\n' "$C_GREEN" "$C_OFF" "$1"; }
warn()  { printf '  %s!%s %s\n' "$C_AMBER" "$C_OFF" "$1"; }
fail()  { printf '  %s✗%s %s\n' "$C_RED" "$C_OFF" "$1"; }
info()  { printf '    %s%s%s\n' "$C_DIM" "$1" "$C_OFF"; }
die()   { fail "$1"; [[ $# -gt 1 ]] && info "$2"; exit 1; }

banner() {
    printf '%s\n' "$C_RED"
    cat <<'ART'
   ___  __  __ ___ _  _    ___         _           _
  / _ \|  \/  | __| \| |  / __|___ _ _| |_ _ _ ___| |
 | (_) | |\/| | _|| .` | | (__/ _ \ ' \  _| '_/ _ \ |
  \___/|_|  |_|___|_|\_|  \___\___/_||_\__|_| \___/_|
ART
    printf '%s' "$C_OFF"
    printf '  %sfans · thermals · RGB · graphics mux — v%s%s\n' "$C_DIM" "$VERSION" "$C_OFF"
}

confirm() {
    [[ ${ASSUME_YES:-0} == 1 ]] && return 0
    local answer
    printf '\n  %s%s%s [y/N] ' "$C_BOLD" "$1" "$C_OFF"
    read -r answer </dev/tty || return 1
    [[ $answer == [yY]* ]]
}

# ── the machine ──────────────────────────────────────────────────────

dmi() { cat "/sys/class/dmi/id/$1" 2>/dev/null || printf 'unknown'; }

# Is this an OMEN or a Victus?
#
# Checked because the EC register map and the WMI command values in this
# project were read out of ONE board's firmware. On an HP gaming laptop the
# protocol is shared and the worst case is a missing feature; on something
# else entirely a fan command could land somewhere that matters. The board is
# reported either way, since that is the first thing anyone will be asked for.
check_hardware() {
    local vendor product board family
    vendor=$(dmi sys_vendor)
    product=$(dmi product_name)
    board=$(dmi board_name)
    family=$(dmi product_family)

    info "vendor   $vendor"
    info "model    $product"
    info "board    $board"

    if [[ $board == 8D24 ]]; then
        ok "OMEN 16-ap0xxx (8D24) — the board this was built and verified on"
        return 0
    fi

    local hp=0 gaming=0
    [[ $vendor =~ ^(HP|Hewlett-Packard)$ ]] && hp=1
    [[ "$product $family" =~ (OMEN|Omen|VICTUS|Victus) ]] && gaming=1

    if (( hp && gaming )); then
        warn "an HP gaming laptop, but not the board this was verified on"
        info "The fan and lighting protocol is shared across OMEN and Victus"
        info "models, so this usually works - but nothing here was measured on"
        info "$board. Watch the first fan change, and read 'omenctl doctor'."
        confirm "Install anyway?" || exit 1
        return 0
    fi

    fail "this does not look like an HP OMEN or Victus"
    info "vendor=$vendor product=$product board=$board"
    info ""
    info "The EC registers and WMI commands here were read out of one HP"
    info "gaming laptop's firmware. On other hardware the same command"
    info "numbers mean different things, and a wrong fan write is not"
    info "something a diagnostic can undo."
    if [[ ${FORCE:-0} == 1 ]]; then
        warn "--force given; continuing against advice"
        return 0
    fi
    info ""
    info "If you are certain, run: ./install.sh --force"
    exit 1
}

# ── dependencies ─────────────────────────────────────────────────────

have() { command -v "$1" >/dev/null 2>&1; }

pkg_manager() {
    have pacman  && { printf 'pacman';  return; }
    have apt-get && { printf 'apt';     return; }
    have dnf     && { printf 'dnf';     return; }
    have zypper  && { printf 'zypper';  return; }
    printf 'unknown'
}

# Kernel headers for the running kernel, whatever they are called here.
has_headers() {
    [[ -d "/lib/modules/$(uname -r)/build" ]]
}

check_deps() {
    local pm missing=()
    pm=$(pkg_manager)
    info "distribution uses $pm"

    have cargo || missing+=("rust")
    have dkms  || missing+=("dkms")
    have make  || missing+=("base-devel / build-essential")
    has_headers || missing+=("kernel headers for $(uname -r)")

    # The window needs a webview. The daemon and the CLI do not, so a missing
    # webview narrows the install rather than stopping it.
    if ! pkg-config --exists webkit2gtk-4.1 2>/dev/null; then
        warn "webkit2gtk-4.1 not found - the window will not build"
        info "The daemon and omenctl do not need it; installing without the GUI."
        BUILD_GUI=0
    fi

    if (( ${#missing[@]} )); then
        fail "missing: ${missing[*]}"
        case $pm in
            pacman) info "sudo pacman -S --needed base-devel dkms rust linux-headers webkit2gtk-4.1" ;;
            apt)    info "sudo apt install build-essential dkms rustc cargo linux-headers-\$(uname -r) libwebkit2gtk-4.1-dev" ;;
            dnf)    info "sudo dnf install @development-tools dkms rust cargo kernel-devel webkit2gtk4.1-devel" ;;
            *)      info "install them with your package manager, then run this again" ;;
        esac
        exit 1
    fi
    ok "everything needed to build is here"
}

# ── the pieces ───────────────────────────────────────────────────────

install_hp_wmi() {
    if dkms status 2>/dev/null | grep -q '^hp-wmi-8d24'; then
        ok "already installed via DKMS"
        return 0
    fi

    info "fetching the upstream hp-wmi source and adding the board entry"
    if bash "$REPO/kernel/hp-wmi-8d24/build-module.sh" --install; then
        ok "hp-wmi patched and installed"
    else
        die "could not build the patched hp-wmi" \
            "Run kernel/hp-wmi-8d24/build-module.sh on its own to see why."
    fi
}

install_module() {
    if have makepkg && [[ $(pkg_manager) == pacman ]]; then
        ( cd "$REPO/kernel/omen-kbd-rgb" && makepkg -sfi --noconfirm ) \
            && ok "omen-kbd-rgb installed (DKMS)" \
            || die "the RGB module package failed to build"
    else
        ( cd "$REPO/kernel/omen-kbd-rgb" && sudo make dkms-install ) \
            && ok "omen-kbd-rgb installed (DKMS)" \
            || die "the RGB module failed to build"
    fi
}

install_userspace() {
    if have makepkg && [[ $(pkg_manager) == pacman ]]; then
        ( cd "$REPO/packaging" && makepkg -sfi --noconfirm ) \
            && ok "omen-control installed" \
            || die "the omen-control package failed to build"
    else
        info "building (this takes a few minutes the first time)"
        local args=(--release)
        (( BUILD_GUI )) || args+=(--workspace --exclude omen-ui)
        ( cd "$REPO" && cargo build "${args[@]}" ) || die "the build failed"
        ( cd "$REPO" && sudo bash packaging/install.sh ) \
            && ok "installed" || die "installing the files failed"
    fi
}

enable_service() {
    sudo systemctl daemon-reload
    sudo systemd-sysusers >/dev/null 2>&1 || true
    sudo udevadm control --reload >/dev/null 2>&1 || true

    if sudo systemctl enable --now omend >/dev/null 2>&1; then
        ok "omend is running and enabled at boot"
    else
        warn "omend did not start"
        info "systemctl status omend    # and: journalctl -u omend -b"
    fi

    if id -nG "$USER" | tr ' ' '\n' | grep -qx omen; then
        ok "you are in the 'omen' group"
    else
        sudo usermod -aG omen "$USER" && \
            warn "added you to the 'omen' group - log out and back in for it to apply"
    fi
}

uninstall() {
    STEPS=3
    banner
    step "Stopping the service"
    sudo systemctl disable --now omend >/dev/null 2>&1 && ok "omend stopped" || info "was not running"

    step "Removing packages"
    if have pacman; then
        sudo pacman -Rns --noconfirm omen-control omen-kbd-rgb-dkms 2>/dev/null \
            && ok "packages removed" || info "nothing to remove with pacman"
    else
        sudo rm -f /usr/bin/{omend,omenctl,omen-ui} \
                   /usr/lib/systemd/system/omend.service \
                   /usr/lib/systemd/system-sleep/omen \
                   /usr/share/applications/dev.wintone.omen-control.desktop
        ok "files removed"
    fi
    sudo dkms remove -m omen-kbd-rgb -v "$VERSION" --all >/dev/null 2>&1 || true
    sudo dkms remove -m hp-wmi-8d24 --all >/dev/null 2>&1 || true

    step "What is left"
    info "/etc/omen/omend.toml and the 'omen' group are kept on purpose."
    info "Remove them by hand if you are done: sudo rm -rf /etc/omen"
    printf '\n'
    exit 0
}

# ── main ─────────────────────────────────────────────────────────────

BUILD_GUI=1
ASSUME_YES=0
FORCE=0
CHECK_ONLY=0

while [[ $# -gt 0 ]]; do
    case $1 in
        --uninstall)  UNINSTALL=1 ;;
        --check)      CHECK_ONLY=1 ;;
        --force)      FORCE=1 ;;
        --yes|-y)     ASSUME_YES=1 ;;
        --no-gui)     BUILD_GUI=0 ;;
        -h|--help)
            sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'
            exit 0 ;;
        *) die "unknown option: $1" "See ./install.sh --help" ;;
    esac
    shift
done

[[ ${UNINSTALL:-0} == 1 ]] && uninstall

if (( CHECK_ONLY )); then
    STEPS=2
    banner
    step "This machine"
    check_hardware
    step "Build dependencies"
    check_deps
    printf '\n  %sNothing was installed. Run ./install.sh to go ahead.%s\n\n' "$C_DIM" "$C_OFF"
    exit 0
fi

STEPS=6
banner

step "This machine"
check_hardware

step "Build dependencies"
check_deps

step "Fan control — the hp-wmi board entry"
install_hp_wmi

step "Keyboard and graphics mux — omen-kbd-rgb"
install_module

step "The daemon, the CLI$( ((BUILD_GUI)) && printf ' and the window')"
install_userspace

step "Service and permissions"
enable_service

printf '\n%s  Done.%s\n\n' "$C_GREEN$C_BOLD" "$C_OFF"
printf '  %somenctl status%s     what the machine is doing now\n' "$C_BOLD" "$C_OFF"
printf '  %somenctl doctor%s     check the whole installation\n' "$C_BOLD" "$C_OFF"
printf '  %somenctl caps%s       what this machine can be asked to do\n' "$C_BOLD" "$C_OFF"
(( BUILD_GUI )) && printf '  %somen-ui%s            the window\n' "$C_BOLD" "$C_OFF"
printf '\n  %sThe RGB module and hp-wmi keep the build that is loaded until you\n' "$C_DIM"
printf '  reboot or reload them; omenctl version says when that matters.%s\n\n' "$C_OFF"
