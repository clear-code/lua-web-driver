local JobProtocol = {}

local methods = {}
local metatable = {}

function metatable.__index(job_protocol, key)
  return methods[key]
end

function methods:write(socket, task)
  if task then
    socket:write(task)
    socket:flush()
  end
  socket:shutdown("w")
  socket:read("*a") -- Wait "GOT"
  socket:close()
end

function methods:read(socket)
  local task = socket:read("*a")
  socket:write("GOT")
  socket:flush()
  socket:shutdown("w")
  socket:close()
  return task
end

function JobProtocol.new()
  local job_protocol = {
  }
  setmetatable(job_protocol, metatable)
  return job_protocol
end

return JobProtocol
