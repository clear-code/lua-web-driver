local log = require("log")

local LogLevel = require("web-driver/log-level")
local RemoteLogger = require("web-driver/remote-logger")
local LogFormatter = require("web-driver/log-formatter")
local pp = require("web-driver/pp")

local Logger = {}

local methods = {}
local metatable = {}

local create_default_logger = (os.getenv("LUA_WEB_DRIVER_LOG_LEVEL") ~= nil)

function metatable.__index(geckodriver, key)
  return methods[key]
end

function methods:level()
  return self.backend.level()
end

function methods:need_log(level)
  level = LogLevel.resolve(level)
  return level <= self:level()
end

function methods:log(level, ...)
  self.backend.log(level, ...)
end

function methods:traceback(level)
  level = LogLevel.resolve(level)
  if not self:need_log(level) then
    return
  end
  self:log(level, "web-driver: Traceback:")
  local offset = 2
  local deep_level = offset
  while true do
    local info = debug.getinfo(deep_level, "Sl")
    if not info then
      break
    end
    self:log(level,
             string.format("web-driver: %d: %s:%d",
                           deep_level - offset + 1,
                           info.short_src,
                           info.currentline))
    deep_level = deep_level + 1
  end
end

function methods:emergency(...)
  self:log(LogLevel.EMERGENCY, ...)
end

function methods:alert(...)
  self:log(LogLevel.ALERT, ...)
end

function methods:fatal(...)
  self:log(LogLevel.FATAL, ...)
end

function methods:error(...)
  self:log(LogLevel.ERROR, ...)
end

function methods:warning(...)
  self:log(LogLevel.WARNING, ...)
end

function methods:notice(...)
  self:log(LogLevel.NOTICE, ...)
end

function methods:info(...)
  self:log(LogLevel.INFO, ...)
end

function methods:debug(...)
  self:log(LogLevel.DEBUG, ...)
end

function methods:trace(...)
  self:log(LogLevel.TRACE, ...)
end

local LUA_LOG_WRITER_NAMES = {
  [LogLevel.EMERGENCY] = "emerg",
  [LogLevel.ALERT]     = "alert",
  [LogLevel.FATAL]     = "fatal",
  [LogLevel.ERROR]     = "error",
  [LogLevel.WARNING]   = "warning",
  [LogLevel.NOTICE]    = "notice",
  [LogLevel.INFO]      = "info",
  [LogLevel.DEBUG]     = "debug",
  [LogLevel.TRACE]     = "trace",
}
local function lua_log_writer_name(level)
  return LUA_LOG_WRITER_NAMES[level]
end

local function detect_backend(real_logger)
  if real_logger then
    if RemoteLogger.is_a(real_logger) then
      return {
        level = function() return real_logger.level end,
        log = function(level, ...)
          if type(level) == "number" then
            level = lua_log_writer_name(level)
          end
          real_logger:log(level, ...)
        end,
      }
    elseif real_logger.lvl then
      -- lua-log
      -- level is compatible.
      return {
        level = function() return real_logger.lvl() end,
        log = function(level, ...)
          if type(level) == "number" then
            level = lua_log_writer_name(level)
          end
          real_logger[level](...)
        end,
      }
    else
      error("web-driver: Unsupported logger: " .. pp.format(real_logger))
    end
  end
  return {
    level = function() return LogLevel.DEFAULT end,
    log = function(level, ...) end,
  }
end

function Logger.new(real_logger)
  if real_logger == nil and create_default_logger then
    local StdErrWriter = require("log/writer/stderr")
    local formatter = nil
    local log_formatter = LogFormatter.new()
    real_logger = log.new(lua_log_writer_name(LogLevel.DEFAULT),
                          StdErrWriter.new(),
                          formatter,
                          log_formatter)
  end
  local logger = {
    logger = real_logger,
    backend = detect_backend(real_logger),
  }
  setmetatable(logger, metatable)
  return logger
end

return Logger
