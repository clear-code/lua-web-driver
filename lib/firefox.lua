local process = require "process"
local requests = require "requests"

local Session = require "lib/session"

local FirefoxDriver = {}

local methods = {}
local metatable = {}

function metatable.__index(driver, key)
  -- driver is a FirefoxDriver instance
  return methods[key]
end

local DEFAULT_HOST = "localhost"
local DEFAULT_PORT = "4444"
local DEFAULT_CAPABILITIES = {
  capabilities = {
    alwaysMatch = {
      acceptInsecureCerts = true
    }
  }
}

function methods:start()
  local args = {
    "--port",
    DEFAULT_PORT
  }
  self.child_process = process.exec("geckodriver", args)
end

function methods:status()
  local success, response
  repeat
    success, response = pcall(requests.get, self.base_url.."status")
    process.nsleep(1000)
  until success
  return response.json()
end

function methods:is_ready()
  return self:status()["value"]["ready"]
end

function methods:stop()
  self.child_process:kill()
end

function methods:start_session(capabilities, callback)
  local response = requests.post(self.base_url.."session", { data = capabilities })
  local session_id = response.json()["value"]["sessionId"]
  local session = Session.new(self.base_url, session_id)
  if callback then
    callback(session)
    session:destroy()
  else
    return session
  end
end

function methods:stop_session(session_id)
  requests.delete(self.base_url.."session/"..session_id)
end

function FirefoxDriver.new(options)
  local host = options.host or DEFAULT_HOST
  local port = options.port or DEFAULT_PORT
  local capabilities = options.capabilities or DEFAULT_CAPABILITIES
  local base_url = "http://"..host..":"..port.."/"
  local firefox_driver = {
    options = options,
    base_url = base_url,
    capabilities = capabilities
  }
  setmetatable(firefox_driver, metatable)
  return firefox_driver
end

return FirefoxDriver
