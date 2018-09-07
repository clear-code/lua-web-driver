local TypingInteraction = {}
local Interaction = require("lib/interactions/interaction")
local Keys = require("lib/keys")

local methods = {}
local metatable = {}

function metatable.__index(typing_interaction, key)
  return methods[key]
end

local SUBTYPES = {
  down  = "keyDown",
  up    = "keyUp",
  pause = "pause"
}

function assert_type(subtype)
  local t = SUBTYPES[subtype]
  if t == nil then
    error("invalid subtype: "..subtype)
  end
  return t
end

function TypingInteraction.new(source, subtype, key)
  local typing_interaction = Interaction.new(source)
  typing_interaction["type"] = assert_type(subtype)
  typing_interaction["key"] = Keys.encode_key(key)
  setmetatable(metatable, getmetatable(typing_interaction))
  setmetatable(methods, getmetatable(typing_interaction))
  setmetatable(typing_interaction, metatable)
  return typing_interaction
end
