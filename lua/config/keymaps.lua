-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>w<", "<cmd>vertical resize -4<cr>", { desc = "Decrease Window Width" })
vim.keymap.set("n", "<leader>w>", "<cmd>vertical resize +4<cr>", { desc = "Increase Window Width" })
vim.keymap.set("n", "<leader>w-", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<leader>w+", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Terminal Normal Mode" })

-- VS Code-style shortcuts ---------------------------------------------------
-- (Ctrl+Shift+* keys need a terminal that forwards them, e.g. kitty/wezterm/
-- ghostty; the <leader> equivalents below always work as fallbacks.)

-- Save with Alt+S (no formatting — this is the default save).
-- The tmux prefix here is C-s, which would otherwise swallow LazyVim's default
-- <C-s> save before it reaches Neovim.
vim.keymap.set({ "i", "x", "n", "s" }, "<M-s>", "<cmd>w<cr><esc>", { desc = "Save File" })
-- Save with formatting on Alt+Shift+S. Forces the formatter even though
-- vim.g.autoformat is off, so format-on-save is opt-in per save.
vim.keymap.set({ "i", "x", "n", "s" }, "<M-S-s>", "<cmd>LazyFormat<cr><cmd>w<cr><esc>", { desc = "Save File (format)" })

-- Command palette (Ctrl+Shift+P / <leader>P)
vim.keymap.set("n", "<leader>P", "<cmd>FzfLua commands<cr>", { desc = "Command Palette" })
vim.keymap.set("n", "<C-S-p>", "<cmd>FzfLua commands<cr>", { desc = "Command Palette" })

-- Quick open file (Ctrl+P) and search across files (Ctrl+Shift+F)
vim.keymap.set("n", "<C-p>", "<cmd>FzfLua files<cr>", { desc = "Find Files" })
vim.keymap.set("n", "<C-S-f>", "<cmd>FzfLua live_grep<cr>", { desc = "Search in Files" })

-- Toggle file explorer (Ctrl+Shift+E) and go to symbol in file (Ctrl+Shift+O)
vim.keymap.set("n", "<C-S-e>", "<cmd>Neotree toggle<cr>", { desc = "Toggle Explorer" })
vim.keymap.set("n", "<C-S-o>", "<cmd>FzfLua lsp_document_symbols<cr>", { desc = "Go to Symbol" })

-- Rename symbol (F2) and go to definition (F12)
vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename Symbol" })
vim.keymap.set("n", "<F12>", vim.lsp.buf.definition, { desc = "Go to Definition" })

-- Move lines with Alt+Up/Down (VS Code parity with LazyVim's Alt+j/k)
vim.keymap.set("n", "<A-Down>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Line Down" })
vim.keymap.set("n", "<A-Up>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Line Up" })
vim.keymap.set("i", "<A-Down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Line Down" })
vim.keymap.set("i", "<A-Up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Line Up" })
vim.keymap.set("v", "<A-Down>", ":m '>+1<cr>gv=gv", { desc = "Move Lines Down" })
vim.keymap.set("v", "<A-Up>", ":m '<-2<cr>gv=gv", { desc = "Move Lines Up" })

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
    { "<leader>U", group = "view" },
    { "<leader>w", group = "window" },
    { "<leader>x", group = "diagnostics" },
    { "gp", group = "peek" },
  })
end
