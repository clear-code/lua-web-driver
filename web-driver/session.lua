--- The class to handle WebDriver's session
-- <https://www.w3.org/TR/webdriver1/>
-- @classmod Session
local SessionClient = require("web-driver/session-client")
local Element = require("web-driver/element")
local Searchable = require("web-driver/searchable")
local Interactions = require("web-driver/interactions")
local ActionBuilder = require("web-driver/action-builder")
local base64 = require("base64")

local Session = {}

local methods = {}
local metatable = {}

function metatable.__index(session, key)
  return methods[key] or
    Searchable[key]
end

--- Destroy the session.
-- <https://www.w3.org/TR/webdriver/#dfn-delete-session>
-- @function Session:destroy
function methods:destroy()
  self.client:delete_session()
end

--- Fetch timeouts
-- <https://www.w3.org/TR/webdriver/#dfn-get-timeouts>
-- @function Session:timeouts
-- @return TODO
function methods:timeouts()
  local response = self.client:get_timeouts()
  return response.json()["value"]
end

--- Set timeouts
-- <https://www.w3.org/TR/webdriver/#dfn-timeouts>
-- @function Session:set_timeouts
-- @param timeouts
function methods:set_timeouts(timeouts)
  local response = self.client:set_timeouts(timeouts)
  return response
end

--- Navigate the current top-level browsing context to to the specified URL
-- @function Session:visit
function methods:navigate_to(url)
  local response = self.client:navigate_to(url)
  return response
end

--- Retrieve current URL
-- @function Session:url
function methods:url()
  local response = self.client:get_current_url()
  return response.json()["value"]
end

function methods:back()
  local response = self.client:back()
  return response
end

function methods:forward()
  local response = self.client:forward()
  return response
end

function methods:refresh()
  local response = self.client:refresh()
  return response
end

function methods:title()
  local response = self.client:get_title()
  return response.json()["value"]
end

function methods:window_handle()
  local response = self.client:get_window_handle()
  return response.json()["value"]
end

function methods:close_window()
  local response = self.client:close_window()
  return response
end

function methods:switch_to_window(handle)
  local response = self.client:switch_to_window(handle)
  return response
end

function methods:window_handles()
  local response = self.client:get_window_handles()
  return response.json()["value"]
end

function methods:maximize_window()
  local response = self.client:maximize_window()
  return response
end

function methods:minimize_window()
  local response = self.client:minimize_window()
  return response
end

function methods:fullscreen_window()
  local response = self.client:fullscreen_window()
  return response
end

function methods:window_rect()
  local response = self.client:get_window_rect()
  return response.json()["value"]
end

-- rect = { height = h, width = w, x = position_x, y = position_y }
function methods:set_window_rect(rect)
  local response = self.client:set_window_rect(rect)
  return response
end

-- Support iframe only
function methods:switch_to_frame(id)
  local response = self.client:switch_to_frame(id)
  return response
end

function methods:switch_to_parent_frame()
  local response = self.client:switch_to_parent_frame()
  return response
end

function methods:find_element(strategy, finder)
  local response = self.client:find_element(strategy, finder)
  local element_value = response.json()["value"]
  return Element.new(self, element_value)
end

function methods:find_elements(strategy, finder)
  local response = self.client:find_elements(strategy, finder)
  local elements = {}
  for i, element_value in ipairs(response.json()["value"]) do
    elements[i] = Element.new(self, element_value)
  end
  return elements
end

function methods:active_element()
  local response = self.client:get_active_element()
  local id = response.json()["value"]
  return Element.new(self, id)
end

function methods:source()
  local response = self.client:get_page_source()
  return response.json()["value"]
end

function methods:xml()
  return self:execute_script("return new XMLSerializer().serializeToString(document)")
end

function methods:execute_script(script, args)
  local response = self.client:execute_script(script, args)
  return response.json()["value"]
end

-- TODO
function methods:execute_script_async(script, args)
  local response = self.client:execute_async_script(script, args)
  return response.json()["value"]
end

function methods:all_cookies()
  local response = self.client:get_all_cookies()
  return response.json()["value"]
end

function methods:get_cookie(name)
  local response = self.client:get_cookie(name)
  return response.json()["value"]
end

function methods:add_cookie(cookie)
  local response = self.client:add_cookie(cookie)
  return response
end

function methods:delete_cookie(name)
  local response = self.client:delete_cookie(name)
  return response
end

function methods:delete_all_cookies()
  local response = self.client:delete_all_cookies(self.id)
  return response
end

--- Create ActionBuilder
-- @function Session:action
function methods:action(async)
  local mouse = Interactions.pointer("mouse", "mouse")
  local keyboard = Interactions.key("keyboard")
  return ActionBuilder.new(self, mouse, keyboard, async)
end

-- TODO
function methods:perform_actions(actions)
  local response = self.client:perform_actions({ actions = actions })
  return response
end

-- TODO
function methods:release_actions()
  local response = self.client:release_actions()
  return response
end

function methods:dismiss_alert()
  local response = self.client:dismiss_alert()
  return response
end

function methods:accept_alert()
  local response = self.client:accept_alert()
  return response
end

function methods:alert_text()
  local response = self.client:get_alert_text()
  return response.json()["value"]
end

function methods:set_alert_text(text)
  local response = self.client:set_alert_text(text)
  return response
end

--- Take screenshot.
-- The screenshot's format is PNG format.
-- @function Session:take_screenshot
function methods:take_screenshot()
  local response = self.client:take_screenshot()
  return base64.decode(response.json()["value"])
end

--- Take screenshot and save to filename.
-- The screenshot is saved to filename as PNG format.
-- @function Session:save_screenshot
-- @param filename The filename to save screenshot
function methods:save_screenshot(filename)
  local png = self:take_screenshot()
  local file_handle, err = io.open(filename, "wb+")
  if err then
    error("lua-web-driver: Failed to open file to save screenshot: " ..
            "<" .. filename .. ">: " .. err)
  end
  file_handle:write(png)
  file_handle:close()
end

--- The constructor of Session class.
-- <https://www.w3.org/TR/webdriver/#dfn-creating-a-new-session>
-- @function Session.new
-- @param driver
-- @param capabilities
function Session.new(driver, capabilities)
  capabilities = capabilities or driver.capabilities
  local response = driver.client:create_session(capabilities)
  local session_id = response.json()["value"]["sessionId"]
  local session = {
    client = SessionClient.new(driver.client.host,
                               driver.client.port,
                               session_id),
    id = session_id,
  }
  setmetatable(session, metatable)
  return session
end

return Session
