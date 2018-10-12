local cqueues = require("cqueues")
local socket = require("cqueues.socket")

local RemoteLogger = require("web-driver/remote-logger")
local IPCProtocol = require("web-driver/ipc-protocol")
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
  self.logger = RemoteLogger.new(self.loop,
                                 self.log_receiver_host,
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
  local _type, consumers_host, consumers_port = self.consumers:localname()
  self.pipe:write(consumers_host, "\n")
  self.pipe:write(consumers_port, "\n")
  IPCProtocol.write(self.pipe, nil)
end

function methods:accept_consumer(job)
  local consumer = self.consumers:accept()
  if IPCProtocol.write(consumer, job) then
    self.failure_counts[job] = 0
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
      if self.unique_job then
        need_consume = false
      end
    else
      self.failure_counts[job] = 0
    end

    if need_consume then
      self.loop:wrap(function() self:accept_consumer(job) end)
    else
      self.logger:debug(string.format("%s: Duplicated: <%s>",
                                      JobQueue.log_prefix,
                                      pp.forrmat(job)))
    end
  end
end

function methods:run()
  self:create_logger()
  self:listen()
  self.loop:wrap(function()
    self:accept_jobs()
  end)
  local success, why, context = self.loop:loop()
  if not success then
    local message = string.format("%s: Failed to run loop: %s: <%s>",
                                  JobQueue.log_prefix,
                                  why,
                                  pp.format(context))
    io.stderr:write(message .. "\n")
    self.logger:error(message)
  end
  self.consumers:close()
end

function JobQueue.new(pipe,
                      log_receiver_host,
                      log_receiver_port,
                      log_level,
                      n_consumers,
                      unique,
                      max_n_failures)
  local job_queue = {
    loop = cqueues.new(),
    pipe = pipe,
    log_receiver_host = log_receiver_host,
    log_receiver_port = log_receiver_port,
    log_level = log_level,
    n_consumers = n_consumers,
    unique = unique,
    max_n_failures = max_n_failures,
    failure_counts = {},
  }
  setmetatable(job_queue, metatable)
  return job_queue
end

return JobQueue
