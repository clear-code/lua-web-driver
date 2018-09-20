local InputDevice = require("web-driver/interactions/input-device")
local PointerInput = require("web-driver/interactions/pointer-input")
local KeyInput = require("web-driver/interactions/key-input")
local NoneInput = require("web-driver/interactions/none-input")

local Interaction = require("web-driver/interactions/interaction")
local PointerPress = require("web-driver/interactions/pointer-press")
local PointerMove = require("web-driver/interactions/pointer-move")
local PointerCancel = require("web-driver/interactions/pointer-cancel")
local TypingInteraction = require("web-driver/interactions/typing-interaction")
local Pause = require("web-driver/interactions/pause")

local Interactions = {
  InputDevice = InputDevice,
  PointerInput = PointerInput,
  KeyInput = KeyInput,

  Interaction = Interaction,
  PointerPress = PointerPress,
  PointerMove = PointerMove,
  PointerCancel = PointerCancel,
  TypingInteraction = TypingInteraction,
  Pause = Pause
}

function Interactions.key(name)
  return KeyInput.new(name)
end

function Interactions.pointer(kind, name)
  return PointerInput.new(kind, name)
end

function Interactions.none(name)
  return NoneInput.new(name)
end

return Interactions
