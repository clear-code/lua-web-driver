local util = require("lib/util")

local ActionBuilder = {}

local methods = {}
local metatable = {}

function metatable.__index(builder, key)
  -- builder is a ActionBuilder instance
  return methods[key]
end

local KeyActions = require("lib/interactions/key-actions")
for key, method in pairs(KeyActions) do
  methods[key] = method
end

local PointerActions = require("lib/interactions/pointer-actions")
for key, method in pairs(PointerActions) do
  methods[key] = method
end

function methods:add_pointer_input(kind, name)
  local new_input = Interactions.pointer(kind, name)
  self:add_input(new_input)
  return new_input
end

function methods:add_key_input(name)
  local new_input = Interactions.key(name)
  self:add_input(new_input)
  return new_input
end

function methods:get_device(name)
  for index, device in ipairs(self.devices) do
    if device.name == name then
      return device
    end
  end
  return nil
end

function methods:pointer_inputs()
  local inputs = {}
  for index, device in ipairs(self.devices) do
    if device:type() == "pointer" then
      table.insert(inputs, device)
    end
  end
  return inputs
end

function methods:key_inputs()
  local inputs = {}
  for index, device in ipairs(self.devices) do
    if device:type() == "key" then
      table.insert(inputs, device)
    end
  end
  return inputs
end

function methods:pause(device, duration)
  device:create_pause(duration)
  return self
end

function methods:pauses(device, number, duration)
  for n = 1, number do
    device:create_pause(duration)
  end
  return self
end

function methods:perform()
  local actions = self:build()
  self.session:perform_actions(actions)
  self:clear_all_actions()
end

function methods:clear_all_actions()
  for index, device in ipairs(self.devices) do
    device:clear_actions()
  end
end

function methods:build()
  local actions = {}
  local actions = {}
  for index, device in ipairs(self.devices) do
    local action = device:encode()
    if action then
      table.insert(actions, action)
    end
  end
  return actions
end

function methods:release_actions()
  self.session:release_actions()
end

function methods:add_input(device)
  table.insert(self.devices, device)
end

function methods:tick(action_devices)
  if self.async then
    return nil
  end
  for _, device in ipairs(self.devices) do
    local is_active = false
    for _, action_device in ipairs(action_devices) do
      is_active = is_active or (action_device == device)
    end
    if is_active then
      device:create_pause()
    end
  end
end

function ActionBuilder.new(session, mouse, keyboard, async)
  local builder = {
    session = session,
    devices = { mouse, keyboard },
    async = async or false,
    actions = {}
  }
  setmetatable(builder, metatable)
  return builder
end

return ActionBuilder
