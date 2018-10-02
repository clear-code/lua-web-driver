local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  session:save_screenshot("sample.png")
end)
