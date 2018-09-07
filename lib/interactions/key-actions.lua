local util = require("lib/util")
local KeyActions = {}

-- { element = element, key = key, device = device }
function KeyActions:key_down(options)
  options["action"] = "create_key_down"
  return self:key_action(options)
end

-- { element = element, key = key, device = device }
function KeyActions:key_up(options)
  options["action"] = "create_key_up"
  return self:key_action(options)
end

-- { element = element, keys = keys, device = device }
function KeyActions:send_keys(options)
  if options.element then
    self:click(options.element)
  end
  if type(options.keys) == "string" then
    local pos = 1
    while pos <= #options.keys do
      local key = string.char(options.keys:byte(pos))
      self:key_down(key, device)
      self:key_up(key, device)
    end
  elseif type(options.keys) == "table" then
    for index, key in pairs(options.keys) do
      self:key_down(key, device)
      self:key_up(key, device)
    end
  else
    error("invalid type: "..type(options.keys)..": "..util.inspect(options.keys))
  end
  return self
end

---
-- @local
-- { element = element, key = key, action = action, device = device }
function KeyActions:key_action(options)
  local key_input = self:get_key_input(options.device)
  if options.element then
    self.click(options.element)
  end
  key_input[options.action](options.key)
  self:tick(key_input)
  return self
end

function KeyActions:get_key_input(device)
  return self:get_device(device) or self:key_inputs()[1]
end

return KeyActions
