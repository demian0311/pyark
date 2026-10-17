# Start a project

```bash
cd ~/code
uv init invoices
cd invoices
uv add polars httpx
uv add --dev pytest ruff
uv run python main.py
```

`uv init` writes a `pyproject.toml`, a `.python-version` pinned to the default Python, a `main.py` and a `README.md`. The first `uv add` creates `.venv` from the store's interpreter and a `uv.lock`.

**Run things**

| What | Command |
|---|---|
| a script in the project | `uv run python main.py` |
| tests | `uv run pytest` |
| lint and format | `ruff check . && ruff format .` |
| type check | `ty check` |
| the REPL with the project importable | `uv run ipython` |
| a notebook | `marimo edit notebook.py` |

**Pick a Python version**

`uv python list --only-installed` shows what the store provided. `uv init --python 3.13` or `uv python pin 3.13` inside a project switches.

**A library without a project**

`uv run --with polars python` starts Python with a library available, no project needed. The environment is cached and reused.

!!! note "Coming"
    `pyark new <name>` with a fuller template (ruff and pytest configured, a justfile, pre-commit) is not built yet as of 2026-10-17.
