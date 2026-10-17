# Working offline

Nothing changes when the network goes away, because nothing used it. These are the things that can still surprise you.

**"No solution found" from `uv add`**
The package or the version you asked for is not in the wheelhouse. See [Add a library or tool](add-a-library.md). To see what is there: `ls ~/code/pyark/store/wheels | grep -i name`.

**`uv self update` or `uv python install 3.15`**
Both need the network. The first is harmless to skip. The second fails because the store only mirrors the versions in `manifest/python.txt`.

**`pre-commit` hooks that clone from GitHub**
`pre-commit` fetches each hook's repository the first time it runs. Run `pre-commit install --install-hooks` in a project while online, or prefer `ruff` and `ty` called directly from a `justfile`.

**Browsers and extensions in notebooks**
`marimo` is self-contained. Anything that loads from a CDN (some plotting backends, Plotly's full bundle) renders blank offline.

**Is the store stale?**
`pyark doctor` prints the harvest date of each part. While online, `pyark harvest` refreshes everything incrementally; `PYARK_REFRESH=1 pyark harvest docs` re-mirrors the documentation.

**Moving the store**
It is a plain directory. `rsync -a ~/code/pyark/store/ target:~/code/pyark/store/`, or put it on a USB drive and set `PYARK_STORE=/path/to/store` before running `pyark install python` so uv's config points there.
