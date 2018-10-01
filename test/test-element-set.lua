local luaunit = require("luaunit")
local web_driver = require("web-driver")

local helper = require("test/helper")

TestElementSet = {}

function TestElementSet:setup()
  self.server = helper.start_server()
  self.driver = web_driver.Firefox.new()
end

function TestElementSet:teardown()
  self.server:kill()
end

function TestElementSet:test_css_select()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local element_set = session:css_select("body")
    local sub_element_set = element_set:css_select("p")
    luaunit.assert_equals(sub_element_set:text(),
                          "Hello 1Hello 2Hello 3")
  end
  self.driver:start_session(callback)
end

function TestElementSet:test_xpath_search()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local element_set = session:xpath_search("//body")
    local sub_element_set = element_set:xpath_search(".//p")
    luaunit.assert_equals(sub_element_set:text(),
                          "Hello 1Hello 2Hello 3")
  end
  self.driver:start_session(callback)
end

function TestElementSet:test_link_search()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/link.html")
    local element_set = session:css_select("body")
    local sub_element_set = element_set:link_search("Hello 1")
    luaunit.assert_equals(sub_element_set:text(),
                          "Hello 1Hello 1")
  end
  self.driver:start_session(callback)
end

function TestElementSet:test_partial_link_search()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/link.html")
    local element_set = session:css_select("body")
    local sub_element_set = element_set:partial_link_search("Hello")
    luaunit.assert_equals(sub_element_set:text(),
                          "Hello 1Hello 1" ..
                            "Hello 2Hello 2" ..
                            "Hello 3Hello 3")
  end
  self.driver:start_session(callback)
end

function TestElementSet:test_tag_search()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local element_set = session:css_select("body")
    local sub_element_set = element_set:tag_search("p")
    luaunit.assert_equals(sub_element_set:text(),
                          "Hello 1Hello 2Hello 3")
  end
  self.driver:start_session(callback)
end

