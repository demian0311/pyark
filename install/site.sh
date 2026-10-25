#!/usr/bin/env bash
# Build the docs site into store/site: copy site/ to a build dir, generate reference.md from
# manifest/docs.txt and what store/docs actually holds, run mkdocs, link store/docs as /ref.
source "$(dirname "$0")/../lib/common.sh"
need mkdocs
ensure_uv
src="$PYARK_STORE/site-src"; out="$PYARK_STORE/site"; docs="$PYARK_STORE/docs"
rm -rf "$src"; cp -r "$PYARK_ROOT/site" "$src"

gen="$src/docs/reference.md"
ver=$(python_version)
# Group heading in manifest/docs.txt → Material icon. A group missing here gets the default.
declare -A group_icon=(
  ["Core reference"]=star-four-points ["Guides and books"]=book-open-variant ["Tools"]=tools
  ["CLI and terminal"]=console ["Data"]=chart-box ["Web and HTTP"]=web ["Databases"]=database
  ["Config, serialization, time"]=cog-outline ["Testing extras"]=test-tube ["System and files"]=folder-cog
)
hues=(blue teal orange purple green red cyan yellow gray)   # one per group, in manifest order
slug() { tr 'A-Z' 'a-z' <<<"$1" | sed -E 's/[^a-z0-9]+/-/g; s/^-|-$//g'; }
body=$(mktemp); jump=$(mktemp); trap 'rm -f "$body" "$jump"' EXIT
n=0; total=0; have=0; count=0
close_group() { if [ $n -gt 0 ]; then echo "</div></div>" >>"$body"; sed -i "0,/@COUNT@/s//$count/" "$jump"; fi; }
while IFS= read -r line; do
  if [[ "$line" =~ ^#\ (.+) ]]; then
    close_group
    g=${BASH_REMATCH[1]} id=$(slug "$g") icon=${group_icon[$g]:-file-document-outline} hue=${hues[n % ${#hues[@]}]}
    printf '<div class="ref-group" style="--hue: var(--slate-%s)" markdown>\n\n## :material-%s: %s {#%s}\n\n<div class="ref-cards">\n' "$hue" "$icon" "$g" "$id" >>"$body"
    printf '<a class="ref-tile" href="#%s" data-group="%s" style="--hue: var(--slate-%s)">:material-%s:<span class="label">%s</span><span class="n">@COUNT@ entries</span></a>\n' "$id" "$id" "$hue" "$icon" "$g" >>"$jump"
    n=$((n+1)); count=0; continue
  fi
  [[ -z "$line" || "$line" =~ ^# ]] && continue
  IFS=$'\t' read -r id kind srcurl title desc _opts <<<"$line"
  title=${title//\{ver\}/$ver}; count=$((count+1)); total=$((total+1))
  if [ -f "$docs/$id/ENTRY" ]; then
    have=$((have+1))
    size=$(du -sh "$docs/$id" | cut -f1 | sed -E 's/([0-9])([KMG])$/\1 \2B/')
    when=$(date -d "$(cut -c1-10 "$docs/$id/HARVESTED" 2>/dev/null)" '+%-d %b %Y' 2>/dev/null || echo "date unknown")
    printf '<a class="ref-card" href="/ref/%s/%s"><span class="name">%s</span><span class="desc">%s</span><span class="meta"><span>%s</span><span>%s</span></span></a>\n' \
      "$id" "$(cat "$docs/$id/ENTRY")" "$title" "$desc" "$size" "$when" >>"$body"
  else
    printf '<div class="ref-card missing"><span class="name">%s</span><span class="desc">%s</span><span class="meta"><span>Not in the store yet</span></span></div>\n' "$title" "$desc" >>"$body"
  fi
done < <(sed -n '/^# Core reference/,$p' "$PYARK_ROOT/manifest/docs.txt")
close_group
{
  printf -- '---\nicon: material/bookshelf\n---\n\n# Reference docs\n\n'
  echo "Every manual and book below is served from this machine ($have entries, $(du -sh "$docs" | cut -f1 | sed -E 's/([0-9])([KMG])$/\1 \2B/')), and each one's own search works offline. To search inside all of them at once, use [Search all docs](../find/)."
  [ "$have" -lt "$total" ] && echo && echo "$((total - have)) entries in red are in the manifest but not in the store yet. Run \`pyark harvest docs\` while online."
  echo
  echo '<nav class="ref-tiles" markdown>'
  command cat "$jump"
  echo '</nav>'
  echo
  echo '<div class="ref-tools" markdown>'
  echo ':material-filter-variant:{ .ref-filter-icon } <input id="ref-filter" type="search" placeholder="Filter by name or description" autocomplete="off"> <span id="ref-count"></span>'
  echo '</div>'
  echo
  command cat "$body"
} > "$gen"

mkdocs build -q -f "$src/mkdocs.yml" -d "$out"
# Cache-bust our own assets: a browser that cached an older slate.css keeps using it on a plain
# reload even with no-cache on later responses (seen 2026-10-24). A content hash in the URL
# makes every rebuild a new address.
for a in slate.css ref-filter.js; do
  v=$(md5sum "$out/assets/$a" | cut -c1-8)
  find "$out" -path "$out/ref" -prune -o -name '*.html' -print0 | xargs -0 sed -i "s|assets/$a\"|assets/$a?v=$v\"|g"
done
ln -sfn "$docs" "$out/ref"
log "site: built $out ($(find "$out" -name '*.html' -not -path '*/ref/*' | wc -l) pages), /ref -> store/docs"

# One search over every mirrored doc: pagefind (from the wheelhouse, no tool install because the
# package has no console script) indexes store/docs into store/site/pagefind. Takes a few minutes;
# skipped when the index is newer than the last docs harvest, forced with PYARK_REINDEX=1.
if [ -f "$docs/HARVESTED" ]; then
  idx="$PYARK_STORE/search"   # outside $out, which mkdocs build recreates every time
  if [ -z "${PYARK_REINDEX:-}" ] && [ -f "$idx/pagefind-entry.json" ] && [ "$idx/pagefind-entry.json" -nt "$docs/HARVESTED" ]; then
    log "site: search index is newer than the docs harvest, kept (PYARK_REINDEX=1 to rebuild)"
  else
    log "site: indexing store/docs for search (a few minutes)"
    rm -rf "$idx"
    UV_OFFLINE=1 "$UV" run -q --no-project --with 'pagefind[bin]' python -m pagefind --site "$docs" --output-path "$idx" --force-language en \
      --exclude-selectors "nav,header,footer,aside,.sidebar,.toctree-wrapper,.md-sidebar,.sphinxsidebar,.bd-sidebar,.md-header,.md-footer" 2>&1 \
      | grep -E 'Indexed [0-9]+ pages|Finished' | sed 's/^/  /' >&2
  fi
  ln -sfn "$idx" "$out/pagefind"
fi
