#!/usr/bin/env bash
# Report the three parts of pyark: the store (what was harvested, when), the installed
# state (what the machine has), and drift between them and the manifests.
source "$(dirname "$0")/../lib/common.sh"

ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$*"; }
meh()  { printf '  \033[33m·\033[0m %s\n' "$*"; }
age()  { [ -f "$1/HARVESTED" ] && printf 'harvested %s' "$(cut -c1-10 "$1/HARVESTED")" || printf 'no HARVESTED stamp'; }

echo "pyark doctor — root $PYARK_ROOT, store $PYARK_STORE"
echo
echo "store"
for part in arch python wheels nvim docs; do
  d="$PYARK_STORE/$part"
  if [ -d "$d" ] && [ -n "$(ls -A "$d" 2>/dev/null)" ]; then
    case $part in
      arch)   n=$(ls "$d"/*.pkg.tar.zst 2>/dev/null | wc -l); what="$n packages";;
      python) n=$(find "$d" -name '*.tar.gz' | wc -l); what="$n builds";;
      wheels) n=$(ls "$d" | grep -cE '\.(whl|tar\.gz|zip)$'); what="$n wheels";;
      *)      what="$(find "$d" -type f | wc -l) files";;
    esac
    ok "$part: $what, $(du -sh "$d" | cut -f1), $(age "$d")"
  else
    bad "$part: empty — run: pyark harvest $part"
  fi
done

echo
echo "arch packages (manifest/arch.txt)"
for p in $(manifest arch); do
  v=$(pacman -Q "$p" 2>/dev/null | awk '{print $2}') && ok "$p $v" || bad "$p not installed — run: pyark install arch"
done

echo
echo "uv"
if command -v uv >/dev/null; then
  u=$(command -v uv)
  if [ -L "$u" ]; then meh "uv is $(uv --version | awk '{print $2}') via symlink $u — after 'pyark install arch' remove it: rm $u"
  else ok "uv $(uv --version | awk '{print $2}') at $u"; fi
else bad "uv not on PATH — run: pyark install python"; fi
cfg="${XDG_CONFIG_HOME:-$HOME/.config}/uv/uv.toml"
if [ -f "$cfg" ] && grep -q "find-links = \[\"$PYARK_STORE/wheels\"\]" "$cfg" && grep -q "python-install-mirror = \"file://$PYARK_STORE/python\"" "$cfg"; then
  ok "uv.toml points at this store"
elif [ -f "$cfg" ]; then bad "uv.toml exists but points elsewhere — run: pyark install python"
else bad "no uv.toml — run: pyark install python"; fi

if command -v uv >/dev/null; then
  echo
  echo "python (manifest/python.txt)"
  have=$(uv python list --only-installed --managed-python 2>/dev/null | awk '{print $1}')
  for v in $(python_version); do
    grep -q "^cpython-$v\." <<<"$have" && ok "$v $(grep -m1 "^cpython-$v\." <<<"$have" | cut -d- -f2)" || bad "$v not installed — run: pyark install python"
  done
  echo
  echo "tools (manifest/tools.txt)"
  have=$(uv tool list 2>/dev/null | grep -vE '^(-|$)' | awk '{print $1}')
  for t in $(manifest tools | awk '{print $1}'); do
    grep -qx "$t" <<<"$have" && ok "$t" || bad "$t — run: pyark install python"
  done
fi

