--- WebDriver for Firefox
--
-- @classmod Firefox
local process = require("process")

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

function methods:name()
  return "firefox"
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
    process.nsleep(sleep_ns_per_trie)
  end
  if not finished then
    local SIGKILL = 9
    geckodriver_process:kill(SIGKILL)
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
    process.nsleep(sleep_ns_per_trie)
  end

  kill(geckodriver_process)
  error("lua-web-driver: Firefox: " ..
          "Failed to run in " .. timeout .. " seconds: " ..
          "<" .. geckodriver_command .. ">")
end

local function apply_geckodriver_args(self)
  local args = {
    "--host", self.bridge.host,
    "--port", self.bridge.port
  }
  if DEFAULT_LOG_LEVEL then
    table.insert(args, "--log")
    table.insert(args, DEFAULT_LOG_LEVEL)
  end
  return args
end

function methods:start(callback)
  local command = "geckodriver"
  local args = apply_geckodriver_args(self)
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
    Session.start(self, self.capabilities, callback)
  else
    return Session.new(self, self.capabilities)
  end
end

local function apply_options(firefox, options)
  options = options or {}

  local host = options.host or DEFAULT_HOST
  local port = options.port or DEFAULT_PORT
  firefox.bridge = Bridge.new(host, port)

  firefox.capabilities = {
    capabilities = {
      alwaysMatch = {
        ["moz:firefoxOptions"] = {
          args = options.args or DEFAULT_ARGS
        }
      }
    }
  }
  if DEFAULT_LOG_LEVEL then
    firefox.capabilities.capabilities.alwaysMatch["moz:firefoxOptions"].log =
      { level = DEFAULT_LOG_LEVEL }
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
