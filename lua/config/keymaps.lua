-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Compiler / task runner
map("n", "<leader>cc", "<cmd>CompilerOpen<cr>", vim.tbl_extend("force", opts, { desc = "Compiler: open" }))
map(
  "n",
  "<leader>cC",
  "<cmd>CompilerStop<cr><cmd>CompilerRedo<cr>",
  vim.tbl_extend("force", opts, { desc = "Compiler: redo last" })
)
map(
  "n",
  "<leader>ct",
  "<cmd>CompilerToggleResults<cr>",
  vim.tbl_extend("force", opts, { desc = "Compiler: toggle results" })
)

-- Buffer navigation (cybu)
map("n", "H", "<Plug>(CybuPrev)", vim.tbl_extend("force", opts, { desc = "Buffer: previous" }))
map("n", "L", "<Plug>(CybuNext)", vim.tbl_extend("force", opts, { desc = "Buffer: next" }))
map({ "n", "v" }, "P", "<Plug>(CybuLastusedPrev)", vim.tbl_extend("force", opts, { desc = "Buffer: last used" }))

-- Sessions (auto-session)
map("n", "<leader>wr", "<cmd>SessionRestore<cr>", { desc = "Session: restore for cwd" })
map("n", "<leader>ws", "<cmd>SessionSave<cr>", { desc = "Session: save for cwd" })
