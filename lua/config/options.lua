-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

-- Global toggles
-- Default save does NOT format; use <M-S-s> (Save + Format) or <leader>cf to format on demand.
vim.g.autoformat = false
vim.env.NODE_OPTIONS = "--experimental-sqlite"

-- UI
opt.termguicolors = true
opt.colorcolumn = "80,120"
opt.pumblend = 0
opt.winblend = 0
opt.winborder = "rounded"

-- Sessions
-- auto-session needs `localoptions` in sessionoptions, otherwise restored
-- buffers come back with no filetype at all: no LSP, no VimTeX, no syntax.
-- LazyVim's default list omits it. `skiprtp` stays — without it the session
-- serialises the whole runtimepath and fights lazy.nvim on the next start.
opt.sessionoptions:append("localoptions")

-- Python provider
-- Pinned to a dedicated venv (pynvim + jupyter_client) rather than `python3`,
-- which is a pyenv shim and changes with whatever .python-version is nearest.
-- molten-nvim is a remote plugin and talks to Neovim through this interpreter;
-- it is deliberately NOT the interpreter your notebooks run on — that is the
-- Jupyter kernel you pick with :MoltenInit.
local python_host = vim.fn.expand("~/.local/share/nvim/python-host/bin/python")
if vim.fn.executable(python_host) == 1 then
  -- The nix-wrapped nvim starts with
  --   --cmd "lua ...vim.g.loaded_python3_provider=0"
  -- which hard-disables every remote provider. Clearing it here (before
  -- anything calls has("python3")) re-enables Python without rebuilding
  -- neovim with withPython3 = true.
  vim.g.loaded_python3_provider = nil
  vim.g.python3_host_prog = python_host
end
