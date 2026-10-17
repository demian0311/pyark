#!/usr/bin/env bash
# pyark new <name> [-d key=value ...]  → a project from templates/project in ./<name>, synced
# from the store (venv, lock, dev tools) and committed. Offline. Extra -d answers go to copier:
#   pyark new invoices -d description="Monthly invoice run" -d cli=true -d python_version=3.13
source "$(dirname "$0")/../lib/common.sh"
need copier uv git
name=$1; shift
[ -d "$name" ] && die "new: ./$name already exists"
pyver=$(python_version)

copier copy --quiet --defaults -d "project_name=$name" -d "python_version=$pyver" "$@" \
  "$PYARK_ROOT/templates/project" "./$name"
cd "$name"
log "new: syncing from the store"
uv sync -q
git init -q -b main
git add -A
git -c user.name="${GIT_AUTHOR_NAME:-$(git config user.name || echo pyark)}" commit -q -m "Scaffold $name with pyark new" || true
log "new: ./$name ready — cd $name && just"
