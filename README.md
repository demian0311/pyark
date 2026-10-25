# pyark

An offline-capable Python development environment for [Omarchy](https://omarchy.org) and other Arch-based Linux machines.

Run it once while online and it fills a **store**: Arch packages, CPython builds, a wheelhouse of curated libraries, and later nvim plugins and documentation. Run it again, with or without a network, and it builds a working Python workstation from that store. uv never touches PyPI afterwards. Everything resolves from disk.

## What you get

- **uv** configured so `uv init`, `uv add`, `uv run` and `uv tool install` work with the network down.
- **One Python**, pinned in `manifest/python.txt`, installed from a local mirror. pyark is opinionated: one interpreter, every project on it.
- **A curated wheelhouse** (`manifest/packages.txt`) with every dependency, no source builds needed.
- **CLI tools** on your PATH: ruff, ty, just, pre-commit, ipython, copier, build, marimo, mkdocs.
- **A Python-ready nvim**: LazyVim with ruff and ty as language servers, parsers and plugins restored from the store, nothing downloaded at runtime.
- **A local docs site** (`pyark serve`, <http://localhost:8800>) with guides and the mirrored documentation of every library in the manifest, plus the Python docs, the Arch Wiki and a shelf of free books.
- **`pyark new <name>`**: a project with a `src/` package, tests, ruff, ty, pytest and a `justfile`, synced from the store and committed.

## Set up a new machine

Requirements: an Arch-based x86_64 Linux (Omarchy, or anything with `pacman`), `git`, `curl`, `bash`. Nothing else. uv itself comes from the store.

```bash
git clone https://github.com/demian0311/pyark ~/code/pyark
ln -s ~/code/pyark/bin/pyark ~/.local/bin/pyark
```

**While online**, fill the store:

```bash
pyark harvest            # arch + python + wheels (+ nvim + docs once they exist)
```

**Online or offline**, build the machine from the store:

```bash
pyark install arch       # asks for your password: pacman -U of the stored packages
pyark install python     # writes ~/.config/uv/uv.toml, installs Pythons and tools
pyark install nvim       # adds the Python layer to LazyVim, restores plugins from the store
pyark install site       # builds the docs site; `pyark serve` serves it on localhost:8800 and opens the browser (PYARK_NO_OPEN=1 skips)
pyark doctor             # every line should be a green tick
```

If `pyark install python` ran before `pyark install arch`, it left a `uv` symlink in `~/.local/bin`. `pyark doctor` tells you to remove it once the package is installed.

### Bringing the store instead of harvesting

The store is a plain directory at `~/code/pyark/store`, gitignored. To set up a machine that will never be online, harvest on a connected one and copy the directory:

```bash
rsync -a ~/code/pyark/store/ other-machine:~/code/pyark/store/
```

Or keep it on a USB drive and point pyark at it: `export PYARK_STORE=/run/media/$USER/ark/store`, or symlink `~/code/pyark/store` to the mount.

## Daily use

```bash
pyark new invoices && cd invoices   # src/ layout, tests, ruff, ty, pytest, justfile, committed
uv add polars httpx                 # resolves from the wheelhouse, instantly
just test
uv add some-package-not-in-the-manifest   # fails fast: not in the store
```

To add a library: put its name in `manifest/packages.txt`, then `pyark harvest wheels` while online. The harvest is incremental and skips files it already has.

To add a CLI tool: `manifest/tools.txt` for Python tools (installed with `uv tool`), `manifest/arch.txt` for pacman packages.

To move to a newer Python: change the single line in `manifest/python.txt`, then `pyark harvest python && pyark harvest wheels && pyark harvest docs && pyark install python`.

## Layout

| Path | What |
|---|---|
| `bin/pyark` | the one command: `harvest`, `install`, `serve`, `new`, `doctor` |
| `harvest/*.sh` | one script per store part, run online |
| `install/*.sh` | one script per target, run offline |
| `manifest/*.txt` | what to fetch: packages, tools, Arch packages, Python versions, docs |
| `templates/project/` | the copier template behind `pyark new` |
| `nvim/` | the LazyVim layer `pyark install nvim` copies into `~/.config/nvim` |
| `site/` | mkdocs source of the local docs site |
| `lib/common.sh` | shared shell: paths, logging, manifest reader, uv bootstrap |
| `store/` | the harvested material, gitignored |
| `mockups/` | dated design pages |
| `DECISIONS.md` | why things are the way they are, dated |

## How it works

- **Arch packages** are fetched with `pacman -Sp` (prints URLs, needs no root) and installed with `pacman -U` from the local files. No `pacman.conf` change.
- **Pythons** are the python-build-standalone tarballs uv would download, stored in the layout uv's `python-install-mirror` setting expects, served with a `file://` URL.
- **Wheels** are collected with `pip download` for the one Python version. uv has no download-only command. Offline, uv's user config sets `no-index` and `find-links` to the wheelhouse.
- **The uv that harvests is the uv that installs**: it is extracted from the stored Arch package, so the Python build URLs match.

Licenses of harvested material belong to their projects. Nothing harvested is committed to this repo.
