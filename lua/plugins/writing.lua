-- Grammar checking for prose (LaTeX, Markdown, Typst, commit messages).
--
-- harper-ls is a single Rust binary: no Java, no Node, ~20-40MB resident, and
-- it parses LaTeX natively, so math zones and commands are skipped instead of
-- being flagged as nonsense words.
--
-- Spelling deliberately stays with Neovim's built-in `spell` (switched on for
-- prose buffers in lua/config/autocmds.lua): `zg`/`z=` are faster than a round
-- trip through the LSP, and running both would double-underline every word.
-- harper is left to do grammar and style only.

local prose_filetypes = { "tex", "markdown", "typst", "gitcommit" }

-- harper 2.10 parses `$...$` and `\begin{equation}` correctly, but reads
-- `\( ... \)` and `\[ ... \]` as ordinary prose - so `\sum_{i=1}` reliably
-- trips the "capitalize the pronoun I" linter, and those are exactly the
-- delimiters the `mk`/`dm` snippets produce. VimTeX already knows where the
-- math zones are, so drop any harper diagnostic that lands inside one.
local function drop_math_diagnostics(result, bufnr)
  local items = result and result.diagnostics
  if not items or #items == 0 then
    return
  end
  if not (bufnr and vim.api.nvim_buf_is_loaded(bufnr)) then
    return
  end
  if not vim.tbl_contains({ "tex", "plaintex" }, vim.bo[bufnr].filetype) then
    return
  end

  vim.api.nvim_buf_call(bufnr, function()
    local kept = {}
    for _, diagnostic in ipairs(items) do
      local pos = diagnostic.range and diagnostic.range.start
      local in_math = false
      if pos then
        local ok, res = pcall(vim.fn["vimtex#syntax#in_mathzone"], pos.line + 1, pos.character + 1)
        in_math = ok and res == 1
      end
      if not in_math then
        table.insert(kept, diagnostic)
      end
    end
    result.diagnostics = kept
  end)
end

local function toggle_grammar()
  local buf = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ name = "harper_ls", bufnr = buf })

  if #clients > 0 then
    for _, client in ipairs(clients) do
      -- Clear only harper's diagnostics, not the buffer's LSP diagnostics.
      vim.diagnostic.reset(vim.lsp.diagnostic.get_namespace(client.id), buf)
      vim.lsp.buf_detach_client(buf, client.id)
    end
    vim.notify("Grammar check: off", vim.log.levels.INFO)
  else
    -- nvim-lspconfig no longer ships :LspStart; start from the resolved config
    -- so the buffer picks up the same settings/handlers as a normal attach.
    local ok, err = pcall(vim.lsp.start, vim.lsp.config["harper_ls"])
    if ok then
      vim.notify("Grammar check: on", vim.log.levels.INFO)
    else
      vim.notify("Could not start harper_ls: " .. tostring(err), vim.log.levels.ERROR)
    end
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        harper_ls = {
          -- lspconfig's default list covers every language harper can read
          -- comments in. That is a lot of noise in a code buffer, so restrict
          -- it to documents. Add filetypes here to widen it.
          filetypes = prose_filetypes,
          handlers = {
            ["textDocument/publishDiagnostics"] = function(err, result, ctx, cfg)
              drop_math_diagnostics(result, vim.uri_to_bufnr(result.uri))
              return vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx, cfg)
            end,
          },
          settings = {
            ["harper-ls"] = {
              userDictPath = vim.fn.stdpath("config") .. "/harper-dictionary.txt",
              -- Style notes are suggestions, not build failures: keep them out
              -- of the error/warning tiers so the statusline stays honest.
              diagnosticSeverity = "hint",
              linters = {
                SpellCheck = false,
                SpelledNumbers = false,
                LongSentences = false, -- academic prose sets its own pace
                SentenceCapitalization = true,
                RepeatedWords = true,
                UnclosedQuotes = true,
                Spaces = true,
                AnA = true,
                Matcher = true,
              },
              -- Documented spelling is capitalised; the lowercase form is
              -- silently ignored by the server.
              codeActions = { ForceStable = true },
              dialect = "American",
            },
          },
        },
      },
    },
    keys = {
      { "<leader>Ug", toggle_grammar, desc = "Toggle Grammar Check" },
    },
  },
}
