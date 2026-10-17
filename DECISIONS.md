# pyark decisions

Dated. Append, never rewrite. Agent-facing.

## 2026-10-17 — shape (mockup: mockups/2026-10-17-shape.html, https://claude.ai/artifact/S3idvHgCseAuUEcEF1rzF5)

- Name `pyark`, repo https://github.com/demian0311/pyark (public, created and pushed 2026-10-17). Public: no machine state, no secrets.
- Architecture: `harvest` (online) fills `store/`; `install` (offline) consumes it. `store/` gitignored, default `$PYARK_ROOT/store` (override `PYARK_STORE`), may be a symlink to a USB mount.
- Target: this laptop, sometimes offline. Omarchy's own packages out of scope. Revisit if a second air-gapped machine appears.
- Python toolchain: uv. Versions in `manifest/python.txt`, first line default. mise stays for non-Python tools only.
- Libraries: curated, `manifest/packages.txt`, defaults accepted by Demian 2026-10-17 (52 incl. marimo). Each harvested with dependency closure, plus HTML docs where a build exists.
- Notebooks: marimo. No JupyterLab.
- Type checker: ty (fallback pyrefly); basedpyright NOT harvested, avoids node in the store. Revisit if ty fails on real code.
- Docs hub: mkdocs site at `localhost:8800` serving own guides + harvested HTML docs under one search. Zeal and DevDocs rejected (separate app / Ruby scraper).
- nvim: layer onto Demian's existing LazyVim (`~/.config/nvim`): python extra, plugin dir pointed at store, Mason disabled. Not `NVIM_APPNAME`, not a replacement.
- Scaffolding: copier template in `templates/`, `pyark new <name>`.
- Entry point `bin/pyark`: harvest · install · serve · new · doctor.

## 2026-10-17 — docs beyond library reference

- `manifest/docs.txt` holds non-library docs: Python HTML zip per version, Packaging Guide, Pro Git, gto76 cheatsheet, Hitchhiker's Guide, cosmicpython, Think Python, Dive Into Python 3, Learn X in Y (python), arch-wiki-docs, and the docs of uv/ruff/pytest/mkdocs/marimo.
- Rejected by Demian: PEPs, Python Module of the Week, Exercism track. Rejected by size: Stack Overflow dump, Wikipedia.
- Harvested texts stay in `store/`, never in the repo; several are CC BY-NC, fine for local use, not for redistribution.
- Site front page links `python -m pydoc -p <port>` (docstrings of everything installed) as a second search, zero harvest cost.
- Local coding model: out of scope for pyark; possible separate add-on.

## 2026-10-17 — docs harvest and site

- Docs are wget mirrors of published sites (`site` kind), not local builds: Read the Docs no longer serves HTML zips for most projects (probe 2026-10-17: only pytest, pytest-cov, build, rich did) and each project's doc build needs its own toolchain. Exceptions: Python, pandas, numpy ship zips (`zip` kind); Arch Wiki is extracted from the stored pacman package (`pacman` kind).
- Per-site cap `PYARK_DOCS_QUOTA` (default 500m). CDN-hosted assets (fonts, some JS) are not fetched; pages still read.
- Library docs are entries in `manifest/docs.txt` whose id equals the package name; `pyark doctor` can diff against `packages.txt`. No source for: tomli-w, orjson, freezegun, anthropic.
- Site: mkdocs-material from the wheelhouse, built into `store/site`, `store/docs` symlinked as `/ref`, served by `python -m http.server` on `localhost:8800`. Reference page generated at build from manifest + store state.
- Search: mkdocs search covers the guides only. One search over all mirrored docs is OPEN; candidate is pagefind (static index over any HTML tree, pip-installable). pydoc is per project (`uv run python -m pydoc -b`), not a global server.

## 2026-10-17 — nvim layer

- One file, `nvim/lua/plugins/pyark-python.lua`, copied into `~/.config/nvim/lua/plugins/`. Imports LazyVim's `lang.python` extra with `vim.g.lazyvim_python_lsp = "ty"`; `ty` and `ruff` get `mason = false` (binaries from the pacman packages). Treesitter `ensure_installed` is the list `harvest/nvim.sh` installs online.
- Store holds `~/.local/share/nvim/{lazy,site/parser,site/queries,mason}` and the lockfile. Install rsyncs without `--delete` and merges the lockfile (store wins per plugin), then `Lazy! restore` offline.
- Wheelhouse now also covers `manifest/tools.txt` names (debugpy was missing). `debugpy-adapter` lands on PATH from `uv tool install debugpy`; the extra's dap-python setup uses it, but dap-python itself only loads with the `dap.core` extra, which is the user's choice.
- Verified 2026-10-17 headless with ruff/ty extracted from the store onto PATH: both attach to a .py buffer, 3 diagnostics. Not yet verified with the pacman-installed binaries (sudo step pending).
- Omarchy's lazy config has `checker.enabled = true`; offline this fails silently (`notify = false`). Left alone; documented on the site's nvim page.

## 2026-10-17 — pyark new and a crawl fix

- `templates/project` is a copier template (copier from the wheelhouse). `install/new.sh` answers `project_name` and `python_version` (first line of `manifest/python.txt`), passes extra `-d` through, runs `uv sync`, `git init`, first commit. Hatchling backend; editable installs need `editables`, which was missing from the wheelhouse until this (found by the first offline test).
- Typer with one command is the root command: `cli-app --name x`, not `cli-app hello`.
- Docs crawl now carries `--domains=<host>`: without it wget followed affiliate redirects on docs.python-guide.org into amazon.com (386 MB before it was killed). The polluted mirror was deleted and the harvest restarted; done entries are skipped by their stamps.
