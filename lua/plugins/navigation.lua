return {
  -- Quick jump navigation
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  -- Buffer cycling UI
  {
    "ghillb/cybu.nvim",
    branch = "main",
    dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
    config = function()
      local ok, cybu = pcall(require, "cybu")
      if not ok then
        vim.notify("cybu.nvim not found", vim.log.levels.ERROR)
        return
      end

      cybu.setup({
        position = {
          relative_to = "win",
          anchor = "topright",
          max_win_height = 10,
          max_win_width = 0.5,
        },
        style = {
          border = "rounded",
          hide_buffer_id = true,
        },
        display_time = 700,
        exclude = { "NvimTree", "TelescopePrompt" },
      })
    end,
  },

  -- Motion tweaks for words separated by symbols
  { "chaoren/vim-wordmotion" },

  -- LSP-powered definition/reference peek
  {
    "DNLHC/glance.nvim",
    config = function()
      local glance = require("glance")
      local actions = glance.actions

      glance.setup({
        height = 18,
        zindex = 45,
        detached = function(winid)
          return vim.api.nvim_win_get_width(winid) < 100
        end,
        preview_win_opts = {
          cursorline = true,
          number = true,
          wrap = true,
        },
        border = {
          enable = false,
          top_char = "―",
          bottom_char = "―",
        },
        list = {
          position = "right",
          width = 0.33,
        },
        theme = {
          enable = true,
          mode = "auto",
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
            ["<leader>l"] = actions.enter_win("preview"),
            ["q"] = actions.close,
            ["Q"] = actions.close,
            ["<Esc>"] = actions.close,
            ["<C-q>"] = actions.quickfix,
          },
          preview = {
            ["Q"] = actions.close,
            ["<Tab>"] = actions.next_location,
            ["<S-Tab>"] = actions.previous_location,
            ["<leader>l"] = actions.enter_win("list"),
          },
        },
        folds = {
          fold_closed = "",
          fold_open = "",
          folded = true,
        },
        indent_lines = {
          enable = true,
          icon = "│",
        },
        winbar = {
          enable = true,
        },
        use_trouble_qf = false,
      })
    end,
  },
}
