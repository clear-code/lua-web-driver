local luaunit = require("luaunit")
local WebDriver = require("web-driver")

TestWebDriver = {}

function TestWebDriver:test_firefox()
  local driver = WebDriver.create("firefox")
  luaunit.assert_equals(driver:browser(), "firefox")
end

function TestWebDriver:test_unknown()
  luaunit.assert_error_msg_contains("Unknown browser: unknown", WebDriver.create, "unknown")
end
