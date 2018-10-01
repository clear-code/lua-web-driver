local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/index.html"

local callback = function(session)
  session:navigate_to(URL)
  local element = session:find_element("css selector", "input[name=wine]")
  local name = element:get_attribute("name")
  local type = element:get_attribute("type")
  print(name, type)
end

driver:start()
driver:start_session(callback)
driver:stop()
