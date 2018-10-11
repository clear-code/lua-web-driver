local socket = require("cqueues.socket")

local JobProtocol = require("web-driver/job-protocol")

local JobPusher = {}

local methods = {}
local metatable = {}

function metatable.__index(job_pusher, key)
  return methods[key]
end

function methods:push(task)
  local queue = socket.connect(self.host, self.port)
  self.protocol:write(queue, task)
end

function JobPusher.new(host, port)
  local job_pusher = {
    host = host,
    port = port,
    protocol = JobProtocol.new(),
  }
  setmetatable(job_pusher, metatable)
  return job_pusher
end

return JobPusher
