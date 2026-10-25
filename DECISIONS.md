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
- Search: mkdocs search covers the guides; pagefind covers all mirrored docs (see 2026-10-17 search entry). pydoc is per project (`uv run python -m pydoc -b`).

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

## 2026-10-17 — first full docs harvest, what it taught

- 61 entries, 3.2 GB before scoping. Three mirrors hit the 500m cap for the wrong content: lxml.de/files (431 MB of release tarballs), Polars' Rust API and dev docs, FastAPI/Typer translations. `manifest/docs.txt` grew a 5th column `quota=,reject=` per entry; the global reject list now covers tgz/bz2/xz/egg/exe/msi/dmg.
- Never edit `harvest/docs.sh` while a harvest runs: bash reads the script incrementally; the running copy died with a syntax error at the last entry (platformdirs completed, summary never printed).
- `PYARK_DOCS_ONLY="a b"` re-mirrors chosen entries; delete the entry's directory first when the scoping changed, wget --mirror never removes files.
- Re-mirror results 2026-10-17: FastAPI 363→40 MB (translations), lxml 507→13 MB (release files AND per-version doc copies `lxml.de/N.N/`), Polars 394 MB and Matplotlib 430 MB complete under a 1g cap. Store total ≈3.2 GB, docs ≈2.3 GB.

## 2026-10-17 — one Python, trimmed SQLite, slate look

- Exactly one Python version (`manifest/python.txt`, `python_version()` in lib dies otherwise). 3.13 removed from store (builds, cp313 wheels, docs) and from uv. Docs id for Python is plain `python`.
- `manifest/docs.txt` columns: id, kind, source, title, description, opts. zip opts `entry=` and `prune=`; SQLite lands on docs.html with support/purchase/news/consortium pages and the CGI search binaries pruned (39→28 MB).
- Site look: slate palette (https://diagrammo.app/slate/) via `site/docs/assets/slate.css` on Material; fonts Schibsted Grotesk / Inter / JetBrains Mono vendored (OFL) in `site/docs/assets/fonts`, `font: false` so nothing loads from Google. Reference page is generated HTML: nine hue-coded groups, name + description + "size · date" (no "harvested"). Home has four hue cards.
- Visual check: headless Chromium screenshots (`chromium --headless=new --screenshot`), dark scheme followed the system.

## 2026-10-17 — cross-docs search (pagefind)

- Considered adopting devpi/Velodex/Posit (index servers: a daemon for a one-machine problem), conda-pack (uv lock + store already reproduce), DevDocs (Ruby), Kiwix (second server and format), Zeal docsets (kept in reserve as a possible `docset` kind if a big mirror keeps breaking). Adopted only pagefind.
- `pagefind[bin]` is in packages.txt, NOT tools.txt: its wheel has no console script, so `uv tool install` fails ("Failed to install entrypoints"). Run as `uv run --no-project --with 'pagefind[bin]' python -m pagefind`.
- Index in `store/search` (outside `store/site`, which mkdocs recreates), symlinked as `/pagefind`. `--force-language en` is required: without it pages tagged en-US or untagged went to separate per-language indexes the UI never queried. Rebuilt only when older than `store/docs/HARVESTED`, or `PYARK_REINDEX=1`. 23,304 pages, 183 MB, ~4.5 min.
- Harvest strips `data-pagefind-body` from mirrored pages: Pro Git ships it, and its presence anywhere makes pagefind index only marked pages (first index: 102 of 23,334).
- (Superseded 2026-10-24: the search box moved to the home page, which takes `?find=<query>`; `/find/` is gone.) Search page is `/find/`, not `/search/` (mkdocs owns that directory for its own index); deep link `?find=<query>` because Material's search grabs `?q=`.
- Verified headless 2026-10-17: "dataframe join" → pandas DataFrame, "pathlib glob" → Python pathlib, "git rebase" → Pro Git Rebasing, "sqlite pragma journal_mode" → SQLite keyword index. First query ~5 s (wasm and chunk load).
