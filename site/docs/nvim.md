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

## :material-keyboard-outline: Keys for Python work

Leader is <kbd>Space</kbd>. Every key below is from LazyVim's own [keymaps page](/ref/lazyvim/keymaps.html), checked 2026-10-24. Press <kbd>Space</kbd> and wait to see the rest in a popup.

### Move around the code

| Key | Does |
|---|---|
| `gd` | go to definition |
| `gr` | list references |
| `K` | hover: signature and docstring |
| `<leader>ss` | symbols in this file |
| `<leader>sS` | symbols in the whole project |
| `]d` / `[d` | next / previous problem |

### Fix and tidy

| Key | Does |
|---|---|
| `<leader>ca` | code action: ruff fixes, add an import |
| `<leader>cr` | rename everywhere |
| `<leader>cf` | format (also runs on save) |
| `<leader>co` | organize imports |
| `<leader>cd` | the problem on this line, in full |
| `<leader>cv` | pick the virtualenv, in a Python file |

### Find things

| Key | Does |
|---|---|
| `<leader><space>` | find a file in the project |
| `<leader>/` | search text in the project |
| `<leader>e` | file explorer |
| `<leader>ft` | terminal in the project root, for `just test` or `uv run` |

### Tests and the debugger

These two need a LazyVim extra turned on once: `:LazyExtras`, then enable `test.core` and `dap.core`. Their plugins must be in the store, so do it online and run `pyark harvest nvim` after.

| Key | Does |
|---|---|
| `<leader>tr` | run the test under the cursor |
| `<leader>tt` | run this test file |
| `<leader>db` | toggle a breakpoint |
| `<leader>dc` | start or continue debugging |

## :material-wifi-off: Offline notes

- Mason installs nothing for Python. Its own list (stylua, shfmt, lua-language-server) is restored from the store.
- LazyVim's update checker is on in the Omarchy config and fails silently offline. `:Lazy` shows "failed to fetch" entries; ignore them.
- Adding a plugin: `:Lazy install` while online, then `pyark harvest nvim` so the store has it.
- New treesitter parsers need source downloads and a compiler. Add the name to the `ensure_installed` list in `pyark-python.lua` and run `pyark harvest nvim` while online.

## :material-bookshelf: Learn more, offline

- [LazyVim keymaps](/ref/lazyvim/keymaps.html): every binding, grouped by plugin.
- [LazyVim Python extra](/ref/lazyvim/extras/lang/python.html): what the Python layer adds.
- [Neovim quick reference](/ref/neovim/doc/user/quickref/): motions, operators and commands on one page.
- [Neovim LSP](/ref/neovim/doc/user/lsp/): how the language servers plug in.
- New to Vim: run `:Tutor` inside nvim, or read the [user manual](/ref/neovim/doc/user/usr_01/).
