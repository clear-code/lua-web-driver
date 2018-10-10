local JobQueue = {}

local methods = {}
local metatable = {}

function metatable.__index(session, key)
  return methods[key]
end

function methods:push(task)
  self.socket:write(task, "\n")
  self.socket:flush()
end

function methods:close()
  self.socket:close()
end

function JobQueue.new(socket)
  local job_queue = {
    socket = socket,
  }
  setmetatable(job_queue, metatable)
  return job_queue
end

return JobQueue
