--- WebDriver for Firefox
--
-- @classmod Firefox
local process = require("process")
local socket = require("socket")

local Geckodriver = require("web-driver/geckodriver")
local Client = require("web-driver/client")
local Session = require("web-driver/session")
local Logger = require("web-driver/logger")

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

local start_timeout_env = process.getenv()["LUA_WEB_DRIVER_START_TIMEOUT"]
if start_timeout_env then
  local start_timeout_env_value = tonumber(start_timeout_env, 10)
  if start_timeout_env_value then
    DEFAULT_START_TIMEOUT = start_timeout_env_value
  end
end

function methods:start_session(callback)
  local geckodriver = Geckodriver.new(self)
  geckodriver:start()
  local success
  local session
  local return_value
  local err
  success, session = pcall(Session.new, self)
  if success then
    success, return_value = pcall(callback, session)
    if not success then
      err = return_value
    end
    pcall(function() session:destroy() end)
  else
    err = session
  end
  geckodriver:stop()
  if not success then
    self.logger:error("web-driver: Firefox:start_session: " .. err)
    self.logger:traceback("error")
    error(err)
  end
  return return_value
end

local function log_level_to_firefox_name(level)
  -- https://firefox-source-docs.mozilla.org/testing/geckodriver/geckodriver/Capabilities.html#log-object
  if level == Logger.LEVELS.TRACE then
    return "trace"
  elseif level == Logger.LEVELS.DEBUG then
    return "debug"
  elseif level == Logger.LEVELS.INFO then
    return "info"
  elseif level == Logger.LEVELS.NOTICE then
    return "warn"
  elseif level == Logger.LEVELS.WARNING then
    return "warn"
  elseif level == Logger.LEVELS.ERROR then
    return "error"
  elseif level == Logger.LEVELS.FATAL then
    return "fatal"
  elseif level == Logger.LEVELS.ALERT then
    return "fatal"
  elseif level == Logger.LEVELS.EMERGENCY then
    return "fatal"
  else
    -- Unknown level
    return "info"
  end
end

local function apply_options(firefox, options)
  options = options or {}

  firefox.logger = Logger.new(options.logger)

  local host = options.host or DEFAULT_HOST
  local port = options.port or DEFAULT_PORT
  firefox.client = Client.new(host, port, firefox.logger)

  firefox.capabilities = {
    capabilities = {
      alwaysMatch = {
        ["moz:firefoxOptions"] = {
          args = options.args or DEFAULT_ARGS,
          log = {
            level = log_level_to_firefox_name(firefox.logger:level()),
          }
        }
      }
    }
  }

  firefox.start_timeout = options.start_timeout or DEFAULT_START_TIMEOUT
end

function Firefox.new(options)
  local firefox = {}
  apply_options(firefox, options)
  setmetatable(firefox, metatable)
  return firefox
end

return Firefox
