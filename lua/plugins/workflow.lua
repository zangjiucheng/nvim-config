return {
  -- Session management
  {
    "rmagatti/auto-session",
    lazy = false,
    ---@type AutoSession.Config
    opts = {
      auto_restore = false,
      suppressed_dirs = { "~/", "~/Dev", "~/Downloads", "~/Documents", "~/Desktop/" },
    },
  },

  -- Project root detection + Telescope integration
  {
    "ahmedkhalf/project.nvim",
    opts = {
      detection_methods = { "lsp", "pattern" },
      patterns = { ".git", "package.json", "pyproject.toml", "Cargo.toml", "Makefile" },
    },
    config = function(_, opts)
      require("project_nvim").setup(opts)
      require("telescope").load_extension("projects")
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<leader>fp",
        function()
          require("telescope").extensions.projects.projects()
        end,
        desc = "Switch Project",
      },
    },
  },

  -- Task runner + compiler UI
  {
    "Zeioth/compiler.nvim",
    cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
    dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" },
    opts = {},
  },
  {
    "stevearc/overseer.nvim",
    commit = "6271cab7ccc4ca840faa93f54440ffae3a3918bd",
    cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
    opts = {
      task_list = {
        direction = "bottom",
        min_height = 25,
        max_height = 25,
        default_detail = 1,
      },
    },
  },
}
