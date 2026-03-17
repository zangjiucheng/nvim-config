local ide = require("config.ide")
local constants = require("overseer.constants")

local function task(name, opts)
  return {
    name = name,
    desc = opts.desc,
    priority = opts.priority or 55,
    tags = opts.tags,
    builder = opts.builder,
    condition = opts.condition,
  }
end

local function python_templates()
  local root = ide.python_root()
  local python = ide.python_command() or "python"
  if not root then
    return {}
  end

  local env = ide.read_env(root)
  local current = vim.api.nvim_buf_get_name(0)
  local ret = {
    task("Python: Pytest", {
      desc = "Run the current Python project's pytest suite",
      priority = 40,
      tags = { constants.TAG.TEST },
      builder = function()
        return {
          cmd = { python },
          args = { "-m", "pytest" },
          cwd = root,
          env = env,
        }
      end,
    }),
    task("Python: Run File", {
      desc = "Run the current Python file with the project interpreter",
      priority = 45,
      tags = { constants.TAG.RUN },
      condition = {
        callback = function()
          return current ~= "" and vim.bo.filetype == "python"
        end,
      },
      builder = function()
        return {
          cmd = { python },
          args = { current },
          cwd = root,
          env = env,
        }
      end,
    }),
  }

  if current ~= "" and vim.bo.filetype == "python" then
    table.insert(ret, 2, task("Python: Pytest File", {
      desc = "Run pytest for the current file",
      priority = 42,
      tags = { constants.TAG.TEST },
      builder = function()
        return {
          cmd = { python },
          args = { "-m", "pytest", current },
          cwd = root,
          env = env,
        }
      end,
    }))
  end

  return ret
end

local function node_templates()
  local root = ide.node_root()
  if not root then
    return {}
  end

  local env = ide.read_env(root)
  local manager = ide.package_manager(root)
  local ret = {}

  local script_specs = {
    {
      label = "Node: Dev",
      scripts = { "dev", "start" },
      desc = "Run the project's primary dev/start script",
      tags = { constants.TAG.RUN },
      priority = 40,
    },
    {
      label = "Node: Build",
      scripts = { "build" },
      desc = "Run the project's build script",
      tags = { constants.TAG.BUILD },
      priority = 42,
    },
    {
      label = "Node: Lint",
      scripts = { "lint" },
      desc = "Run the project's lint script",
      tags = { constants.TAG.BUILD },
      priority = 44,
    },
  }

  for _, spec in ipairs(script_specs) do
    local script = ide.package_script(root, spec.scripts)
    if script then
      table.insert(ret, task(spec.label, {
        desc = spec.desc,
        priority = spec.priority,
        tags = spec.tags,
        builder = function()
          return {
            cmd = { manager },
            args = { "run", script },
            cwd = root,
            env = env,
          }
        end,
      }))
    end
  end

  local runner = ide.preferred_node_test_runner(root)
  if runner == "vitest" then
    table.insert(ret, task("Node: Vitest", {
      desc = "Run Vitest using the workspace's preferred command",
      priority = 46,
      tags = { constants.TAG.TEST },
      builder = function()
        return {
          cmd = vim.split(ide.vitest_command(root), "%s+"),
          cwd = root,
          env = env,
        }
      end,
    }))
  elseif runner == "jest" then
    table.insert(ret, task("Node: Jest", {
      desc = "Run Jest using the workspace's preferred command",
      priority = 46,
      tags = { constants.TAG.TEST },
      builder = function()
        return {
          cmd = vim.split(ide.jest_command(root), "%s+"),
          cwd = root,
          env = env,
        }
      end,
    }))
  end

  return ret
end

return {
  generator = function(_, cb)
    local templates = {}
    vim.list_extend(templates, python_templates())
    vim.list_extend(templates, node_templates())
    cb(templates)
  end,
}
