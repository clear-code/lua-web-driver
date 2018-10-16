local socket = require("cqueues.socket")

local IPCProtocol = require("web-driver/ipc-protocol")

local JobPusher = {}

local methods = {}
local metatable = {}

function metatable.__index(job_pusher, key)
  return methods[key]
end

function methods:push(job)
  local queue = socket.connect(self.host, self.port)
  IPCProtocol.write(queue, job)
end

function JobPusher.new(host, port)
  local job_pusher = {
    host = host,
    port = port,
  }
  setmetatable(job_pusher, metatable)
  return job_pusher
end

return JobPusher
