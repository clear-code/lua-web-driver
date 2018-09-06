local WebDriver = require("web-driver")

local driver = WebDriver.create("firefox")

function callback(session)
  session:visit("https://www.google.com/")
  -- TODO
end

driver.start(callback)
