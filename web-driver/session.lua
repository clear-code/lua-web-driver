--- The class to handle WebDriver's session
-- <https://www.w3.org/TR/webdriver1/>
-- @classmod Session

local base64 = require("base64")

local SessionClient = require("web-driver/session-client")
local Element = require("web-driver/element")
local ElementSet = require("web-driver/element-set")
local Searchable = require("web-driver/searchable")
local Interactions = require("web-driver/interactions")
-- local ActionBuilder = require("web-driver/action-builder")
local pp = require("web-driver/pp")

local Session = {}

local methods = {}
local metatable = {}

function metatable.__index(session, key)
  return methods[key] or
    Searchable[key]
end

--- Delete the session.
-- <https://www.w3.org/TR/webdriver/#dfn-delete-session>
-- @function Session:delete
function methods:delete()
  local success, why = pcall(function() self.client:delete_session() end)
  if self.delete_hook then
    self.delete_hook()
  end
  if not success then
    -- TODO: Log backtrace
    error(why)
  end
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
  self.client:set_timeouts(timeouts)
end

--- Navigate the current top-level browsing context to to the specified URL
-- @function Session:navigate_to
function methods:navigate_to(url)
  self.client:navigate_to(url)
  self.last_status_code = nil
  local host, path = url:match("^[^:]+://([^/]+)([^#]+)")
  local i, log
  for i, log in ipairs(self.driver:connection_logs()) do
    if log.host == host and log.path == path then
      self.last_status_code = log.status_code
      self.last_request_headers = log.request_headers
      break
    end
  end
  self.driver:clear_connection_logs()
end

function methods:status_code()
  return self.last_status_code
end

function methods:request_headers()
  return self.last_request_headers
end

--- Retrieve current URL
-- @function Session:url
function methods:url()
  local response = self.client:get_current_url()
  return response.json()["value"]
end

function methods:back()
  self.client:back()
end

function methods:forward()
  self.client:forward()
end

function methods:refresh()
  self.client:refresh()
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
  return response.json()["value"]
end

function methods:switch_to_window(handle)
  self.client:switch_to_window(handle)
end

function methods:window_handles()
  local response = self.client:get_window_handles()
  return response.json()["value"]
end

function methods:maximize_window()
  local response = self.client:maximize_window()
  return response.json()["value"]
end

function methods:minimize_window()
  local response = self.client:minimize_window()
  return response.json()["value"]
end

function methods:fullscreen_window()
  local response = self.client:fullscreen_window()
  return response.json()["value"]
end

function methods:window_rect()
  local response = self.client:get_window_rect()
  return response.json()["value"]
end

-- rect = { height = h, width = w, x = position_x, y = position_y }
function methods:set_window_rect(rect)
  local response = self.client:set_window_rect(rect)
  return response.json()["value"]
end

-- Support iframe only
function methods:switch_to_frame(id)
  self.client:switch_to_frame(id)
end

function methods:switch_to_parent_frame()
  self.client:switch_to_parent_frame()
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
  return ElementSet.new(elements)
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

function methods:content_type()
  return self:execute_script("return document.contentType")
end

function methods:execute_script(script, args, options)
  local response = self.client:execute_script(script, args, options)
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
  self.client:add_cookie(cookie)
end

function methods:delete_cookie(name)
  self.client:delete_cookie(name)
end

function methods:delete_all_cookies()
  self.client:delete_all_cookies(self.id)
end

-- --- Create ActionBuilder
-- -- @function Session:action
-- function methods:action(async)
--   local mouse = Interactions.pointer("mouse", "mouse")
--   local keyboard = Interactions.key("keyboard")
--   return ActionBuilder.new(self, mouse, keyboard, async)
-- end

function methods:perform_actions(actions)
  self.client:perform_actions(actions)
end

function methods:release_actions()
  self.client:release_actions()
end

function methods:dismiss_alert()
  self.client:dismiss_alert()
end

function methods:accept_alert()
  self.client:accept_alert()
end

function methods:alert_text()
  local response = self.client:get_alert_text()
  return response.json()["value"]
end

function methods:set_alert_text(text)
  self.client:set_alert_text(text)
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
    local message =
      "web-driver: Session: Failed to open file to save screenshot: " ..
      "<" .. filename .. ">: " .. err
    self.logger:error(message)
    self.logger:traceback("error")
    error(message)
  end
  file_handle:write(png)
  file_handle:close()
end

--- The constructor of Session class.
-- <https://www.w3.org/TR/webdriver/#dfn-creating-a-new-session>
-- @function Session.new
-- @param driver
-- @param capabilities
function Session.new(driver, options)
  options = options or {}
  capabilities = options.capabilities or driver.capabilities
  local response = driver.client:create_session(capabilities)
  local session_id = response.json()["value"]["sessionId"]
  local session = {
    driver = driver,
    client = SessionClient.new(driver.client, session_id),
    logger = driver.logger,
    id = session_id,
    delete_hook = options.delete_hook,
    last_status_code = nil,
    last_request_headers = nil,
  }
  setmetatable(session, metatable)
  return session
end

return Session
