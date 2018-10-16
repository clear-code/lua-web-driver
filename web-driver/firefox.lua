--- WebDriver for Firefox
--
-- @classmod Firefox
local process = require("process")
local socket = require("socket")

local Geckodriver = require("web-driver/geckodriver")
local Client = require("web-driver/client")
local Session = require("web-driver/session")
local LogLevel = require("web-driver/log-level")
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
local DEFAULT_GET_REQUEST_TIMEOUT = 5
local DEFAULT_POST_REQUEST_TIMEOUT = 5
local DEFAULT_DELETE_REQUEST_TIMEOUT = 5

local start_timeout_env = process.getenv()["LUA_WEB_DRIVER_START_TIMEOUT"]
if start_timeout_env then
  local start_timeout_env_value = tonumber(start_timeout_env, 10)
  if start_timeout_env_value then
    DEFAULT_START_TIMEOUT = start_timeout_env_value
  end
end

local get_request_timeout_env =
  process.getenv()["LUA_WEB_DRIVER_GET_REQUEST_TIMEOUT"]
if get_request_timeout_env then
  local get_request_timeout_env_value =
    tonumber(get_request_timeout_env, 10)
  if get_request_timeout_env_value then
    DEFAULT_GET_REQUEST_TIMEOUT = get_request_timeout_env_value
  end
end

local post_request_timeout_env =
  process.getenv()["LUA_WEB_DRIVER_POST_REQUEST_TIMEOUT"]
if post_request_timeout_env then
  local post_request_timeout_env_value =
    tonumber(post_request_timeout_env, 10)
  if post_request_timeout_env_value then
    DEFAULT_POST_REQUEST_TIMEOUT = post_request_timeout_env_value
  end
end

local delete_request_timeout_env =
  process.getenv()["LUA_WEB_DRIVER_DELETE_REQUEST_TIMEOUT"]
if delete_request_timeout_env then
  local delete_request_timeout_env_value =
    tonumber(delete_request_timeout_env, 10)
  if delete_request_timeout_env_value then
    DEFAULT_DELETE_REQUEST_TIMEOUT = delete_request_timeout_env_value
  end
end

function methods:start_session(callback)
  self.geckodriver = Geckodriver.new(self)
  self.geckodriver:start()
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
  self.geckodriver:stop()
  if not success then
    self.logger:error("web-driver: Firefox:start_session: " .. err)
    self.logger:traceback("error")
    error(err)
  end
  return return_value
end

local function log_level_to_firefox_name(level)
  -- https://firefox-source-docs.mozilla.org/testing/geckodriver/geckodriver/Capabilities.html#log-object
  if level == LogLevel.TRACE then
    return "trace"
  elseif level == LogLevel.DEBUG then
    return "debug"
  elseif level == LogLevel.INFO then
    return "info"
  elseif level == LogLevel.NOTICE then
    return "warn"
  elseif level == LogLevel.WARNING then
    return "warn"
  elseif level == LogLevel.ERROR then
    return "error"
  elseif level == LogLevel.FATAL then
    return "fatal"
  elseif level == LogLevel.ALERT then
    return "fatal"
  elseif level == LogLevel.EMERGENCY then
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
  local post_request_hook = function()
    if firefox.geckodriver then
      firefox.geckodriver:log_outputs()
    end
  end

  local get_request_timeout = options.get_request_timeout
                              or DEFAULT_GET_REQUEST_TIMEOUT
  local post_request_timeout = options.post_request_timeout
                               or DEFAULT_POST_REQUEST_TIMEOUT
  local delete_request_timeout = options.delete_request_timeout
                                 or DEFAULT_DELETE_REQUEST_TIMEOUT
  firefox.client = Client.new(host,
                              port,
                              firefox.logger,
                              {
                                post_request_hook = post_request_hook,
                                get_request_timeout = get_request_timeout,
                                post_request_timeout = post_request_timeout,
                                delete_request_timeout = delete_request_timeout,
                              }
                             )
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
