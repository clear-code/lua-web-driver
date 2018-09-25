local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

function callback(session)
  session:navigate_to("https://www.google.com/")
end

driver:start()
driver:start_session(callback)
driver:stop()
