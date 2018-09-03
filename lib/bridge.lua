local requests = require("requests")

local Commands = require("lib/commands")
local Bridge = {}

local methods = {}
local metatable = {}

function metatable.__index(bridge, key)
  return methods[key]
end
local inspect = require("inspect")

function p(root, options)
  print(inspect.inspect(root, options))
end

function methods:execute(command, params, data)
  local verb, path = unpack(Commands[command])
  -- p(verb)
  -- p(path)
  -- p(self:endpoint(path, params))
  local response
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

function methods:create_session(capabilities)
  return self:execute("new_session", nil, capabilities)
end

function methods:delete_session(session_id)
  return self:execute("delete_session", { session_id = session_id })
end

function methods:status()
  return self:execute("status")
end

function methods:timeouts(session_id)
  return self:execute("get_timeout", { session_id = session_id })
end

function methods:set_timeouts(session_id, timeouts)
  return self:execute("set_timeout", { session_id = session_id }, timeouts)
end

function methods:get(session_id, url)
  return self:execute("get", { session_id = session_id }, { url = url })
end

function methods:get_current_url(session_id)
  return self:execute("get_current_url", { session_id = session_id })
end

function methods:go_back(session_id)
  return self:execute("back", { session_id = session_id })
end

function methods:go_forward(session_id)
  return self:execute("forward", { session_id = session_id })
end

function methods:refresh(session_id)
  return self:execute("refresh", { session_id = session_id })
end

function methods:get_title(session_id)
  return self:execute("get_title", { session_id = session_id })
end

function methods:get_window_handle(session_id)
  return self:execute("get_window_handle", { session_id = session_id })
end

function methods:close_window(session_id)
  return self:execute("close_window", { session_id = session_id })
end

function methods:switch_to_window(session_id, handle)
  return self:execute("switch_to_window", { session_id = session_id }, { handle = handle })
end

function methods:get_window_handles(session_id)
  return self:execute("get_window_handles", { session_id = session_id })
end

function methods:fullscreen_window(session_id)
  return self:execute("fullscreen_window", { session_id = session_id })
end

function methods:maximize_window(session_id)
  return self:execute("maximize_window", { session_id = session_id })
end

function methods:minimize_window(session_id)
  return self:execute("minimize_window", { session_id = session_id })
end

function methods:get_window_rect(session_id)
  return self:execute("get_window_rect", { session_id = session_id })
end

function methods:set_window_rect(session_id, rect)
  return self:execute("set_window_rect", { session_id = session_id },  rect)
end

function methods:switch_to_frame(session_id, id)
  return self:execute("switch_to_frame", { session_id = session_id }, { id = id })
end

function methods:switch_to_parent_frame(session_id, id)
  return self:execute("switch_to_parent_frame", { session_id = session_id })
end

function methods:find_element(session_id, strategy, finder)
  return self:execute("find_element", { session_id = session_id }, { using = strategy, value = finder })
end

function methods:find_elements(session_id, strategy, finder)
  return self:execute("find_elements", { session_id = session_id }, { using = strategy, value = finder })
end

function methods:find_child_element(session_id, element_id, strategy, finder)
  local params = { session_id = session_id, element_id = element_id }
  return self:execute("find_child_element", params, { using = strategy, value = finder })
end

function methods:find_child_elements(session_id, element_id, strategy, finder)
  local params = { session_id = session_id, element_id = element_id }
  return self:execute("find_child_elements", params, { using = strategy, value = finder })
end

function methods:get_active_element(session_id)
  return self:execute("get_active_element", { session_id = session_id })
end

function methods:is_element_selected(session_id, element_id)
  local params = { session_id = session_id, element_id = element_id }
  return self:execute("is_element_selected", params)
end

function methods:get_element_attribute(session_id, element_id, name)
  local params = { session_id = session_id, element_id = element_id, name = name }
  return self:execute("get_element_attribute", params)
end

function methods:get_element_property(session_id, element_id, name)
  local params = { session_id = session_id, element_id = element_id, name = name }
  return self:execute("get_element_property", params)
end

function methods:get_element_css_value(session_id, element_id, property_name)
  local params = { session_id = session_id, element_id = element_id, property_name = property_name }
  return self:execute("get_element_css_value", params)
end

function methods:get_element_text(session_id, element_id)
  local params = { session_id = session_id, element_id = element_id }
  return self:execute("get_element_text", params)
end

function methods:get_element_tag_name(session_id, element_id)
  local params = { session_id = session_id, element_id = element_id }
  return self:execute("get_element_tag_name", params)
end

function methods:get_element_rect(session_id, element_id)
  local params = { session_id = session_id, element_id = element_id }
  return self:execute("get_element_rect", params)
end

function methods:is_element_enabled(session_id, element_id)
  local params = { session_id = session_id, element_id = element_id }
  return self:execute("is_element_enabled", params)
end

function methods:element_click(session_id, element_id)
  local params = { session_id = session_id, element_id = element_id }
  return self:execute("element_click", params)
end

function methods:element_clear(session_id, element_id)
  local params = { session_id = session_id, element_id = element_id }
  return self:execute("element_clear", params)
end

function methods:element_send_keys(session_id, element_id, keys)
  local params = { session_id = session_id, element_id = element_id }
  return self:execute("element_clear", params, keys)
end

function methods:get_page_source(session_id)
  return self:execute("get_page_source", { session_id = session_id })
end

function methods:execute_script(session_id, script, args)
  return self:execute("execute_script", { session_id = session_id }, { script = script, args = (args or {1}) })
end

function methods:execute_async_script(session_id, script, args)
  return self:execute("execute_async_script", { session_id = session_id }, { script = script, args = (args or {1}) })
end

function methods:get_all_cookies(session_id)
  return self:execute("get_all_cookies", { session_id = session_id })
end

function methods:get_cookie(session_id, name)
  return self:execute("get_cookie", { session_id = session_id, name = name })
end

function methods:add_cookie(session_id, cookie)
  return self:execute("add_cookie", { session_id = session_id }, { cookie = cookie })
end

function methods:delete_cookie(session_id, name)
  return self:execute("delete_cookie", { session_id = session_id, name = name })
end

function methods:delete_all_cookies(session_id)
  return self:execute("delete_cookies", { session_id = session_id })
end

function methods:perform_actions(session_id, actions)
  return self:execute("perform_actions", { session_id = session_id }, { actions = actions })
end

function methods:release_actions(session_id)
  return self:execute("release_actions", { session_id = session_id })
end

function methods:dismiss_alert(session_id)
  return self:execute("dismiss_alert", { session_id = session_id })
end

function methods:accept_alert(session_id)
  return self:execute("accept_alert", { session_id = session_id })
end

function methods:get_alert_text(session_id)
  return self:execute("get_alert_text", { session_id = session_id })
end

function methods:set_alert_text(session_id, text)
  return self:execute("set_alert_text", { session_id = session_id }, { text = text })
end

function methods:take_screenshot(session_id)
  return self:execute("take_screenshot", { session_id = session_id })
end

function methods:take_element_screenshot(session_id, element_id)
  return self:execute("take_element_screenshot", { session_id = session_id, element_id = element_id  })
end

function Bridge.new(host, port)
  local bridge = {
    host = host,
    port = port,
    base_url = "http://"..host..":"..port.."/"
  }
  setmetatable(bridge, metatable)
  return bridge
end

return Bridge
