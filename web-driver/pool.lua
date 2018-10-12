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
      logger:close()
    end)
  end)
  local success, why, error_context = self.loop:loop()
  if not success then
    self.logger:error(string.format("%s: %s: %s: %s",
                                    "web-driver: pool",
                                    "Failed to run loop",
                                    why,
                                    pp.format(error_context)))
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
  local queue = function(pipe,
                         log_receiver_host, log_receiver_port, log_level,
                         n_consumers,
                         unique,
                         max_n_failures)
    local pp = require("web-driver/pp")
    local success, why = pcall(function()
      local cqueues = require("cqueues")
      local socket = require("cqueues.socket")

      local loop = cqueues.new()
      local RemoteLogger = require("web-driver/remote-logger")
      local logger = RemoteLogger.new(loop,
                                      log_receiver_host,
                                      log_receiver_port,
                                      log_level)

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

      local failure_counts = {}
      loop:wrap(function()
        for producer in producers:clients() do
          local task = IPCProtocol.read(producer)
          if task == nil then
            producers:close()
            break
          end
          local need_consume = true
          if failure_counts[task] then
            if unique_task then
              need_consume = false
            end
          else
            failure_counts[task] = 0
          end
          local log_prefix = "web-driver: pool: queue: task"
          if need_consume then
            local function consume_task(task)
              local consumer = consumers:accept()
              if IPCProtocol.write(consumer, task) then
                failure_counts[task] = 0
              else
                failure_counts[task] = failure_counts[task] + 1
                local n_failures = failure_counts[task]
                logger:debug(string.format("%s: Error: <%d>: <%s>",
                                           log_prefix,
                                           n_failures,
                                           pp.format(task)))
                if n_failures < max_n_failures then
                  logger:debug(string.format("%s: Resubmit: <%d>: <%s>",
                                             log_prefix,
                                             n_failures,
                                             pp.format(task)))
                  loop:wrap(function() consume_task(task) end)
                else
                  logger:error(string.format("%s: Drop: <%d>: <%s>",
                                             log_prefix,
                                             n_failures,
                                             pp.format(task)))
                end
              end
            end
            loop:wrap(function() consume_task(task) end)
          else
            logger:debug(string.format("%s: Duplicated: <%s>",
                                       log_prefix,
                                       pp.forrmat(task)))
          end
        end
      end)
      loop:loop()
      for i = 1, n_consumers do
        local consumer = consumers:accept()
        IPCProtocol.write(consumer, nil)
      end
      consumers:close()
    end)
    if not success then
      local prefix = "web-driver: pool: queue: "
      print(prefix .. "Error: " .. why)
    end
  end
  local pipe
  pool.queue, pipe = thread.start(queue,
                                  pool.log_receiver_host, pool.log_receiver_port,
                                  pool.logger:level(),
                                  pool.size,
                                  pool.unique_task,
                                  pool.max_n_failures)
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
    local consumer = function(pipe,
                              i,
                              log_receiver_host, log_receiver_port, log_level,
                              queue_host, queue_port,
                              producer_host, producer_port,
                              runner)
      local pp = require("web-driver/pp")
      local log_prefix = "web-driver: pool: consumer: " .. i

      local success, why = pcall(function()
        pipe:close()

        local cqueues = require("cqueues")
        local socket = require("cqueues.socket")

        local RemoteLogger = require("web-driver/remote-logger")
        local JobPusher = require("web-driver/job-pusher")
        local IPCProtocol = require("web-driver/ipc-protocol")

        local loop = cqueues.new()
        local logger = RemoteLogger.new(loop,
                                        log_receiver_host,
                                        log_receiver_port,
                                        log_level)
        local job_pusher = JobPusher.new(queue_host, queue_port)
        while true do
          local producer = socket.connect(producer_host, producer_port)
          local need_break = IPCProtocol.read(producer, function(task)
            if task == nil then
              return true, true
            else
              local context = {
                id = i,
                loop = loop,
                logger = logger,
                job_pusher = job_pusher,
                task = task,
              }
              logger:debug(string.format("%s: Running task: <%s>",
                                         log_prefix,
                                         pp.format(task)))
              local runner_success, runner_why = pcall(runner, context)
              if not runner_success then
                logger:error(string.format("%s: runner: Error: %s: <%s>",
                                           log_prefix,
                                           runner_why,
                                           pp.format(task)))
              end
              loop:loop()
              return runner_success, false
            end
          end)
          if need_break then
            break
          end
        end
      end)
      if not success then
        print(log_prefix .. "Error: " .. why)
      end
    end
    local pipe
    pool.consumers[i], pipe =
      thread.start(consumer,
                   i,
                   pool.log_receiver_host, pool.log_receiver_port,
                   pool.logger:level(),
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
    logger = Logger.new(options.logger),
    unique_task = true,
    finish_on_empty = true,
    max_n_failures = options.max_n_failures or 3,
  }
  if options.unique_task == false then
    pool.unique_task = false
  end
  if options.finish_on_empty == false then
    pool.finish_on_empty = false
  end
  setmetatable(pool, metatable)
  create_log_receiver(pool)
  create_queue(pool)
  run_consumers(pool)
  return pool
end

return Pool
