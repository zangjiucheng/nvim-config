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
      current_line_blame = true,
    },
  },

  -- Diff UI
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewFileHistory",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewClose",
      "DiffviewRefresh",
      "DiffviewLog",
    },
  },

  -- Full Git panel (VS Code-style source control, Magit-like staging/commit/log)
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = "Neogit",
    opts = {
      graph_style = "unicode",
      integrations = {
        diffview = true,
        telescope = true,
      },
    },
    keys = {
      { "<leader>gn", "<cmd>Neogit<cr>", desc = "Neogit (Source Control)" },
      { "<C-S-g>", "<cmd>Neogit<cr>", desc = "Source Control" },
    },
  },
}
