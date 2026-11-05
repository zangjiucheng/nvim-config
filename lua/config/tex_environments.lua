-- Environment shortcuts complement texlab's command and \begin{} completion.
local source = {}
source.__index = source

local environments = {
  "align", "align*", "aligned", "equation", "equation*", "gather", "gather*", "gathered",
  "multline", "multline*", "split", "cases", "matrix", "pmatrix", "bmatrix", "Bmatrix",
  "vmatrix", "Vmatrix", "enumerate", "itemize", "description", "center", "quote",
  "theorem", "lemma", "proposition", "corollary", "definition", "example", "remark", "proof",
}

function source.new()
  return setmetatable({}, source)
end

function source:enabled()
  return vim.bo.filetype == "tex" or vim.bo.filetype == "plaintex"
end

function source:get_trigger_characters()
  return { "\\" }
end

function source:get_completions(ctx, callback)
  local items = {}
  -- Blink uses Neovim cursor coordinates: row is 1-based, byte column 0-based.
  local before = ctx.line:sub(1, ctx.cursor[2])
  local start, prefix = before:match("()\\(%a+%*?)$")
  local excluded = false
  for _, zone in ipairs({ "texComment", "texVerb", "texZone" }) do
    local ok, inside = pcall(vim.fn["vimtex#syntax#in"], zone)
    excluded = excluded or (ok and inside == 1)
  end
  if self:enabled() and start and before:sub(start - 1, start - 1) ~= "\\" and not excluded then
    for _, env in ipairs(environments) do
      if env:sub(1, #prefix) == prefix then
        local body = ("\\begin{%s}\n\t${1}\n\\end{%s}$0"):format(env, env)
        if env == "itemize" or env == "enumerate" or env == "description" then
          body = ("\\begin{%s}\n\t\\item ${1}\n\\end{%s}$0"):format(env, env)
        end
        table.insert(items, {
          label = env,
          kind = vim.lsp.protocol.CompletionItemKind.Snippet,
          insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
          detail = ("\\begin{%s} … \\end{%s}"):format(env, env),
          documentation = { kind = "markdown", value = "```latex\n" .. body:gsub("%${1}", ""):gsub("%$0", "") .. "\n```" },
          textEdit = {
            -- Include the backslash so accepting never produces \\begin.
            range = {
              start = { line = ctx.cursor[1] - 1, character = start - 1 },
              ["end"] = { line = ctx.cursor[1] - 1, character = ctx.cursor[2] },
            },
            newText = body,
          },
        })
      end
    end
  end
  callback({ items = items, is_incomplete_forward = true, is_incomplete_backward = true })
end

return source
