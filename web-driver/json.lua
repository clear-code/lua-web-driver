local cjson = require("cjson")

local json = {}

function json.normalize(value)
  if value == cjson.null then
    return nil
  else
    return value
  end
end

return json
