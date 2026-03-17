local function open_git_diffview(state)
  local node = state.tree and state.tree:get_node()
  local path = node and (node.path or node:get_id()) or nil
  if not path or path == "" then
    return
  end
  vim.cmd("DiffviewOpen -- " .. vim.fn.fnameescape(path))
end

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.close_if_last_window = false
      opts.source_selector = vim.tbl_deep_extend("force", opts.source_selector or {}, {
        winbar = true,
        statusline = false,
      })
      opts.window = vim.tbl_deep_extend("force", opts.window or {}, {
        position = "left",
        width = 34,
      })
      opts.git_status = vim.tbl_deep_extend("force", opts.git_status or {}, {
        window = {
          mappings = {
            ["<cr>"] = open_git_diffview,
            ["l"] = open_git_diffview,
            ["gd"] = open_git_diffview,
            ["o"] = "open",
          },
        },
      })
      opts.filesystem = vim.tbl_deep_extend("force", opts.filesystem or {}, {
        bind_to_cwd = false,
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true,
        },
        use_libuv_file_watcher = true,
      })
    end,
  },

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
    keys = {
      { "H", "<Plug>(CybuPrev)", desc = "Previous Buffer" },
      { "L", "<Plug>(CybuNext)", desc = "Next Buffer" },
    },
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

  {
    "stevearc/aerial.nvim",
    opts = function(_, opts)
      opts.attach_mode = "window"
      opts.close_automatic_events = { "unsupported" }
      opts.layout = vim.tbl_deep_extend("force", opts.layout or {}, {
        default_direction = "right",
        min_width = 28,
        max_width = { 36, 0.3 },
        resize_to_content = false,
        win_opts = {
          winhl = "Normal:AerialNormal,NormalNC:AerialNormalNC,FloatBorder:AerialBorder,SignColumn:SignColumnSB",
          signcolumn = "yes",
          statuscolumn = " ",
        },
      })
    end,
    keys = {
      { "<leader>cs", false },
      {
        "<leader>cs",
        function()
          require("aerial").toggle({ direction = "right" })
        end,
        desc = "Toggle Outline",
      },
    },
  },

  {
    "folke/trouble.nvim",
    opts = function(_, opts)
      opts.modes = vim.tbl_deep_extend("force", opts.modes or {}, {
        diagnostics = {
          win = { position = "bottom", size = 12 },
        },
        qflist = {
          win = { position = "bottom", size = 10 },
        },
        loclist = {
          win = { position = "bottom", size = 10 },
        },
        lsp = {
          win = { position = "right", size = 0.33 },
        },
      })
    end,
  },

  -- Motion tweaks for words separated by symbols
  { "chaoren/vim-wordmotion" },

  -- LSP-powered definition/reference peek
  {
    "DNLHC/glance.nvim",
    keys = {
      { "gpd", "<cmd>Glance definitions<cr>", desc = "Peek Definition" },
      { "gpr", "<cmd>Glance references<cr>", desc = "Peek References" },
      { "gpi", "<cmd>Glance implementations<cr>", desc = "Peek Implementation" },
      { "gpy", "<cmd>Glance type_definitions<cr>", desc = "Peek Type Definition" },
    },
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
