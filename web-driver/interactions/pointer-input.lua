local PointerInput = {}
local InputDevice = require("web-driver/interactions/input-device")
local PointerMove = require("web-driver/interactions/pointer-move")
local PointerPress = require("web-driver/interactions/pointer-press")
local PointerCancel = require("web-driver/interactions/pointer-cancel")

local methods = {}
local metatable = {}

function metatable.__index(input_device, key)
  return methods[key]
end

function methods:type()
  return "pointer"
end

function methods:encode()
  if self:is_no_actions() then
    return nil
  end
  local actions = {}
  for index, action in ipairs(self.actions) do
    table.insert(actions, action:encode())
  end
  local output = {
    type = self:type(),
    id = self.name,
    actions = actions
  }
  output["parameters"] = { pointerType = self.kind }
  return output
end

-- options = { duration = 0, x = 0, y = 0, element = nil, origin = nil }
function methods:create_pointer_move(options)
  self:add_action(PointerMove.new(self,
                                  options.duration or 0,
                                  options.x or 0,
                                  options.y or 0,
                                  { element = options.element, origin = options.origin }))
end

function methods:create_pointer_down(button)
  self:add_action(PointerPress.new(self, "down", button))
end

function methods:create_pointer_up(button)
  self:add_action(PointerPress.new(self, "up", button))
end

function methods:create_pointer_cancel()
  self:add_action(PointerCancel.new(self))
end

local KIND = {
  mouse = "mouse",
  pen = "pen",
  touch = "touch"
}

function assert_kind(pointer)
  local k = KIND[pointer]
  if k == nil then
    error("invalid pointer type: "..pointer)
  end
  return k
end

function PointerInput.new(kind, name)
  local pointer_input = InputDevice.new(name)
  pointer_input["kind"] = assert_kind(kind)
  setmetatable(metatable, getmetatable(pointer_input))
  setmetatable(methods, getmetatable(pointer_input))
  setmetatable(pointer_input, metatable)
  return pointer_input
end

return PointerInput
