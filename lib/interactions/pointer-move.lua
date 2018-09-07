local PointerMove = {}
local Interaction = require("lib/interactions/interaction")

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
  return output
end

function PointerMove.new(source, duration, x, y, options)
  local pointer_move = Interaction.new(source)
  pointer_move["duration"] = duration * 1000
  pointer_move["x_offset"] = x
  pointer_move["y_offset"] = y
  pointer_move["origin"] = options.element or options.origin
  setmetatable(metatable, getmetatable(pointer_move))
  setmetatable(pointer_move, metatable)
  return pointer_move
end

return PointerMove
