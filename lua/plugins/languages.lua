return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}

      for _, parser in ipairs({
        "python",
        "javascript",
        "typescript",
        "tsx",
        "jsdoc",
        "json",
        "toml",
        "yaml",
      }) do
        if not vim.tbl_contains(opts.ensure_installed, parser) then
          table.insert(opts.ensure_installed, parser)
        end
      end
    end,
  },

  {
    "linux-cultist/venv-selector.nvim",
    optional = true,
    opts = function(_, opts)
      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        notify_user_on_venv_activation = true,
        cached_venv_automatic_activation = true,
      })
    end,
    config = function(_, opts)
      local ide = require("config.ide")
      local venv_selector = require("venv-selector")

      venv_selector.setup(opts)

      local group = vim.api.nvim_create_augroup("IDEPythonVenv", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "python",
        callback = function(args)
          vim.schedule(function()
            ide.activate_python_venv(vim.api.nvim_buf_get_name(args.buf))
          end)
        end,
      })

      vim.schedule(function()
        if vim.bo.filetype == "python" then
          ide.activate_python_venv(vim.api.nvim_buf_get_name(0))
        end
      end)
    end,
  },

  -- Python notebook helpers
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "marilari88/neotest-vitest",
      "nvim-neotest/neotest-jest",
    },
    opts = function(_, opts)
      local ide = require("config.ide")
      local jest_default = require("neotest-jest.jest-util").defaultIsTestFile

      opts.adapters = opts.adapters or {}
      opts.adapters["neotest-python"] = vim.tbl_deep_extend("force", opts.adapters["neotest-python"] or {}, {
        runner = "pytest",
        python = function()
          return ide.python_command(vim.api.nvim_buf_get_name(0))
        end,
        pytest_discover_instances = true,
        dap = {
          justMyCode = false,
          envFile = "${workspaceFolder}/.env",
        },
      })
      opts.adapters["neotest-jest"] = vim.tbl_deep_extend("force", opts.adapters["neotest-jest"] or {}, {
        cwd = function()
          return ide.node_root(vim.api.nvim_buf_get_name(0)) or vim.uv.cwd()
        end,
        env = function()
          return ide.read_env(vim.api.nvim_buf_get_name(0))
        end,
        jestCommand = function()
          return ide.jest_command(vim.api.nvim_buf_get_name(0))
        end,
        isTestFile = function(file_path)
          return ide.preferred_node_test_runner(file_path) == "jest" and jest_default(file_path)
        end,
      })
      opts.adapters["neotest-vitest"] = vim.tbl_deep_extend("force", opts.adapters["neotest-vitest"] or {}, {
        cwd = function()
          return ide.node_root(vim.api.nvim_buf_get_name(0)) or vim.uv.cwd()
        end,
        env = function()
          return ide.read_env(vim.api.nvim_buf_get_name(0))
        end,
        vitestCommand = function()
          return ide.vitest_command(vim.api.nvim_buf_get_name(0))
        end,
        is_test_file = function(file_path)
          return ide.preferred_node_test_runner(file_path) == "vitest" and ide.is_node_test_file(file_path)
        end,
      })
    end,
  },

  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    config = function()
      require("jupytext").setup({
        style = "percent",
        output_extension = "py",
        force_ft = "python",
        custom_language_formatting = {
          python = {
            extension = "py",
            style = "percent",
            force_ft = "python",
          },
        },
      })
    end,
  },

  -- LaTeX tooling
  {
    "lervag/vimtex",
    ft = { "tex" },
    init = function()
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_compiler_method = "latexmk"
    end,
  },
}
