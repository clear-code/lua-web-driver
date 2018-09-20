local PointerCancel = {}
local Interaction = require("web-driver/interactions/interaction")

local methods = {}
local metatable = {}

function metatable.__index(typing_interaction, key)
  return methods[key]
end

function methods:type()
  return "pointerCancel"
end

function methods:encode()
  return { type = self:type() }
end

function PointerCancel.new(source)
  local pointer_cancel = Interaction.new(source)
  setmetatable(metatable, getmetatable(pointer_cancel))
  setmetatable(methods, getmetatable(pointer_cancel))
  setmetatable(pointer_cancel, metatable)
  return pointer_cancel
end

return PointerCancel
