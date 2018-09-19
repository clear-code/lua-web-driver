local luaunit = require("luaunit")
local WebDriver = require("web-driver")
local helper = require("test/helper")
local p = helper.p
local capabilities = helper.capabilities

TestElement = {}


function TestElement:setup()
  self.server = helper.start_server()
  self.driver = WebDriver.create("firefox", { capabilities = capabilities })
  self.driver:start()
end

function TestElement:teardown()
  self.driver:stop()
  self.server:kill()
end

function TestElement:test_get_attribute()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local element = session:find_element("css selector", "input[name=cheese]")
    luaunit.assert_equals(element:get_attribute("checked"), "true")
    luaunit.assert_equals(element:get_attribute("disabled"), "true")

    element = session:find_element("css selector", "input[name=wine]")
    local u1 = element:get_attribute("checked")
    local u2 = element:get_attribute("disabled")
    luaunit.assert_equals(tostring(u1), "userdata: NULL")
    luaunit.assert_equals(tostring(u2), "userdata: NULL")
  end
  self.driver:start_session(callback)
end

function TestElement:test_get_property()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local element = session:find_element("css selector", "input[name=cheese]")
    luaunit.assert_equals(element:get_property("checked"), true)
    luaunit.assert_equals(element:get_property("disabled"), true)

    element = session:find_element("css selector", "input[name=wine]")
    luaunit.assert_equals(element:get_property("checked"), false)
    luaunit.assert_equals(element:get_property("disabled"), false)
  end
  self.driver:start_session(callback)
end

function TestElement:test_get_css_value()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local element = session:find_element("xpath", '//*[@id="p1"]')
    luaunit.assert_equals(element:get_css_value("color"), "rgb(255, 0, 0)")
    luaunit.assert_equals(element:get_css_value("background-color"), "rgba(0, 0, 0, 0)")
  end
  self.driver:start_session(callback)
end

function TestElement:test_get_text()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local element = session:find_element("css selector", '#p2')
    luaunit.assert_equals(element:get_text(), "Hello 2")
  end
  self.driver:start_session(callback)
end

function TestElement:test_get_tag_name()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local element = session:find_element("css selector", '#p2')
    luaunit.assert_equals(element:get_tag_name(element_id), "p")
  end
  self.driver:start_session(callback)
end

function TestElement:test_is_enabled()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local element = session:find_element("css selector", 'input[name=cheese]')
    luaunit.assert_equals(element:is_enabled(), false)

    element = session:find_element("css selector", "input[name=wine]")
    luaunit.assert_equals(element:is_enabled(), true)
  end
  self.driver:start_session(callback)
end

function TestElement:test_click()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local element = session:find_element("css selector", 'input[name=wine]')
    luaunit.assert_equals(element:get_property("checked"), false)
    element:click()
    luaunit.assert_equals(element:get_property("checked"), true)
  end
  self.driver:start_session(callback)
end

function TestElement:test_send_keys()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local element = session:find_element("css selector", 'input[name=name]')
    local response = element:send_keys("This is test")
    luaunit.assert_equals(response.status_code, 200)
    luaunit.assert_equals(response.text, "{\"value\": null}")
    luaunit.assert_equals(element:get_property("value"), "This is test")
  end
  self.driver:start_session(callback)
end

function TestElement:test_screenshot()
  local callback = function(session)
    session:visit("http://localhost:10080/index.html")
    local element = session:find_element("css selector", "#p1")
    local value = element:screenshot("tmp/element.png")
    local filehandle, err = io.open("tmp/element.png", "rb")
    local binary = filehandle:read("*a")
    filehandle:close()
    os.remove("tmp/element.png")
    local header = { binary:byte(0, 8) }
    luaunit.assert_equals(header, helper.PNG_HEADER)
  end
  self.driver:start_session(callback)
end
