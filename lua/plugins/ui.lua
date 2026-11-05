-- Filetypes where the VS Code-style chrome is switched off, so a document
-- reads like a document. Window-local options for the same buffers live in
-- lua/config/autocmds.lua.
local prose_filetypes = { "tex", "plaintex", "bib", "typst", "markdown" }

return {
  -- Visual theme with solid panels
  {
    "folke/tokyonight.nvim",
    opts = function(_, opts)
      opts.transparent = false
      opts.styles = vim.tbl_deep_extend("force", opts.styles or {}, {
        sidebars = "dark",
        floats = "dark",
      })

      local existing = opts.on_highlights
      opts.on_highlights = function(hl, colors)
        if existing then
          existing(hl, colors)
        end

        local panel_bg = colors.bg_dark
        local panel_border = colors.blue1
        local panel_alt = colors.bg_highlight

        -- Rulers at 80/120 as a stripe *darker* than the background, so it
        -- reads as a recessed guide rather than a highlighted column. Defined
        -- here rather than in a BufReadPost autocmd, which re-set a global
        -- highlight on every file open and lost to the theme on reload.
        hl.ColorColumn = { bg = colors.bg_dark1 }

        -- Visible math boundaries, distinct from both prose and parentheses
        -- inside a formula. VimTeX links \(...\), \[...\], $ and $$ here.
        hl.texMathDelimZone = { fg = colors.cyan, bold = true }

        hl.NormalFloat = { bg = panel_bg, fg = colors.fg }
        hl.FloatBorder = { bg = panel_bg, fg = panel_border }
        hl.FloatTitle = { bg = panel_bg, fg = panel_border, bold = true }
        hl.Pmenu = { bg = panel_bg }
        hl.PmenuSel = { bg = panel_alt }
        hl.PmenuSbar = { bg = colors.bg_sidebar }
        hl.PmenuThumb = { bg = colors.fg_gutter }
        hl.TelescopeNormal = { bg = panel_bg, fg = colors.fg }
        hl.TelescopeBorder = { bg = panel_bg, fg = panel_border }
        hl.WhichKeyFloat = { bg = panel_bg }
        hl.WhichKeyBorder = { bg = panel_bg, fg = panel_border }
        hl.BlinkCmpMenu = { bg = panel_bg }
        hl.BlinkCmpMenuBorder = { bg = panel_bg, fg = panel_border }
        hl.BlinkCmpDoc = { bg = panel_bg }
        hl.BlinkCmpDocBorder = { bg = panel_bg, fg = panel_border }
        hl.BlinkCmpSignatureHelp = { bg = panel_bg }
        hl.BlinkCmpSignatureHelpBorder = { bg = panel_bg, fg = panel_border }
        hl.NoiceCmdlinePopup = { bg = panel_bg }
        hl.NoiceCmdlinePopupBorder = { bg = panel_bg, fg = panel_border }
        hl.NoicePopup = { bg = panel_bg }
        hl.NoicePopupBorder = { bg = panel_bg, fg = panel_border }
        hl.NeoTreeNormal = { bg = panel_bg }
        hl.NeoTreeNormalNC = { bg = panel_bg }
        hl.NeoTreeFloatNormal = { bg = panel_bg }
        hl.NeoTreeFloatBorder = { bg = panel_bg, fg = panel_border }
        hl.TroubleNormal = { bg = panel_bg }
        hl.TroubleNormalNC = { bg = panel_bg }
        hl.AerialNormal = { bg = panel_bg }
        hl.AerialNormalNC = { bg = panel_bg }
        hl.AerialBorder = { bg = panel_bg, fg = panel_border }
        hl.AerialLine = { bg = panel_alt }
        hl.DapUIFloatNormal = { bg = panel_bg }
        hl.DapUIFloatBorder = { bg = panel_bg, fg = panel_border }
        -- AI ghost text. Tokyonight's own CopilotSuggestion is #444a73, which
        -- is darker than both Comment and NonText and nearly invisible on the
        -- moon background. fg_dark stays clearly secondary but is actually
        -- readable; italic keeps a suggestion distinguishable from real text.
        -- Raise to colors.fg if you want it brighter still.
        local ghost = { fg = colors.fg_dark, italic = true }
        hl.CopilotSuggestion = ghost
        hl.CopilotAnnotation = ghost
        hl.BlinkCmpGhostText = ghost

        hl.CopilotChatHeader = { fg = colors.blue1, bold = true }
        hl.CopilotChatSeparator = { fg = panel_border }
        hl.CopilotChatHelp = { fg = colors.fg_gutter }
      end
    end,
  },

  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.presets = vim.tbl_deep_extend("force", opts.presets or {}, {
        lsp_doc_border = true,
      })
    end,
  },

  -- Cursor animation and trail
  {
    "gen740/SmoothCursor.nvim",
    config = function()
      require("smoothcursor").setup({
        type = "default",
        cursor = "",
        texthl = "SmoothCursor",
        linehl = nil,
        fancy = {
          enable = true,
          head = { cursor = "▷", texthl = "SmoothCursor", linehl = nil },
          body = {
            { cursor = "󰝥", texthl = "SmoothCursorYellow" },
            { cursor = "󰝥", texthl = "SmoothCursorYellow" },
            { cursor = "●", texthl = "SmoothCursorYellow" },
            { cursor = "●", texthl = "SmoothCursorYellow" },
            { cursor = "•", texthl = "SmoothCursorYellow" },
            { cursor = ".", texthl = "SmoothCursorYellow" },
            { cursor = ".", texthl = "SmoothCursorYellow" },
          },
          tail = { cursor = nil, texthl = "SmoothCursor" },
        },
        autostart = true,
        always_redraw = true,
        flyin_effect = nil,
        speed = 25,
        intervals = 35,
        priority = 10,
        timeout = 3000,
        threshold = 3,
        max_threshold = nil,
        disable_float_win = false,
        enabled_filetypes = nil,
        disabled_filetypes = nil,
        show_last_positions = nil,
      })
    end,
  },

  -- Mode-aware line accent
  {
    "mvllow/modes.nvim",
    tag = "v0.2.0",
    config = function()
      require("modes").setup()
    end,
  },

  -- Toggle between relative and absolute numbers when switching modes
  { "sitiom/nvim-numbertoggle", event = "VeryLazy" },

  -- Breadcrumbs: VS Code-style "file > Class > method" winbar
  {
    "Bekaboo/dropbar.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      -- Grab dropbar's own default guard before setup merges ours on top of it,
      -- so special buffers (help, terminals, huge files) stay excluded too.
      local default_enable = require("dropbar.configs").opts.bar.enable
      opts.bar = vim.tbl_deep_extend("force", opts.bar or {}, {
        enable = function(buf, win, info)
          buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
          if not vim.api.nvim_buf_is_valid(buf) then
            return false
          end
          if vim.tbl_contains(prose_filetypes, vim.bo[buf].filetype) then
            return false
          end
          return default_enable(buf, win, info)
        end,
      })
    end,
    keys = {
      {
        "<leader>cb",
        function()
          require("dropbar.api").pick()
        end,
        desc = "Pick Breadcrumb",
      },
    },
  },

  -- Sticky scroll: pin the current function/class header to the top
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    opts = {
      max_lines = 3,
      multiline_threshold = 1,
      trim_scope = "outer",
      mode = "cursor",
      separator = nil,
      on_attach = function(buf)
        return not vim.tbl_contains(prose_filetypes, vim.bo[buf].filetype)
      end,
    },
    keys = {
      {
        "<leader>Us",
        function()
          require("treesitter-context").toggle()
        end,
        desc = "Toggle Sticky Scroll",
      },
    },
  },

  -- Inline color swatches for hex/rgb/hsl/named/tailwind colors
  {
    "brenoprata10/nvim-highlight-colors",
    event = "VeryLazy",
    opts = {
      render = "virtual",
      virtual_symbol = "■",
      virtual_symbol_position = "inline",
      virtual_symbol_prefix = " ",
      virtual_symbol_suffix = "",
      enable_named_colors = true,
      enable_tailwind = true,
    },
    keys = {
      { "<leader>Uc", "<cmd>HighlightColors Toggle<cr>", desc = "Toggle Color Swatches" },
    },
  },

  -- Smooth scrolling through the already-present snacks.nvim
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.scroll = vim.tbl_deep_extend("force", opts.scroll or {}, { enabled = true })
    end,
  },

  -- Minimap: VS Code-style code overview with git/diagnostic markers
  {
    "Isrothy/neominimap.nvim",
    version = "v3.x.x",
    -- Off by default: it eats a column of the window and is only occasionally
    -- wanted. Loading on the command keeps its ~3.5ms plugin file out of
    -- startup entirely; `init` still runs eagerly, so the config below applies.
    cmd = "Neominimap",
    init = function()
      vim.opt.wrap = false
      vim.g.neominimap = {
        -- Nothing is lost by starting disabled: the api's enable() creates the
        -- autocmds itself, and the initial enabled state is read from this, so
        -- the first <leader>Um toggles ON rather than off.
        auto_enable = false,
        exclude_filetypes = vim.list_extend(vim.deepcopy(prose_filetypes), {
          "help",
          "neo-tree",
          "aerial",
          "Trouble",
          "trouble",
          "OverseerList",
          "copilot-chat",
          "dap-repl",
          "dapui_scopes",
          "dapui_stacks",
          "dapui_watches",
          "dapui_console",
        }),
        exclude_buftypes = {
          "nofile",
          "nowrite",
          "quickfix",
          "terminal",
          "prompt",
        },
      }
    end,
    keys = {
      { "<leader>Um", "<cmd>Neominimap Toggle<cr>", desc = "Toggle Minimap" },
    },
  },
}
