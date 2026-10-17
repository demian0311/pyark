# pyark

An offline-capable Python development environment for [Omarchy](https://omarchy.org) and other Arch-based Linux machines.

Run it once while online and it fills a **store**: Arch packages, CPython builds, a wheelhouse of curated libraries, and later nvim plugins and documentation. Run it again, with or without a network, and it builds a working Python workstation from that store. uv never touches PyPI afterwards. Everything resolves from disk.

## What you get

- **uv** configured so `uv init`, `uv add`, `uv run` and `uv tool install` work with the network down.
- **Two managed Pythons** (see `manifest/python.txt`) installed from a local mirror.
- **A curated wheelhouse** (`manifest/packages.txt`) with every dependency, no source builds needed.
- **CLI tools** on your PATH: ruff, ty, just, pre-commit, ipython, copier, build, marimo, mkdocs.
- **Coming** (not built as of 2026-10-17): a Python-ready nvim layer, offline docs for every library in the manifest, a local docs site with guides, and `pyark new` for scaffolding projects.

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
uv init invoices && cd invoices
uv add polars httpx pytest    # resolves from the wheelhouse, instantly
uv run pytest
uv add some-package-not-in-the-manifest   # fails fast: not in the store
```

To add a library: put its name in `manifest/packages.txt`, then `pyark harvest wheels` while online. The harvest is incremental and skips files it already has.

To add a CLI tool: `manifest/tools.txt` for Python tools (installed with `uv tool`), `manifest/arch.txt` for pacman packages.

To change Python versions: edit `manifest/python.txt` (first line is the default), then `pyark harvest python && pyark install python`.

## Layout

| Path | What |
|---|---|
| `bin/pyark` | the one command: `harvest`, `install`, `doctor`, and soon `serve`, `new` |
| `harvest/*.sh` | one script per store part, run online |
| `install/*.sh` | one script per target, run offline |
| `manifest/*.txt` | what to fetch: packages, tools, Arch packages, Python versions, docs |
| `lib/common.sh` | shared shell: paths, logging, manifest reader, uv bootstrap |
| `store/` | the harvested material, gitignored |
| `mockups/` | dated design pages |
| `DECISIONS.md` | why things are the way they are, dated |

## How it works

- **Arch packages** are fetched with `pacman -Sp` (prints URLs, needs no root) and installed with `pacman -U` from the local files. No `pacman.conf` change.
- **Pythons** are the python-build-standalone tarballs uv would download, stored in the layout uv's `python-install-mirror` setting expects, served with a `file://` URL.
- **Wheels** are collected with `pip download` once per Python version. uv has no download-only command. Offline, uv's user config sets `no-index` and `find-links` to the wheelhouse.
- **The uv that harvests is the uv that installs**: it is extracted from the stored Arch package, so the Python build URLs match.

Licenses of harvested material belong to their projects. Nothing harvested is committed to this repo.
