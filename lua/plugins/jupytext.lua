return {
  "GCBallesteros/jupytext.nvim",
  lazy = false, -- Disable lazy loading to avoid issues with `.ipynb` files
  config = function()
    require("jupytext").setup({
      style = "percent", -- Use percent format (e.g., `# %%` for cells in Python)
      output_extension = "py", -- Convert to `.py` files
      force_ft = "python", -- Treat as Python for syntax highlighting
      custom_language_formatting = {
        python = {
          extension = "py",
          style = "percent",
          force_ft = "python",
        },
      },
    })
  end,
}
