return {
  -- Move through the completion menu with Ctrl+j / Ctrl+k (vim-style j/k;
  -- plain j/k must stay literal text in insert mode). Arrows and <C-n>/<C-p>
  -- keep working. <C-k> was blink's signature-help toggle: that still happens
  -- when no menu is open.
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      keymap = {
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "show_signature", "hide_signature", "fallback" },
      },
    },
  },

  -- LSP/treesitter-aware folding with a fold preview (VS Code-style)
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "VeryLazy",
    init = function()
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    opts = {
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
    },
    keys = {
      {
        "zR",
        function()
          require("ufo").openAllFolds()
        end,
        desc = "Open All Folds",
      },
      {
        "zM",
        function()
          require("ufo").closeAllFolds()
        end,
        desc = "Close All Folds",
      },
      {
        "zK",
        function()
          local winid = require("ufo").peekFoldedLinesUnderCursor()
          if not winid then
            vim.lsp.buf.hover()
          end
        end,
        desc = "Peek Fold / Hover",
      },
    },
  },
}
