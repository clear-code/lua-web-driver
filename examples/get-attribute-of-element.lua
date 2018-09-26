local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local callback = function(session)
  session:navigate_to("http://localhost:10080/index.html")
  local element = session:find_element("css selector", "input[name=wine]")
  local name = element:get_attribute("name")
  local type = element:get_attribute("type")
  print(name, type)
end

driver:start()
driver:start_session(callback)
driver:stop()
