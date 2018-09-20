local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

function callback(session)
  session:visit("https://www.google.com/")
  local xml = session:xml()
  print(xml)
end

driver:start()
driver:start_session(callback)
driver:stop()
