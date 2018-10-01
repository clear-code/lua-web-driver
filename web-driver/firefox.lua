--- WebDriver for Firefox
--
-- @classmod Firefox
local process = require("process")
local socket = require("socket")

local Geckodriver = require("web-driver/geckodriver")
local Client = require("web-driver/client")
local Session = require("web-driver/session")

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

function methods:start_session(callback)
  local geckodriver = Geckodriver.new(self)
  geckodriver:start()
  local session = Session.new(self)
  local success, return_value = pcall(callback, session)
  session:destroy()
  geckodriver:stop()
  if not success then
    local err = return_value
    error(err)
  end
  return return_value
end

local function apply_options(firefox, options)
  options = options or {}

  local host = options.host or DEFAULT_HOST
  local port = options.port or DEFAULT_PORT
  firefox.client = Client.new(host, port)

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
