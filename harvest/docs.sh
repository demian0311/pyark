#!/usr/bin/env bash
# Mirror every entry in manifest/docs.txt into store/docs/<id>/. See the manifest header for
# the kinds. Incremental: an id whose directory already has a HARVESTED stamp is skipped unless
# PYARK_REFRESH=1. PYARK_DOCS_ONLY="<id> <id>" harvests only those entries. Never edit this
# file while a harvest runs: bash reads it incrementally and the running copy breaks. Each entry writes <id>/ENTRY with
# the relative path of its landing page.
source "$(dirname "$0")/../lib/common.sh"
need wget curl bsdtar
root=$(store_dir docs)
ver=$(python_version)
failed=()

landing() { # landing <url> → path of the mirrored landing page relative to the mirror dir
  local p=${1#*://}; p=${p#*/}            # strip scheme and host
  case "$p" in */|"") p="${p}index.html";; *.html) ;; *) p="$p.html";; esac   # --adjust-extension
  printf '%s' "$p"
}

do_zip() { # do_zip <dir> <url>   (reads $entry and $prune, set per entry from the manifest's opts column)
  local tmp; tmp=$(mktemp -d)
  if ! curl -fsSL --retry 3 -o "$tmp/docs.zip" "$2"; then rm -rf "$tmp"; return 1; fi
  mkdir -p "$1"
  # strip the single top-level directory if there is one
  if [ "$(bsdtar -tf "$tmp/docs.zip" | cut -d/ -f1 | sort -u | wc -l)" -eq 1 ]; then
    bsdtar -xf "$tmp/docs.zip" -C "$1" --strip-components=1
  else
    bsdtar -xf "$tmp/docs.zip" -C "$1"
  fi
  rm -rf "$tmp"
  if [ -n "$prune" ]; then
    ( cd "$1" && find . -mindepth 1 -regextype posix-extended -regex "\./($prune)" -exec rm -rf {} + )
  fi
  printf '%s' "${entry:-index.html}" > "$1/ENTRY"
}

do_site() { # do_site <dir> <url>   (reads $reject and $quota, set per entry from the manifest's 5th column)
  mkdir -p "$1"
  local host; host=${2#*://}; host=${host%%/*}
  # --no-parent keeps the crawl below the URL's path; --domains pins it to the site's host even
  # when a link redirects elsewhere (2026-10-17: affiliate links on docs.python-guide.org sent
  # wget to amazon.com for 386 MB); -nH drops the host directory; --convert-links makes links
  # relative so the tree serves under any prefix.
  wget --quiet --mirror --no-parent --domains="$host" --no-host-directories --page-requisites --adjust-extension \
       --convert-links --quota="$quota" --wait=0 -e robots=off --user-agent="pyark-harvest (wget)" \
       --reject-regex="(\?|/_sources/|\.(pdf|zip|whl|tar\.gz|tgz|tar\.bz2|bz2|xz|egg|exe|msi|dmg|mp4|webm)\$${reject:+|$reject})" \
       --directory-prefix="$1" "$2" || [ $? -eq 8 ]   # 8 = some pages 404'd; not fatal
  [ -n "$(find "$1" -name '*.html' -print -quit)" ] || return 1
  landing "$2" > "$1/ENTRY"
}

do_pacman() { # do_pacman <dir> <package:path/inside/pkg>
  local pkg=${2%%:*} inner=${2#*:} f
  f=$(ls "$PYARK_STORE"/arch/"$pkg"-*.pkg.tar.zst 2>/dev/null | sort -V | tail -1) || true
  [ -n "$f" ] || { warn "docs: $pkg not in store/arch — run: pyark harvest arch"; return 1; }
  mkdir -p "$1"
  tar -xf "$f" -C "$1" --strip-components="$(tr -cd / <<<"$inner" | wc -c | xargs -I{} expr {} + 1)" "$inner"
  printf 'en/Main_page.html' > "$1/ENTRY"
}

harvest_one() { # harvest_one <id> <kind> <source> [opts]
  # opts, comma-separated: quota=1g reject=<ERE> (site) · entry=<file> prune=<ERE of paths to delete> (zip)
  local dir="$root/$1" opt
  quota="${PYARK_DOCS_QUOTA:-500m}"; reject=""; entry=""; prune=""
  IFS=, read -ra _opts <<<"${4:-}"
  for opt in "${_opts[@]}"; do case "$opt" in
    quota=*) quota=${opt#quota=};; reject=*) reject=${opt#reject=};; entry=*) entry=${opt#entry=};; prune=*) prune=${opt#prune=};;
  esac; done
  if [ -f "$dir/HARVESTED" ] && [ -z "${PYARK_REFRESH:-}" ]; then log "docs: have $1"; return; fi
  log "docs: $1 ($2)"
  if "do_$2" "$dir" "$3"; then
    # A page carrying data-pagefind-body makes pagefind index ONLY such pages site-wide
    # (Pro Git had 101 of them; the whole store indexed as 102 pages). Strip the marker.
    grep -rl --include='*.html' 'data-pagefind-body' "$dir" 2>/dev/null | xargs -r sed -i 's/ data-pagefind-body\(="[^"]*"\)\?//g'
    stamp "$dir"; log "docs: $1 done ($(du -sh "$dir" | cut -f1))"
  else
    failed+=("$1"); warn "docs: $1 FAILED"
  fi
}

while IFS=$'\t' read -r id kind src title desc opts; do
  if [ -n "${PYARK_DOCS_ONLY:-}" ]; then case " $PYARK_DOCS_ONLY " in *" $id "*) ;; *) continue;; esac; fi
  harvest_one "$id" "$kind" "${src//\{ver\}/$ver}" "$opts"
done < <(manifest docs)

stamp "$root"
log "docs: $(ls -d "$root"/*/ | wc -l) entries in store ($(du -sh "$root" | cut -f1))"
[ ${#failed[@]} -eq 0 ] || { warn "docs: failed: ${failed[*]}"; exit 1; }
