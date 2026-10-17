#!/usr/bin/env bash
# Mirror the CPython build uv would download for the version in manifest/python.txt
# into store/python, laid out so UV_PYTHON_INSTALL_MIRROR=file://store/python works:
# the path after .../releases/download/ is kept as-is. Only x86_64 Linux gnu, not free-threaded.
source "$(dirname "$0")/../lib/common.sh"
need curl tar
ensure_uv

dir=$(store_dir python)
for ver in $(python_version); do
  url=$("$UV" python list --only-downloads --show-urls "cpython@$ver" 2>/dev/null \
        | grep -E 'cpython-[0-9.]+-linux-x86_64-gnu\s' | grep -v -- '+freethreaded' | awk '{print $2}' | head -1)
  [ -n "$url" ] || die "python: uv lists no x86_64 linux download for $ver"
  # The mirror URL replaces everything up to and including /releases/download/ (uv's own
  # prefix changed from github.com to releases.astral.sh at some point; the suffix is stable).
  case "$url" in */releases/download/*) ;; *) die "python: unexpected URL $url";; esac
  rel=${url#*/releases/download/}; rel=${rel//%2B/+}   # uv asks the file:// mirror for the decoded name (tested 2026-10-17)
  f="$dir/$rel"
  if [ -s "$f" ]; then log "python: have $rel"; continue; fi
  log "python: fetching $rel"
  mkdir -p "$(dirname "$f")"
  curl -fsSL --retry 3 -o "$f" "$url"
done
stamp "$dir"
log "python: $(find "$dir" -name '*.tar.gz' | wc -l) builds in store ($(du -sh "$dir" | cut -f1))"
