local luaunit = require("luaunit")
local web_driver = require("web-driver")

TestWebDriver = {}

function TestWebDriver:test_firefox()
  local driver = web_driver.Firefox.new()
  luaunit.assert_equals(driver:browser(), "firefox")
end
