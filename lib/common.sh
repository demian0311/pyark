# Sourced by bin/pyark and every harvest/* install/* script. Bash only.
set -euo pipefail

PYARK_ROOT="${PYARK_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
PYARK_STORE="${PYARK_STORE:-$PYARK_ROOT/store}"   # gitignored; may be a symlink to a USB mount
PYARK_SITE_PORT="${PYARK_SITE_PORT:-8800}"
PYARK_PYDOC_PORT="${PYARK_PYDOC_PORT:-8801}"

log()  { printf '\033[1;34m[pyark]\033[0m %s\n' "$*" >&2; }
warn() { printf '\033[1;33m[pyark]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[pyark]\033[0m %s\n' "$*" >&2; exit 1; }

need() { for c in "$@"; do command -v "$c" >/dev/null || die "missing command: $c"; done; }

# manifest <name>  → the non-comment, non-blank lines of manifest/<name>.txt
manifest() { grep -vE '^\s*(#|$)' "$PYARK_ROOT/manifest/$1.txt"; }

# stamp <dir>  → writes <dir>/HARVESTED with the date, so `pyark doctor` can report age
stamp() { date -u +%Y-%m-%dT%H:%MZ > "$1/HARVESTED"; }

store_dir() { local d="$PYARK_STORE/$1"; mkdir -p "$d"; printf '%s' "$d"; }

# ensure_uv → sets $UV to the uv binary that matches store/arch (extracted into store/bin),
# falling back to uv on PATH. Harvest and install must use the same uv version, because
# uv's own table decides which Python build URL it asks the mirror for.
ensure_uv() {
  UV="$PYARK_STORE/bin/uv"
  if [ ! -x "$UV" ]; then
    local pkg; pkg=$(ls "$PYARK_STORE"/arch/uv-*.pkg.tar.zst 2>/dev/null | sort -V | tail -1 || true)
    if [ -n "$pkg" ]; then
      mkdir -p "$PYARK_STORE/bin"
      tar -xf "$pkg" -O usr/bin/uv > "$UV" && chmod +x "$UV"
      log "uv: extracted $("$UV" --version) from store/arch"
    elif command -v uv >/dev/null; then
      UV=$(command -v uv); warn "uv: store has no uv package, using $UV ($($UV --version))"
    else
      die "uv: not in store/arch and not on PATH — run: pyark harvest arch"
    fi
  fi
}

# install_nvim_layer → copies nvim/lua/plugins/pyark-*.lua into the live LazyVim config.
# Used by both harvest/nvim.sh (lazy must know the extra's plugins to fetch them) and install/nvim.sh.
NVIM_CONFIG="${NVIM_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/nvim}"
NVIM_DATA="${NVIM_DATA:-${XDG_DATA_HOME:-$HOME/.local/share}/nvim}"
install_nvim_layer() {
  [ -f "$NVIM_CONFIG/lua/config/lazy.lua" ] || die "nvim: $NVIM_CONFIG is not a LazyVim config (Omarchy ships one)"
  mkdir -p "$NVIM_CONFIG/lua/plugins"
  cp "$PYARK_ROOT"/nvim/lua/plugins/pyark-*.lua "$NVIM_CONFIG/lua/plugins/"
  log "nvim: layer in $NVIM_CONFIG/lua/plugins: $(ls "$PYARK_ROOT"/nvim/lua/plugins | paste -sd' ')"
}
