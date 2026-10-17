#!/usr/bin/env bash
# Apply the Python layer and restore plugins, parsers and Mason packages from store/nvim.
# Nothing is downloaded. The user's own plugins and settings are left alone: rsync adds and
# updates, never deletes, and the lockfile is merged (store entries win for plugins it holds).
source "$(dirname "$0")/../lib/common.sh"
need nvim rsync python3
dir="$PYARK_STORE/nvim"
[ -d "$dir/lazy" ] || die "nvim: store/nvim is empty — run: pyark harvest nvim"
install_nvim_layer

mkdir -p "$NVIM_DATA"
rsync -a "$dir/lazy/" "$NVIM_DATA/lazy/"
[ -d "$dir/site" ]  && rsync -a "$dir/site/"  "$NVIM_DATA/site/"
[ -d "$dir/mason" ] && rsync -a "$dir/mason/" "$NVIM_DATA/mason/"

lock="$NVIM_CONFIG/lazy-lock.json"
if [ -f "$lock" ]; then
  cp "$lock" "$lock.pre-pyark"
  python3 - "$lock" "$dir/lazy-lock.json" <<'PY'
import json, sys
mine, store = (json.load(open(p)) for p in sys.argv[1:3])
mine.update(store)
json.dump(mine, open(sys.argv[1], "w"), indent=2, sort_keys=True); open(sys.argv[1], "a").write("\n")
PY
  log "nvim: lockfile merged (previous copy at $lock.pre-pyark)"
else
  cp "$dir/lazy-lock.json" "$lock"; log "nvim: lockfile copied"
fi

log "nvim: lazy restore from local clones"
nvim --headless "+Lazy! restore" +qa 2>&1 | grep -vE '^\s*$' | tail -3 || true
log "nvim: done — open a .py file; :LspInfo should list ty and ruff"
