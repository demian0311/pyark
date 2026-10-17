#!/usr/bin/env bash
# Build the docs site into store/site: copy site/ to a build dir, generate reference.md from
# manifest/docs.txt and what store/docs actually holds, run mkdocs, link store/docs as /ref.
source "$(dirname "$0")/../lib/common.sh"
need mkdocs
src="$PYARK_STORE/site-src"; out="$PYARK_STORE/site"; docs="$PYARK_STORE/docs"
rm -rf "$src"; cp -r "$PYARK_ROOT/site" "$src"

gen="$src/docs/reference.md"
{
  echo "# Reference docs"
  echo
  echo "Everything below is served from this machine. Each entry's own search box works offline."
  echo
  echo "Harvest state as of $(date +%Y-%m-%d): entries marked ✗ are in the manifest but not in the store yet; run \`pyark harvest docs\` while online."
  section=""
  while IFS= read -r line; do
    if [[ "$line" =~ ^#\ (.+) ]]; then section="${BASH_REMATCH[1]}"; printf '\n## %s\n\n| | |\n|---|---|\n' "$section"; continue; fi
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    IFS=$'\t' read -r id kind srcurl title <<<"$line"
    if [[ "$srcurl" == *"{ver}"* ]]; then ids=(); for v in $(manifest python); do ids+=("$id-$v|${title//\{ver\}/$v}"); done
    else ids=("$id|$title"); fi
    for it in "${ids[@]}"; do
      i=${it%%|*}; t=${it#*|}
      if [ -f "$docs/$i/ENTRY" ]; then
        printf '| [%s](/ref/%s/%s) | %s, harvested %s |\n' "$t" "$i" "$(cat "$docs/$i/ENTRY")" "$(du -sh "$docs/$i" | cut -f1)" "$(cut -c1-10 "$docs/$i/HARVESTED" 2>/dev/null || echo ?)"
      else
        printf '| ✗ %s | not in store (%s) |\n' "$t" "$kind"
      fi
    done
  done < <(sed -n '/^# Core reference/,$p' "$PYARK_ROOT/manifest/docs.txt")
} > "$gen"

mkdocs build -q -f "$src/mkdocs.yml" -d "$out"
ln -sfn "$docs" "$out/ref"
log "site: built $out ($(find "$out" -name '*.html' -not -path '*/ref/*' | wc -l) pages), /ref -> store/docs"
