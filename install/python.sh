#!/usr/bin/env bash
# Point uv at the store and install the Python versions and CLI tools from it. No network.
#  - ~/.config/uv/uv.toml: no-index + find-links=store/wheels + python-install-mirror=store/python
#  - uv python install <manifest/python.txt>   (the one version, from the mirror)
#  - uv tool install <manifest/tools.txt>      (from the wheelhouse, into ~/.local/bin)
# uv itself is expected on PATH from the pacman package (install/arch.sh); until then the
# copy extracted into store/bin is linked to ~/.local/bin/uv.
source "$(dirname "$0")/../lib/common.sh"
ensure_uv

cfg="${XDG_CONFIG_HOME:-$HOME/.config}/uv/uv.toml"
mkdir -p "$(dirname "$cfg")"
[ -f "$cfg" ] && cp "$cfg" "$cfg.pre-pyark" && warn "python: existing $cfg saved as $cfg.pre-pyark"
command cat > "$cfg" <<TOML
# Written by pyark install python on $(date -u +%Y-%m-%d). Re-run that command after editing the store path.
# Resolution never touches PyPI: only the wheelhouse. A package not in the store fails fast.
no-index = true
find-links = ["$PYARK_STORE/wheels"]
# Managed Pythons come from the mirrored python-build-standalone tarballs.
python-install-mirror = "file://$PYARK_STORE/python"
TOML
log "python: wrote $cfg"

if ! command -v uv >/dev/null; then
  mkdir -p "$HOME/.local/bin" && ln -sf "$UV" "$HOME/.local/bin/uv" && log "python: linked ~/.local/bin/uv -> store/bin/uv (until the pacman package is installed)"
fi

ver=$(python_version)
log "python: installing $ver from the mirror"
"$UV" python install "$ver"

while read -r line; do
  log "python: uv tool install $line"
  # shellcheck disable=SC2086
  "$UV" tool install -q --python "$ver" $line
done < <(manifest tools)

log "python: $("$UV" python list --only-installed 2>/dev/null | grep -c cpython) pythons visible to uv, tools: $("$UV" tool list 2>/dev/null | grep -vE '^-' | awk '{print $1}' | paste -sd' ')"
