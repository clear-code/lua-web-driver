local cqueues = require("cqueues")
local thread = require("cqueues.thread")
local socket = require("cqueues.socket")

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
  self.queue:join()
  for i = 1, #self.consumers do
    if self.consumers[i] then
      self.consumers[i]:join()
    end
  end
end

local function create_queue(pool)
  local queue = function(pipe, n_consumers)
    local cqueues = require("cqueues")
    local socket = require("cqueues.socket")
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

    local loop = cqueues.new()
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
    loop:loop()
    for i = 1, n_consumers do
      local consumer = consumers:accept()
      IPCProtocol.write(consumer, nil)
    end
    consumers:close()
  end
  local pipe
  pool.queue, pipe = thread.start(queue, pool.size)
  pool.queue_host = pipe:read("*l")
  pool.queue_port = tonumber(pipe:read("*l"))
  pool.producer_host = pipe:read("*l")
  pool.producer_port = tonumber(pipe:read("*l"))
  IPCProtocol.read(pipe)
  pool.job_pusher = JobPusher.new(pool.queue_host, pool.queue_port)
end

local function start(pool)
  for i = 1, pool.size do
    local consumer = function(pipe,
                              i,
                              queue_host, queue_port,
                              producer_host, producer_port,
                              runner)
      local cqueues = require("cqueues")
      local socket = require("cqueues.socket")
      local JobPusher = require("web-driver/job-pusher")
      local IPCProtocol = require("web-driver/ipc-protocol")
      local job_pusher = JobPusher.new(queue_host, queue_port)
      while true do
        local producer = socket.connect(producer_host, producer_port)
        local task = IPCProtocol.read(producer)
        if task == nil then
          break
        end
        runner(i, job_pusher, task)
      end
    end
    pool.consumers[i], pool.sockets[i] =
      thread.start(consumer,
                   i,
                   pool.queue_host, pool.queue_port,
                   pool.producer_host, pool.producer_port,
                   pool.runner)
  end
end

function Pool.new(runner, options)
  options = options or {}
  local pool = {
    runner = runner,
    size = options.size or 8,
    consumers = {},
    sockets = {},
    logger = options.logger,
  }
  setmetatable(pool, metatable)
  create_queue(pool)
  start(pool)
  return pool
end

return Pool
