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
local DEFAULT_CAPABILITIES = {
  capabilities = {
    alwaysMatch = {
      acceptInsecureCerts = true,
      ["moz:firefoxOptions"] = {
        args = { "-headless" }
      }
    }
  }
}

function methods:name()
  return "firefox"
end

local function ensure_running(firefox, geckodriver_process, geckodriver_command)
  local timeout_sec = 1.0
  local n_tries = 10
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
    process.nsleep((timeout_sec / n_tries) * (10 ^ 6))
  end
  geckodriver_process:kill()
  process.waitpid(geckodriver_process:pid(), process.WNOHANG)
  error("lua-web-driver: Firefox: " ..
          "Failed to run in " .. timeout_sec .. " seconds: " ..
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

local function set_options(options)
  if not options then
    return DEFAULT_HOST, DEFAULT_PORT, DEFAULT_CAPABILITIES
  end

  local host = options.host
  local port = options.port
  local capabilities = {
    capabilities = {
      alwaysMatch = {
        acceptInsecureCerts = true,
        ["moz:firefoxOptions"] = {
          args = options
        }
      }
    }
  }
  return host, port, capabilities
end

function Firefox.new(options)
  local host, port, capabilities = set_options(options)
  local firefox = {
    options = options,
    bridge = Bridge.new(host, port),
    capabilities = capabilities
  }
  setmetatable(firefox, metatable)
  return firefox
end

return Firefox
