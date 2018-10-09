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

function TestElementSet:test_texts()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local element_set = session:css_select("body")
    local sub_element_set = element_set:tag_search("p")
    local expected = { "Hello 1", "Hello 2", "Hello 3" }
    luaunit.assert_equals(sub_element_set:texts(),
                          expected)
  end
  self.driver:start_session(callback)
end

function TestElementSet:test_click()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local element_set = session:css_select('input[name=wine]')
    luaunit.assert_equals(element_set[1].checked, false)
    element_set:click()
    luaunit.assert_equals(element_set[1].checked, true)
  end
  self.driver:start_session(callback)
end

function TestElementSet:test_send_keys()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local element_set = session:css_select('input[name=name]')
    element_set:send_keys("This is test")
    luaunit.assert_equals(element[1].value, "This is test")
  end
end

function TestElementSet:test_insert()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local p = session:css_select('p')
    local checkbox = session:find_element("css selector", 'input[name=cheese]')
    p:insert(1, checkbox)
    luaunit.assert_equals(p[1].name, "cheese")
  end
end

function TestElementSet:test_insert_same_object()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local p = session:css_select('p')
    local checkbox1 = session:find_element("css selector", 'input[name=cheese]')
    p:insert(1, checkbox1)
    local checkbox2 = session:find_element("css selector", 'input[name=cheese]')
    p:insert(1, checkbox2)
    luaunit.assert_equals(p[1].name, "cheese")
    luaunit.assert_nil(p[2])
  end
end

function TestElementSet:test_merge()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local p = session:css_select('p')
    local label = session:css_select('label')
    merged_element = p:merge(label)
    local expected = { "Hello 1", "Hello 2", "Hello 3", "Cheese", "Wine" }
    luaunit.assert_equals(merged_element:texts(),
                          expected)
 end
end

function TestElementSet:test_merge_same_object()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local p = session:css_select('p')
    local label1 = session:css_select('label')
    local label2 = session:css_select('label')
    local merged_element = p:merge(label1)
    merged_element = merged_element:merge(label2)
    local expected = { "Hello 1", "Hello 2", "Hello 3", "Cheese", "Wine" }
    luaunit.assert_equals(merged_element:texts(),
                          expected)
 end
end

function TestElementSet:test_remove()
  local callback = function(session)
    session:navigate_to("http://localhost:10080/index.html")
    local p = session:css_select('p')
    p:remove(2)
    local expected = { "Hello 1", "Hello 3" }
    luaunit.assert_equals(p:texts(),
                          expected)
 end
end
