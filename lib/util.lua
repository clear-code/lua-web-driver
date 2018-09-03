local inspect = require("inspect")

local util = {}

function util.p(root, options)
  print(inspect.inspect(root, options))
end

function util.element_id_from(id)
  return id["ELEMENT"] or id["element-6066-11e4-a52e-4f735466cecf"]
end

return util
