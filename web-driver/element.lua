--- The class to handle web elements
--
-- @classmod Element
local ElementClient = require("web-driver/element-client")
local ElementSet = require("web-driver/element-set")
local Searchable = require("web-driver/searchable")
local pp = require("web-driver/pp")
local base64 = require("base64")
local Element = {}

local methods = {}
local metatable = {}

function metatable.__index(element, key)
  local value = methods[key] or Searchable[key]
  if value then
    return value
  end
  value = methods.get_property(element, key)
  if not (value == nil) then
    return value
  end
  value = methods.get_attribute(element, key)
  if not (value == nil) then
    return value
  end
  value = methods.get_css_value(element, key)
  if not (value == nil or value == "") then
    return value
  end
  return nil
end

-- TODO: Support more patterns
function metatable.__tostring(element)
  local tag = element:tag_name()
  local s = "<"..tag
  local id = element:get_property("id")
  if id then
    s = s..' id="'..id..'"'
  end
  if tag == "input" then
    local type_property = element:get_property("type")
    if type_property then
      s = s..' type="'..type_property..'"'
    end
    local name_property = element:get_property("name")
    if name_property then
      s = s..' name="'..name_property..'"'
    end
  end
  s = s..">"
  return s
end

function methods:find_element(strategy, finder)
  local response = self.client:find_child_element(strategy, finder)
  local element_value = response.json()["value"]
  return Element.new(self.session, element_value)
end

function methods:find_elements(strategy, finder)
  local response = self.client:find_child_elements(strategy, finder)
  local elements = {}
  for i, element_value in ipairs(response.json()["value"]) do
    elements[i] = Element.new(self.session, element_value)
  end
  return ElementSet.new(elements)
end

function methods:is_selected()
  local response = self.client:is_selected()
  return response.json()["value"]
end

function methods:get_attribute(name)
  local response = self.client:get_attribute(name)
  return response.json()["value"]
end

function methods:get_property(name)
  local response = self.client:get_property(name)
  return response.json()["value"]
end

function methods:get_css_value(property_name)
  local response = self.client:get_css_value(property_name)
  return response.json()["value"]
end

function methods:text()
  local response = self.client:get_text()
  return response.json()["value"]
end

function methods:tag_name()
  local response = self.client:get_tag_name()
  return response.json()["value"]
end

function methods:rect()
  local response = self.client:get_rect()
  return response.json()["value"]
end

function methods:is_enabled()
  local response = self.client:is_enabled()
  return response.json()["value"]
end

function methods:click()
  self.client:click()
end

function methods:clear()
  self.client:clear()
end

--- Send keys to element
-- TODO Support Element Send Keys specification
-- <https://www.w3.org/TR/webdriver/#dfn-element-send-keys>
-- @function Element:send_keys
-- @param keys must be string
function methods:send_keys(keys)
  self.client:send_keys({ text = keys })
end

function methods:take_screenshot()
  local response = self.client:take_screenshot()
  return base64.decode(response.json()["value"])
end

function methods:save_screenshot(filename)
  local png = self:take_screenshot()
  local file_handle, err = io.open(filename, "wb+")
  if err then
    local message =
      "web-driver: Element: Failed to open file to save screenshot: " ..
      "<" .. filename .. ">: " .. err
    self.client.logger:error(message)
    self.client.logger:traceback("error")
    error(message)
  end
  file_handle:write(png)
  file_handle:close()
end

function methods:to_data()
  -- This method supports W3C WebDriver only
  return { ["element-6066-11e4-a52e-4f735466cecf"] = self.id }
end

function Element.new(session, id_or_element_value)
  if type(id_or_element_value) == "table" then
    -- Why should we check "ELEMENT" here?
    id = id_or_element_value["ELEMENT"] or
      id_or_element_value["element-6066-11e4-a52e-4f735466cecf"]
  else
    id = id_or_element_value
  end
  local element = {
    client = ElementClient.new(session.client.parent,
                               session.id,
                               id),
    session = session,
    id = id,
  }
  setmetatable(element, metatable)
  return element
end

return Element
