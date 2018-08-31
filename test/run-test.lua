#!/usr/bin/env lua

require("test/test-web-driver")
require("test/test-firefox")
require("test/test-session")
require("test/test-element")

local luaunit = require("luaunit")
os.exit(luaunit.LuaUnit.run())
