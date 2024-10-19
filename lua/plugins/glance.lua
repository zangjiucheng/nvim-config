-- ~/.config/nvim/lua/plugins/glance.lua
return {
  "DNLHC/glance.nvim", -- Plugin repository
  config = function()
    local glance = require("glance")
    local actions = glance.actions

    glance.setup({
      height = 18, -- Height of the window
      zindex = 45,

      -- Detached mode configuration
      detached = function(winid)
        return vim.api.nvim_win_get_width(winid) < 100
      end,

      preview_win_opts = { -- Configure preview window options
        cursorline = true,
        number = true,
        wrap = true,
      },

      border = {
        enable = false, -- Disable borders
        top_char = "―",
        bottom_char = "―",
      },

      list = {
        position = "right", -- Place the list window to the right
        width = 0.33, -- Takes up 33% of the active window's width
      },

      theme = {
        enable = true, -- Enable theme-based colors
        mode = "auto", -- Auto-detect brightness and set the mode accordingly
      },

      mappings = {
        list = {
          ["j"] = actions.next,
          ["k"] = actions.previous,
          ["<Down>"] = actions.next,
          ["<Up>"] = actions.previous,
          ["<Tab>"] = actions.next_location,
          ["<S-Tab>"] = actions.previous_location,
          ["<C-u>"] = actions.preview_scroll_win(5),
          ["<C-d>"] = actions.preview_scroll_win(-5),
          ["v"] = actions.jump_vsplit,
          ["s"] = actions.jump_split,
          ["t"] = actions.jump_tab,
          ["<CR>"] = actions.jump,
          ["o"] = actions.jump,
          ["l"] = actions.open_fold,
          ["h"] = actions.close_fold,
          ["<leader>l"] = actions.enter_win("preview"), -- Focus preview window
          ["q"] = actions.close,
          ["Q"] = actions.close,
          ["<Esc>"] = actions.close,
          ["<C-q>"] = actions.quickfix,
        },
        preview = {
          ["Q"] = actions.close,
          ["<Tab>"] = actions.next_location,
          ["<S-Tab>"] = actions.previous_location,
          ["<leader>l"] = actions.enter_win("list"), -- Focus list window
        },
      },

      folds = {
        fold_closed = "",
        fold_open = "",
        folded = true, -- Start with the list folded
      },

      indent_lines = {
        enable = true,
        icon = "│",
      },

      winbar = {
        enable = true, -- Requires nvim-0.8+ for winbar support
      },

      use_trouble_qf = false, -- Use built-in quickfix list instead of trouble.nvim
    })
  end,
}

