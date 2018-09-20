local PointerMove = {}
local Interaction = require("web-driver/interactions/interaction")

local methods = {}
local metatable = {}

function metatable.__index(typing_interaction, key)
  return methods[key]
end

function methods:type()
  return "pointerMove"
end

function methods:encode()
  local output = {
    type = self:type(),
    duration = self.duration,
    x = self.x_offset,
    y = self.y_offset
  }
  if self.origin then
    if type(self.origin) == "string" then
      output["origin"] = self.origin
    else
      -- self.origin is an Element
      output["origin"] = self.origin:to_data()
    end
  end
  return output
end

function PointerMove.new(source, duration, x, y, options)
  local pointer_move = Interaction.new(source)
  pointer_move["duration"] = duration * 1000
  pointer_move["x_offset"] = x
  pointer_move["y_offset"] = y
  pointer_move["origin"] = options.element or options.origin
  setmetatable(metatable, getmetatable(pointer_move))
  setmetatable(methods, getmetatable(pointer_move))
  setmetatable(pointer_move, metatable)
  return pointer_move
end

return PointerMove
