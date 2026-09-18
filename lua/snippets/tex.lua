-- LaTeX snippets for fast mathematical writing.
--
-- Three families, with deliberately different trigger behaviour:
--
--   1. Math autosnippets  - expand the instant the trigger is typed, but ONLY
--                           inside a real math zone (VimTeX syntax detection).
--   2. Text autosnippets  - `mk`/`dm`, the two ways into math. Prose only.
--   3. Structural snippets - environments. Explicit <Tab> only, never automatic,
--                           so `\def`, `item`, `proof` etc. stay typeable.
--
-- Every snippet is additionally blocked after a backslash, so typing `\int`,
-- `\sum`, `\deg` by hand never double-expands.

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local rep = require("luasnip.extras").rep
local fmta = require("luasnip.extras.fmt").fmta

-- Zone detection -------------------------------------------------------------

local function vimtex_bool(fn, ...)
  local ok, res = pcall(vim.fn[fn], ...)
  return ok and res == 1
end

-- Comments, \verb, and verbatim/lstlisting/minted zones (texZone*) are always
-- off limits: nothing should rewrite what the reader is meant to see verbatim.
local function in_excluded_zone()
  return vimtex_bool("vimtex#syntax#in", "texComment")
    or vimtex_bool("vimtex#syntax#in", "texVerb")
    or vimtex_bool("vimtex#syntax#in", "texZone")
end

-- vimtex#syntax#in_mathzone() already treats \text{…} and \ref{…} as NOT math,
-- which is exactly what we want.
local function in_math()
  return vimtex_bool("vimtex#syntax#in_mathzone") and not in_excluded_zone()
end

local function in_prose()
  return not in_math() and not in_excluded_zone()
end

local function not_after_backslash(line_to_cursor, matched_trigger)
  local before = line_to_cursor:sub(1, #line_to_cursor - #(matched_trigger or ""))
  return before:sub(-1) ~= "\\"
end

local function math_cond(line_to_cursor, matched_trigger)
  return in_math() and not_after_backslash(line_to_cursor, matched_trigger)
end

local function prose_cond(line_to_cursor, matched_trigger)
  return in_prose() and not_after_backslash(line_to_cursor, matched_trigger)
end

local function tex_cond(line_to_cursor, matched_trigger)
  return not in_excluded_zone() and not_after_backslash(line_to_cursor, matched_trigger)
end

-- Builders -------------------------------------------------------------------

-- luasnip.loaders.from_lua expects `return snippets, autosnippets`, so the two
-- kinds are tracked as they are built rather than sniffed afterwards.
local auto_set = {}

local function mark_auto(snip)
  auto_set[snip] = true
  return snip
end

---Auto-expanding, math zones only.
local function am(trig, nodes, opts)
  opts = opts or {}
  return mark_auto(
    s(
      { trig = trig, snippetType = "autosnippet", wordTrig = opts.word ~= false, priority = 1100 },
      nodes,
      { condition = math_cond, show_condition = in_math }
    )
  )
end

---Auto-expanding, prose only (the two entry points into math).
local function ap(trig, nodes)
  return mark_auto(
    s(
      { trig = trig, snippetType = "autosnippet", priority = 1100 },
      nodes,
      { condition = prose_cond, show_condition = in_prose }
    )
  )
end

---<Tab>-triggered anywhere in a TeX buffer except comments/verbatim.
---
---The trigger is a Lua pattern with an optional leading backslash, because in
---LaTeX your hand reaches for `\\` first and these names (cases, align,
---theorem, pmatrix, ...) are environments rather than commands. Matching the
---backslash means it is *replaced* rather than left in front of the expansion.
---wordTrig stays on: without it `\\pmat` would match the `mat` trigger midway
---through and expand to `\\p\\begin{matrix}`. The priority bump outranks
---friendly-snippets' own LaTeX pack, which registers plain triggers like `ali`
---that would otherwise win and leave the backslash behind.
local function tb(trig, nodes)
  return s(
    { trig = "\\?" .. trig, regTrig = true, priority = 1100 },
    nodes,
    -- No backslash guard here: the pattern above consumes it deliberately.
    {
      condition = function()
        return not in_excluded_zone()
      end,
    }
  )
end

---Optional `[name]` argument: first choice is empty (the common case),
---<C-l> cycles to the named variant.
local function opt_arg(index)
  return c(index, {
    t(""),
    sn(nil, { t("["), i(1), t("]") }),
  })
end

local M = {}

-- 1. Entering math -----------------------------------------------------------

vim.list_extend(M, {
  ap("mk", fmta("\\( <> \\)<>", { i(1), i(0) })),
  ap(
    "dm",
    fmta(
      [[
\[
  <>
\]
]],
      { i(1) }
    )
  ),
})

-- 2. Math autosnippets -------------------------------------------------------

vim.list_extend(M, {
  -- Fractions, roots, big operators
  am("ff", fmta("\\frac{<>}{<>}", { i(1), i(2) })),
  am("sr", fmta("\\sqrt{<>}", { i(1) })),
  am("sum", fmta("\\sum_{<>}^{<>}", { i(1, "i=1"), i(2, "n") })),
  am("prod", fmta("\\prod_{<>}^{<>}", { i(1, "i=1"), i(2, "n") })),
  am("int", fmta("\\int_{<>}^{<>}", { i(1, "a"), i(2, "b") })),
  am("lim", fmta("\\lim_{<> \\to <>}", { i(1, "n"), i(2, "\\infty") })),

  -- Delimiters and font switches
  am("abs", fmta("\\lvert <> \\rvert", { i(1) })),
  am("norm", fmta("\\lVert <> \\rVert", { i(1) })),
  am("set", fmta("\\{ <> \\}", { i(1) })),
  am("txt", fmta("\\text{<>}", { i(1) })),
  am("bb", fmta("\\mathbb{<>}", { i(1) })),
  am("bf", fmta("\\mathbf{<>}", { i(1) })),
  am("cal", fmta("\\mathcal{<>}", { i(1) })),
})

-- Number sets, logic, relations. Triggers are chosen so that none is a prefix
-- of another - an autosnippet fires the moment its trigger matches, so a
-- shorter trigger would make a longer one unreachable.
local symbols = {
  RR = "\\mathbb{R}",
  NN = "\\mathbb{N}",
  ZZ = "\\mathbb{Z}",
  QQ = "\\mathbb{Q}",
  CC = "\\mathbb{C}",
  FF = "\\mathbb{F}",
  OO = "\\mathcal{O}",
  AA = "\\forall",
  EE = "\\exists",
  inn = "\\in",
  nin = "\\notin",
  sbt = "\\subset",
  sbe = "\\subseteq",
  spt = "\\supset",
  spe = "\\supseteq",
  cup = "\\cup",
  cap = "\\cap",
  smi = "\\setminus",
  iff = "\\iff",
  imp = "\\implies",
  leq = "\\leq",
  geq = "\\geq",
  neq = "\\neq",
  inf = "\\infty",
  ese = "\\emptyset",
  xx = "\\times",
  mto = "\\mapsto",
  ooo = "\\circ",
  lll = "\\ell",
  ddd = "\\cdot",
  dts = "\\dots",
}

for trig, out in pairs(symbols) do
  table.insert(M, am(trig, t(out)))
end

-- Symbol triggers: typed as operators, so word boundaries do not apply.
-- `!=` is deliberately absent - it would rewrite `n!=0` (factorial) as `n\neq 0`.
for trig, out in pairs({ ["<="] = "\\leq", [">="] = "\\geq", ["->"] = "\\to" }) do
  table.insert(M, am(trig, t(out), { word = false }))
end

-- Greek. `;` prefix, one keystroke per letter.
-- Note: `;p` is \phi as requested, so \pi takes `;i` (iota is rare enough in
-- practice that this is the cheaper collision to accept).
local greek = {
  a = "alpha",
  b = "beta",
  g = "gamma",
  d = "delta",
  e = "epsilon",
  v = "varepsilon",
  z = "zeta",
  h = "eta",
  t = "theta",
  i = "pi",
  k = "kappa",
  l = "lambda",
  m = "mu",
  n = "nu",
  x = "xi",
  p = "phi",
  f = "varphi",
  r = "rho",
  s = "sigma",
  u = "upsilon",
  c = "chi",
  y = "psi",
  w = "omega",
}

-- Only these have real uppercase commands in LaTeX; \Alpha and friends do not exist.
local greek_upper = {
  G = "Gamma",
  D = "Delta",
  T = "Theta",
  L = "Lambda",
  X = "Xi",
  I = "Pi",
  S = "Sigma",
  U = "Upsilon",
  P = "Phi",
  Y = "Psi",
  W = "Omega",
}

for key, name in pairs(vim.tbl_extend("error", greek, greek_upper)) do
  table.insert(M, am(";" .. key, t("\\" .. name), { word = false }))
end

-- 3. Graph theory / combinatorics (explicit <Tab>) ---------------------------

vim.list_extend(M, {
  tb("graph", fmta("<> = (<>, <>)", { i(1, "G"), i(2, "V"), i(3, "E") })),
  tb("vertices", fmta("V(<>)", { i(1, "G") })),
  tb("edges", fmta("E(<>)", { i(1, "G") })),
  tb("deg", fmta("\\deg_{<>}(<>)", { i(1, "G"), i(2, "v") })),
  tb("nbhd", fmta("N_{<>}(<>)", { i(1, "G"), i(2, "v") })),
  tb("complete", fmta("K_{<>}", { i(1, "n") })),
  tb("path", fmta("P_{<>}", { i(1, "n") })),
  tb("cycle", fmta("C_{<>}", { i(1, "n") })),
  tb("bigo", fmta("\\mathcal{O}(<>)", { i(1) })),
  tb("binom", fmta("\\binom{<>}{<>}", { i(1, "n"), i(2, "k") })),
  tb("lbl", fmta("\\label{<>}", { i(1) })),
  tb("ref", fmta("\\Cref{<>}", { i(1) })),
  tb("cite", fmta("\\cite{<>}", { i(1) })),
})

-- 4. Structural environments (explicit <Tab>) --------------------------------

-- amsthm-style environments, all with an optional [name] via <C-l>.
local theorem_like = {
  thm = "theorem",
  lem = "lemma",
  prop = "proposition",
  cor = "corollary",
  dfn = "definition",
  exa = "example",
  rmk = "remark",
  clm = "claim",
  prf = "proof",
}

for trig, env in pairs(theorem_like) do
  table.insert(
    M,
    tb(
      trig,
      fmta(
        [[
\begin{<>}<>
  <>
\end{<>}
]],
        { t(env), opt_arg(1), i(2), t(env) }
      )
    )
  )
end

-- Plain environments: body is the only field.
local plain_envs = {
  eq = "equation",
  eqs = "equation*",
  ali = "align",
  alis = "align*",
  gat = "gather",
  gats = "gather*",
  mat = "matrix",
  pmat = "pmatrix",
  bmat = "bmatrix",
  Bmat = "Bmatrix",
  vmat = "vmatrix",
  cas = "cases",
  cent = "center",
  quot = "quote",
  frame = "frame",
}

for trig, env in pairs(plain_envs) do
  table.insert(
    M,
    tb(
      trig,
      fmta(
        [[
\begin{<>}
  <>
\end{<>}
]],
        { t(env), i(1), t(env) }
      )
    )
  )
end

vim.list_extend(M, {
  -- Generic environment; the \end{} mirrors what you type in \begin{}.
  tb(
    "beg",
    fmta(
      [[
\begin{<>}
  <>
\end{<>}
]],
      { i(1), i(2), rep(1) }
    )
  ),

  tb(
    "enum",
    fmta(
      [[
\begin{enumerate}
  \item <>
\end{enumerate}
]],
      { i(1) }
    )
  ),

  tb(
    "item",
    fmta(
      [[
\begin{itemize}
  \item <>
\end{itemize}
]],
      { i(1) }
    )
  ),

  tb("it", fmta("\\item <>", { i(1) })),

  -- cases gets real rows; this is the one place manual brace-walking hurts most.
  tb(
    "cases",
    fmta(
      [[
\begin{cases}
  <> & \text{if } <> \\
  <> & \text{otherwise}
\end{cases}
]],
      { i(1), i(2), i(3) }
    )
  ),

  -- Sectioning
  tb("sec", fmta("\\section{<>}", { i(1) })),
  tb("ssec", fmta("\\subsection{<>}", { i(1) })),
  tb("sssec", fmta("\\subsubsection{<>}", { i(1) })),
})

local snippets, autosnippets = {}, {}
for _, snip in ipairs(M) do
  table.insert(auto_set[snip] and autosnippets or snippets, snip)
end

return snippets, autosnippets
