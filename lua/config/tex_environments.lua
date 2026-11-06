-- Environment shortcuts complement texlab's command and \begin{} completion.
local source = {}
source.__index = source

local environments = {
  "align", "align*", "aligned", "equation", "equation*", "gather", "gather*", "gathered",
  "multline", "multline*", "split", "cases", "matrix", "pmatrix", "bmatrix", "Bmatrix",
  "vmatrix", "Vmatrix", "enumerate", "itemize", "description", "center", "quote",
  "theorem", "lemma", "proposition", "corollary", "definition", "example", "remark", "proof",
  "minipage", "figure", "figure*", "table", "table*", "tabular", "tabular*", "tabularx",
  "subfigure", "abstract", "verbatim", "lstlisting", "minted", "frame", "columns", "column",
  "block", "flushleft", "flushright", "quotation", "array", "smallmatrix", "alignat",
  "alignat*", "flalign", "flalign*", "tikzpicture", "algorithm", "algorithmic", "document",
}

-- Text inserted right after \begin{env} for environments with required (or
-- almost always wanted) arguments. Tabstops start at ${1}; the body gets the
-- next one.
local args = {
  minipage = "{${1:0.45\\\\textwidth}}",
  figure = "[${1:htbp}]",
  ["figure*"] = "[${1:htbp}]",
  table = "[${1:htbp}]",
  ["table*"] = "[${1:htbp}]",
  tabular = "{${1:ll}}",
  ["tabular*"] = "{${1:\\\\textwidth}}{${2:ll}}",
  tabularx = "{${1:\\\\textwidth}}{${2:lX}}",
  subfigure = "{${1:0.45\\\\textwidth}}",
  array = "{${1:cc}}",
  alignat = "{${1:2}}",
  ["alignat*"] = "{${1:2}}",
  minted = "{${1:python}}",
  column = "{${1:0.5\\\\textwidth}}",
  frame = "{${1:Title}}",
  block = "{${1:Title}}",
}

-- Environments the buffer already uses or defines (\newenvironment,
-- \newtheorem, …), so project-specific ones complete too.
local function buffer_environments()
  local found = {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    for name in line:gmatch("\\begin%s*{([%a@]+%*?)}") do
      found[name] = true
    end
    for name in line:gmatch("\\new%a*environment%*?%s*{\\?([%a@]+%*?)}") do
      found[name] = true
    end
    for name in line:gmatch("\\newtheorem%*?%s*{([%a@]+%*?)}") do
      found[name] = true
    end
  end
  return found
end

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
    local candidates, seen = {}, {}
    for _, env in ipairs(environments) do
      seen[env] = true
      table.insert(candidates, env)
    end
    for env in pairs(buffer_environments()) do
      if not seen[env] then
        table.insert(candidates, env)
      end
    end
    for _, env in ipairs(candidates) do
      if env:sub(1, #prefix) == prefix then
        local arg = args[env] or ""
        local n = 1
        for _ in arg:gmatch("%${%d") do
          n = n + 1
        end
        local item = (env == "itemize" or env == "enumerate" or env == "description") and "\\item " or ""
        local body = ("\\begin{%s}%s\n\t%s${%d}\n\\end{%s}$0"):format(env, arg, item, n, env)
        table.insert(items, {
          label = env,
          kind = vim.lsp.protocol.CompletionItemKind.Snippet,
          insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
          detail = ("\\begin{%s} … \\end{%s}"):format(env, env),
          documentation = { kind = "markdown", value = "```latex\n" .. body:gsub("%${%d+:([^}]*)}", "%1"):gsub("\\\\", "\\"):gsub("%${%d+}", ""):gsub("%$0", "") .. "\n```" },
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
