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
