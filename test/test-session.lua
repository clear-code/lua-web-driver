local luaunit = require("luaunit")
local web_driver = require("web-driver")

local base64 = require("base64")
local helper = require("test/helper")
local pp = require("web-driver/pp")

TestSession = {}

function TestSession:setup()
  self.server = helper.start_server()
  self.driver = web_driver.Firefox.new()
end

function TestSession:teardown()
  self.server:kill()
  self.server:check(true)
end

function TestSession:test_timeouts()
  self.driver:start_session(function(session)
    luaunit.assert_equals(session:timeouts(),
                          {
                            script = 30000,
                            pageLoad = 300000,
                            implicit = 0,
                          })
    session:set_timeouts({
                            script = 40000,
                            pageLoad = 400000,
                            implicit = 10,
                          })
    luaunit.assert_equals(session:timeouts(),
                          {
                            script = 40000,
                            pageLoad = 400000,
                            implicit = 10,
                          })
  end)
end

function TestSession:test_navigate_to()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    luaunit.assert_equals(session:url(), "http://localhost:10080/index.html")
    luaunit.assert_equals(session:title(), "This is test html")
  end
  self.driver:start_session(callback)
end

function TestSession:test_status_code()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/not-found.html")
    luaunit.assert_equals(session:status_code(), 404)
  end
  self.driver:start_session(callback)
end

function TestSession:test_back_forward()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/1.html")
    luaunit.assert_equals(session:url(), "http://localhost:10080/1.html")
    session:navigate_to("http://localhost:10080/2.html")
    luaunit.assert_equals(session:url(), "http://localhost:10080/2.html")
    session:back()
    luaunit.assert_equals(session:url(), "http://localhost:10080/1.html")
    session:forward()
    luaunit.assert_equals(session:url(), "http://localhost:10080/2.html")
  end
  self.driver:start_session(callback)
end

function TestSession:test_refresh()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/1.html")
    luaunit.assert_equals(session:url(), "http://localhost:10080/1.html")
    session:refresh()
    luaunit.assert_equals(session:url(), "http://localhost:10080/1.html")
  end
  self.driver:start_session(callback)
end

function TestSession:test_window_handle()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/window.html")
    local next_handle = session:window_handles()[2]
    luaunit.assert_not_equals(next_handle, session:window_handle())
    session:switch_to_window(next_handle)
    luaunit.assert_equals(next_handle, session:window_handle())
  end
  self.driver:start_session(callback)
end

function TestSession:test_close_window()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/window.html")
    local current_handle = session:window_handle()
    local handles = session:window_handles()
    local remaining_handles = session:close_window()
    local i, value
    for i, value in ipairs(handles) do
      if value == current_handle then
        table.remove(handles, i)
      end
    end
    luaunit.assert_equals(remaining_handles, handles)
  end
  self.driver:start_session(callback)
end

function TestSession:test_window_handles()
  local callback = function(session)
    local handles = session:window_handles()
    luaunit.assert_equals(handles, {session:window_handle()})
  end
  self.driver:start_session(callback)
end

function TestSession:test_switch_to_window()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/window.html")
    local remaining_handles = session:close_window()
    local switched_handle = remaining_handles[1]
    session:switch_to_window(switched_handle)
    luaunit.assert_equals(switched_handle,
                          session:window_handle())
  end
  self.driver:start_session(callback)
end

function TestSession:test_frame()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/frame.html")
    luaunit.assert_equals(session:title(), "This is parent frame")
    session:switch_to_frame(0)
    local ps = session:css_select("p")
    luaunit.assert_equals(ps:texts(), {"1"})
    session:switch_to_parent_frame()
    ps = session:css_select("p")
    luaunit.assert_equals(ps:texts(), {"parent"})
  end
  self.driver:start_session(callback)
end

function TestSession:test_window_rect()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    session:set_window_rect({ height = 500, width = 500, x = 0, y = 0 })
    local rect = session:window_rect()
    local expected = { height = 500, width = 500, x = 0, y = 0 }
    luaunit.assert_equals(rect, expected)
  end
  self.driver:start_session(callback)
end

local function extract_keys(key_value_list)
  local keys = {}
  for k,_ in pairs(key_value_list) do
    table.insert(keys,k)
  end
  return keys
end

function TestSession:test_set_window_rect()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local rect = { height = 500, width = 500, x = 0, y = 0 }
    luaunit.assert_equals(session:set_window_rect(rect),
                          rect)
  end
  self.driver:start_session(callback)
end

function TestSession:test_fullscreen_window()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")

    local window_geometry = session:fullscreen_window()
    local keys = extract_keys(window_geometry)
    table.sort(keys)
    luaunit.assert_equals(keys, { "height", "width", "x", "y" })
  end
  self.driver:start_session(callback)
end

function TestSession:test_maximize_window()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")

    local window_geometry = session:maximize_window()
    local keys = extract_keys(window_geometry)
    table.sort(keys)
    luaunit.assert_equals(keys, { "height", "width", "x", "y" })
  end
  self.driver:start_session(callback)
end

function TestSession:test_minimize_window()
  if true then
    print("Omit: Because Firefox blocks minimize_window in headless mode")
    return
  end

  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local rect = { height = 500, width = 500, x = 0, y = 0 }
    local expected = { height = 0, width = 0, x = 0, y = 0 }
    session:set_window_rect(rect)

    local actual = session:minimize_window()
    luaunit.assert_equals(actual, expected)
  end
  self.driver:start_session(callback)
end

function TestSession:test_active_element()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    luaunit.assert_not_nil(session:active_element())
  end
  self.driver:start_session(callback)
end

function TestSession:test_find_element()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local element = session:find_element("css selector", "#p1")
    luaunit.assert_equals(element:text(), "Hello 1")
  end
  self.driver:start_session(callback)
end

function TestSession:test_find_elements()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local elements = session:find_elements("css selector", "p")
    local actual = {}
    for index, element in ipairs(elements) do
      actual[index] = element:text()
    end
    luaunit.assert_equals(actual, { "Hello 1", "Hello 2", "Hello 3" })
  end
  self.driver:start_session(callback)
end

function TestSession:test_css_select()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local elements = session:css_select("p, label")
    local actual = {}
    for index, element in ipairs(elements) do
      actual[index] = element:text()
    end
    luaunit.assert_equals(actual,
                          {
                            "Hello 1",
                            "Hello 2",
                            "Hello 3",
                            "Cheese",
                            "Wine",
                          })
  end
  self.driver:start_session(callback)
end

function TestSession:test_xpath_search()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local elements = session:xpath_search("//p")
    local actual = {}
    for index, element in ipairs(elements) do
      actual[index] = element:text()
    end
    luaunit.assert_equals(actual,
                          {
                            "Hello 1",
                            "Hello 2",
                            "Hello 3",
                          })
  end
  self.driver:start_session(callback)
end

function TestSession:test_link_search()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/link.html")
    local elements = session:link_search("Hello 1")
    local actual = {}
    for index, element in ipairs(elements) do
      actual[index] = element:text()
    end
    luaunit.assert_equals(actual,
                          {
                            "Hello 1",
                            "Hello 1",
                          })
  end
  self.driver:start_session(callback)
end

function TestSession:test_partial_link_search()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/link.html")
    local elements = session:partial_link_search("Hello")
    local actual = {}
    for index, element in ipairs(elements) do
      actual[index] = element:text()
    end
    luaunit.assert_equals(actual,
                          {
                            "Hello 1",
                            "Hello 1",
                            "Hello 2",
                            "Hello 2",
                            "Hello 3",
                            "Hello 3",
                          })
  end
  self.driver:start_session(callback)
end

function TestSession:test_tag_search()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local elements = session:tag_search("p")
    local actual = {}
    for index, element in ipairs(elements) do
      actual[index] = element:text()
    end
    luaunit.assert_equals(actual,
                          {
                            "Hello 1",
                            "Hello 2",
                            "Hello 3",
                          })
  end
  self.driver:start_session(callback)
end

function TestSession:test_source()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local expected = [[<html><head>
    <style type="text/css" media="screen">
      body { color: black; }
      #p1 { color: red; }
    </style>
    <title>This is test html</title>
  </head>
  <body>
    <p id="p1">Hello 1</p>
    <p id="p2">Hello 2</p>
    <p id="p3">Hello 3</p>
    <input id="name" name="name" data-placeholder="Input your name" type="text">
    <label>
      <input checked="checked" name="cheese" disabled="disabled" type="checkbox">
      Cheese
    </label>
    <label>
      <input name="wine" type="checkbox">
      Wine
    </label>
  

</body></html>]]
    luaunit.assert_equals(session:source(), expected)
  end
  self.driver:start_session(callback)
end

function TestSession:test_xml()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local expected = [[<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml"><head>
    <style type="text/css" media="screen">
      body { color: black; }
      #p1 { color: red; }
    </style>
    <title>This is test html</title>
  </head>
  <body>
    <p id="p1">Hello 1</p>
    <p id="p2">Hello 2</p>
    <p id="p3">Hello 3</p>
    <input id="name" name="name" data-placeholder="Input your name" type="text" />
    <label>
      <input checked="checked" name="cheese" disabled="disabled" type="checkbox" />
      Cheese
    </label>
    <label>
      <input name="wine" type="checkbox" />
      Wine
    </label>
  

</body></html>]]
    luaunit.assert_equals(session:xml(), expected)
  end
  self.driver:start_session(callback)
end

function TestSession:test_content_type()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/")
    luaunit.assert_equals(session:content_type(), "text/html")
  end
  self.driver:start_session(callback)
end

function TestSession:test_execute_script()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local script = [[return 1 + arguments[0] + arguments[1];]]
    local response = session:execute_script(script, {2, 3})
    luaunit.assert_equals(response, 6)
  end
  self.driver:start_session(callback)
end

function TestSession:test_execute_script_with_error()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local script = [[return 1 + x]]
    luaunit.assert_error_msg_contains("javascript error: ReferenceError: x is not defined",
                                      session.execute_script, session, script)
  end
  self.driver:start_session(callback)
end

function TestSession:test_execute_script_async()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local script = [[
var resolve = arguments[arguments.length - 1];
resolve("result");
]]
    local response = session:execute_script(script, {}, {async = true})
    luaunit.assert_equals(response, "result")
  end
  self.driver:start_session(callback)
end

function TestSession:test_get_cookie()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/cookie.html")
    luaunit.assert_equals(session:get_cookie("data1")["value"], "123")
    luaunit.assert_equals(session:get_cookie("data2")["value"], "456")
  end
  self.driver:start_session(callback)
end

function TestSession:test_all_cookies()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/cookie.html")
    local cookies = session:all_cookies()
    luaunit.assert_equals(#cookies, 2)
  end
  self.driver:start_session(callback)
end

function TestSession:test_add_cookie()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/cookie.html")
    local cookie = {
      name = "new-cookie",
      value = "789",
    }
    luaunit.assert_error_msg_contains("no such cookie",
                                      session.get_cookie,
                                      session,
                                      cookie.name)
    session:add_cookie(cookie)
    luaunit.assert_equals(session:get_cookie(cookie.name).value,
                          cookie.value)
  end
  self.driver:start_session(callback)
end

function TestSession:test_delete_cookie()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/cookie.html")
    luaunit.assert_equals(session:get_cookie("data1").value,
                          "123")
    session:delete_cookie("data1")
    luaunit.assert_error_msg_contains("no such cookie",
                                      session.get_cookie,
                                      session,
                                      "data1")
  end
  self.driver:start_session(callback)
end

function TestSession:test_delete_all_cookies()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/cookie.html")
    luaunit.assert_not_equals(session:all_cookies(), {})
    session:delete_all_cookies()
    luaunit.assert_equals(session:all_cookies(), {})
  end
  self.driver:start_session(callback)
end

function TestSession:test_alert_text()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/alert.html")
    luaunit.assert_equals(session:alert_text(), "test1")
  end
  self.driver:start_session(callback)
end

function TestSession:test_set_alert_text()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/alert_text.html")
    luaunit.assert_equals(session:alert_text(), "alert text")
    session:set_alert_text("test")
    session:accept_alert()
    luaunit.assert_equals(session:alert_text(), "test")
  end
  self.driver:start_session(callback)
end

function TestSession:test_accept_alert()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/alert.html")
    local n_alerts = 0
    for i = 1, 10 do
      local success, _ = pcall(function() session:accept_alert() end)
      if success then
        n_alerts = n_alerts + 1
      end
    end
    luaunit.assert_equals(n_alerts, 2)
  end
  self.driver:start_session(callback)
end

function TestSession:test_actions()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/dropdown.html")
    local select = session:css_select("select")[1]
    local move_to_select_action = {
      type = "pointerMove",
      duration = 250,
      x = 0,
      y = 0,
      origin = select:to_data(),
    }
    local left_button_down_action = {
      type = "pointerDown",
      button = 0,
    }
    local left_button_up_action = {
      type = "pointerUp",
      button = 0,
    }
    local pause_action = {
      type = "pause",
      duration = 0,
    }
    local actions = {
      {
        type = "pointer",
        id = "mouse",
        actions = {
          move_to_select_action,
          left_button_down_action,
          left_button_up_action,
          pause_action,
          pause_action,
          pause_action,
          pause_action,
          pause_action,
          pause_action,
          move_to_select_action,
          left_button_down_action,
          left_button_up_action,
        },
      },
      {
        type = "key",
        id = "keyboard",
        actions = {
          pause_action,
          pause_action,
          pause_action,
          {type = "keyDown", value = "l"},
          {type = "keyUp", value = "l"},
          {type = "keyDown", value = "u"},
          {type = "keyUp", value = "u"},
          {type = "keyDown", value = "a"},
          {type = "keyUp", value = "a"},
          pause_action,
          pause_action,
          pause_action,
        },
      },
    }
    luaunit.assert_equals(select.value, "c")
    session:perform_actions(actions)
    luaunit.assert_equals(select.value, "lua")
    session:release_actions()
  end
  self.driver:start_session(callback)
end

function TestSession:test_dismiss_alert()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/alert.html")
    local n_alerts = 0
    for i = 1, 10 do
      local success, _ = pcall(function() session:dismiss_alert() end)
      if success then
        n_alerts = n_alerts + 1
      end
    end
    luaunit.assert_equals(n_alerts, 2)
  end
  self.driver:start_session(callback)
end

function TestSession:test_accept_confirm()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/confirm.html")
    local element = session:find_element("css selector", "#button")
    element:click()
    session:accept_alert()
    element = session:find_element("css selector", "#confirm")
    luaunit.assert_equals(element:text(), "Accept!")
  end
  self.driver:start_session(callback)
end

function TestSession:test_dismiss_confirm()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/confirm.html")
    local element = session:find_element("css selector", "#button")
    element:click()
    session:dismiss_alert()
    element = session:find_element("css selector", "#confirm")
    luaunit.assert_equals(element:text(), "Dismiss!")
  end
  self.driver:start_session(callback)
end

function TestSession:test_take_screenshot()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local png = session:take_screenshot()
    local header = { png:byte(0, 8) }
    luaunit.assert_equals(header, helper.PNG_HEADER)
  end
  self.driver:start_session(callback)
end

function TestSession:test_save_screenshot()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    session:save_screenshot("session.png")
    local file_handle, err = io.open("session.png", "rb")
    local png = file_handle:read("*a")
    file_handle:close()
    os.remove("session.png")
    local header = { png:byte(0, 8) }
    luaunit.assert_equals(header, helper.PNG_HEADER)
  end
  self.driver:start_session(callback)
end
