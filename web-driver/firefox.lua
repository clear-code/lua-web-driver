--- WebDriver for Firefox
--
-- @classmod Firefox
local process = require("process")
local socket = require("socket")

local Bridge = require("web-driver/bridge")
local Session = require("web-driver/session")
local util = require("web-driver/util")

local Firefox = {}

local methods = {}
local metatable = {}

function metatable.__index(firefox, key)
  return methods[key]
end

local DEFAULT_HOST = "127.0.0.1"
local DEFAULT_PORT = "4444"
local DEFAULT_ARGS = { "-headless" }
local DEFAULT_START_TIMEOUT = 5
local DEFAULT_LOG_LEVEL = nil

local start_timeout_env = process.getenv()["LUA_WEB_DRIVER_START_TIMEOUT"]
if start_timeout_env then
  local start_timeout_env_value = tonumber(start_timeout_env, 10)
  if start_timeout_env_value then
    DEFAULT_START_TIMEOUT = start_timeout_env_value
  end
end

local log_level_env = process.getenv()["LUA_WEB_DRIVER_LOG_LEVEL"]
if log_level_env then
  DEFAULT_LOG_LEVEL = tostring(log_level_env):lower()
end

local function log_lines(prefix, lines)
  -- TODO: Remove this check when we use logger
  if DEFAULT_LOG_LEVEL then
    -- TODO: Use logger
    print(prefix .. lines:gsub("\n", "\n" .. prefix))
  end
end

local function log_output(geckodriver_process)
  local stdio, stdout, stderr = geckodriver_process:fds()
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
      local data, err, again = geckodriver_process:stdout()
      if data then
        log_lines("lua-web-driver: Firefox: stdout: ", data)
      end
    end
    if fd == stderr then
      local data, err, again = geckodriver_process:stderr()
      if data then
        log_lines("lua-web-driver: Firefox: stderr: ", data)
      end
    end
  end
end

local function kill(geckodriver_process)
  local timeout = 5
  local n_tries = 100
  local sleep_ns_per_trie = (timeout / n_tries) * (10 ^ 6)
  local finished = false
  geckodriver_process:kill()
  for i = 1, n_tries do
    local status, err = process.waitpid(geckodriver_process:pid(),
                                        process.WNOHANG)
    if status then
      finished = true
      break
    end
    log_output(geckodriver_process)
    process.nsleep(sleep_ns_per_trie)
  end
  if not finished then
    local SIGKILL = 9
    geckodriver_process:kill(SIGKILL)
    log_output(geckodriver_process)
    process.waitpid(geckodriver_process:pid())
  end
end

local function ensure_running(firefox, geckodriver_process, geckodriver_command)
  local timeout = firefox.start_timeout
  local n_tries = 100
  local sleep_ns_per_trie = (timeout / n_tries) * (10 ^ 6)
  for i = 1, n_tries do
    local success, _ = pcall(firefox.bridge.status, firefox.bridge)
    if success then
      return true
    end
    local status, err = process.waitpid(geckodriver_process:pid(),
                                        process.WNOHANG)
    if status then
      error("lua-web-driver: Firefox: " ..
              "Failed to run: <" .. geckodriver_command .. ">")
    end
    log_output(geckodriver_process)
    process.nsleep(sleep_ns_per_trie)
  end

  kill(geckodriver_process)
  error("lua-web-driver: Firefox: " ..
          "Failed to run in " .. timeout .. " seconds: " ..
          "<" .. geckodriver_command .. ">")
end

local function make_geckodriver_args(self)
  local args = {
    "--host", self.bridge.host,
    "--port", self.bridge.port
  }
  if self.log_level then
    table.insert(args, "--log")
    table.insert(args, self.log_level)
  end
  return args
end

function methods:start(callback)
  local command = "geckodriver"
  local args = make_geckodriver_args(self)
  local geckodriver_process, err = process.exec(command, args)
  if err then
    error("lua-web-driver: Firefox: " ..
            "Failed to execute: <" .. command .. ">: " ..
            err)
  end
  ensure_running(self, geckodriver_process, command)
  self.geckodriver_process = geckodriver_process
  if callback then
    local _, err = pcall(callback, self)
    self:stop()
    if err then
      error(err)
    end
  end
end

function methods:stop()
  if not self.geckodriver_process then
    return
  end
  kill(self.geckodriver_process)
  self.geckodriver_process = nil
end

function methods:start_session(callback)
  if callback then
    Session.start(self, nil, callback)
  else
    return Session.new(self)
  end
end

local function apply_options(firefox, options)
  options = options or {}

  local host = options.host or DEFAULT_HOST
  local port = options.port or DEFAULT_PORT
  firefox.bridge = Bridge.new(host, port)

  firefox.log_level = options.log_level or DEFAULT_LOG_LEVEL

  firefox.capabilities = {
    capabilities = {
      alwaysMatch = {
        ["moz:firefoxOptions"] = {
          args = options.args or DEFAULT_ARGS
        }
      }
    }
  }
  if firefox.log_level then
    firefox.capabilities.capabilities.alwaysMatch["moz:firefoxOptions"].log =
      { level = firefox.log_level }
  end

  firefox.start_timeout = options.start_timeout or DEFAULT_START_TIMEOUT
end

function Firefox.new(options)
  local firefox = {}
  apply_options(firefox, options)
  setmetatable(firefox, metatable)
  return firefox
end

return Firefox
