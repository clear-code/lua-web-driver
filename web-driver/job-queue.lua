local cqueues = require("cqueues")
local socket = require("cqueues.socket")

local RemoteLogger = require("web-driver/remote-logger")
local IPCProtocol = require("web-driver/ipc-protocol")
local JobPusher = require("web-driver/job-pusher")
local pp = require("web-driver/pp")

local JobQueue = {
  log_prefix = "web-driver: pool: job-queue"
}

local methods = {}
local metatable = {}

function metatable.__index(job_pusher, key)
  return methods[key]
end

function methods:create_logger()
  self.logger = RemoteLogger.new(self.log_receiver_host,
                                 self.log_receiver_port,
                                 self.log_level)
end

function methods:listen()
  -- TODO: Add UNIX domain socket support as option.
  local options = {
    host = "127.0.0.1",
    port = 0,
  }
  self.producers = socket.listen(options)
  self.consumers = socket.listen(options)

  local _type, producers_host, producers_port = self.producers:localname()
  self.pipe:write(producers_host, "\n")
  self.pipe:write(producers_port, "\n")
  self.producers_host = producers_host
  self.producers_port = producers_port
  local _type, consumers_host, consumers_port = self.consumers:localname()
  self.pipe:write(consumers_host, "\n")
  self.pipe:write(consumers_port, "\n")
  IPCProtocol.write(self.pipe, nil)
end

function methods:job_completed()
  self.n_jobs = self.n_jobs - 1
  if self.n_jobs == 0 and self.finish_on_empty then
    self.loop:wrap(function()
      local job_pusher = JobPusher.new(self.producers_host, self.producers_port)
      job_pusher:push(nil)
    end)
  end
end

function methods:accept_consumer(job)
  local consumer = self.consumers:accept()
  if IPCProtocol.write(consumer, job) then
    self.failure_counts[job] = 0
    self:job_completed()
  else
    self.failure_counts[job] = self.failure_counts[job] + 1
    local n_failures = self.failure_counts[job]
    self.logger:debug(string.format("%s: Error: <%d>: <%s>",
                                    JobQueue.log_prefix,
                                    n_failures,
                                    pp.format(job)))
    if n_failures < self.max_n_failures then
      self.logger:debug(string.format("%s: Resubmit: <%d>: <%s>",
                                      JobQueue.log_prefix,
                                      n_failures,
                                      pp.format(job)))
      self.loop:wrap(function() self:accept_consumer(job) end)
    else
      self.logger:error(string.format("%s: Drop: <%d>: <%s>",
                                      JobQueue.log_prefix,
                                      n_failures,
                                      pp.format(job)))
      self:job_completed()
    end
  end
end

function methods:accept_jobs()
  local producer
  for producer in self.producers:clients() do
    local job = IPCProtocol.read(producer)
    if job == nil then
      self.producers:close()
      break
    end
    local need_consume = true
    if self.failure_counts[job] then
      if self.unique then
        need_consume = false
      end
    else
      self.failure_counts[job] = 0
    end

    if need_consume then
      self.n_jobs = self.n_jobs + 1
      self.loop:wrap(function() self:accept_consumer(job) end)
    else
      self.logger:debug(string.format("%s: Duplicated: <%s>",
                                      JobQueue.log_prefix,
                                      pp.format(job)))
    end
  end
end

function methods:run()
  self:create_logger()
  self:listen()
  self.loop:wrap(function()
    self:accept_jobs()
  end)
  local success, why = self.loop:loop()
  if not success then
    local message = string.format("%s: Failed to run loop: %s",
                                  JobQueue.log_prefix,
                                  why)
    io.stderr:write(message .. "\n")
    self.logger:error(message)
  end
  self.consumers:close()
end

function JobQueue.new(pipe, options)
  local job_queue = {
    loop = cqueues.new(),
    pipe = pipe,
    log_receiver_host = options.log.receiver.host,
    log_receiver_port = options.log.receiver.port,
    log_level = options.log.level,
    unique = options.unique,
    max_n_failures = options.max_n_failures,
    finish_on_empty = options.finish_on_empty,
    failure_counts = {},
    n_jobs = 0,
  }
  setmetatable(job_queue, metatable)
  return job_queue
end

return JobQueue
