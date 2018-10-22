local LogLevel = {}

LogLevel.EMERGENCY = 1
LogLevel.ALERT     = 2
LogLevel.FATAL     = 3
LogLevel.ERROR     = 4
LogLevel.WARNING   = 5
LogLevel.NOTICE    = 6
LogLevel.INFO      = 7
LogLevel.DEBUG     = 8
LogLevel.TRACE     = 9

function LogLevel.resolve(level)
  if type(level) == "string" then
    local level_number = LogLevel[level:upper()]
    if not level_number then
      error("web-driver: LogLevel: Invalid: <" .. level .. ">")
    end
    return level_number
  else
    return level
  end
end

LogLevel.DEFAULT = LogLevel.NOTICE
local level_env = os.getenv("LUA_WEB_DRIVER_LOG_LEVEL")
if level_env then
  LogLevel.DEFAULT = LogLevel.resolve(level_env)
end

return LogLevel
