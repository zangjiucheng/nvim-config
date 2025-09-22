return {
  -- project root detection
  {
    "ahmedkhalf/project.nvim",
    opts = {
      detection_methods = { "lsp", "pattern" },
      patterns = { ".git", "package.json", "pyproject.toml", "Cargo.toml", "Makefile" },
    },
    config = function(_, opts)
      require("project_nvim").setup(opts)
      -- integrate with telescope
      require("telescope").load_extension("projects")
    end,
  },

  -- telescope keymap for switching projects
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
}
