local luaunit = require("luaunit")
local Firefox = require("web-driver/firefox")

TestFirefox = {}

function TestFirefox:test_name()
  local firefox = Firefox.new()
  luaunit.assert_equals(firefox:name(), "firefox")
end

function TestFirefox:test_default_options()
  local firefox = Firefox.new()
  luaunit.assert_equals(firefox.bridge.base_url, "http://127.0.0.1:4444/")
end

function TestFirefox:test_start_without_callback()
  local firefox = Firefox.new()
  firefox:start()
  local session = firefox:start_session()
  session:destroy()
  firefox:stop()
end

