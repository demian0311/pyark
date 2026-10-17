-- pyark: Python layer for LazyVim. `pyark install nvim` copies this file into
-- ~/.config/nvim/lua/plugins/. Everything works offline: ruff and ty are the language
-- servers and come from PATH (pacman packages in the pyark store), debugpy comes from
-- `uv tool`, plugins and treesitter parsers are restored from the store. Mason installs nothing.
vim.g.lazyvim_python_lsp = "ty"
vim.g.lazyvim_python_ruff = "ruff"

return {
  { import = "lazyvim.plugins.extras.lang.python" },

  -- Servers from PATH, never from Mason.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ty = { mason = false },
        ruff = { mason = false },
      },
    },
  },

  -- Parsers pyark harvests while online (harvest/nvim.sh installs exactly this list).
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "python", "toml", "rst", "ninja", "requirements" } },
  },

  -- Debugger: the extra calls dap-python.setup("debugpy-adapter"); that executable is on
  -- PATH from `uv tool install debugpy` (manifest/tools.txt).
}
