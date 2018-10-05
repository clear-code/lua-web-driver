local luaunit = require("luaunit")
local Logger = require("web-driver/logger")
local log = require("log")

local helper = require("test/helper")

TestLogger = {}

local function string_writer_new(output)
  return function(formatter, ...)
    output.data = output.data .. formatter(...) .. "\n"
  end
end

function TestLogger:setup()
  self.data = ""
  self.logger = Logger.new(log.new("trace", string_writer_new(self)))
end

function TestLogger:teardown()
end

local function normalize(log)
  return log:gsub("^%d+-%d+-%d+ %d+:%d+:%d+",
                  "2000-01-01 00:00:00")
end

function TestLogger:test_emergency()
  self.logger:emergency("Emergency")
  luaunit.assert_equals(normalize(self.data),
                        "2000-01-01 00:00:00 [EMERG] Emergency\n")
end

function TestLogger:test_alert()
  self.logger:alert("Alert")
  luaunit.assert_equals(normalize(self.data),
                        "2000-01-01 00:00:00 [ALERT] Alert\n")
end

function TestLogger:test_fatal()
  self.logger:fatal("Fatal")
  luaunit.assert_equals(normalize(self.data),
                        "2000-01-01 00:00:00 [FATAL] Fatal\n")
end

function TestLogger:test_error()
  self.logger:error("Error")
  luaunit.assert_equals(normalize(self.data),
                        "2000-01-01 00:00:00 [ERROR] Error\n")
end

function TestLogger:test_warning()
  self.logger:warning("Warning")
  luaunit.assert_equals(normalize(self.data),
                        "2000-01-01 00:00:00 [WARNING] Warning\n")
end

function TestLogger:test_notice()
  self.logger:notice("Notice")
  luaunit.assert_equals(normalize(self.data),
                        "2000-01-01 00:00:00 [NOTICE] Notice\n")
end

function TestLogger:test_info()
  self.logger:info("Info")
  luaunit.assert_equals(normalize(self.data),
                        "2000-01-01 00:00:00 [INFO] Info\n")
end

function TestLogger:test_debug()
  self.logger:debug("Debug")
  luaunit.assert_equals(normalize(self.data),
                        "2000-01-01 00:00:00 [DEBUG] Debug\n")
end

function TestLogger:test_trace()
  self.logger:trace("Trace")
  luaunit.assert_equals(normalize(self.data),
                        "2000-01-01 00:00:00 [TRACE] Trace\n")
end

function TestLogger:test_max_level()
  self.logger = Logger.new(log.new("debug", string_writer_new(self)))
  self.logger:trace("Trace")
  luaunit.assert_equals(normalize(self.data), "")
end
