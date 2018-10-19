--- Internal object to send session related WebDriver requests
--
-- @classmod SessionClient
-- @local
local Client = require("web-driver/client")

local SessionClient = {}

local methods = {}
local metatable = {}

function metatable.__index(session_client, key)
  return methods[key] or
    session_client.parent[key]
end

function methods:delete_session()
  return self:execute("delete", "session/:session_id",
                      { session_id = self.id })
end

function methods:get_timeouts()
  return self:execute("get", "session/:session_id/timeouts",
                      { session_id = self.id })
end

function methods:set_timeouts(timeouts)
  return self:execute("post", "session/:session_id/timeouts",
                      { session_id = self.id },
                      timeouts)
end

function methods:navigate_to(url)
  return self:execute("post", "session/:session_id/url",
                      { session_id = self.id },
                      { url = url })
end

function methods:get_current_url()
  return self:execute("get", "session/:session_id/url",
                      { session_id = self.id })
end

function methods:back()
  return self:execute("post", "session/:session_id/back",
                      { session_id = self.id })
end

function methods:forward()
  return self:execute("post", "session/:session_id/forward",
                      { session_id = self.id })
end

function methods:refresh()
  return self:execute("post", "session/:session_id/refresh",
                      { session_id = self.id })
end

function methods:get_title()
  return self:execute("get", "session/:session_id/title",
                      { session_id = self.id })
end

function methods:get_window_handle()
  return self:execute("get", "session/:session_id/window",
                      { session_id = self.id })
end

function methods:close_window()
  return self:execute("delete", "session/:session_id/window",
                      { session_id = self.id })
end

function methods:switch_to_window(handle)
  return self:execute("post", "session/:session_id/window",
                      { session_id = self.id },
                      { handle = handle })
end

function methods:get_window_handles()
  return self:execute("get", "session/:session_id/window/handles",
                      { session_id = self.id })
end

function methods:fullscreen_window()
  return self:execute("post", "session/:session_id/window/fullscreen",
                      { session_id = self.id })
end

function methods:maximize_window()
  return self:execute("post", "session/:session_id/window/maximize",
                      { session_id = self.id })
end

function methods:minimize_window()
  return self:execute("post", "session/:session_id/window/minimize",
                      { session_id = self.id })
end

function methods:get_window_rect()
  return self:execute("get", "session/:session_id/window/rect",
                      { session_id = self.id })
end

function methods:set_window_rect(rect)
  return self:execute("post", "session/:session_id/window/rect",
                      { session_id = self.id },
                      rect)
end

function methods:switch_to_frame(id)
  return self:execute("post", "session/:session_id/frame",
                      { session_id = self.id },
                      { id = id })
end

function methods:switch_to_parent_frame()
  return self:execute("post", "session/:session_id/frame/parent",
                      { session_id = self.id })
end

function methods:find_element(strategy, finder)
  return self:execute("post", "session/:session_id/element",
                      { session_id = self.id },
                      { using = strategy, value = finder })
end

function methods:find_elements(strategy, finder)
  return self:execute("post", "session/:session_id/elements",
                      { session_id = self.id },
                      { using = strategy, value = finder })
end

function methods:get_active_element()
  return self:execute("get", "session/:session_id/element/active",
                      { session_id = self.id })
end

function methods:get_page_source()
  return self:execute("get", "session/:session_id/source",
                      { session_id = self.id })
end

function methods:execute_script(script, args, options)
  options = options or {}
  local path = "session/:session_id/execute/"
  if options.async then
    path = path .. "async"
  else
    path = path .. "sync"
  end
  args = args or {}
  if #args == 0 then
    args = {[0] = 0} -- {[0] = 0} is size zero array in Lunajson
  end
  return self:execute("post", path,
                      { session_id = self.id },
                      { script = script, args = args })
end

function methods:get_all_cookies()
  return self:execute("get", "session/:session_id/cookie",
                      { session_id = self.id })
end

function methods:get_cookie(name)
  return self:execute("get", "session/:session_id/cookie/:name",
                      { session_id = self.id, name = name })
end

function methods:add_cookie(cookie)
  return self:execute("post", "session/:session_id/cookie",
                      { session_id = self.id },
                      { cookie = cookie })
end

function methods:delete_cookie(name)
  return self:execute("delete", "session/:session_id/cookie/:name",
                      { session_id = self.id, name = name })
end

function methods:delete_all_cookies()
  return self:execute("delete", "session/:session_id/cookie",
                      { session_id = self.id })
end

function methods:perform_actions(actions)
  return self:execute("post", "session/:session_id/actions",
                      { session_id = self.id },
                      { actions = actions })
end

function methods:release_actions()
  return self:execute("delete", "session/:session_id/actions",
                      { session_id = self.id })
end

function methods:dismiss_alert()
  return self:execute("post", "session/:session_id/alert/dismiss",
                      { session_id = self.id })
end

function methods:accept_alert()
  return self:execute("post", "session/:session_id/alert/accept",
                      { session_id = self.id })
end

function methods:get_alert_text()
  return self:execute("get", "session/:session_id/alert/text",
                      { session_id = self.id })
end

function methods:set_alert_text(text)
  return self:execute("post", "session/:session_id/alert/text",
                      { session_id = self.id },
                      { text = text })
end

function methods:take_screenshot()
  return self:execute("get", "session/:session_id/screenshot",
                      { session_id = self.id })
end

function SessionClient.new(parent, id)
  local session_client = {
    parent = parent,
    id = id,
  }
  setmetatable(session_client, metatable)
  return session_client
end

return SessionClient
