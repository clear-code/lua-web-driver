local cqueues = require("cqueues")
local thread = require("cqueues.thread")
local socket = require("cqueues.socket")
local lunajson = require("lunajson")

local Logger = require("web-driver/logger")
local JobPusher = require("web-driver/job-pusher")
local IPCProtocol = require("web-driver/ipc-protocol")
local pp = require("web-driver/pp")

local ThreadPool = {}

local methods = {}
local metatable = {}

function metatable.__index(session, key)
  return methods[key]
end

function methods:push(task)
  self.job_pusher:push(task)
end

function methods:join()
  self.loop:wrap(function()
    self.queue:join()
    for i = 1, #self.consumers do
      if self.consumers[i] then
        self.consumers[i]:join()
      end
    end
    local logger = socket.connect(self.log_receiver_host,
                                  self.log_receiver_port)
    cqueues.poll(logger)
    logger:close()
  end)
  local success, why = self.loop:loop()
  if not success then
    self.logger:error(string.format("%s: %s: %s",
                                    "web-driver: pool",
                                    "Failed to run loop",
                                    why))
    self.logger.traceback("error")
  end
end

local function create_log_receiver(pool)
  -- TODO: Add UNIX domain socket support as option.
  local options = {
    host = "127.0.0.1",
    port = 0,
  }
  pool.log_receiver = socket.listen(options)
  local _type
  _type, pool.log_receiver_host, pool.log_receiver_port =
    pool.log_receiver:localname()
  pool.loop:wrap(function()
    for client in pool.log_receiver:clients() do
      local level, message = IPCProtocol.receive_log(client)
      if not level then
        pool.log_receiver:close()
        break
      end
      pool.logger:log(level, message)
    end
  end)
end

local function create_queue(pool)
  local queue = function(pipe, options_json)
    local lunajson = require("lunajson")
    local JobQueue = require("web-driver/job-queue")
    local pp = require("web-driver/pp")
    local success, why = pcall(function()
      local job_queue = JobQueue.new(pipe, lunajson.decode(options_json))
      job_queue:run()
    end)
    if not success then
      io.stderr:write(string.format("%s: Error: %s\n",
                                    JobQueue.log_prefix,
                                    why))
    end
  end
  local pipe
  local options = {
    log = {
      receiver = {
        host = pool.log_receiver_host,
        port = pool.log_receiver_port,
      },
      level = pool.logger:level(),
    },
    size = pool.size,
    unique = pool.unique_job,
    max_n_failures = pool.max_n_failures,
    finish_on_empty = pool.finish_on_empty,
  }
  pool.queue, pipe = thread.start(queue, lunajson.encode(options))
  pool.queue_host = pipe:read("*l")
  pool.queue_port = tonumber(pipe:read("*l"))
  pool.producer_host = pipe:read("*l")
  pool.producer_port = tonumber(pipe:read("*l"))
  IPCProtocol.read(pipe)
  if not (pool.queue_host and
          pool.queue_port and
          pool.producer_host and
          pool.producer_port) then
    local local_error, why = pool.queue:join()
    if why then
      local message = "web-driver: pool: Failed to run queue thread: " .. why
      pool.logger:error(message)
      pool.logger:traceback("error")
      error(message)
    end
  end
  pool.job_pusher = JobPusher.new(pool.queue_host, pool.queue_port)
end

local function run_consumers(pool)
  for i = 1, pool.size do
    local consumer = function(pipe, consumer, options_json)
      local lunajson = require("lunajson")
      local JobConsumer = require("web-driver/job-consumer")
      local pp = require("web-driver/pp")
      local success, why = pcall(function()
        local job_consumer = JobConsumer.new(pipe,
                                             consumer,
                                             lunajson.decode(options_json))
        job_consumer:run()
      end)
      if not success then
        io.stderr:write(string.format("%s: %d: Error: %s\n",
                                      JobConsumer.log_prefix,
                                      id,
                                      why))
      end
    end
    local pipe
    local options = {
      id = i,
      log = {
        receiver = {
          host = pool.log_receiver_host,
          port = pool.log_receiver_port,
        },
        level = pool.logger:level(),
      },
      queue = {
        host = pool.queue_host,
        port = pool.queue_port,
      },
      producer = {
        host = pool.producer_host,
        port = pool.producer_port,
      },
    }
    if pool.firefox_options then
      options.firefox_options = pool.firefox_options
    end
    pool.consumers[i], pipe =
      thread.start(consumer, pool.consumer, lunajson.encode(options))
    pipe:shutdown("w")
    local pipe_read_pollable = {
      pollfd = function() return pipe:pollfd() end,
      events = function() return "r" end,
    }
    cqueues.poll(pipe_read_pollable)
    pipe:read("*l")
    pipe:close()
  end
end

function ThreadPool.new(consumer, options)
  options = options or {}
  local pool = {
    loop = cqueues.new(),
    consumer = consumer,
    size = options.size or 4,
    consumers = {},
    logger = Logger.new(options.logger),
    unique_job = true,
    finish_on_empty = true,
    max_n_failures = options.max_n_failures or 3,
    firefox_options = options.firefox_options,
  }
  if options.unique_job == false then
    pool.unique_job = false
  end
  if options.finish_on_empty == false then
    pool.finish_on_empty = false
  end
  setmetatable(pool, metatable)
  create_log_receiver(pool)
  create_queue(pool)
  pool.loop:wrap(function()
    run_consumers(pool)
  end)
  return pool
end

return ThreadPool
