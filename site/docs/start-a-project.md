# Start a project

```bash
cd ~/code
pyark new invoices -d description="Monthly invoice run"
cd invoices
just            # lists the tasks: test, check, fmt, cov, reset
uv add polars httpx
```

`pyark new` lays out a `src/` package with a test, a `pyproject.toml` with ruff, pytest and ty configured, a `justfile`, a `.gitignore`, and a `.python-version` pinned to the store's default Python. It then runs `uv sync`, which creates `.venv` and `uv.lock` from the store, and makes the first git commit. Options, all passed as `-d key=value`: `cli=true` adds a typer command named after the project, `python_version=3.13` picks another stored Python.

For a throwaway, `uv init scratch` is enough: `pyproject.toml`, `main.py`, nothing else.

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

