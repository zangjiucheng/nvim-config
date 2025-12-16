return {
  -- Inline git signs and line number highlights
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "-" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      signcolumn = true,
      numhl = true,
      linehl = false,
    },
  },

  -- Diff UI
  {
    "sindrets/diffview.nvim",
  },
}
