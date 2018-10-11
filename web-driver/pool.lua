local cqueues = require("cqueues")
local thread = require("cqueues.thread")
local socket = require("cqueues.socket")

local Logger = require("web-driver/logger")
local JobPusher = require("web-driver/job-pusher")
local IPCProtocol = require("web-driver/ipc-protocol")
local pp = require("web-driver/pp")

local Pool = {}

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
    self.loop:wrap(function()
      local logger = socket.connect(self.log_receiver_host,
                                    self.log_receiver_port)
      IPCProtocol.write(logger, nil)
    end)
  end)
  self.loop:loop()
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
        log_receiver:close()
        break
      end
      pool.logger:log(level, message)
    end
  end)
end

local function create_queue(pool)
  local queue = function(pipe,
                         log_receiver_host, log_receiver_port,
                         n_consumers)
    local cqueues = require("cqueues")
    local socket = require("cqueues.socket")

    local loop = cqueues.new()
    local RemoteLogger = require("web-driver/remote-logger")
    local logger = RemoteLogger.new(loop,
                                    log_receiver_host,
                                    log_receiver_port)

    -- TODO: Add UNIX domain socket support as option.
    local options = {
      host = "127.0.0.1",
      port = 0,
    }
    local producers = socket.listen(options)
    local consumers = socket.listen(options)

    local IPCProtocol = require("web-driver/ipc-protocol")
    local _type, producers_host, producers_port = producers:localname()
    pipe:write(producers_host, "\n")
    pipe:write(producers_port, "\n")
    local _type, consumers_host, consumers_port = consumers:localname()
    pipe:write(consumers_host, "\n")
    pipe:write(consumers_port, "\n")
    IPCProtocol.write(pipe, nil)

    loop:wrap(function()
      for producer in producers:clients() do
        local task = IPCProtocol.read(producer)
        if task == nil then
          producers:close()
          break
        end
        loop:wrap(function()
          local consumer = consumers:accept()
          IPCProtocol.write(consumer, task)
        end)
      end
    end)
    logger:error(producers_host)
    loop:loop()
    for i = 1, n_consumers do
      local consumer = consumers:accept()
      IPCProtocol.write(consumer, nil)
    end
    consumers:close()
  end
  local pipe
  pool.queue, pipe = thread.start(queue,
                                  pool.log_receiver_host, pool.log_receiver_port,
                                  pool.size)
  pool.queue_host = pipe:read("*l")
  pool.queue_port = tonumber(pipe:read("*l"))
  pool.producer_host = pipe:read("*l")
  pool.producer_port = tonumber(pipe:read("*l"))
  IPCProtocol.read(pipe)
  pool.job_pusher = JobPusher.new(pool.queue_host, pool.queue_port)
end

local function run_consumers(pool)
  for i = 1, pool.size do
    local consumer = function(pipe,
                              i,
                              log_receiver_host, log_receiver_port,
                              queue_host, queue_port,
                              producer_host, producer_port,
                              runner)
      pipe:close()

      local cqueues = require("cqueues")
      local socket = require("cqueues.socket")

      local RemoteLogger = require("web-driver/remote-logger")
      local JobPusher = require("web-driver/job-pusher")
      local IPCProtocol = require("web-driver/ipc-protocol")

      local loop = cqueues.new()
      local logger = RemoteLogger.new(loop,
                                      log_receiver_host,
                                      log_receiver_port)
      local job_pusher = JobPusher.new(queue_host, queue_port)
      while true do
        local producer = socket.connect(producer_host, producer_port)
        local task = IPCProtocol.read(producer)
        if task == nil then
          break
        end
        runner({
          id = i,
          loop = loop,
          logger = logger,
          job_pusher = job_pusher,
          task = task,
        })
        loop:loop()
      end
    end
    local pipe
    pool.consumers[i], pipe =
      thread.start(consumer,
                   i,
                   pool.log_receiver_host, pool.log_receiver_port,
                   pool.queue_host, pool.queue_port,
                   pool.producer_host, pool.producer_port,
                   pool.runner)
    pipe:close()
  end
end

function Pool.new(loop, runner, options)
  options = options or {}
  local pool = {
    loop = loop,
    runner = runner,
    size = options.size or 8,
    consumers = {},
    logger = options.logger or Logger.new(nil),
  }
  setmetatable(pool, metatable)
  create_log_receiver(pool)
  create_queue(pool)
  run_consumers(pool)
  return pool
end

return Pool
