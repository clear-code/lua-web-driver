local process = require("process")
local log = require("log")

local pp = require("web-driver/pp")

local Logger = {}

local methods = {}
local metatable = {}

Logger.LEVELS = {
  EMERGENCY = 1,
  ALERT     = 2,
  FATAL     = 3,
  ERROR     = 4,
  WARNING   = 5,
  NOTICE    = 6,
  INFO      = 7,
  DEBUG     = 8,
  TRACE     = 9,
}

local default_level = Logger.LEVELS.NOTICE
local create_default_logger = false
local level_env = process.getenv()["LUA_WEB_DRIVER_LOG_LEVEL"]
if level_env then
  default_level = Logger.LEVELS[level_env:upper()] or default_level
  create_default_logger = true
end

function metatable.__index(geckodriver, key)
  return methods[key]
end

function methods:level()
  return self.backend.level()
end

function methods:log(level, ...)
  self.backend.log(level, ...)
end

function methods:emergency(...)
  self:log(Logger.LEVELS.EMERGENCY, ...)
end

function methods:alert(...)
  self:log(Logger.LEVELS.ALERT, ...)
end

function methods:fatal(...)
  self:log(Logger.LEVELS.FATAL, ...)
end

function methods:error(...)
  self:log(Logger.LEVELS.ERROR, ...)
end

function methods:warning(...)
  self:log(Logger.LEVELS.WARNING, ...)
end

function methods:notice(...)
  self:log(Logger.LEVELS.NOTICE, ...)
end

function methods:info(...)
  self:log(Logger.LEVELS.INFO, ...)
end

function methods:debug(...)
  self:log(Logger.LEVELS.DEBUG, ...)
end

function methods:trace(...)
  self:log(Logger.LEVELS.TRACE, ...)
end

local LUA_LOG_WRITER_NAMES = {
  [Logger.LEVELS.EMERGENCY] = "emerg",
  [Logger.LEVELS.ALERT]     = "alert",
  [Logger.LEVELS.FATAL]     = "fatal",
  [Logger.LEVELS.ERROR]     = "error",
  [Logger.LEVELS.WARNING]   = "warning",
  [Logger.LEVELS.NOTICE]    = "notice",
  [Logger.LEVELS.INFO]      = "info",
  [Logger.LEVELS.DEBUG]     = "debug",
  [Logger.LEVELS.TRACE]     = "trace",
}
local function lua_log_writer_name(level)
  return LUA_LOG_WRITER_NAMES[level]
end

local function detect_backend(real_logger)
  if real_logger then
    if real_logger.lvl then
      -- lua-log
      -- level is compatible.
      return {
        level = function() return real_logger.lvl() end,
        log = function(level, ...)
          real_logger[lua_log_writer_name(level)](...)
        end,
      }
    else
      error("web-driver: Unsupported logger: " .. pp.format(real_logger))
    end
  end
  return {
    level = function() return default_level end,
    log = function(level, ...) end,
  }
end

function Logger.new(real_logger)
  if real_logger == nil and create_default_logger then
    local stderr_writer = require("log/writer/stderr")
    real_logger = log.new(default_level,
                          stderr_writer.new())
  end
  local logger = {
    logger = real_logger,
    backend = detect_backend(real_logger),
  }
  setmetatable(logger, metatable)
  return logger
end

return Logger
