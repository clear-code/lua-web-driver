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

function methods:name()
  return "firefox"
end

local function ensure_running(firefox, geckodriver_process, geckodriver_command)
  local timeout = firefox.start_timeout
  local n_tries = 100
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
    process.nsleep((timeout / n_tries) * (10 ^ 6))
  end
  geckodriver_process:kill()
  process.waitpid(geckodriver_process:pid(), process.WNOHANG)
  error("lua-web-driver: Firefox: " ..
          "Failed to run in " .. timeout .. " seconds: " ..
          "<" .. geckodriver_command .. ">")
end

function methods:start(callback)
  local command = "geckodriver"
  local args = {
    "--host", self.bridge.host,
    "--port", self.bridge.port
  }
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
  self.geckodriver_process:kill()
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
        acceptInsecureCerts = true,
        ["moz:firefoxOptions"] = {
          args = options.args or DEFAULT_ARGS
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
