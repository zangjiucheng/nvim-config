-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("ColorColumn", { clear = true }),
  desc = "Change ColorColumn highlight",
  callback = function()
    vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#2d2f34" }) -- subtle dark-grey stripe
  end,
})
