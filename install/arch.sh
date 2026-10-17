#!/usr/bin/env bash
# Install the Arch packages in store/arch with pacman. Needs root, so this is the one
# pyark step that asks for your password. Uses `pacman -U` on the local files (signatures
# are checked against the Arch keys already on the machine); no pacman.conf change and
# no sync, so it works with the network down.
source "$(dirname "$0")/../lib/common.sh"
dir="$PYARK_STORE/arch"
ls "$dir"/*.pkg.tar.zst >/dev/null 2>&1 || die "arch: store/arch is empty — run: pyark harvest arch"

if [ "$EUID" -ne 0 ]; then
  log "arch: pacman needs root — running sudo (enter your password)"
  exec sudo pacman -U --needed "$dir"/*.pkg.tar.zst
fi
pacman -U --needed "$dir"/*.pkg.tar.zst
