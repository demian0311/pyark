#!/usr/bin/env bash
# Serve store/site (guides + /ref/<id>/ harvested docs) on localhost. Static files only, so
# Python's http.server is enough. Builds the site first if it is missing.
source "$(dirname "$0")/../lib/common.sh"
out="$PYARK_STORE/site"
[ -f "$out/index.html" ] || bash "$PYARK_ROOT/install/site.sh"
log "serve: http://localhost:$PYARK_SITE_PORT  (Ctrl-C stops)"
exec python3 -m http.server "$PYARK_SITE_PORT" --bind 127.0.0.1 --directory "$out"
