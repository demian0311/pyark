---
icon: material/file-code-outline
---

# Editor (nvim)

Omarchy ships LazyVim. `pyark install nvim` adds one file to it, `lua/plugins/pyark-python.lua`, and restores plugins and parsers from the store. Your own plugins, keymaps and theme are untouched.

## :material-language-python: What you get in a `.py` buffer

| | Provided by |
|---|---|
| diagnostics, code actions, import sorting, format on save | `ruff` (language server, from the pacman package) |
| type checking, hover, go to definition, completion | `ty` (language server, from the pacman package) |
| syntax highlighting, text objects | treesitter parsers for python, toml, rst, ninja, requirements |
| pick a virtualenv | venv-selector, `<leader>cv` |
| debugging | `debugpy-adapter` is on PATH from `uv tool`; enable LazyVim's `dap.core` extra with `:LazyExtras` to use it |

`:LspInfo` in a Python file lists `ruff` and `ty`. If it lists nothing, the two binaries are missing: run `pyark install arch`.

## :material-wifi-off: Offline notes

- Mason installs nothing for Python. Its own list (stylua, shfmt, lua-language-server) is restored from the store.
- LazyVim's update checker is on in the Omarchy config and fails silently offline. `:Lazy` shows "failed to fetch" entries; ignore them.
- Adding a plugin: `:Lazy install` while online, then `pyark harvest nvim` so the store has it.
- New treesitter parsers need source downloads and a compiler. Add the name to the `ensure_installed` list in `pyark-python.lua` and run `pyark harvest nvim` while online.
