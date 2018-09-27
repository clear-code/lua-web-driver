#!/usr/bin/env lua

require("test/test-firefox")
require("test/test-session")
require("test/test-element")
require("test/test-element-set")

local luaunit = require("luaunit")
os.exit(luaunit.LuaUnit.run())
