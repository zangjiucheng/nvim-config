-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>w<", "<cmd>vertical resize -4<cr>", { desc = "Decrease Window Width" })
vim.keymap.set("n", "<leader>w>", "<cmd>vertical resize +4<cr>", { desc = "Increase Window Width" })
vim.keymap.set("n", "<leader>w-", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<leader>w+", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Terminal Normal Mode" })

-- Fast insert-mode exit: `jk` -> <Esc> ---------------------------------------
-- Deliberately NOT a plain `inoremap jk <Esc>`: that would make Neovim wait
-- `timeoutlen` (300ms here) after every literal `j`, so typing "just" or
-- "adjacent" visibly stutters. Instead only `k` is mapped, and it rewrites the
-- preceding `j` when that `j` was typed moments ago. Zero pending-key timeout.
local jk = { last = 0, window_ns = 200 * 1e6 }

vim.api.nvim_create_autocmd("InsertCharPre", {
  group = vim.api.nvim_create_augroup("JkEscape", { clear = true }),
  desc = "Timestamp `j` for the jk escape mapping",
  callback = function()
    if vim.v.char == "j" then
      jk.last = vim.uv.hrtime()
    end
  end,
})

vim.keymap.set("i", "k", function()
  local col = vim.fn.col(".")
  if col > 1 and (vim.uv.hrtime() - jk.last) < jk.window_ns then
    if vim.api.nvim_get_current_line():sub(col - 1, col - 1) == "j" then
      jk.last = 0
      return "<BS><Esc>"
    end
  end
  return "k"
end, { expr = true, desc = "jk -> Esc" })

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

-- Quick Fix: VS Code's Cmd+. ------------------------------------------------
-- Ghostty sends Cmd+. as ESC-. (see shared/modules/ghostty.nix), which arrives
-- here as <M-.>. On a misspelled word this offers spelling corrections;
-- anywhere else it falls back to LSP code actions, which is what Cmd+. does in
-- VS Code. `spell` is only on in prose buffers, so code stays on code actions.
local function quick_fix()
  local bad = vim.wo.spell and vim.fn.spellbadword()[1] or ""
  if vim.fn.mode() == "n" and bad ~= "" then
    local suggestions = vim.fn.spellsuggest(bad, 25)
    if #suggestions == 0 then
      vim.notify("No spelling suggestions for " .. bad, vim.log.levels.INFO)
      return
    end
    vim.ui.select(suggestions, { prompt = "Spelling: " .. bad }, function(_, idx)
      if idx then
        -- `Nz=` applies the Nth entry of the very list spellsuggest() returns,
        -- so Vim locates and replaces the word itself — no manual text surgery.
        vim.cmd("normal! " .. idx .. "z=")
      end
    end)
    return
  end
  vim.lsp.buf.code_action()
end

vim.keymap.set({ "n", "x" }, "<M-.>", quick_fix, { desc = "Quick Fix / Spelling" })
vim.keymap.set("i", "<M-.>", function()
  vim.cmd("stopinsert")
  vim.schedule(quick_fix)
end, { desc = "Quick Fix / Spelling" })
