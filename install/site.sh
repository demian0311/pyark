#!/usr/bin/env bash
# Build the docs site into store/site: copy site/ to a build dir, generate reference.md from
# manifest/docs.txt and what store/docs actually holds, run mkdocs, link store/docs as /ref.
source "$(dirname "$0")/../lib/common.sh"
need mkdocs
src="$PYARK_STORE/site-src"; out="$PYARK_STORE/site"; docs="$PYARK_STORE/docs"
rm -rf "$src"; cp -r "$PYARK_ROOT/site" "$src"

gen="$src/docs/reference.md"
ver=$(python_version)
hues=(blue teal orange purple green red yellow cyan gray)
{
  echo "# Reference docs"
  echo
  echo "Everything below is served from this machine. Each entry's own search box works offline. Rows in red are in the manifest but not in the store yet: \`pyark harvest docs\` while online."
  echo
  n=0
  while IFS= read -r line; do
    if [[ "$line" =~ ^#\ (.+) ]]; then
      [ $n -gt 0 ] && echo "</ul></div>"
      printf '<div class="ref-group" style="--hue: var(--slate-%s)" markdown>\n<h2>%s</h2>\n<ul class="ref-list">\n' "${hues[n % ${#hues[@]}]}" "${BASH_REMATCH[1]}"
      n=$((n+1)); continue
    fi
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    IFS=$'\t' read -r id kind srcurl title desc _opts <<<"$line"
    title=${title//\{ver\}/$ver}
    if [ -f "$docs/$id/ENTRY" ]; then
      printf '<li><span class="name"><a href="/ref/%s/%s">%s</a></span><span class="desc">%s</span><span class="meta">%s · %s</span></li>\n' \
        "$id" "$(cat "$docs/$id/ENTRY")" "$title" "$desc" "$(du -sh "$docs/$id" | cut -f1)" "$(cut -c1-10 "$docs/$id/HARVESTED" 2>/dev/null || echo ?)"
    else
      printf '<li class="missing"><span class="name">%s</span><span class="desc">%s</span><span class="meta">not in store</span></li>\n' "$title" "$desc"
    fi
  done < <(sed -n '/^# Core reference/,$p' "$PYARK_ROOT/manifest/docs.txt")
  [ $n -gt 0 ] && echo "</ul></div>"
} > "$gen"

mkdocs build -q -f "$src/mkdocs.yml" -d "$out"
ln -sfn "$docs" "$out/ref"
log "site: built $out ($(find "$out" -name '*.html' -not -path '*/ref/*' | wc -l) pages), /ref -> store/docs"
