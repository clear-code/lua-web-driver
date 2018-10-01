local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/index.html"

local callback = function(session)
  session:navigate_to(URL)
  local element = session:find_element("css selector", 'input[name=name]')
  element:send_keys("This is test")
end

driver:start()
driver:start_session(callback)
driver:stop()
