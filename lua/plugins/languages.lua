return {
  -- Python helpers
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap-python" },
    opts = {},
    event = "VeryLazy",
    keys = {
      { "<leader>vs", "<cmd>VenvSelect<cr>" },
    },
  },
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    config = function()
      require("jupytext").setup({
        style = "percent",
        output_extension = "py",
        force_ft = "python",
        custom_language_formatting = {
          python = {
            extension = "py",
            style = "percent",
            force_ft = "python",
          },
        },
      })
    end,
  },

  -- LaTeX tooling
  {
    "lervag/vimtex",
    ft = { "tex" },
    init = function()
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_compiler_method = "latexmk"
    end,
  },
}
