-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
-- Quiet UI for prose buffers -------------------------------------------------
-- The VS Code-style chrome (minimap, breadcrumbs, sticky scroll, colorcolumn,
-- fold column) earns its keep in code and just gets in the way in a LaTeX or
-- Typst document. Code buffers are untouched; see also the per-plugin
-- exclusions in lua/plugins/ui.lua.
local prose_filetypes = { "tex", "plaintex", "bib", "typst", "markdown" }

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("ProseUI", { clear = true }),
  pattern = prose_filetypes,
  desc = "Writing-focused window options",
  callback = function()
    local opt = vim.opt_local
    opt.wrap = true
    opt.linebreak = true -- wrap at word boundaries, not mid-word
    opt.breakindent = true
    opt.colorcolumn = ""
    opt.foldcolumn = "0"
    opt.spell = true
    opt.spelllang = { "en_us" }
    -- VimTeX renders \alpha, \in, ^{} etc. as the real symbols at level 2.
    -- Set to 0 if you would rather always see the raw source.
    opt.conceallevel = 2
    -- `j`/`k` should move by visual line once text is soft-wrapped, but only
    -- when no count is given, so 5j still means five real lines.
    for _, key in ipairs({ "j", "k" }) do
      vim.keymap.set("n", key, function()
        return vim.v.count == 0 and ("g" .. key) or key
      end, { buffer = true, expr = true, desc = "Move by display line" })
    end
  end,
})
