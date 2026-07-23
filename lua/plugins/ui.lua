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
    opts = {},
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
    lazy = false,
    init = function()
      vim.opt.wrap = false
      vim.g.neominimap = {
        auto_enable = true,
        exclude_filetypes = {
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
        },
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
