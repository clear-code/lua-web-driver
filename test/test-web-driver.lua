local luaunit = require("luaunit")
local WebDriver = require("web-driver")

TestWebDriver = {}

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

function TestWebDriver:test_firefox()
  local driver = WebDriver.create("firefox", { capabilities = capabilities })
  luaunit.assert_equals(driver:browser(), "firefox")
end

function TestWebDriver:test_unknown()
  luaunit.assert_error_msg_contains("Unknown browser: unknown", WebDriver.create, "unknown")
end
