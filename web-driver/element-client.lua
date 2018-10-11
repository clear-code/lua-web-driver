--- Internal object to send element related WebDriver requests
--
-- @classmod ElementClient
-- @local
local Client = require("web-driver/client")

local ElementClient = {}

local methods = {}
local metatable = {}

function metatable.__index(element_client, key)
  return methods[key] or
    element_client.parent[key]
end

function methods:find_child_element(strategy, finder)
  return self:execute("post", "session/:session_id/element/:element_id/element",
                      {
                        session_id = self.session_id,
                        element_id = self.id,
                      },
                      { using = strategy, value = finder })
end

function methods:find_child_elements(strategy, finder)
  return self:execute("post", "session/:session_id/element/:element_id/elements",
                      {
                        session_id = self.session_id,
                        element_id = self.id,
                      },
                      { using = strategy, value = finder })
end

function methods:is_selected()
  return self:execute("get", "session/:session_id/element/:element_id/selected",
                      {
                        session_id = self.session_id,
                        element_id = self.id,
                      })
end

function methods:get_attribute(name)
  return self:execute("get",
                      "session/:session_id/element/:element_id/attribute/:name",
                      {
                        session_id = self.session_id,
                        element_id = self.id,
                        name = name,
                      })
end

function methods:get_property(name)
  return self:execute("get",
                      "session/:session_id/element/:element_id/property/:name",
                      {
                        session_id = self.session_id,
                        element_id = self.id,
                        name = name,
                      })
end

function methods:get_css_value(property_name)
  return self:execute("get",
                      "session/:session_id/element/:element_id/css/:property_name",
                      {
                        session_id = self.session_id,
                        element_id = self.id,
                        property_name = property_name,
                      })
end

function methods:get_text()
  return self:execute("get",
                      "session/:session_id/element/:element_id/text",
                      {
                        session_id = self.session_id,
                        element_id = self.id,
                      })
end

function methods:get_tag_name()
  return self:execute("get",
                      "session/:session_id/element/:element_id/name",
                      {
                        session_id = self.session_id,
                        element_id = self.id,
                      })
end

function methods:get_rect()
  return self:execute("get",
                      "session/:session_id/element/:element_id/rect",
                      {
                        session_id = self.session_id,
                        element_id = self.id,
                      })
end

function methods:is_enabled()
  return self:execute("get",
                      "session/:session_id/element/:element_id/enabled",
                      {
                        session_id = self.session_id,
                        element_id = self.id,
                      })
end

function methods:click()
  return self:execute("post", "session/:session_id/element/:element_id/click",
                      {
                        session_id = self.session_id,
                        element_id = self.id,
                      })
end

function methods:clear()
  return self:execute("post", "session/:session_id/element/:element_id/clear",
                      {
                        session_id = self.session_id,
                        element_id = self.id,
                      })
end

function methods:send_keys(keys)
  return self:execute("post", "session/:session_id/element/:element_id/value",
                      {
                        session_id = self.session_id,
                        element_id = self.id,
                      },
                      keys)
end

function methods:take_screenshot()
  return self:execute("get",
                      "session/:session_id/element/:element_id/screenshot",
                      {
                        session_id = self.session_id,
                        element_id = self.id,
                      })
end

function ElementClient.new(parent, session_id, id)
  local element_client = {
    parent = parent,
    session_id = session_id,
    id = id,
  }
  setmetatable(element_client, metatable)
  return element_client
end

return ElementClient
