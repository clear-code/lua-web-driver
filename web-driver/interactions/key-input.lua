local KeyInput = {}
local InputDevice = require("web-driver/interactions/input-device")
local TypingInteraction = require("web-driver/interactions/typing-interaction")

local methods = {}
local metatable = {}

function metatable.__index(input_device, key)
  return methods[key]
end

function methods:type()
  return "key"
end

function methods:encode()
  if self:is_no_actions() then
    return nil
  end
  local actions = {}
  for index, action in ipairs(self.actions) do
    table.insert(actions, action:encode())
  end
  return {
    type = self:type(),
    id = self.name,
    actions = actions
  }
end

function methods:create_key_down(key)
  self:add_action(TypingInteraction.new(self, "down", key))
end

function methods:create_key_up(key)
  self:add_action(TypingInteraction.new(self, "up", key))
end

function KeyInput.new(name)
  local key_input = InputDevice.new(name)
  setmetatable(metatable, getmetatable(key_input))
  setmetatable(methods, getmetatable(key_input))
  setmetatable(key_input, metatable)
  return key_input
end

return KeyInput
