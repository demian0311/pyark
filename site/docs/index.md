# pyark

This machine has a complete Python development environment that works with the network down. Packages, interpreters, tools and the documentation on this site all come from a local **store** filled while online.

**Three things to know**

1. `uv` never contacts PyPI. `uv add polars` resolves from the local wheelhouse in well under a second. A package that is not in the store fails at once, and [Add a library or tool](add-a-library.md) says what to do.
2. Documentation for every library in the store is on this site under [Reference docs](reference.md), along with the Python docs, the Arch Wiki and a shelf of free books.
3. `pyark doctor` in a terminal tells you what the store holds, how old it is, and what is missing on the machine.

**Where things are**

| | |
|---|---|
| the repo | `~/code/pyark` |
| the store | `~/code/pyark/store` (not in git) |
| uv's config | `~/.config/uv/uv.toml` |
| tools | `~/.local/bin` |
| this site | `pyark serve`, then <http://localhost:8800> |

**Living without a search engine**

- Library API: open the library under Reference docs and use its own search.
- Anything installed in a project: run `uv run python -m pydoc -b` inside the project. It opens a browser on the docstrings of every module the project can import.
- Standard library: the Python docs under Reference docs have the full module index.
- System questions: the Arch Wiki is under Reference docs.
