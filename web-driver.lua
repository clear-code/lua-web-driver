--- WebDriver interface for Lua
--
-- @author Kenji Okimoto
-- @copyright 2018
-- @license MIT
local FirefoxDriver = require "lib/firefox"

local WebDriver = {}

WebDriver.VERSION = "0.0.1"

--- Create driver object
-- @param browser the name of browser
-- @param options
-- @return a driver object
WebDriver.create = function(browser, options)
  if browser == "firefox" then
    return FirefoxDriver.new(options or {})
  else
    error("Unknown browser: "..browser)
  end
end

return WebDriver
