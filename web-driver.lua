--- WebDriver interface for Lua
--
-- @author Kenji Okimoto
-- @copyright 2018
-- @license MIT
local web_driver = {}

web_driver.VERSION = "0.0.1"
web_driver.Firefox = require("web-driver/firefox")

return web_driver
