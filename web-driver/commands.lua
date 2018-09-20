--- WebDriver API commands mapping
--
-- @classmod Commands
-- @local
local Commands = {
  status = { "get", "status" },
  --
  -- session handling
  --
  new_session = { "post", "session"  },
  delete_session = { "delete", "session/:session_id"  },

  --
  -- basic driver
  --
  get = { "post", "session/:session_id/url"  },
  get_current_url = { "get", "session/:session_id/url" },
  back = { "post", "session/:session_id/back" },
  forward = { "post", "session/:session_id/forward" },
  refresh = { "post", "session/:session_id/refresh" },
  get_title = { "get", "session/:session_id/title" },

  --
  -- window and Frame handling
  --
  get_window_handle = { "get", "session/:session_id/window" },
  close_window = { "delete", "session/:session_id/window" },
  switch_to_window = { "post", "session/:session_id/window" },
  get_window_handles = { "get", "session/:session_id/window/handles" },
  fullscreen_window = { "post", "session/:session_id/window/fullscreen" },
  minimize_window = { "post", "session/:session_id/window/minimize" },
  maximize_window = { "post", "session/:session_id/window/maximize" },
  -- Undefined in WebDriver specification
  -- set_window_size = { "post", "session/:session_id/window/size" },
  -- get_window_size = { "get", "session/:session_id/window/size" },
  -- set_window_position = { "post", "session/:session_id/window/position" },
  -- get_window_position = { "get", "session/:session_id/window/position" },
  set_window_rect = { "post", "session/:session_id/window/rect" },
  get_window_rect = { "get", "session/:session_id/window/rect" },
  switch_to_frame = { "post", "session/:session_id/frame" },
  switch_to_parent_frame = { "post", "session/:session_id/frame/parent" },

  --
  -- element
  --
  find_element = { "post", "session/:session_id/element" },
  find_elements = { "post", "session/:session_id/elements" },
  find_child_element = { "post", "session/:session_id/element/:element_id/element" },
  find_child_elements = { "post", "session/:session_id/element/:element_id/elements" },
  get_active_element = { "get", "session/:session_id/element/active" },
  is_element_selected = { "get", "session/:session_id/element/:element_id/selected" },
  get_element_attribute = { "get", "session/:session_id/element/:element_id/attribute/:name" },
  get_element_property = { "get", "session/:session_id/element/:element_id/property/:name" },
  get_element_css_value = { "get", "session/:session_id/element/:element_id/css/:property_name" },
  get_element_text = { "get", "session/:session_id/element/:element_id/text" },
  get_element_tag_name = { "get", "session/:session_id/element/:element_id/name" },
  get_element_rect = { "get", "session/:session_id/element/:element_id/rect" },
  is_element_enabled = { "get", "session/:session_id/element/:element_id/enabled" },

  --
  -- document handling
  --
  get_page_source = { "get", "session/:session_id/source" },
  execute_script = { "post", "session/:session_id/execute/sync" },
  execute_async_script = { "post", "session/:session_id/execute/async" },

  --
  -- cookies
  --
  get_all_cookies = { "get", "session/:session_id/cookie" },
  get_cookie = { "get", "session/:session_id/cookie/:name" },
  add_cookie = { "post", "session/:session_id/cookie" },
  delete_cookie = { "delete", "session/:session_id/cookie/:name" },
  delete_all_cookies = { "delete", "session/:session_id/cookie" },

  --
  -- timeouts
  --
  get_timeout = { "get", "session/:session_id/timeouts" },
  set_timeout = { "post", "session/:session_id/timeouts" },

  --
  -- actions
  --
  perform_actions = { "post", "session/:session_id/actions" },
  release_actions = { "delete", "session/:session_id/actions" },

  --
  -- Element Operations
  --
  element_click = { "post", "session/:session_id/element/:element_id/click" },
  -- Undefined in WebDriver specification
  -- element_tap = { "post", "session/:session_id/element/:element_id/tap" },
  element_clear = { "post", "session/:session_id/element/:element_id/clear" },
  element_send_keys = { "post", "session/:session_id/element/:element_id/value" },

  --
  -- alerts
  --
  dismiss_alert = { "post", "session/:session_id/alert/dismiss" },
  accept_alert = { "post", "session/:session_id/alert/accept" },
  get_alert_text = { "get", "session/:session_id/alert/text" },
  set_alert_text = { "post", "session/:session_id/alert/text" },

  --
  -- screenshot
  --
  take_screenshot = { "get", "session/:session_id/screenshot" },
  take_element_screenshot = { "get", "session/:session_id/element/:element_id/screenshot" }

}

return Commands
