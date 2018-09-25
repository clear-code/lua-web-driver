local inspect = require("inspect")

local pp = {}

function pp.p(root, options)
  print(pp.format(root, options))
end

function pp.format(root, options)
  return inspect.inspect(root, options)
end

return pp
