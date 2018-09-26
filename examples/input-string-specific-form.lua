local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local callback = function(session)
  session:navigate_to("http://localhost:10080/index.html")
  local element = session:find_element("css selector", 'input[name=name]')
  element:send_keys("This is test")
end

driver:start()
driver:start_session(callback)
driver:stop()
