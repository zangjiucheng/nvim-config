-- Typst. Kept deliberately separate from the LaTeX setup: Typst has its own
-- incremental compiler and its own preview protocol, and none of VimTeX's
-- SyncTeX machinery applies to it.
--
-- Tinymist (LSP) and typst-preview.nvim both come from LazyVim's
-- `lang.typst` extra; this file only adds the optional PDF-on-disk workflow.
return {
  {
    "chomosuke/typst-preview.nvim",
    optional = true,
    keys = {
      {
        -- `typst watch` writes a real PDF next to the source, which Skim (or
        -- Galley) auto-reloads. Use this when you need the actual PDF; the
        -- extra's <leader>cp live preview is lower latency for pure drafting.
        "<leader>cw",
        function()
          local file = vim.api.nvim_buf_get_name(0)
          if not file:match("%.typ$") then
            vim.notify("Not a Typst file", vim.log.levels.WARN)
            return
          end
          Snacks.terminal({ "typst", "watch", file }, {
            cwd = vim.fs.dirname(file),
            win = { position = "bottom", height = 0.25 },
          })
        end,
        ft = "typst",
        desc = "Typst Watch (PDF)",
      },
    },
  },
}
