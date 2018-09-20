--- Utility class for internal use
--
-- @classmod Util
-- @local
local inspect = require("inspect")

local util = {}

function util.p(root, options)
  print(inspect.inspect(root, options))
end

function util.inspect(root, options)
  return inspect.inspect(root, options)
end

function util.element_id_from(id)
  return id["ELEMENT"] or id["element-6066-11e4-a52e-4f735466cecf"]
end

-- https://gist.github.com/jrus/3197011
function util.uuid()
  local template ="xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
  function callback(c)
    if c == "x" then
      return string.format("%x", random(0, 0xf))
    else
      return string.format("%x", random(8, 0xb))
    end
  end
  return template:gsub("[xy]", callback)
end

return util
