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
opt.colorcolumn = "80,100"
opt.pumblend = 0
opt.winblend = 0
opt.winborder = "rounded"

-- Sessions
-- auto-session needs `localoptions` in sessionoptions, otherwise restored
-- buffers come back with no filetype at all: no LSP, no VimTeX, no syntax.
-- LazyVim's default list omits it. `skiprtp` stays — without it the session
-- serialises the whole runtimepath and fights lazy.nvim on the next start.
opt.sessionoptions:append("localoptions")
