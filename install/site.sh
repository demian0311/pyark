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
slug() { tr 'A-Z' 'a-z' <<<"$1" | sed -E 's/[^a-z0-9]+/-/g; s/^-|-$//g'; }
body=$(mktemp); jump=$(mktemp); trap 'rm -f "$body" "$jump"' EXIT
n=0; total=0; have=0; count=0
close_group() { if [ $n -gt 0 ]; then echo "</ul></div>" >>"$body"; sed -i "0,/@COUNT@/s//$count/" "$jump"; fi; }
while IFS= read -r line; do
  if [[ "$line" =~ ^#\ (.+) ]]; then
    close_group
    g=${BASH_REMATCH[1]} id=$(slug "$g") icon=${group_icon[$g]:-file-document-outline}
    printf '<div class="ref-group" markdown>\n\n## :material-%s: %s {#%s}\n\n<ul class="ref-list">\n' "$icon" "$g" "$id" >>"$body"
    printf '<a href="#%s" data-group="%s">:material-%s: <span>%s</span><span class="n">@COUNT@</span></a>\n' "$id" "$id" "$icon" "$g" >>"$jump"
    n=$((n+1)); count=0; continue
  fi
  [[ -z "$line" || "$line" =~ ^# ]] && continue
  IFS=$'\t' read -r id kind srcurl title desc _opts <<<"$line"
  title=${title//\{ver\}/$ver}; count=$((count+1)); total=$((total+1))
  if [ -f "$docs/$id/ENTRY" ]; then
    have=$((have+1))
    printf '<li><span class="name"><a href="/ref/%s/%s">%s</a></span><span class="desc">%s</span><span class="size">%s</span><span class="date">%s</span></li>\n' \
      "$id" "$(cat "$docs/$id/ENTRY")" "$title" "$desc" "$(du -sh "$docs/$id" | cut -f1)" "$(cut -c1-10 "$docs/$id/HARVESTED" 2>/dev/null || echo ?)" >>"$body"
  else
    printf '<li class="missing"><span class="name">%s</span><span class="desc">%s</span><span class="size"></span><span class="date">not in store</span></li>\n' "$title" "$desc" >>"$body"
  fi
done < <(sed -n '/^# Core reference/,$p' "$PYARK_ROOT/manifest/docs.txt")
close_group
{
  printf -- '---\nicon: material/bookshelf\n---\n\n# Reference docs\n\n'
  echo "Every manual and book below is served from this machine ($have entries, $(du -sh "$docs" | cut -f1)), and each one's own search works offline. To search inside all of them at once, use [Search all docs](../find/)."
  [ "$have" -lt "$total" ] && echo && echo "$((total - have)) entries in red are in the manifest but not in the store yet. Run \`pyark harvest docs\` while online."
  echo
  echo '<nav class="ref-index" markdown>'
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
