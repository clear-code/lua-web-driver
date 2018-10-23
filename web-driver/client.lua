--- Internal base object to send WebDriver requests
--
-- @classmod Client
-- @local

local http_request = require("http.request")
local lunajson = require("lunajson")

local pp = require("web-driver/pp")

local Client = {}
Client.log_prefix = "web-driver: client"

local methods = {}
local metatable = {}

function metatable.__index(client, key)
  return methods[key]
end

function methods:_request(method, url, options)
  local req = http_request.new_from_uri(url)
  req.headers:upsert(":method", method)
  if options.data then
    req:set_body(lunajson.encode(options.data))
  end
  local response_headers, response_stream
  response_headers, response_stream = req:go(options.timeout)
  if not response_headers then
    local why = response_stream
    local message = string.format("%s: Failed to request: %s",
                                  Client.log_prefix,
                                  why)
    self.logger:error(message)
    self.logger:traceback("error")
    error(message)
  end
  local success, response_body = pcall(function()
    return response_stream:get_body_as_string()
  end)
  if not success then
    local why = response_body
    local message = string.format("%s: Failed to read response body: %s",
                                  Client.log_prefix,
                                  why)
    self.logger:error(message)
    self.logger:traceback("error")
    error(message)
  end
  return {
    status_code = tonumber(response_headers:get(":status")),
    headers = response_headers,
    body = response_body,
    json = function() return lunajson.decode(response_body) end,
  }
end

function methods:execute(method, path, params, data)
  local response
  local url = self:endpoint(path, params)
  if method == "get" then
    response = self:_request("GET",
                             url,
                             {
                               timeout = self.get_request_timeout,
                             })
  elseif method == "post" then
    response = self:_request("POST",
                             url,
                             {
                               data = (data or {}),
                               timeout = self.post_request_timeout,
                             })
  elseif method == "delete" then
    response = self:_request("DELETE",
                             url,
                             {
                               timeout = self.delete_request_timeout,
                             })
  else
    error(string.format("%s: Unknown HTTP method: <%s>",
                        Client.log_prefix, method))
  end
  if self.post_request_hook then
    self.post_request_hook(method, url, data, response)
  end
  if response.status_code == 200 then
    if self.logger:need_log("trace") then
      self.logger:trace(string.format("%s: <%s>: <%s>: <%s>: %s",
                                      Client.log_prefix,
                                      method,
                                      path,
                                      pp.format(params),
                                      pp.format(response)))
    end
    return response
  else
    local value = response.json()["value"]
    local message = string.format("%s: <%s>: <%s>: <%s>: %s: %s",
                                  Client.log_prefix,
                                  method,
                                  path,
                                  pp.format(params),
                                  value["error"],
                                  value["message"])
    self.logger:error(message)
    self.logger:traceback("error")
    error(message)
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

function Client.new(host, port, logger, loop, options)
  options = options or {}
  local client = {
    host = host,
    port = port,
    base_url = "http://"..host..":"..port.."/",
    logger = logger,
    loop = loop,
    post_request_hook = options.post_request_hook,
    get_request_timeout = options.get_request_timeout,
    post_request_timeout = options.post_request_timeout,
    delete_request_timeout = options.delete_request_timeout,
  }
  setmetatable(client, metatable)
  return client
end

return Client
