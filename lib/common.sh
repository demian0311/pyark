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
