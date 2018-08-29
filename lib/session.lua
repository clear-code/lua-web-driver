local requests = require "requests"

-- https://www.w3.org/TR/webdriver1/
local Session = {}

local methods = {}
local metatable = {}

function metatable.__index(session, key)
  -- driver is a Session instance
  return methods[key]
end

function methods:destroy()
  requests.delete(self.base_url)
end

function methods:timeouts()
  local response = requests.get(self:endpoint("timeouts"))
  return response.json()["value"]
end

function methods:set_timeouts(timeouts)
  local response = requests.post(self:endpoint("timeouts"), { data = timeouts })
  return response
end

function methods:visit(url)
  local response = requests.post(self:endpoint("url"), { data = { url = url } })
  return response
end

function methods:url()
  local response = requests.get(self:endpoint("url"))
  return response.json()["value"]
end

function methods:back()
  local response = requests.post(self:endpoint("back"), { data = {}})
  return response
end

function methods:forward()
  local response = requests.post(self:endpoint("forward"), { data = {}})
  return response
end

function methods:refresh()
  local response = requests.post(self:endpoint("refresh"), { data = {}})
  return response
end

function methods:title()
  local response = requests.get(self:endpoint("title"))
  return response.json()["value"]
end

function methods:window_handle()
  local response = requests.get(self:endpoint("window"))
  return response.json()["value"]
end

function methods:close_window()
  local response = requests.delete(self:endpoint("window"))
  return response
end

function methods:switch_to_window(handle)
  local response = requests.post(self:endpoint("window"), { data = { handle = handle } })
  return response
end

function methods:window_handles()
  local response = requests.get(self:endpoint("window/handles"))
  return response.json()["value"]
end

-- TODO
function methods:switch_to_frame(id)
  local response = requests.post(self:endpoint("frame"), { data = { id = id } })
  return response
end

-- TODO
function methods:switch_to_parent_frame()
  local response = requests.post(self:endpoint("frame/parent"), { data = {} })
  return response
end

function methods:window_rect()
  local response = requests.get(self:endpoint("window/rect"))
  return response.json()["value"]
end

-- rect = { height = h, width = w, x = position_x, y = position_y }
function methods:set_window_rect(rect)
  local response = requests.post(self:endpoint("window/rect"), { data = rect })
  return response
end

function methods:window_maximize()
  local response = requests.post(self:endpoint("window/maximize"), { data = {} })
  return response
end

function methods:window_minimize()
  local response = requests.post(self:endpoint("window/minimize"), { data = {} })
  return response
end

function methods:window_fullscreen()
  local response = requests.post(self:endpoint("window/fullscreen"), { data = {} })
  return response
end

function methods:element_active()
  local response = requests.get(self:endpoint("element/active"))
  return response["value"]
end

function methods:element(strategy, finder)
  local response = requests.post(self:endpoint("element"), { data = { using = strategy, value = finder } })
  return response.json()["value"]
end

function methods:elements(strategy, finder)
  local response = requests.post(self:endpoint("elements"), { data = { using = strategy, value = finder } })
  return response.json()["value"]
end

function methods:element_from_element(element_id, strategy, finder)
  local endpoint = self:endpoint("element/:element_id/element", { element_id = element_id })
  local response = requests.post(endpoint, { data = { using = strategy, value = finder } })
  return response.json()["value"]
end

function methods:elements_from_element(element_id, strategy, finder)
  local endpoint = self:endpoint("element/:element_id/elements", { element_id = element_id })
  local response = requests.post(endpoint, { data = { using = strategy, value = finder } })
  return response.json()["value"]
end

function methods:is_element_selected(element_id)
  local endpoint = self:endpoint("element/:element_id/selected", { element_id = element_id })
  local response = requests.get(self:endpoint("element/"..element_id.."/selected"))
  return response.json()["value"]
end

function methods:element_attribute(element_id, name)
  local endpoint = self:endpoint("element/:element_id/attribute/:name", { element_id = element_id, name = name })
  local response = requests.get(endpoint)
  return response.json()["value"]
end

function methods:element_property(element_id, name)
  local endpoint = self:endpoint("element/:element_id/property/:name", { element_id = element_id, name = name })
  local response = requests.get(endpoint)
  return response.json()["value"]
end

function methods:element_css(element_id, name)
  local endpoint = self:endpoint("element/:element_id/css/:name", { element_id = element_id, name = name })
  local response = requests.get(endpoint)
  return response.json()["value"]
end

function methods:element_text(element_id)
  local endpoint = self:endpoint("element/:element_id/text", { element_id = element_id })
  local response = requests.get(endpoint)
  return response.json()["value"]
end

function methods:element_tag(element_id)
  local endpoint = self:endpoint("element/:element_id/name", { element_id = element_id })
  local response = requests.get(endpoint)
  return response.json()["value"]
end

function methods:element_rect(element_id)
  local endpoint = self:endpoint("element/:element_id/rect", { element_id = element_id })
  local response = requests.get(endpoint)
  return response.json()["value"]
end

function methods:is_element_enabled(element_id)
  local endpoint = self:endpoint("element/:element_id/enabled", { element_id = element_id })
  local response = requests.get(endpoint)
  return response.json()["value"]
end

function methods:element_click(element_id)
  local endpoint = self:endpoint("element/:element_id/click", { element_id = element_id })
  local response = requests.post(endpoint, { data = {} })
  return response
end

function methods:element_clear(element_id)
  local endpoint = self:endpoint("element/:element_id/clear", { element_id = element_id })
  local response = requests.post(endpoint, { data = {} })
  return response
end

function methods:element_send_keys(element_id)
  local endpoint = self:endpoint("element/:element_id/value", { element_id = element_id })
  local response = requests.post(endpoint, { data = {} })
  return response
end

function methods:source()
  local response = requests.get(self:endpoint("source"))
  return response.json()["value"]
end

function methods:endpoint(template, params)
  local path, _ = template:gsub("%:([%w_]+)", params or {})
  return self.base_url.."/"..path
end

function Session.new(base_url, session_id)
  local session = {
    base_url = base_url.."session/"..session_id
  }
  setmetatable(session, metatable)
  return session
end

return Session
