local Interaction = {}

local methods = {}
local metatable = {}

function metatable.__index(interaction, key)
  return methods[key]
end

function methods:source()
  return self._source
end

local SOURCE_TYPES = { "key", "pointer", "none" }

function Interaction.new(source)
  local t = source:type()
  if t ~= "key" and t ~= "pointer" and t ~= "none" then
    error("invalid input type: "..t)
  end
  local interaction = {
    _source = source
  }
  setmetatable(interaction, metatable)
  return interaction
end

return Interaction
