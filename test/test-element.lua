local luaunit = require("luaunit")
local web_driver = require("web-driver")
local helper = require("test/helper")
local pp = require("web-driver/pp")

TestElement = {}


function TestElement:setup()
  self.server = helper.start_server()
  self.driver = web_driver.Firefox.new()
end

function TestElement:teardown()
  self.server:kill()
end

function TestElement:test_get_attribute()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local element = session:find_element("css selector", "input[name=cheese]")
    luaunit.assert_equals(element:get_attribute("checked"), "true")
    luaunit.assert_equals(element:get_attribute("disabled"), "true")

    element = session:find_element("css selector", "input[name=wine]")
    local u1 = element:get_attribute("checked")
    local u2 = element:get_attribute("disabled")
    luaunit.assert_equals(u1, nil)
    luaunit.assert_equals(u2, nil)
  end
  self.driver:start_session(callback)
end

function TestElement:test_get_attribute_shortcut()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local element = session:find_element("css selector", "input[type=text]")
    luaunit.assert_equals(element["data-placeholder"], "Input your name")
    luaunit.assert_equals(element.noneixstent, nil)
  end
  self.driver:start_session(callback)
end

function TestElement:test_get_property()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local element = session:find_element("css selector", "input[name=cheese]")
    luaunit.assert_equals(element:get_property("checked"), true)
    luaunit.assert_equals(element:get_property("disabled"), true)

    element = session:find_element("css selector", "input[name=wine]")
    luaunit.assert_equals(element:get_property("checked"), false)
    luaunit.assert_equals(element:get_property("disabled"), false)
  end
  self.driver:start_session(callback)
end

function TestElement:test_get_property_shortcut()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local element = session:find_element("css selector", "input[name=cheese]")
    luaunit.assert_equals(element.checked, true)
    luaunit.assert_equals(element.disabled, true)

    element = session:find_element("css selector", "input[name=wine]")
    luaunit.assert_equals(element.checked, false)
    luaunit.assert_equals(element.disabled, false)
  end
  self.driver:start_session(callback)
end

function TestElement:test_get_css_value()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local element = session:find_element("xpath", '//*[@id="p1"]')
    luaunit.assert_equals(element:get_css_value("color"), "rgb(255, 0, 0)")
    luaunit.assert_equals(element:get_css_value("background-color"), "rgba(0, 0, 0, 0)")
  end
  self.driver:start_session(callback)
end

function TestElement:test_get_css_value_shortcut()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local element = session:find_element("xpath", '//*[@id="p1"]')
    luaunit.assert_equals(element.color, "rgb(255, 0, 0)")
    luaunit.assert_equals(element["background-color"], "rgba(0, 0, 0, 0)")
  end
  self.driver:start_session(callback)
end

function TestElement:test_text()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local element = session:find_element("css selector", '#p2')
    luaunit.assert_equals(element:text(), "Hello 2")
  end
  self.driver:start_session(callback)
end

function TestElement:test_tag_name()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local element = session:find_element("css selector", '#p2')
    luaunit.assert_equals(element:tag_name(element_id), "p")
  end
  self.driver:start_session(callback)
end

function TestElement:test_is_enabled()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local element = session:find_element("css selector", 'input[name=cheese]')
    luaunit.assert_equals(element:is_enabled(), false)

    element = session:find_element("css selector", "input[name=wine]")
    luaunit.assert_equals(element:is_enabled(), true)
  end
  self.driver:start_session(callback)
end

function TestElement:test_click()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local element = session:find_element("css selector", 'input[name=wine]')
    luaunit.assert_equals(element:get_property("checked"), false)
    element:click()
    luaunit.assert_equals(element:get_property("checked"), true)
  end
  self.driver:start_session(callback)
end

function TestElement:test_clear()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local text = session:css_select("input[type=text]")[1]
    text:send_keys("My Name")
    luaunit.assert_equals(text.value, "My Name")
    text:clear()
    luaunit.assert_equals(text.value, "")
  end
  self.driver:start_session(callback)
end

function TestElement:test_send_keys()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local element = session:find_element("css selector", 'input[name=name]')
    element:send_keys("This is test")
    luaunit.assert_equals(element:get_property("value"), "This is test")
  end
  self.driver:start_session(callback)
end

function TestElement:test_take_screenshot()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local element = session:find_element("css selector", "#p1")
    local png = element:take_screenshot("tmp/element.png")
    local header = { png:byte(0, 8) }
    luaunit.assert_equals(header, helper.PNG_HEADER)
  end
  self.driver:start_session(callback)
end

function TestElement:test_save_screenshot()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local element = session:find_element("css selector", "#p1")
    element:save_screenshot("element.png")
    local file_handle, err = io.open("element.png", "rb")
    local png = file_handle:read("*a")
    file_handle:close()
    os.remove("element.png")
    local header = { png:byte(0, 8) }
    luaunit.assert_equals(header, helper.PNG_HEADER)
  end
  self.driver:start_session(callback)
end
