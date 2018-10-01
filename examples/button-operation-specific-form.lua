local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/confirm.html"

local callback = function(session)
  session:navigate_to(URL)
  local element = session:find_element("css selector", "#button")
  element:click()
end

driver:start()
driver:start_session(callback)
driver:stop()
