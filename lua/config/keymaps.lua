-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

---- Keymaps for Compiler

-- Open compiler
vim.api.nvim_set_keymap("n", "<leader>cc", "<cmd>CompilerOpen<cr>", { noremap = true, silent = true })

-- Redo last selected option
vim.api.nvim_set_keymap(
  "n",
  "<leader>cC",
  "<cmd>CompilerStop<cr>" -- (Optional, to dispose all tasks before redo)
    .. "<cmd>CompilerRedo<cr>",
  { noremap = true, silent = true }
)

-- Toggle compiler results
vim.api.nvim_set_keymap("n", "<leader>ct", "<cmd>CompilerToggleResults<cr>", { noremap = true, silent = true })

---- Keymaps for Cybu

-- Keymaps for buffer navigation
vim.api.nvim_set_keymap("n", "H", "<Plug>(CybuPrev)", { silent = true, noremap = true, desc = "Previous Buffer" })
vim.api.nvim_set_keymap("n", "L", "<Plug>(CybuNext)", { silent = true, noremap = true, desc = "Next Buffer" })
vim.keymap.set(
  { "n", "v" },
  "P",
  "<Plug>(CybuLastusedPrev)",
  { silent = true, noremap = true, desc = "Previous Recently Used Buffer" }
)

vim.keymap.set("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "Restore session for cwd" }) -- restore last workspace session for current directory
vim.keymap.set("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "Save session for auto session root dir" }) -- save workspace session for current working directory
