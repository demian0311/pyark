#!/usr/bin/env bash
# Fill store/wheels with every package in manifest/packages.txt plus its dependency
# closure, once per Python version in manifest/python.txt (wheels differ per version;
# identical files are skipped). uv has no download-only command (checked in its CLI
# reference 2026-10-17), so a throwaway venv runs `pip download`. Offline, uv consumes
# the directory via find-links + no-index (install/python.sh writes that config).
source "$(dirname "$0")/../lib/common.sh"
ensure_uv

dir=$(store_dir wheels)
export UV_PYTHON_INSTALL_MIRROR="file://$PYARK_STORE/python"
for ver in $(manifest python); do
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  log "wheels: python $ver — creating helper venv"
  UV_NO_CONFIG=1 "$UV" venv -q --python "$ver" "$tmp/venv"
  UV_NO_CONFIG=1 "$UV" pip install -q --python "$tmp/venv/bin/python" pip
  log "wheels: python $ver — downloading manifest/packages.txt with dependencies"
  "$tmp/venv/bin/python" -m pip download -q --prefer-binary -d "$dir" -r "$PYARK_ROOT/manifest/packages.txt"
  rm -rf "$tmp"
done
stamp "$dir"
log "wheels: $(ls "$dir" | grep -cE '\.(whl|tar\.gz|zip)$') files in store ($(du -sh "$dir" | cut -f1))"
