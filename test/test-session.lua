local luaunit = require("luaunit")
local web_driver = require("web-driver")

local base64 = require("base64")
local helper = require("test/helper")

TestSession = {}

function TestSession:setup()
  self.server = helper.start_server()
  self.driver = web_driver.Firefox.new()
end

function TestSession:teardown()
  self.server:kill()
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
    local handle = session:window_handle()
    luaunit.assert_is_string(handle)
    local response = session:switch_to_window(handle)
    luaunit.assert_equals(response.status_code, 200)
  end
  self.driver:start_session(callback)
end

function TestSession:test_window_handles()
  local callback = function(session)
    local handles = session:window_handles()
    luaunit.assert_is_table(handles)
    luaunit.assert_equals(#handles, 1)
  end
  self.driver:start_session(callback)
end

function TestSession:test_frame()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/frame.html")
    luaunit.assert_equals(session:title(), "This is parent frame")
    local response = session:switch_to_frame(0)
    luaunit.assert_equals(response.status_code, 200)
    local element = session:find_element("css selector", "p")
    luaunit.assert_equals(element:text(), "1")
    response = session:switch_to_parent_frame()
    luaunit.assert_equals(response.status_code, 200)
    element = session:find_element("css selector", "p")
    luaunit.assert_equals(element:text(), "parent")
    luaunit.assert_equals(session:title(), "This is parent frame")
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

function TestSession:test_window_fullscreen()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local rect = { height = 500, width = 500, x = 0, y = 0 }
    local expected = { height = 500, width = 500, x = 0, y = 0 }
    session:set_window_rect(rect)
    local response = session:fullscreen_window()
    luaunit.assert_equals(response.status_code, 200)
    session:set_window_rect(rect)
    local actual = session:window_rect()
    luaunit.assert_equals(actual, expected)
  end
  self.driver:start_session(callback)
end

function TestSession:test_window_maximize_window()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local rect = { height = 500, width = 500, x = 0, y = 0 }
    local expected = { height = 500, width = 500, x = 0, y = 0 }
    session:set_window_rect(rect)

    local response = session:maximize_window()
    luaunit.assert_equals(response.status_code, 200)
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

function TestSession:test_execute_script()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local script = [[return 1]]
    local response = session:execute_script(script)
    luaunit.assert_equals(response, 1)
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
    local cookies = session:all_cookies()
    luaunit.assert_equals(#cookies, 2)
    local cookie = {
      name = "data3",
      value = "789",
    }
    session:add_cookie(cookie)
    cookies = session:all_cookies()
    luaunit.assert_equals(#cookies, 3)
    luaunit.assert_equals(session:get_cookie("data3")["value"], "789")
  end
  self.driver:start_session(callback)
end

function TestSession:test_delete_cookie()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/cookie.html")
    local cookies = session:all_cookies()
    luaunit.assert_equals(#cookies, 2)
    session:delete_cookie("data1")
    cookies = session:all_cookies()
    luaunit.assert_equals(#cookies, 1)
  end
  self.driver:start_session(callback)
end

function TestSession:test_delete_all_cookies()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/cookie.html")
    local cookies = session:all_cookies()
    luaunit.assert_equals(#cookies, 2)
    session:delete_all_cookies()
    cookies = session:all_cookies()
    luaunit.assert_equals(#cookies, 0)
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
