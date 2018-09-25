local uuid = require("web-driver/uuid")
local Pause = require("web-driver/interactions/pause")
local InputDevice = {}

local methods = {}
local metatable = {}

function metatable.__index(input_device, key)
  return methods[key]
end

function methods:add_action(action)
  table.insert(self.actions, action)
end

function methods:clear_actions()
  while next(self.actions) do
    table.remove(self.actions)
  end
end

function methods:create_pause(duration)
  self:add_action(Pause.new(self, duration))
end

function methods:is_no_actions()
  local actions = {}
  for index, action in ipairs(self.actions) do
    if action["type"] ~= "pause" then
      table.insert(actions, action)
    end
  end
  if next(actions) then
    return false
  end
  return true
end

function InputDevice.new(name)
  local device = {
    name = name or uuid.generate(),
    actions = {}
  }
  setmetatable(device, metatable)
  return device
end

return InputDevice
