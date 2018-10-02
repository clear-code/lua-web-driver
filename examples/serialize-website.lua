local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/index.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local xml = session:xml()
  print(xml)
end)
