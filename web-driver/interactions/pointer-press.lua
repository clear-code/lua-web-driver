local PointerPress = {}
local Interaction = require("web-driver/interactions/interaction")

local methods = {}
local metatable = {}

function metatable.__index(typing_interaction, key)
  return methods[key]
end

function methods:type()
  return self.direction
end

function methods:encode()
  return {
    type = self:type(),
    button = self.button
  }
end

local BUTTONS = {
  left = 0,
  middle = 1,
  right = 2,
}

function assert_button(button)
  if type(button) == "string" then
    local b = BUTTONS[button]
    if b == nil then
      error("invalid button: "..button)
    end
    return b
  end
  if button < 0 then
    error("button number must be positive")
  end
  return button
end

local DIRECTIONS = {
  down = "pointerDown",
  up   = "pointerUp"
}

function assert_direction(direction)
  local d = DIRECTIONS[direction]
  if d == nil then
    error("invalid button direction: "..direction)
  end
  return d
end


function PointerPress.new(source, direction, button)
  local pointer_press = Interaction.new(source)
  pointer_press["direction"] = assert_direction(direction)
  pointer_press["button"] = assert_button(button)
  setmetatable(metatable, getmetatable(pointer_press))
  setmetatable(methods, getmetatable(pointer_press))
  setmetatable(pointer_press, metatable)
  return pointer_press
end

return PointerPress
