local log = require("log")

local pp = require("web-driver/pp")

local LogFormatter = {}

function LogFormatter.new()
  return function(message, level, now)
    return string.format("%s [%s] %s",
                         now:fmt("%Y-%m-%dT%H:%M:%\f"),
                         log.LVL_NAMES[level],
                         message)
  end
end

return LogFormatter
