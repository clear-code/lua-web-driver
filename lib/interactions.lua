local InputDevice = require("lib/interactions/input-device")
local PointerInput = require("lib/interactions/pointer-input")
local KeyInput = require("lib/interactions/key-input")
local NoneInput = require("lib/interactions/none-input")

local Interaction = require("lib/interactions/interaction")
local PointerPress = require("lib/interactions/pointer-press")
local PointerMove = require("lib/interactions/pointer-move")
local PointerCancel = require("lib/interactions/pointer-cancel")
local TypingInteraction = require("lib/interactions/typing-interaction")
local Pause = require("lib/interactions/pause")

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
