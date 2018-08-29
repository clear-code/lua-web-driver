local FirefoxDriver = require "lib/firefox"

local web_driver = {}

web_driver.VERSION = "0.0.1"

web_driver.create = function(browser, options)
  if browser == "firefox" then
    return FirefoxDriver.new(options or {})
  else
    error("Unknown browser: "..browser)
  end
end

return web_driver
