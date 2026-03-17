local function open_gitui(opts)
  return function()
    Snacks.terminal({ "gitui" }, {
      cwd = opts and opts.root and LazyVim.root() or nil,
      win = {
        position = "float",
        border = "rounded",
        width = 0.92,
        height = 0.9,
      },
    })
  end
end

return {
  {
    "mason-org/mason.nvim",
    optional = true,
    keys = {
      { "<leader>gg", false },
      { "<leader>gG", false },
      { "<leader>gg", open_gitui({ root = true }), desc = "GitUi (Root Dir)" },
      { "<leader>gG", open_gitui(), desc = "GitUi (cwd)" },
    },
  },

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
