local cqueues = require("cqueues")
local socket = require("cqueues.socket")

local RemoteLogger = require("web-driver/remote-logger")
local JobPusher = require("web-driver/job-pusher")
local IPCProtocol = require("web-driver/ipc-protocol")
local pp = require("web-driver/pp")

local JobConsumer = {
  log_prefix = "web-driver: pool: job-consumer"
}

local methods = {}
local metatable = {}

function metatable.__index(job_pusher, key)
  return methods[key]
end

function methods:log_prefix()
  return JobConsumer.log_prefix .. ": " .. self.id
end

function methods:create_logger()
  self.logger = RemoteLogger.new(self.log_receiver_host,
                                 self.log_receiver_port,
                                 self.log_level)
end

function methods:create_job_pusher()
  self.job_pusher = JobPusher.new(self.queue_host,
                                  self.queue_port)
end

function methods:process_job(job)
  local success = true
  local context = {
    id = self.id,
    loop = self.loop,
    logger = self.logger,
    job_pusher = self.job_pusher,
    job = job,
  }
  self.loop:wrap(function()
    self.logger:debug(string.format("%s: Consuming job: <%s>",
                                    self:log_prefix(),
                                    pp.format(job)))
    local why
    success, why = pcall(self.consumer, context)
    self.logger:debug(string.format("%s: Consumed job: <%s>: <%s>",
                                    self:log_prefix(),
                                    success,
                                    pp.format(job)))
    if not success then
      self.logger:error(string.format("%s: consumer: Error: %s: <%s>",
                                      self:log_prefix(),
                                      why,
                                      pp.format(job)))
    end
  end)
  self.loop:loop()
  return success
end

function methods:consume_job()
  local producer = socket.connect(self.producer_host, self.producer_port)
  local continue = true
  IPCProtocol.read(producer, function(job)
    if job then
      continue = true
      return self:process_job(job)
    else
      continue = false
      return true
    end
  end)
  return continue
end

function methods:run()
  self:create_logger()
  self:create_job_pusher()
  self.pipe:close()
  while self:consume_job() do
    -- Do nothing
  end
end

function JobConsumer.new(pipe,
                         id,
                         log_receiver_host,
                         log_receiver_port,
                         log_level,
                         queue_host,
                         queue_port,
                         producer_host,
                         producer_port,
                         consumer)
  local job_consumer = {
    loop = cqueues.new(),
    pipe = pipe,
    id = id,
    log_receiver_host = log_receiver_host,
    log_receiver_port = log_receiver_port,
    log_level = log_level,
    queue_host = queue_host,
    queue_port = queue_port,
    producer_host = producer_host,
    producer_port = producer_port,
    consumer = consumer,
  }
  setmetatable(job_consumer, metatable)
  return job_consumer
end

return JobConsumer
