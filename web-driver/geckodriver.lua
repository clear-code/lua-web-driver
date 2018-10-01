local process = require("process")
local socket = require("socket")

local Geckodriver = {}

local methods = {}
local metatable = {}

function metatable.__index(geckodriver, key)
  return methods[key]
end

function methods:log_lines(prefix, lines)
  -- TODO: Remove this check when we use logger
  if self.firefox.log_level then
    -- TODO: Use logger
    print(prefix .. lines:gsub("\n", "\n" .. prefix))
  end
end

function methods:log_output()
  local stdio, stdout, stderr = self.process:fds()
  local read_sockets = {
    {
      getfd = function() return stdout; end,
    },
    {
      getfd = function() return stderr; end,
    },
  }
  local readable_sockets, _ = socket.select(read_sockets, {}, 0)
  for _, socket in ipairs(readable_sockets) do
    local fd = socket.getfd()
    if fd == stdout then
      local data, err, again = self.process:stdout()
      if data then
        self:log_lines("lua-web-driver: geckodriver: stdout: ", data)
      end
    end
    if fd == stderr then
      local data, err, again = self.process:stderr()
      if data then
        self:log_lines("lua-web-driver: Firefox: stderr: ", data)
      end
    end
  end
end

function methods:kill()
  local timeout = 5
  local n_tries = 100
  local sleep_ns_per_trie = (timeout / n_tries) * (10 ^ 6)
  local finished = false
  self.process:kill()
  for i = 1, n_tries do
    local status, err = process.waitpid(self.process:pid(), process.WNOHANG)
    if status then
      finished = true
      break
    end
    self:log_output()
    process.nsleep(sleep_ns_per_trie)
  end
  if not finished then
    local SIGKILL = 9
    self.process:kill(SIGKILL)
    self:log_output()
    process.waitpid(self.process:pid())
  end
end

function methods:ensure_running()
  local timeout = self.firefox.start_timeout
  local n_tries = 100
  local sleep_ns_per_trie = (timeout / n_tries) * (10 ^ 6)
  for i = 1, n_tries do
    local success, _ = pcall(function() return self.firefox.client:status() end)
    if success then
      return true
    end
    local status, err = process.waitpid(self.process:pid(), process.WNOHANG)
    if status then
      error("lua-web-driver: geckodriver: " ..
              "Failed to run: <" .. self.command .. ">")
    end
    self:log_output()
    process.nsleep(sleep_ns_per_trie)
  end

  self:kill()
  error("lua-web-driver: geckodriver: " ..
          "Failed to run in " .. timeout .. " seconds: " ..
          "<" .. self.command .. ">")
end

function methods:start(callback)
  local geckodriver_process, err = process.exec(self.command, self.args)
  if err then
    error("lua-web-driver: geckodriver: " ..
            "Failed to execute: <" .. self.command .. ">: " ..
            err)
  end
  self.process = geckodriver_process
  self:ensure_running()
  if callback then
    local _, err = pcall(callback, self)
    self:stop()
    if err then
      error(err)
    end
  end
end

function methods:stop()
  if not self.process then
    return
  end
  self:kill()
end

local function build_args(firefox)
  local args = {
    "--host", firefox.client.host,
    "--port", firefox.client.port
  }
  if firefox.log_level then
    table.insert(args, "--log")
    table.insert(args, firefox.log_level)
  end
  return args
end

function Geckodriver.new(firefox)
  local geckodriver = {
    firefox = firefox,
    command = "geckodriver",
    args = build_args(firefox),
    process = nil,
  }
  setmetatable(geckodriver, metatable)
  return geckodriver
end

return Geckodriver
