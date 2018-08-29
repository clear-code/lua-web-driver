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

function methods:browser()
  return "firefox"
end

function methods:start(callback)
  local args = {
    "--port",
    DEFAULT_PORT
  }
  self.child_process = process.exec("geckodriver", args)
  if not self:wait_for_ready() then
    error("Timeout: geckodriver may not be running")
  end
  if callback then
    local _, err = pcall(self.start_session, self, self.capabilities, callback)
    self:stop()
    if err then
      error(err)
    end
  end
end

function methods:status()
  local success, response
  for _ = 1, 10 do
    success, response = pcall(requests.get, self.base_url.."status")
    process.nsleep(10000)
    if success then
      return response.json()["value"]
    end
  end
  return { ready = false, message = "Timeout: geckodriver may not be running" }
end

function methods:is_ready()
  return self:status()["ready"]
end

function methods:wait_for_ready()
  for _ = 1, 10 do
    if self:is_ready() then
      return true
    end
    process.nsleep(10000)
  end
  return false
end

function methods:stop()
  self.child_process:kill()
end

function methods:start_session(capabilities, callback)
  local response = requests.post(self.base_url.."session", { data = capabilities })
  local session_id = response.json()["value"]["sessionId"]
  local session = Session.new(self.base_url, session_id)
  if callback then
    local _, err = pcall(callback, session)
    session:destroy()
    if err then
      error(err)
    end
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
