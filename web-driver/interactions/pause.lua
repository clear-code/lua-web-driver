local Interaction = require("web-driver/interactions/interaction")

local Pause = {}

local methods = {}
local metatable = {}

function metatable.__index(pause, key)
  return methods[key]
end

function methods:type()
  return "pause"
end

function methods:encode()
  local output = {
    ["type"] = self:type()
  }
  if self.duration then
    output["duration"] = math.floor(self.duration)
  end
  return output
end

function Pause.new(source, duration)
  local pause = Interaction.new(source)
  if duration then
    pause["duration"] = duration * 1000
  end
  setmetatable(metatable, getmetatable(pause))
  setmetatable(methods, getmetatable(pause))
  setmetatable(pause, metatable)
  return pause
end

return Pause
