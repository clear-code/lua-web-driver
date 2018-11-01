local cqueues = require("cqueues")
local socket = require("cqueues.socket")

local Firefox = require("web-driver/firefox")
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
    logger = self.logger,
    job_pusher = self.job_pusher,
    session = self.session,
    job = job,
  }
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

function methods:create_driver()
  local options = {}
  if self.firefox_options then
    local name, value
    for name, value in pairs(self.firefox_options) do
      options[name] = value
    end
  end
  options.port = 4444 + self.id
  options.logger = self.logger
  self.driver = Firefox.new(options)
end

function methods:stop_session()
  self.session:delete()
end

function methods:run()
  self:create_logger()
  self:create_job_pusher()
  self:create_driver()
  self.driver:start_session(function(session)
    self.session = session
    self.pipe:write("READY\n")
    self.pipe:flush()
    self.pipe:shutdown("w")
    local pipe_read_pollable = {
      pollfd = function() return self.pipe:pollfd() end,
      events = function() return "r" end,
    }
    cqueues.poll(pipe_read_pollable)
    self.pipe:close()
    local success, why = pcall(function()
      while self:consume_job() do
        -- Do nothing
      end
    end)
    if not success then
      self.logger:error(string.format("%s: Error in consume loop: %s",
                                      self:log_prefix(),
                                      why))
    end
  end)
end

function JobConsumer.new(pipe, consumer, options)
  local job_consumer = {
    loop = cqueues.new(),
    pipe = pipe,
    consumer = consumer,
    id = options.id,
    log_receiver_host = options.log.receiver.host,
    log_receiver_port = options.log.receiver.port,
    log_level = options.log.level,
    queue_host = options.queue.host,
    queue_port = options.queue.port,
    producer_host = options.producer.host,
    producer_port = options.producer.port,
    firefox_options = options.firefox_options,
  }
  setmetatable(job_consumer, metatable)
  return job_consumer
end

return JobConsumer
