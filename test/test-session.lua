local luaunit = require("luaunit")
local process = require("process")
local requests = require("requests")
local WebDriver = require("web-driver")

local base64 = require("base64")
local inspect = require("inspect")

function p(root, options)
  print(inspect.inspect(root, options))
end

TestSession = {}

local capabilities = {
  capabilities = {
    alwaysMatch = {
      acceptInsecureCerts = true,
      ["moz:firefoxOptions"] = {
        args = { "-headless" }
      }
    }
  }
}

function TestSession:start_server(con, thread_number)
  self.server = process.exec("ruby", { "-run", "-e", "httpd", "--", "--port", "10080", "test/fixtures" })
  local success, response
  while true do
    success, response = pcall(requests.get, "http://localhost:10080/index.html")
    if success then
      break
    end
    process.nsleep(1000)
  end
end

function TestSession:stop_server()
  self.server:kill()
end

function TestSession:setup()
  self:start_server()
  self.driver = WebDriver.create("firefox", { capabilities = capabilities })
end

function TestSession:teardown()
  self:stop_server()
end

function TestSession:test_visit()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    luaunit.assert_equals(session:url(), "http://localhost:10080/index.html")
    luaunit.assert_equals(session:title(), "This is test html")
  end
  self.driver:start(callback)
end

function TestSession:test_back_forward()
  local callback = function(session)
    session:visit("http://localhost:10080/1.html")
    luaunit.assert_equals(session:url(), "http://localhost:10080/1.html")
    session:visit("http://localhost:10080/2.html")
    luaunit.assert_equals(session:url(), "http://localhost:10080/2.html")
    session:back()
    luaunit.assert_equals(session:url(), "http://localhost:10080/1.html")
    session:forward()
    luaunit.assert_equals(session:url(), "http://localhost:10080/2.html")
  end
  self.driver:start(callback)
end

function TestSession:test_refresh()
  local callback = function(session)
    session:visit("http://localhost:10080/1.html")
    luaunit.assert_equals(session:url(), "http://localhost:10080/1.html")
    session:refresh()
    luaunit.assert_equals(session:url(), "http://localhost:10080/1.html")
  end
  self.driver:start(callback)
end

function TestSession:test_window_handle()
  local callback = function(session)
    local handle = session:window_handle()
    luaunit.assert_is_string(handle)
    local response = session:switch_to_window(handle)
    luaunit.assert_equals(response.status_code, 200)
    response = session:close_window()
    luaunit.assert_equals(response.status_code, 200)
  end
  self.driver:start(callback)
end

function TestSession:test_window_handles()
  local callback = function(session)
    local handles = session:window_handles()
    luaunit.assert_is_table(handles)
    luaunit.assert_equals(#handles, 1)
  end
  self.driver:start(callback)
end

function TestSession:test_frame()
  local callback = function(session)
    session:visit("http://localhost:10080/frame.html")
    luaunit.assert_equals(session:title(), "This is parent frame")
    local response = session:switch_to_frame(0)
    luaunit.assert_equals(response.status_code, 200)
    local element_id = session:element("css selector", "p")
    luaunit.assert_equals(session:element_text(element_id), "1")
    response = session:switch_to_parent_frame()
    luaunit.assert_equals(response.status_code, 200)
    element_id = session:element("css selector", "p")
    luaunit.assert_equals(session:element_text(element_id), "parent")
    luaunit.assert_equals(session:title(), "This is parent frame")
  end
  self.driver:start(callback)
end

function TestSession:test_window_rect()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    session:set_window_rect({ height = 500, width = 500, x = 0, y = 0 })
    local rect = session:window_rect()
    local expected = { height = 500, width = 500, x = 0, y = 0 }
    luaunit.assert_equals(rect, expected)
  end
  self.driver:start(callback)
end

function TestSession:test_window_fullscreen()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local rect = { height = 500, width = 500, x = 0, y = 0 }
    local expected = { height = 500, width = 500, x = 0, y = 0 }
    session:set_window_rect(rect)
    local response = session:window_fullscreen()
    luaunit.assert_equals(response.status_code, 200)
    session:set_window_rect(rect)
    local actual = session:window_rect()
    luaunit.assert_equals(actual, expected)
  end
  self.driver:start(callback)
end

function TestSession:test_element_active()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    luaunit.assert_nil(session:element_active())
  end
  self.driver:start(callback)
end

function TestSession:test_element()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    element_id = session:element("css selector", "#p1")
    luaunit.assert_equals(session:element_text(element_id), "Hello 1")
  end
  self.driver:start(callback)
end

function TestSession:test_elements()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local element_ids = session:elements("css selector", "p")
    local actual = {}
    for index, element_id in ipairs(element_ids) do
      actual[index] = session:element_text(element_id)
    end
    luaunit.assert_equals(actual, { "Hello 1", "Hello 2", "Hello 3" })
  end
  self.driver:start(callback)
end

function TestSession:test_element_attribute()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local element_id = session:element("css selector", "input[name=cheese]")
    luaunit.assert_equals(session:element_attribute(element_id, "checked"), "true")
    luaunit.assert_equals(session:element_attribute(element_id, "disabled"), "true")

    element_id = session:element("css selector", "input[name=wine]")
    local u1 = session:element_attribute(element_id, "checked")
    local u2 = session:element_attribute(element_id, "disabled")
    luaunit.assert_equals(tostring(u1), "userdata: NULL")
    luaunit.assert_equals(tostring(u2), "userdata: NULL")
  end
  self.driver:start(callback)
end

function TestSession:test_element_property()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local element_id = session:element("css selector", "input[name=cheese]")
    luaunit.assert_equals(session:element_property(element_id, "checked"), true)
    luaunit.assert_equals(session:element_property(element_id, "disabled"), true)

    element_id = session:element("css selector", "input[name=wine]")
    luaunit.assert_equals(session:element_property(element_id, "checked"), false)
    luaunit.assert_equals(session:element_property(element_id, "disabled"), false)
  end
  self.driver:start(callback)
end

function TestSession:test_element_css()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local element_id = session:element("xpath", '//*[@id="p1"]')
    luaunit.assert_equals(session:element_css(element_id, "color"), "rgb(255, 0, 0)")
    luaunit.assert_equals(session:element_css(element_id, "background-color"), "rgba(0, 0, 0, 0)")
  end
  self.driver:start(callback)
end

function TestSession:test_element_text()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local element_id = session:element("css selector", '#p2')
    luaunit.assert_equals(session:element_text(element_id), "Hello 2")
  end
  self.driver:start(callback)
end

function TestSession:test_element_tag()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local element_id = session:element("css selector", '#p2')
    luaunit.assert_equals(session:element_tag(element_id), "p")
  end
  self.driver:start(callback)
end

function TestSession:test_is_element_enabled()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local element_id = session:element("css selector", 'input[name=cheese]')
    luaunit.assert_equals(session:is_element_enabled(element_id), false)

    element_id = session:element("css selector", "input[name=wine]")
    luaunit.assert_equals(session:is_element_enabled(element_id), true)
  end
  self.driver:start(callback)
end

function TestSession:test_element_click()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local element_id = session:element("css selector", 'input[name=wine]')
    luaunit.assert_equals(session:element_property(element_id, "checked"), false)
    session:element_click(element_id)
    luaunit.assert_equals(session:element_property(element_id, "checked"), true)
  end
  self.driver:start(callback)
end

function TestSession:test_source()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
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
    <input id="name" name="name" type="text">
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
  self.driver:start(callback)
end

function TestSession:test_execute_script()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local script = [[return 1]]
    local response = session:execute_script(script)
    luaunit.assert_equals(response, 1)
  end
  self.driver:start(callback)
end

function TestSession:test_execute_script_with_error()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local script = [[return 1 + x]]
    luaunit.assert_error_msg_contains("javascript error: ReferenceError: x is not defined",
                                      session.execute_script, session, script)
  end
  self.driver:start(callback)
end

function TestSession:test_cookie()
  local callback = function(session)
    session:visit("http://localhost:10080/cookie.html")
    luaunit.assert_equals(session:cookie("data1")["value"], "123")
    luaunit.assert_equals(session:cookie("data2")["value"], "456")
  end
  self.driver:start(callback)
end

function TestSession:test_cookies()
  local callback = function(session)
    session:visit("http://localhost:10080/cookie.html")
    local cookies = session:cookies()
    luaunit.assert_equals(#cookies, 2)
  end
  self.driver:start(callback)
end

function TestSession:test_add_cookie()
  local callback = function(session)
    session:visit("http://localhost:10080/cookie.html")
    local cookies = session:cookies()
    luaunit.assert_equals(#cookies, 2)
    local cookie = {
      name = "data3",
      value = "789",
    }
    session:add_cookie(cookie)
    cookies = session:cookies()
    luaunit.assert_equals(#cookies, 3)
    luaunit.assert_equals(session:cookie("data3")["value"], "789")
  end
  self.driver:start(callback)
end

function TestSession:test_delete_cookie()
  local callback = function(session)
    session:visit("http://localhost:10080/cookie.html")
    local cookies = session:cookies()
    luaunit.assert_equals(#cookies, 2)
    session:delete_cookie("data1")
    cookies = session:cookies()
    luaunit.assert_equals(#cookies, 1)
  end
  self.driver:start(callback)
end

function TestSession:test_accept_alert()
  local callback = function(session)
    session:visit("http://localhost:10080/alert.html")
    local response = session:accept_alert()
    luaunit.assert_equals(response.status_code, 200)
    response = session:accept_alert()
    luaunit.assert_equals(response.status_code, 200)
  end
  self.driver:start(callback)
end

function TestSession:test_dismiss_alert()
  local callback = function(session)
    session:visit("http://localhost:10080/alert.html")
    local response = session:dismiss_alert()
    luaunit.assert_equals(response.status_code, 200)
    response = session:dismiss_alert()
    luaunit.assert_equals(response.status_code, 200)
  end
  self.driver:start(callback)
end

function TestSession:test_accept_confirm()
  local callback = function(session)
    session:visit("http://localhost:10080/confirm.html")
    local id = session:element("css selector", "#button")
    session:element_click(id)
    session:accept_alert()
    id = session:element("css selector", "#confirm")
    luaunit.assert_equals(session:element_text(id), "Accept!")
  end
  self.driver:start(callback)
end

function TestSession:test_dismiss_confirm()
  local callback = function(session)
    session:visit("http://localhost:10080/confirm.html")
    local id = session:element("css selector", "#button")
    session:element_click(id)
    session:dismiss_alert()
    id = session:element("css selector", "#confirm")
    luaunit.assert_equals(session:element_text(id), "Dismiss!")
  end
  self.driver:start(callback)
end

local PNG_HEADER = { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A }

function TestSession:test_screenshot()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local value = session:screenshot()
    local binary = base64.decode(value)
    local header = { binary:byte(0, 8) }
    luaunit.assert_equals(header, PNG_HEADER)
  end
  self.driver:start(callback)
end

function TestSession:test_element_screenshot()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local id = session:element("css selector", "#p1")
    local value = session:element_screenshot(id)
    local binary = base64.decode(value)
    local header = { binary:byte(0, 8) }
    luaunit.assert_equals(header, PNG_HEADER)
  end
  self.driver:start(callback)
end

