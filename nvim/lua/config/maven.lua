local M = {}

local uv = vim.uv or vim.loop

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Maven" })
end

local function buf_dir(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr or 0)
  if name == "" then
    return uv.cwd()
  end
  return vim.fs.dirname(name)
end

local function find_root(dir)
  local pom = vim.fs.find("pom.xml", { path = dir, upward = true })[1]
  if pom then
    return vim.fs.dirname(pom)
  end
  local mvnw = vim.fs.find("mvnw", { path = dir, upward = true })[1]
  if mvnw then
    return vim.fs.dirname(mvnw)
  end
  local git = vim.fs.find(".git", { path = dir, upward = true })[1]
  if git then
    return vim.fs.dirname(git)
  end
  return dir
end

local function exists(path)
  return uv.fs_stat(path) ~= nil
end

local function shellsplit(args)
  local ok, parts = pcall(vim.fn.shellsplit, args)
  if ok and type(parts) == "table" then
    return parts
  end
  return vim.split(vim.trim(args), "%s+")
end

local function pick_maven(root)
  local mvnw = root .. "/mvnw"
  if exists(mvnw) and vim.fn.executable(mvnw) == 1 then
    return "./mvnw"
  end
  if vim.fn.executable("mvn") == 1 then
    return "mvn"
  end
  return nil
end

local function open_terminal(cmd, opts)
  opts = opts or {}
  local snacks = rawget(_G, "Snacks")
  if snacks and snacks.terminal then
    return snacks.terminal(cmd, vim.tbl_deep_extend("force", {
      interactive = false,
      auto_close = false,
      start_insert = true,
      auto_insert = true,
      win = { position = "bottom", height = 15 },
    }, opts))
  end

  vim.cmd("botright 15split")
  vim.fn.termopen(cmd, opts.cwd and { cwd = opts.cwd } or {})
  vim.cmd.startinsert()
end

---@param args string|string[]?
---@param opts? {root?: string, cwd?: string}
function M.run(args, opts)
  opts = opts or {}
  local root = opts.root or find_root(buf_dir(0))

  local mvn = pick_maven(root)
  if not mvn then
    notify("No Maven found (expected ./mvnw or mvn in PATH)", vim.log.levels.ERROR)
    return
  end

  local argv = { mvn }
  if type(args) == "string" then
    argv = vim.list_extend(argv, shellsplit(args))
  elseif type(args) == "table" then
    argv = vim.list_extend(argv, args)
  end

  if not exists(root .. "/pom.xml") then
    notify(("No pom.xml found; running in %s"):format(root), vim.log.levels.WARN)
  end

  open_terminal(argv, { cwd = root })
end

function M.prompt(default)
  vim.ui.input({ prompt = "mvn goals: ", default = default or "test" }, function(input)
    if not input or input == "" then
      return
    end
    M.run(input)
  end)
end

---@param profile string
---@param extra_args? string|string[]
---@param opts? {root?: string, cwd?: string}
function M.spring_run(profile, extra_args, opts)
  profile = vim.trim(profile or "")
  if profile == "" then
    notify("Spring profile is required", vim.log.levels.ERROR)
    return
  end

  M._last_profile = profile

  local args = {
    "spring-boot:run",
    ("-Dspring-boot.run.profiles=%s"):format(profile),
  }

  if type(extra_args) == "string" then
    args = vim.list_extend(args, shellsplit(extra_args))
  elseif type(extra_args) == "table" then
    args = vim.list_extend(args, extra_args)
  end

  M.run(args, opts)
end

function M.spring_prompt(default)
  vim.ui.input({ prompt = "Spring profile: ", default = default or M._last_profile or "local" }, function(profile)
    if not profile or vim.trim(profile) == "" then
      return
    end
    M.spring_run(profile)
  end)
end

function M.setup()
  if M._setup then
    return
  end
  M._setup = true

  vim.api.nvim_create_user_command("Mvn", function(cmdopts)
    if cmdopts.args == "" then
      M.prompt()
      return
    end
    M.run(cmdopts.args)
  end, { nargs = "*", desc = "Run Maven (uses mvnw when present)" })

  vim.api.nvim_create_user_command("MvnTest", function()
    M.run("test")
  end, { desc = "mvn test" })

  vim.api.nvim_create_user_command("MvnPackage", function()
    M.run("package")
  end, { desc = "mvn package" })

  vim.api.nvim_create_user_command("MvnInstall", function()
    M.run("install")
  end, { desc = "mvn install" })

  vim.api.nvim_create_user_command("MvnSpringRun", function(cmdopts)
    if cmdopts.args == "" then
      M.spring_prompt()
      return
    end
    local parts = shellsplit(cmdopts.args)
    local profile = table.remove(parts, 1)
    M.spring_run(profile, parts)
  end, { nargs = "*", desc = "mvn spring-boot:run with -Dspring-boot.run.profiles=<profile>" })
end

return M
