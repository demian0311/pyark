#!/usr/bin/env bash
# Serve store/site (guides + /ref/<id>/ harvested docs) on localhost. Static files only, so
# Python's http.server is enough. Builds the site first if it is missing. Opens the browser once
# the port answers, unless PYARK_NO_OPEN=1 or there is no graphical session.
source "$(dirname "$0")/../lib/common.sh"
out="$PYARK_STORE/site"
[ -f "$out/index.html" ] || bash "$PYARK_ROOT/install/site.sh"
url="http://localhost:$PYARK_SITE_PORT"
log "serve: $url  (Ctrl-C stops)"
if [ "${PYARK_NO_OPEN:-0}" != 1 ] && [ -n "${WAYLAND_DISPLAY:-}${DISPLAY:-}" ] && command -v xdg-open >/dev/null; then
  # $$ becomes the server after exec; stop if it dies (port taken) so we never open someone else's.
  ( for _ in $(seq 50); do
      sleep 0.2; kill -0 $$ 2>/dev/null || exit 0
      curl -fsS -o /dev/null "$url" 2>/dev/null && exec xdg-open "$url" >/dev/null 2>&1
    done ) &
fi
# no-cache: the browser revalidates every file, so a rebuilt slate.css shows on the next reload
# instead of a cached copy styling new markup (seen 2026-10-24).
exec python3 -c '
import functools, http.server, sys
class H(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-cache")
        super().end_headers()
http.server.ThreadingHTTPServer(("127.0.0.1", int(sys.argv[1])), functools.partial(H, directory=sys.argv[2])).serve_forever()
' "$PYARK_SITE_PORT" "$out"
