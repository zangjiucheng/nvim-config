-- LaTeX: VimTeX + latexmk + Skim.
--
-- Division of labour, kept deliberately strict:
--   * latexmk owns compilation *and* dependency tracking (\input, \include,
--     bibliography, graphics). Nothing in this config watches files or
--     recompiles on TextChanged.
--   * VimTeX owns the editor side: SyncTeX, quickfix parsing, TOC, motions.
--   * texlab owns completion only. Its own build/forward-search are switched
--     off below so the two never race over the same .aux/.pdf.

-- Buffer-local <leader>l… aliases for the standard <localleader>l… mappings.
-- Buffer-local on purpose: LazyVim's global <leader>l (":Lazy") keeps working
-- in every other filetype.
local leader_maps = {
  ll = { "<plug>(vimtex-compile)", "Compile (toggle continuous)" },
  lg = { "<plug>(vimtex-compile-ss)", "Compile Once" },
  lv = { "<plug>(vimtex-view)", "View PDF (forward search)" },
  lk = { "<plug>(vimtex-stop)", "Stop Compilation" },
  lK = { "<plug>(vimtex-stop-all)", "Stop All Compilations" },
  le = { "<plug>(vimtex-errors)", "Errors (quickfix)" },
  lo = { "<plug>(vimtex-compile-output)", "Compiler Output" },
  lt = { "<plug>(vimtex-toc-toggle)", "Table of Contents" },
  lc = { "<plug>(vimtex-clean)", "Clean Aux Files" },
  lC = { "<plug>(vimtex-clean-full)", "Clean All (incl. PDF)" },
  lm = { "<plug>(vimtex-context-menu)", "Context Menu" },
  ls = { "<plug>(vimtex-status)", "Compiler Status" },
  li = { "<plug>(vimtex-info)", "Project Info" },
  lr = { "<plug>(vimtex-reverse-search)", "Reverse Search" },
  lx = { "<plug>(vimtex-reload)", "Reload VimTeX" },
}

local function attach_latex_keymaps(buf)
  vim.keymap.set("n", "<leader>l", "<nop>", { buffer = buf, desc = "+latex" })
  for lhs, spec in pairs(leader_maps) do
    vim.keymap.set("n", "<leader>" .. lhs, spec[1], {
      buffer = buf,
      desc = spec[2],
      remap = true, -- <plug> targets need recursive mapping
    })
  end

  local ok, wk = pcall(require, "which-key")
  if ok then
    wk.add({ { "<leader>l", group = "latex", buffer = buf } })
  end
end

-- Visual-mode math surrounds, e.g. select `G = (V,E)` then `gsam` -> `\( G = (V,E) \)`.
-- mini.surround reads vim.b.minisurround_config, so this stays scoped to TeX.
local function attach_surround(buf)
  vim.b[buf].minisurround_config = {
    custom_surroundings = {
      m = { output = { left = "\\( ", right = " \\)" } },
      M = { output = { left = "\\[\n", right = "\n\\]" } },
      c = {
        output = function()
          local name = require("mini.surround").user_input("Command name")
          if not name or name == "" then
            return nil
          end
          return { left = "\\" .. name .. "{", right = "}" }
        end,
      },
    },
  }
end

return {
  {
    "lervag/vimtex",
    -- Never lazy-load this. On startup VimTeX registers this Neovim instance in
    -- ~/.cache/vimtex/nvim_servernames.log; that registry is what the headless
    -- `nvim --headless -c "VimtexInverseSearch …"` process launched by Skim
    -- talks to. Lazy-loading silently breaks inverse search.
    lazy = false,
    init = function()
      -- Compiler -------------------------------------------------------------
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        continuous = 1, -- latexmk -pvc: it watches dependencies, we don't
        callback = 1,
        hooks = {},
        options = {
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }

      -- Viewer ---------------------------------------------------------------
      -- Skim, driven through VimTeX's JXA bridge (no hardcoded app path, so the
      -- nix-installed /Applications/Nix Apps/Skim.app is found fine).
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_automatic = 1 -- open the PDF after the first build
      vim.g.vimtex_view_skim_sync = 1 -- forward-search after every build
      vim.g.vimtex_view_skim_activate = 0 -- but keep keyboard focus in Neovim
      vim.g.vimtex_view_skim_reading_bar = 1
      vim.g.vimtex_view_reverse_search_edit_cmd = "edit"

      -- Quickfix -------------------------------------------------------------
      -- Errors open the list without stealing the cursor; warnings never do.
      -- A LaTeX run emits warnings constantly, and a popping quickfix window
      -- mid-sentence is exactly the VS Code behaviour we are getting away from.
      vim.g.vimtex_quickfix_mode = 2
      vim.g.vimtex_quickfix_open_on_warning = 0
      vim.g.vimtex_quickfix_ignore_filters = {
        "Underfull \\\\hbox",
        "Overfull \\\\hbox",
        "LaTeX Font Warning",
        "Package hyperref Warning",
      }

      -- Editor ---------------------------------------------------------------
      -- VimTeX's own insert-mode imaps (`a -> \alpha) are switched off: LuaSnip
      -- covers the same ground (see lua/snippets/tex.lua), and leaving them on
      -- puts a timeout on every literal backtick.
      vim.g.vimtex_imaps_enabled = 0
      vim.g.vimtex_toc_config = {
        split_pos = "vert rightbelow",
        split_width = 40,
        show_help = 0,
        hotkeys_enabled = 1,
      }
      vim.g.vimtex_fold_enabled = 0 -- nvim-ufo already provides folding
      vim.g.vimtex_indent_on_ampersands = 0 -- keep align blocks from jumping

      local group = vim.api.nvim_create_augroup("LatexWorkflow", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "tex", "plaintex", "bib" },
        callback = function(args)
          attach_latex_keymaps(args.buf)
          attach_surround(args.buf)
        end,
      })
    end,
  },

  -- texlab: completion only. VimTeX/latexmk keep exclusive ownership of builds.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        texlab = {
          settings = {
            texlab = {
              build = { onSave = false, forwardSearchAfter = false },
              forwardSearch = { executable = nil, args = {} },
              -- chktex on every keystroke is the kind of per-edit process we
              -- are explicitly avoiding; latexmk already reports real errors.
              chktex = { onOpenAndSave = false, onEdit = false },
              diagnosticsDelay = 300,
              latexFormatter = "latexindent",
              latexindent = { modifyLineBreaks = false },
            },
          },
        },
      },
    },
  },

  -- Completion in TeX: useful for \cite/\ref/\begin/commands, silent otherwise.
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        providers = {
          snippets = {
            -- In LaTeX a leading backslash means "I am typing a command", which
            -- is texlab's job. Snippet triggers are typed WITHOUT one (`enum`,
            -- `thm`, `pmat`). Offering them after a `\\` produces
            -- `\\\\begin{enumerate}`: blink's keyword boundary stops at the
            -- backslash, so accepting leaves the one you typed behind.
            enabled = function()
              if not vim.tbl_contains({ "tex", "plaintex", "bib" }, vim.bo.filetype) then
                return true
              end
              local before = vim.api.nvim_get_current_line():sub(1, vim.fn.col(".") - 1)
              return before:match("\\%a*$") == nil
            end,
          },
        },
      },
      completion = {
        menu = {
          auto_show = function()
            if not vim.tbl_contains({ "tex", "plaintex", "bib" }, vim.bo.filetype) then
              return true
            end
            -- Only offer completion where texlab actually has something to say:
            -- after a backslash command, or inside a command's {…} argument
            -- (\cite{, \ref{, \begin{, …). Prose and math never open the menu.
            local before = vim.api.nvim_get_current_line():sub(1, vim.fn.col(".") - 1)
            return before:match("\\%a*$") ~= nil or before:match("\\%a+%*?{[^}]*$") ~= nil
          end,
        },
      },
    },
  },
}
