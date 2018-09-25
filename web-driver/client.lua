--- Internal base object to send WebDriver requests
--
-- @classmod Client
-- @local
local requests = require("requests")

local Client = {}

local methods = {}
local metatable = {}

function metatable.__index(client, key)
  return methods[key]
end

function methods:execute(verb, path, params, data)
  local response
  local url = self:endpoint(path, params)
  if verb == "get" then
    response = requests.get(self:endpoint(path, params))
  elseif verb == "post" then
    response = requests.post(self:endpoint(path, params), { data = (data or {})})
  elseif verb == "delete" then
    response = requests.delete(self:endpoint(path, params))
  else
    error("Unknown verb: "..verb)
  end
  if response.status_code == 200 then
    return response
  else
    local value = response.json()["value"]
    error(value["error"]..": "..value["message"])
  end
end

function methods:endpoint(template, params)
  local path, _ = template:gsub("%:([%w_]+)", params or {})
  return self.base_url..path
end

function methods:status()
  return self:execute("get", "status")
end

function methods:create_session(capabilities)
  return self:execute("post", "session", {}, capabilities)
end

function Client.new(host, port)
  local client = {
    host = host,
    port = port,
    base_url = "http://"..host..":"..port.."/"
  }
  setmetatable(client, metatable)
  return client
end

return Client
