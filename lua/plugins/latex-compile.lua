return {
  {
    "lervag/vimtex",
    ft = { "tex" },
    init = function()
      -- Set the PDF viewer (macOS example: Skim; Linux: Zathura; Windows: SumatraPDF)
      vim.g.vimtex_view_method = "skim"   -- or "skim" / "sioyek" / "sumatrapdf"
      -- Continuous compilation with latexmk
      vim.g.vimtex_compiler_method = "latexmk"
    end,
  },
}

