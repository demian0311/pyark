#!/usr/bin/env bash
# Put the Python layer into the live LazyVim config, let lazy.nvim fetch the plugins it needs
# (to the lockfile; existing plugins are not updated), install the treesitter parsers, then
# copy plugins, parsers, Mason packages and the lockfile into store/nvim.
source "$(dirname "$0")/../lib/common.sh"
need nvim rsync
install_nvim_layer

log "nvim: lazy restore (fetches plugins missing from $NVIM_DATA/lazy)"
nvim --headless "+Lazy! restore" +qa 2>&1 | grep -vE '^\s*$' | tail -3 || true

parsers=$(grep -oE 'ensure_installed = \{[^}]*\}' "$PYARK_ROOT/nvim/lua/plugins/pyark-python.lua" | grep -oE '"[a-z_]+"' | paste -sd,)
log "nvim: treesitter install {$parsers}"
nvim --headless -c "lua require('nvim-treesitter').install({$parsers}):wait(600000)" -c qa 2>&1 | grep -vE '^\s*$' | tail -3 || true

dir=$(store_dir nvim)
rsync -a --delete "$NVIM_DATA/lazy/" "$dir/lazy/"
mkdir -p "$dir/site"; for d in parser queries; do [ -d "$NVIM_DATA/site/$d" ] && rsync -a --delete "$NVIM_DATA/site/$d/" "$dir/site/$d/"; done
[ -d "$NVIM_DATA/mason" ] && rsync -a --delete "$NVIM_DATA/mason/" "$dir/mason/"
cp "$NVIM_CONFIG/lazy-lock.json" "$dir/lazy-lock.json"
stamp "$dir"
log "nvim: $(ls "$dir/lazy" | wc -l) plugins, $(ls "$dir/site/parser" 2>/dev/null | wc -l) parsers in store ($(du -sh "$dir" | cut -f1))"
