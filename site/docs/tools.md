# Tools

Installed by `pyark install arch` (pacman) and `pyark install python` (uv tool). All on your PATH.

| Tool | Does | First command |
|---|---|---|
| `uv` | Python versions, venvs, packages, tools | `uv init`, `uv add`, `uv run` |
| `ruff` | lint and format | `ruff check --fix . && ruff format .` |
| `ty` | type check | `ty check` |
| `just` | run project tasks from a `justfile` | `just --list` |
| `pytest` (per project) | tests | `uv run pytest` |
| `pre-commit` | git hooks | `pre-commit install` |
| `ipython` | REPL | `uv run ipython` |
| `copier` | project templates | `copier copy <template> <dest>` |
| `pyproject-build` | build an sdist and wheel | `pyproject-build` |
| `marimo` | notebooks as `.py` files | `marimo edit nb.py` |
| `mkdocs` | this site and your project docs | `mkdocs serve` |

Each tool's own documentation is under [Reference docs](reference.md).
