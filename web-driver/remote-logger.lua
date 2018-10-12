local socket = require("cqueues.socket")

local LogLevel = require("web-driver/log-level")
local IPCProtocol = require("web-driver/ipc-protocol")
local pp = require("web-driver/pp")

local RemoteLogger = {}

local methods = {}
local metatable = {}

function metatable.__index(geckodriver, key)
  return methods[key]
end

function methods:need_log(level)
  level = LogLevel.resolve(level)
  return level <= self.level
end

function methods:log(level, message)
  if not self:need_log(level) then
    return
  end
  local log_receiver = socket.connect(self.host, self.port)
  IPCProtocol.log(log_receiver, level, message)
end

function methods:traceback(level)
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
  self:log("emergency", ...)
end

function methods:alert(...)
  self:log("alert", ...)
end

function methods:fatal(...)
  self:log("fatal", ...)
end

function methods:error(...)
  self:log("error", ...)
end

function methods:warning(...)
  self:log("warning", ...)
end

function methods:notice(...)
  self:log("notice", ...)
end

function methods:info(...)
  self:log("info", ...)
end

function methods:debug(...)
  self:log("debug", ...)
end

function methods:trace(...)
  self:log("trace", ...)
end

function RemoteLogger.new(host, port, level)
  local remote_logger = {
    host = host,
    port = port,
    level = level,
  }
  setmetatable(remote_logger, metatable)
  return remote_logger
end

function RemoteLogger.is_a(logger)
  return getmetatable(logger) == metatable
end

return RemoteLogger
