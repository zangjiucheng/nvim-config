return {
  -- Visual theme and transparency
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
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
