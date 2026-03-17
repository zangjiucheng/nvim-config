-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local ok, wk = pcall(require, "which-key")

if ok then
  wk.add({
    { "<leader>a", group = "ai" },
    { "<leader>b", group = "buffer" },
    { "<leader>c", group = "code" },
    { "<leader>d", group = "debug" },
    { "<leader>f", group = "file/find" },
    { "<leader>g", group = "git" },
    { "<leader>p", group = "project/session" },
    { "<leader>r", group = "run/task" },
    { "<leader>s", group = "search" },
    { "<leader>t", group = "test" },
    { "<leader>w", group = "window" },
    { "<leader>x", group = "diagnostics" },
    { "gp", group = "peek" },
  })
end
