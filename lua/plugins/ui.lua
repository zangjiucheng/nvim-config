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
  { "sitiom/nvim-numbertoggle" },
}
