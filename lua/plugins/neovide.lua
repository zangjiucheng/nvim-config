-- Neovide-only plugins. GUI settings live in lua/config/neovide.lua.
return {
  -- IME preedit for Neovide >= 0.16. Neovide's IME API does not draw the
  -- text being composed (e.g. Pinyin before a candidate is picked) on its
  -- own, so typing Chinese looked like nothing was happening until commit.
  -- This installs Neovide's preedit/commit handlers to render it inline.
  -- Highlights: NeovImePreedit (-> Pmenu), NeovImePreeditSelected (-> PmenuSel).
  {
    "sevenc-nanashi/neov-ime.nvim",
    cond = vim.g.neovide ~= nil,
    lazy = false,
  },
}
