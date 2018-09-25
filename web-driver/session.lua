--- The class to handle WebDriver's session
-- <https://www.w3.org/TR/webdriver1/>
-- @classmod Session
local Element = require("web-driver/element")
local Interactions = require("web-driver/interactions")
local ActionBuilder = require("web-driver/action-builder")
local util = require("web-driver/util")
local base64 = require("base64")

local Session = {}

local methods = {}
local metatable = {}

function metatable.__index(session, key)
  return methods[key]
end

--- Destroy the session.
-- <https://www.w3.org/TR/webdriver/#dfn-delete-session>
-- @function Session:destroy
function methods:destroy()
  self.bridge:delete_session(self.id)
end

--- Fetch timeouts
-- <https://www.w3.org/TR/webdriver/#dfn-get-timeouts>
-- @function Session:timeouts
-- @return TODO
function methods:timeouts()
  local response = self.bridge:timeouts(self.id)
  return response.json()["value"]
end

--- Set timeouts
-- <https://www.w3.org/TR/webdriver/#dfn-timeouts>
-- @function Session:set_timeouts
-- @param timeouts
function methods:set_timeouts(timeouts)
  local response = self.bridge:set_timeouts(self.id, timeouts)
  return response
end

--- Navigate the current top-level browsing context to to the specified URL
-- @function Session:visit
function methods:navigate_to(url)
  local response = self.bridge:navigate_to(self.id, url)
  return response
end

--- Retrieve current URL
-- @function Session:url
function methods:url()
  local response = self.bridge:get_current_url(self.id)
  return response.json()["value"]
end

function methods:back()
  local response = self.bridge:go_back(self.id)
  return response
end

function methods:forward()
  local response = self.bridge:go_forward(self.id)
  return response
end

function methods:refresh()
  local response = self.bridge:refresh(self.id)
  return response
end

function methods:title()
  local response = self.bridge:get_title(self.id)
  return response.json()["value"]
end

function methods:window_handle()
  local response = self.bridge:get_window_handle(self.id)
  return response.json()["value"]
end

function methods:close_window()
  local response = self.bridge:close_window(self.id)
  return response
end

function methods:switch_to_window(handle)
  local response = self.bridge:switch_to_window(self.id, handle)
  return response
end

function methods:window_handles()
  local response = self.bridge:get_window_handles(self.id)
  return response.json()["value"]
end

function methods:maximize_window()
  local response = self.bridge:maximize_window(self.id)
  return response
end

function methods:minimize_window()
  local response = self.bridge:minimize_window(self.id)
  return response
end

function methods:fullscreen_window()
  local response = self.bridge:fullscreen_window(self.id)
  return response
end

function methods:window_rect()
  local response = self.bridge:get_window_rect(self.id)
  return response.json()["value"]
end

-- rect = { height = h, width = w, x = position_x, y = position_y }
function methods:set_window_rect(rect)
  local response = self.bridge:set_window_rect(self.id, rect)
  return response
end

-- Support iframe only
function methods:switch_to_frame(id)
  local response = self.bridge:switch_to_frame(self.id, id)
  return response
end

function methods:switch_to_parent_frame()
  local response = self.bridge:switch_to_parent_frame(self.id)
  return response
end

function methods:find_element(strategy, finder)
  local response = self.bridge:find_element(self.id, strategy, finder)
  local id = response.json()["value"]
  return Element.new(self, util.element_id_from(id))
end

function methods:find_elements(strategy, finder)
  local response = self.bridge:find_elements(self.id, strategy, finder)
  local elements = {}
  for i, id in ipairs(response.json()["value"]) do
    elements[i] = Element.new(self, util.element_id_from(id))
  end
  return elements
end

function methods:css(finder)
  return self:find_elements("css selector", finder)
end

function methods:xpath(finder)
  return self:find_elements("xpath", finder)
end

function methods:links(finder)
  return self:find_elements("link text", finder)
end

function methods:get_active_element()
  local response = self.bridge:get_active_element(self.id)
  local id = response.json()["value"]
  return Element.new(self, util.element_id_from(id))
end


function methods:source()
  local response = self.bridge:get_page_source(self.id)
  return response.json()["value"]
end

function methods:xml()
  return self:execute_script("return new XMLSerializer().serializeToString(document)")
end

function methods:execute_script(script, args)
  local response = self.bridge:execute_script(self.id, script, args)
  return response.json()["value"]
end

-- TODO
function methods:execute_script_async(script, args)
  local response = self.bridge:execute_async_script(self.id, script, args)
  return response.json()["value"]
end

function methods:get_all_cookies()
  local response = self.bridge:get_all_cookies(self.id)
  return response.json()["value"]
end

function methods:get_cookie(name)
  local response = self.bridge:get_cookie(self.id, name)
  return response.json()["value"]
end

function methods:add_cookie(cookie)
  local response = self.bridge:add_cookie(self.id, cookie)
  return response
end

function methods:delete_cookie(name)
  local response = self.bridge:delete_cookie(self.id, name)
  return response
end

function methods:delete_all_cookies()
  local response = self.bridge:delete_all_cookies(self.id)
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
  local response = self.bridge:perform_actions(self.id, { actions = actions })
  return response
end

-- TODO
function methods:release_actions()
  local response = self.bridge:release_actions(self.id)
  return response
end

function methods:dismiss_alert()
  local response = self.bridge:dismiss_alert(self.id)
  return response
end

function methods:accept_alert()
  local response = self.bridge:accept_alert(self.id)
  return response
end

function methods:alert_text()
  local response = self.bridge:get_alert_text(self.id)
  return response.json()["value"]
end

function methods:set_alert_text(text)
  local response = self.bridge:set_alert_text(self.id, text)
  return response
end


--- Take screenshot.
-- The screenshot is downloaded as PNG format and save to filename.
-- @function Session:screenshot
-- @param filename The filename to save screenshot
function methods:screenshot(filename)
  local response = self.bridge:take_screenshot(self.id)
  local binary = base64.decode(response.json()["value"])
  local file_handle, err = io.open(filename, "wb+")
  if err then
    error(err)
  end
  file_handle:write(binary)
  file_handle:close()
end

--- The constructor of Session class.
-- <https://www.w3.org/TR/webdriver/#dfn-creating-a-new-session>
-- @function Session.new
-- @param driver
-- @param capabilities
function Session.new(driver, capabilities)
  capabilities = capabilities or driver.capabilities
  local response = driver.bridge:create_session(capabilities)
  local session_id = response.json()["value"]["sessionId"]
  local session = {
    bridge = driver.bridge,
    id = session_id,
  }
  setmetatable(session, metatable)
  return session
end

--- Start new session.
-- <https://www.w3.org/TR/webdriver/#dfn-creating-a-new-session>
-- @function Session.start
-- @param driver
-- @param capabilities
-- @param callback
function Session.start(driver, capabilities, callback)
  local session = Session.new(driver, capabilities)
  if callback then
    local success, return_value = pcall(callback, session)
    session:destroy()
    if not success then
      local err = return_value
      error(err)
    end
    return return_value
  else
    return session
  end
end

return Session
