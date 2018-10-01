local luaunit = require("luaunit")
local Firefox = require("web-driver/firefox")

TestFirefox = {}

function TestFirefox:test_default_options()
  local firefox = Firefox.new()
  luaunit.assert_equals(firefox.client.base_url, "http://127.0.0.1:4444/")
end
