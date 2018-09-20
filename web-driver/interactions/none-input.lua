local NoneInput = {}
local InputDevice = require("web-driver/interactions/input-device")

local methods = {}
local metatable = {}

function metatable.__index(input_device, key)
  return methods[key]
end

function methods:type()
  return "none"
end

function methods:encode()
  if self:is_no_actions() then
    return nil
  end
  local actions = {}
  for index, action in self.actions do
    table.insert(actions, action:encode())
  end
  return {
    type = self:type(),
    id = self.name,
    actions = actions
  }
end

function NoneInput.new(name)
  local none_input = InputDevice.new()
  setmetatable(metatable, getmetatable(none_input))
  setmetatable(methods, getmetatable(none_input))
  setmetatable(none_input, metatable)
  return none_input
end

return NoneInput
