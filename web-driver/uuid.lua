-- Is it needed?
local uuid = {}

-- https://gist.github.com/jrus/3197011
function uuid.generate()
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

return uuid
