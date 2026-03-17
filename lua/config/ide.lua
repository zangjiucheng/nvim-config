local M = {}

local uv = vim.uv or vim.loop
local is_windows = package.config:sub(1, 1) == "\\"
local path_sep = is_windows and "\\" or "/"
local python_bin_dir = is_windows and "Scripts" or "bin"
local python_exe = is_windows and "python.exe" or "python"

local function joinpath(...)
  if vim.fs and vim.fs.joinpath then
    return vim.fs.joinpath(...)
  end
  return table.concat({ ... }, path_sep)
end

local function exists(path)
  return path and uv.fs_stat(path) ~= nil
end

local function stat_type(path)
  local stat = path and uv.fs_stat(path) or nil
  return stat and stat.type or nil
end

local function start_dir(start)
  local path = start
  if not path or path == "" then
    path = vim.api.nvim_buf_get_name(0)
  end
  if not path or path == "" then
    path = uv.cwd()
  end
  if stat_type(path) == "file" then
    return vim.fs.dirname(path)
  end
  return path
end

local function find_up(markers, start)
  local found = vim.fs.find(markers, {
    upward = true,
    path = start_dir(start),
    limit = 1,
  })[1]
  return found and vim.fs.dirname(found) or nil
end

local function read_json(path)
  if not exists(path) then
    return nil
  end
  local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), "\n"))
  return ok and decoded or nil
end

local function parse_env_file(path, env)
  if not exists(path) then
    return
  end
  for _, raw_line in ipairs(vim.fn.readfile(path)) do
    local line = raw_line:gsub("^%s*export%s+", "")
    if line ~= "" and not line:match("^%s*#") then
      local key, value = line:match("^%s*([%w_%.%-]+)%s*=%s*(.-)%s*$")
      if key then
        if #value >= 2 then
          local first = value:sub(1, 1)
          local last = value:sub(-1)
          if (first == '"' and last == '"') or (first == "'" and last == "'") then
            value = value:sub(2, -2)
          end
        end
        env[key] = value:gsub("\\n", "\n")
      end
    end
  end
end

local function package_data(start)
  local root = M.node_root(start)
  if not root then
    return nil, nil
  end
  return read_json(joinpath(root, "package.json")), root
end

local function has_any_key(tbl, names)
  if not tbl then
    return false
  end
  for _, name in ipairs(names) do
    if tbl[name] then
      return true
    end
  end
  return false
end

local function script_contains(scripts, pattern)
  if not scripts then
    return false
  end
  for _, command in pairs(scripts) do
    if type(command) == "string" and command:match(pattern) then
      return true
    end
  end
  return false
end

function M.project_root(start)
  return find_up({
    ".git",
    "package.json",
    "pyproject.toml",
    "pytest.ini",
    "setup.py",
    "requirements.txt",
    "Pipfile",
    "Cargo.toml",
    "Makefile",
  }, start)
end

function M.python_root(start)
  return find_up({
    "pyproject.toml",
    "pytest.ini",
    "setup.py",
    "requirements.txt",
    "Pipfile",
    "tox.ini",
    ".venv",
    "venv",
    "env",
  }, start) or M.project_root(start)
end

function M.node_root(start)
  return find_up({ "package.json", "tsconfig.json", "jsconfig.json" }, start) or M.project_root(start)
end

function M.env_file(start)
  local root = M.project_root(start)
  if not root then
    return nil
  end
  for _, name in ipairs({ ".env.local", ".env" }) do
    local path = joinpath(root, name)
    if exists(path) then
      return path
    end
  end
  return nil
end

function M.read_env(start)
  local root = M.project_root(start)
  if not root then
    return {}
  end
  local env = {}
  parse_env_file(joinpath(root, ".env"), env)
  parse_env_file(joinpath(root, ".env.local"), env)
  return env
end

function M.local_python_command(start)
  local root = M.python_root(start)
  if not root then
    return nil
  end

  for _, dirname in ipairs({ ".venv", "venv", "env" }) do
    local candidate = joinpath(root, dirname, python_bin_dir, python_exe)
    if exists(candidate) then
      return candidate
    end
  end
  return nil
end

function M.python_command(start)
  if vim.env.VIRTUAL_ENV then
    local activated = joinpath(vim.env.VIRTUAL_ENV, python_bin_dir, python_exe)
    if exists(activated) then
      return activated
    end
  end

  local local_python = M.local_python_command(start)
  if local_python then
    return local_python
  end
  return nil
end

function M.python_venv(start)
  local python = M.python_command(start)
  if not python then
    return nil
  end
  return vim.fs.dirname(vim.fs.dirname(python))
end

function M.activate_python_venv(start)
  local python = M.local_python_command(start)
  if not python then
    return false
  end

  local ok, venv_selector = pcall(require, "venv-selector")
  if not ok then
    return false
  end

  local current_python = venv_selector.python()
  if current_python == python then
    return false
  end

  venv_selector.activate_from_path(python, "venv")
  return true
end

function M.package_manager(start)
  local root = M.node_root(start)
  if not root then
    return "npm"
  end
  for _, lockfile in ipairs({
    { "pnpm-lock.yaml", "pnpm" },
    { "yarn.lock", "yarn" },
    { "bun.lockb", "bun" },
    { "package-lock.json", "npm" },
  }) do
    if exists(joinpath(root, lockfile[1])) then
      return lockfile[2]
    end
  end
  return "npm"
end

function M.node_command(start, executable)
  local root = M.node_root(start)
  if not root then
    return executable
  end
  local ext = is_windows and ".cmd" or ""
  local local_bin = joinpath(root, "node_modules", ".bin", executable .. ext)
  if exists(local_bin) then
    return local_bin
  end
  return executable
end

function M.package_script(start, preferred_names)
  local data, root = package_data(start)
  if not data or not data.scripts then
    return nil, root
  end
  for _, name in ipairs(preferred_names) do
    if data.scripts[name] then
      return name, root
    end
  end
  return nil, root
end

function M.preferred_node_test_runner(start)
  local data, root = package_data(start)
  if not data or not root then
    return nil
  end

  local dependencies = vim.tbl_extend("force", data.dependencies or {}, data.devDependencies or {})
  local scripts = data.scripts or {}

  local has_vitest_dep = has_any_key(dependencies, { "vitest", "@vitest/ui", "@vitest/coverage-v8" })
  local has_jest_dep = has_any_key(dependencies, { "jest", "@jest/globals", "ts-jest" })

  local has_vitest_config = vim.fs.find({
    "vitest.config.ts",
    "vitest.config.js",
    "vitest.config.mts",
    "vitest.config.mjs",
  }, { path = root, limit = 1 })[1] ~= nil

  local has_jest_config = vim.fs.find({
    "jest.config.ts",
    "jest.config.js",
    "jest.config.cjs",
    "jest.config.mjs",
    "jest.config.json",
  }, { path = root, limit = 1 })[1] ~= nil

  if has_vitest_config then
    return "vitest"
  end
  if has_jest_config then
    return "jest"
  end
  if script_contains(scripts, "vitest") then
    return "vitest"
  end
  if script_contains(scripts, "jest") then
    return "jest"
  end
  if has_vitest_dep and not has_jest_dep then
    return "vitest"
  end
  if has_jest_dep and not has_vitest_dep then
    return "jest"
  end
  if has_vitest_dep then
    return "vitest"
  end
  if has_jest_dep then
    return "jest"
  end
  return nil
end

function M.is_node_test_file(file_path)
  if not file_path or file_path == "" then
    return false
  end
  if file_path:match("__tests__") then
    return true
  end
  return file_path:match("%.(spec|test)%.[cm]?[jt]sx?$") ~= nil or file_path:match("%.e2e%.[cm]?[jt]sx?$") ~= nil
end

function M.jest_command(start)
  local root = M.node_root(start)
  if not root then
    return "jest"
  end
  local local_bin = M.node_command(root, "jest")
  if local_bin ~= "jest" then
    return local_bin
  end
  local script = M.package_script(root, { "test:unit", "test", "test:jest" })
  if script then
    return string.format("%s run %s --", M.package_manager(root), script)
  end
  return "jest"
end

function M.vitest_command(start)
  local root = M.node_root(start)
  if not root then
    return "vitest"
  end
  local local_bin = M.node_command(root, "vitest")
  if local_bin ~= "vitest" then
    return local_bin
  end
  local script = M.package_script(root, { "test:unit", "test", "vitest" })
  if script then
    return string.format("%s run %s --", M.package_manager(root), script)
  end
  return "vitest"
end

return M
