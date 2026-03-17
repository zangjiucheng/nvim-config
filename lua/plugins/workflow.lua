local function latest_task(filter)
  local ok, overseer = pcall(require, "overseer")
  if not ok then
    return nil
  end
  for _, task in ipairs(overseer.list_tasks({ recent_first = true })) do
    if not filter or filter(task) then
      return task
    end
  end
  return nil
end

local function with_task(filter, action, missing)
  return function()
    local task = latest_task(filter)
    if not task then
      vim.notify(missing, vim.log.levels.WARN)
      return
    end
    action(task)
  end
end

local function run_overseer(opts)
  return function()
    require("overseer").run_template(opts or {})
  end
end

local terminal_ignored_filetypes = {
  ["aerial"] = true,
  ["copilot-chat"] = true,
  ["neo-tree"] = true,
  ["OverseerList"] = true,
  ["qf"] = true,
  ["snacks_terminal"] = true,
  ["trouble"] = true,
  ["Trouble"] = true,
}

local function terminal_parent_win()
  local current = vim.api.nvim_get_current_win()

  local function is_main_window(win)
    if not vim.api.nvim_win_is_valid(win) then
      return false
    end
    local buf = vim.api.nvim_win_get_buf(win)
    local bt = vim.bo[buf].buftype
    local ft = vim.bo[buf].filetype
    if bt ~= "" then
      return false
    end
    return not terminal_ignored_filetypes[ft]
  end

  if is_main_window(current) then
    return current
  end

  local best, best_area = nil, -1
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_main_window(win) then
      local area = vim.api.nvim_win_get_width(win) * vim.api.nvim_win_get_height(win)
      if area > best_area then
        best = win
        best_area = area
      end
    end
  end

  return best or current
end

local function open_terminal(opts)
  return function()
    opts = opts or {}
    local win = terminal_parent_win()
    Snacks.terminal(nil, {
      cwd = opts.root and LazyVim.root() or nil,
      win = {
        position = "bottom",
        relative = "win",
        win = win,
        height = 0.3,
      },
    })
  end
end

return {
  -- Session management
  {
    "rmagatti/auto-session",
    lazy = false,
    ---@type AutoSession.Config
    opts = {
      auto_restore = false,
      suppressed_dirs = { "~/", "~/Dev", "~/Downloads", "~/Documents", "~/Desktop/" },
      session_lens = {
        load_on_setup = true,
      },
    },
    keys = {
      { "<leader>pr", "<cmd>AutoSession restore<cr>", desc = "Restore Session" },
      { "<leader>ps", "<cmd>AutoSession save<cr>", desc = "Save Session" },
      { "<leader>pS", "<cmd>AutoSession search<cr>", desc = "Search Sessions" },
    },
  },

  -- Project root detection + Telescope integration
  {
    "ahmedkhalf/project.nvim",
    opts = {
      detection_methods = { "lsp", "pattern" },
      patterns = { ".git", "package.json", "pyproject.toml", "Cargo.toml", "Makefile" },
    },
    config = function(_, opts)
      require("project_nvim").setup(opts)
      require("telescope").load_extension("projects")
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>fp", false },
      {
        "<leader>pp",
        function()
          require("telescope").extensions.projects.projects()
        end,
        desc = "Projects",
      },
    },
  },

  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>fp", false },
      { "<leader>fT", false },
      { "<leader>ft", false },
      { "<c-/>", false, mode = { "n", "t" } },
      { "<c-_>", false, mode = { "n", "t" } },
      { "<leader>fT", open_terminal(), desc = "Terminal (cwd)" },
      { "<leader>ft", open_terminal({ root = true }), desc = "Terminal (Root Dir)" },
      { "<c-/>", open_terminal({ root = true }), desc = "Terminal (Root Dir)", mode = { "n", "t" } },
      { "<c-_>", open_terminal({ root = true }), desc = "which_key_ignore", mode = { "n", "t" } },
    },
    opts = function(_, opts)
      opts.terminal = vim.tbl_deep_extend("force", opts.terminal or {}, {
        win = {
          position = "bottom",
          relative = "win",
          height = 0.3,
          keys = {
            term_normal_twice = {
              "<Esc><Esc>",
              "<C-\\><C-n>",
              mode = "t",
              desc = "Terminal Normal Mode",
            },
          },
        },
      })
    end,
  },

  -- Task runner + compiler UI
  {
    "Zeioth/compiler.nvim",
    cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo", "CompilerStop" },
    dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" },
    keys = {
      { "<leader>rf", "<cmd>CompilerOpen<cr>", desc = "Run File Action" },
    },
    opts = {},
  },
  {
    "stevearc/overseer.nvim",
    commit = "6271cab7ccc4ca840faa93f54440ffae3a3918bd",
    cmd = {
      "CompilerOpen",
      "CompilerToggleResults",
      "CompilerRedo",
      "CompilerStop",
      "OverseerRun",
      "OverseerToggle",
      "OverseerQuickAction",
      "OverseerRunCmd",
      "OverseerOpen",
      "OverseerClose",
    },
    keys = {
      { "<leader>rr", run_overseer({ prompt = "always" }), desc = "Run Task" },
      {
        "<leader>rn",
        function()
          local tag = require("overseer.constants").TAG.RUN
          require("overseer").run_template({ tags = { tag } })
        end,
        desc = "Run Project Task",
      },
      {
        "<leader>rb",
        function()
          local tag = require("overseer.constants").TAG.BUILD
          require("overseer").run_template({ tags = { tag } })
        end,
        desc = "Run Build Task",
      },
      { "<leader>ro", "<cmd>OverseerToggle bottom<cr>", desc = "Toggle Task Panel" },
      {
        "<leader>rl",
        with_task(nil, function(task)
          task:restart(true)
        end, "No recent task to restart"),
        desc = "Restart Last Task",
      },
      {
        "<leader>rq",
        with_task(nil, function(task)
          require("overseer").run_action(task)
        end, "No recent task for actions"),
        desc = "Task Actions",
      },
      {
        "<leader>rs",
        with_task(function(task)
          return task:is_running()
        end, function(task)
          task:stop()
        end, "No running task to stop"),
        desc = "Stop Task",
      },
    },
    opts = function(_, opts)
      opts.templates = opts.templates or { "builtin" }
      if not vim.tbl_contains(opts.templates, "user.ide") then
        table.insert(opts.templates, "user.ide")
      end
      opts.task_list = vim.tbl_deep_extend("force", opts.task_list or {}, {
        direction = "bottom",
        min_height = 14,
        max_height = 18,
        default_detail = 2,
      })
    end,
  },

  {
    "nvim-neotest/neotest",
    dependencies = { "antoinemadec/FixCursorHold.nvim" },
    opts = {
      summary = {
        open = "botright vsplit | vertical resize 42",
      },
      output = {
        open_on_run = true,
      },
      output_panel = {
        open = "botright split | resize 14",
      },
    },
  },

  {
    "rcarriga/nvim-dap-ui",
    opts = {
      floating = {
        border = "rounded",
      },
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.55 },
            { id = "stacks", size = 0.2 },
            { id = "watches", size = 0.25 },
          },
          position = "right",
          size = 48,
        },
        {
          elements = {
            { id = "repl", size = 0.55 },
            { id = "console", size = 0.45 },
          },
          position = "bottom",
          size = 12,
        },
      },
    },
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, "python") then
        -- Installs Mason's debugpy package for nvim-dap-python.
        table.insert(opts.ensure_installed, "python")
      end
    end,
  },

  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
      for _, language in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact" }) do
        for _, config in ipairs(dap.configurations[language] or {}) do
          config.cwd = config.cwd or "${workspaceFolder}"
          config.envFile = config.envFile or "${workspaceFolder}/.env"
        end
      end
    end,
  },

  {
    "mfussenegger/nvim-dap-python",
    optional = true,
    config = function()
      local ide = require("config.ide")
      local dap_python = require("dap-python")

      dap_python.setup("debugpy-adapter")
      dap_python.resolve_python = function()
        return ide.python_command(vim.api.nvim_buf_get_name(0)) or "python3"
      end

      for _, config in ipairs(require("dap").configurations.python or {}) do
        config.console = config.console or "integratedTerminal"
        config.cwd = config.cwd or "${workspaceFolder}"
        config.envFile = config.envFile or "${workspaceFolder}/.env"
        if config.justMyCode == nil then
          config.justMyCode = false
        end
      end
    end,
  },
}
