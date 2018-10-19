--- WebDriver for Firefox
--
-- @classmod Firefox
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
local DEFAULT_START_TIMEOUT = 60
local DEFAULT_HTTP_REQUEST_TIMEOUT = 60
local DEFAULT_GET_REQUEST_TIMEOUT = 60
local DEFAULT_POST_REQUEST_TIMEOUT = 60
local DEFAULT_DELETE_REQUEST_TIMEOUT = 60

local start_timeout_env = os.getenv("LUA_WEB_DRIVER_START_TIMEOUT")
if start_timeout_env then
  local start_timeout_env_value = tonumber(start_timeout_env, 10)
  if start_timeout_env_value then
    DEFAULT_START_TIMEOUT = start_timeout_env_value
  end
end

local http_request_timeout_env = os.getenv("LUA_WEB_DRIVER_HTTP_REQUEST_TIMEOUT")
if http_request_timeout_env then
  http_request_timeout_env_value =
    tonumber(http_request_timeout_env, 10)
  if http_request_timeout_env_value then
    DEFAULT_HTTP_REQUEST_TIMEOUT = http_request_timeout_env_value
  end
end

local get_request_timeout_env = os.getenv("LUA_WEB_DRIVER_GET_REQUEST_TIMEOUT")
if get_request_timeout_env then
  get_request_timeout_env_value =
    tonumber(get_request_timeout_env, 10)
  if get_request_timeout_env_value then
    DEFAULT_GET_REQUEST_TIMEOUT = get_request_timeout_env_value
  end
end

local post_request_timeout_env = os.getenv("LUA_WEB_DRIVER_POST_REQUEST_TIMEOUT")
if post_request_timeout_env then
  post_request_timeout_env_value =
    tonumber(post_request_timeout_env, 10)
  if post_request_timeout_env_value then
    DEFAULT_POST_REQUEST_TIMEOUT = post_request_timeout_env_value
  end
end

local delete_request_timeout_env =
  os.getenv("LUA_WEB_DRIVER_DELETE_REQUEST_TIMEOUT")
if delete_request_timeout_env then
  delete_request_timeout_env_value =
    tonumber(delete_request_timeout_env, 10)
  if delete_request_timeout_env_value then
    DEFAULT_DELETE_REQUEST_TIMEOUT = delete_request_timeout_env_value
  end
end

if not os.getenv("MOZ_LOG") then
  -- For implementing Session:status_code
  local ffi = require("ffi")
  ffi.cdef("int setenv(const char *name, const char *value, int overwrite);")
  ffi.C.setenv("MOZ_LOG", "timestamp,sync,nsHttp:3", 1)
end

local function start_geckodriver(firefox)
  firefox.geckodriver = Geckodriver.new(firefox)
  firefox.geckodriver:start()
end

local function stop_geckodriver(firefox)
  if not firefox.geckodriver then
    return
  end
  firefox.geckodriver:stop()
  firefox.geckodriver = nil
end

function methods:start_session(callback)
  start_geckodriver(self)
  local success
  local session
  local return_value
  local why
  local options = {
    delete_hook = function()
      stop_geckodriver(self)
    end
  }
  success, session = pcall(Session.new, self, options)
  if success then
    if callback then
      success, return_value = pcall(callback, session)
      if not success then
        why = return_value
      end
      pcall(function() session:delete() end)
    else
      return_value = session
    end
  else
    why = session
    stop_geckodriver(self)
  end
  if not success then
    self.logger:error("web-driver: Firefox:start_session: " .. why)
    self.logger:traceback("error")
    error(why)
  end
  return return_value
end

function methods:connection_logs()
  if self.geckodriver then
    return self.geckodriver.connection_logs
  else
    return {}
  end
end

function methods:clear_connection_logs()
  if self.geckodriver then
    return self.geckodriver:clear_connection_logs()
  else
    return {}
  end
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

  local get_request_timeout = DEFAULT_GET_REQUEST_TIMEOUT
  local post_request_timeout = DEFAULT_POST_REQUEST_TIMEOUT
  local delete_request_timeout = DEFAULT_DELETE_REQUEST_TIMEOUT

  if options.http_request_timeout or http_request_timeout_env_value then
    get_request_timeout = options.http_request_timeout
                          or http_request_timeout_env_value
    post_request_timeout = options.http_request_timeout
                           or http_request_timeout_env_value
    delete_request_timeout = options.http_request_timeout
                             or http_request_timeout_env_value
  end
  if options.get_request_timeout or get_request_timeout_env_value then
    get_request_timeout = options.get_request_timeout
                          or get_request_timeout_env_value
  end
  if options.post_request_timeout or post_request_timeout_env_value then
    post_request_timeout = options.post_request_timeout
                           or post_request_timeout_env_value
  end
  if options.delete_request_timeout or delete_request_timeout_env_value then
    delete_request_timeout = options.delete_request_timeout
                             or delete_request_timeout_env_value
  end
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
