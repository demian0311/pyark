#!/usr/bin/env bash
# Fetch the Arch packages in manifest/arch.txt into store/arch and build a pacman
# repo there (pyark.db), so `pacman -S` works offline once install/arch.sh adds the
# repo to pacman.conf. Needs no root: pacman -Sp only prints URLs.
source "$(dirname "$0")/../lib/common.sh"
need pacman curl repo-add

dir=$(store_dir arch)
mapfile -t pkgs < <(manifest arch)
log "arch: resolving ${#pkgs[@]} packages"
mapfile -t urls < <(pacman -Sp --noconfirm "${pkgs[@]}")
[ "${#urls[@]}" -gt 0 ] || die "arch: pacman -Sp returned no URLs (sync db stale? run: sudo pacman -Sy)"

for u in "${urls[@]}"; do
  f="$dir/$(basename "$u")"
  if [ -s "$f" ]; then log "arch: have $(basename "$u")"; continue; fi
  log "arch: fetching $(basename "$u")"
  curl -fsSL --retry 3 -o "$f" "$u"
  curl -fsSL --retry 3 -o "$f.sig" "$u.sig" || warn "arch: no signature for $(basename "$u")"
done

repo-add -q "$dir/pyark.db.tar.gz" "$dir"/*.pkg.tar.zst
stamp "$dir"
log "arch: $(ls "$dir"/*.pkg.tar.zst | wc -l) packages in store ($(du -sh "$dir" | cut -f1))"
