local luaunit = require("luaunit")
local FirefoxDriver = require("lib/firefox")

TestFirefoxDriver = {}

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

function TestFirefoxDriver:test_browser()
  local driver = FirefoxDriver.new({ capabilities = capabilities })
  luaunit.assert_equals(driver:browser(), "firefox")
end

function TestFirefoxDriver:test_default_options()
  local driver = FirefoxDriver.new({})
  luaunit.assert_equals(driver.bridge.base_url, "http://127.0.0.1:4444/")
end

function TestFirefoxDriver:test_wait_for_ready()
  local driver = FirefoxDriver.new({})
  luaunit.assert_equals(driver:wait_for_ready(), false)
end

function TestFirefoxDriver:test_start_without_callback()
  local driver = FirefoxDriver.new({})
  driver:start()
  luaunit.assert_equals(driver:wait_for_ready(), true)
  driver:stop()
  local status = driver:status()
  luaunit.assert_equals(status.ready, false)
  luaunit.assert_equals(status.message, "Timeout: geckodriver may not be running")
end

