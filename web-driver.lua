--- WebDriver interface for Lua
--
-- @author Kenji Okimoto <okimoto@clear-code.com>
-- @author Horimoto Yasuhiro <horimoto@clear-code.com>
-- @author Kouhei Sutou <kou@clear-code.com>
-- @copyright 2018
-- @license MIT
local web_driver = {}

web_driver.VERSION = "0.1.3"
web_driver.Firefox = require("web-driver/firefox")
web_driver.ThreadPool = require("web-driver/thread-pool")

return web_driver
