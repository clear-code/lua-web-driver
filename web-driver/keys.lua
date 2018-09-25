local utf8 = require("lua-utf8")
local u = utf8.escape
local Keys = {}

local KEYS = {
  ["null"]             = u("%x{000}"),
  ["cancel"]           = u("%x{001}"),
  ["help"]             = u("%x{002}"),
  ["backspace"]        = u("%x{003}"),
  ["tab"]              = u("%x{004}"),
  ["clear"]            = u("%x{005}"),
  ["return"]           = u("%x{006}"),
  ["enter"]            = u("%x{007}"),
  ["shift"]            = u("%x{008}"),
  ["left_shift"]       = u("%x{008}"),
  ["control"]          = u("%x{009}"),
  ["left_control"]     = u("%x{009}"),
  ["alt"]              = u("%x{00A}"),
  ["left_alt"]         = u("%x{00A}"),
  ["pause"]            = u("%x{00B}"),
  ["escape"]           = u("%x{00C}"),
  ["space"]            = u("%x{00D}"),
  ["page_up"]          = u("%x{00E}"),
  ["page_down"]        = u("%x{00F}"),
  ["end"]              = u("%x{010}"),
  ["home"]             = u("%x{011}"),
  ["left"]             = u("%x{012}"),
  ["arrow_left"]       = u("%x{012}"),
  ["up"]               = u("%x{013}"),
  ["arrow_up"]         = u("%x{013}"),
  ["right"]            = u("%x{014}"),
  ["arrow_right"]      = u("%x{014}"),
  ["down"]             = u("%x{015}"),
  ["arrow_down"]       = u("%x{015}"),
  ["insert"]           = u("%x{016}"),
  ["delete"]           = u("%x{017}"),
  ["semicolon"]        = u("%x{018}"),
  ["equals"]           = u("%x{019}"),
  ["numpad0"]          = u("%x{01A}"),
  ["numpad1"]          = u("%x{01B}"),
  ["numpad2"]          = u("%x{01C}"),
  ["numpad3"]          = u("%x{01D}"),
  ["numpad4"]          = u("%x{01E}"),
  ["numpad5"]          = u("%x{01F}"),
  ["numpad6"]          = u("%x{020}"),
  ["numpad7"]          = u("%x{021}"),
  ["numpad8"]          = u("%x{022}"),
  ["numpad9"]          = u("%x{023}"),
  ["multiply"]         = u("%x{024}"),
  ["add"]              = u("%x{025}"),
  ["separator"]        = u("%x{026}"),
  ["subtract"]         = u("%x{027}"),
  ["decimal"]          = u("%x{028}"),
  ["divide"]           = u("%x{029}"),
  ["f1"]               = u("%x{031}"),
  ["f2"]               = u("%x{032}"),
  ["f3"]               = u("%x{033}"),
  ["f4"]               = u("%x{034}"),
  ["f5"]               = u("%x{035}"),
  ["f6"]               = u("%x{036}"),
  ["f7"]               = u("%x{037}"),
  ["f8"]               = u("%x{038}"),
  ["f9"]               = u("%x{039}"),
  ["f10"]              = u("%x{03A}"),
  ["f11"]              = u("%x{03B}"),
  ["f12"]              = u("%x{03C}"),
  ["meta"]             = u("%x{03D}"),
  ["command"]          = u("%x{03D}"), -- alias
  ["left_meta"]        = u("%x{03D}"), -- alias
  ["right_shift"]      = u("%x{050}"),
  ["right_control"]    = u("%x{051}"),
  ["right_alt"]        = u("%x{052}"),
  ["right_meta"]       = u("%x{053}"),
  ["numpad_page_up"]   = u("%x{054}"),
  ["numpad_page_down"] = u("%x{055}"),
  ["numpad_end"]       = u("%x{056}"),
  ["numpad_home"]      = u("%x{057}"),
  ["numpad_left"]      = u("%x{058}"),
  ["numpad_up"]        = u("%x{059}"),
  ["numpad_right"]     = u("%x{05A}"),
  ["numpad_down"]      = u("%x{05B}"),
  ["numpad_insert"]    = u("%x{05C}"),
  ["numpad_delete"]    = u("%x{05D}")
}

local metatable = {}

function metatable.__index(self, key)
  return KEYS[key]
end

setmetatable(Keys, metatable)

function Keys.encode(keys)
  local _keys = {}
  for index, key in ipairs(keys) do
    _keys[index] = Keys.encode_key(key)
  end
  return _keys
end

function Keys.encode_key(key)
  local _key = Keys[key]
  if _key then
    return _key
  end
  return key
end

return Keys
