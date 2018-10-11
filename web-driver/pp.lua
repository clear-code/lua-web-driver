local inspect = require("inspect")

local pp = {}

function pp.p(root, options)
  print(pp.format(root, options))
end

function pp.format(root, options)
  return inspect.inspect(root, options)
end

function pp.traceback(prefix, offset)
  print(prefix .. "Traceback")
  if not offset then
    offset = 2
  end
  local deep_level = offset
  while true do
    local info = debug.getinfo(deep_level, "Sl")
    if not info then
      break
    end
    print(string.format("%s%d: %s:%d",
                        prefix,
                        deep_level - offset + 1,
                        info.short_src,
                        info.currentline))
    deep_level = deep_level + 1
  end
end

return pp
