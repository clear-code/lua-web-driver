local cqueues = require("cqueues")
local thread = require("cqueues.thread")
local socket = require("cqueues.socket")

local JobQueue = require("web-driver/job-queue")
local pp = require("web-driver/pp")

local Pool = {}

local methods = {}
local metatable = {}

function metatable.__index(session, key)
  return methods[key]
end

function methods:start()
  self.job_queue = JobQueue.new(socket.connect(self.tasks_host,
                                               self.tasks_port))
  for i = 1, self.size do
    local consumer = function(pipe,
                              i,
                              tasks_host, tasks_port,
                              producer_host, producer_port,
                              runner)
      local cqueues = require("cqueues")
      local socket = require("cqueues.socket")
      local JobQueue = require("web-driver/job-queue")
      local job_queue = JobQueue.new(socket.connect(tasks_host, tasks_port))
      while true do
        local producer = socket.connect(producer_host, producer_port)
        local task = producer:read("*l")
        if task == "" then
          break
        end
        runner(i, job_queue, task)
      end
      job_queue:close()
    end
    self.consumers[i], self.sockets[i] =
      thread.start(consumer,
                   i,
                   self.tasks_host, self.tasks_port,
                   self.consumers_host, self.consumers_port,
                   self.runner)
  end
end

function methods:push(task)
  self.job_queue:push(task)
end

function methods:stop()
  self:push()
  self.producer:join()
  for i = 1, #self.consumers do
    if self.consumers[i] then
      self.consumers[i]:join()
    end
  end
  self.job_queue:close()
end

local function create_producer(pool)
  local producer = function(pipe, n_consumers)
    local cqueues = require("cqueues")
    local socket = require("cqueues.socket")
    -- TODO: Add UNIX domain socket support as option.
    local options = {
      host = "127.0.0.1",
      port = 0,
    }
    local tasks = socket.listen(options)
    local consumers = socket.listen(options)
    local _type, tasks_host, tasks_port = tasks:localname()
    pipe:write(tasks_host, "\n")
    pipe:write(tasks_port, "\n")
    local _type, consumers_host, consumers_port = consumers:localname()
    pipe:write(consumers_host, "\n")
    pipe:write(consumers_port, "\n")
    pipe:flush()

    local loop = cqueues.new()
    loop:wrap(function()
      while true do
        -- TODO: accept and read
        local task = tasks:read("*l")
        if task == "" then
          tasks:close()
          break
        end
        loop:wrap(function()
          local consumer = consumers:accept()
          consumer:write(task)
          consumer:write("\n")
          consumer:flush()
          consumer:close()
        end)
      end
    end)
    loop:loop()
    for i = 1, n_consumers do
      local consumer = consumers:accept()
      consumer:write("\n")
      consumer:flush()
      consumer:close()
    end
    consumers:close()
  end
  local pipe
  pool.producer, pipe = thread.start(producer, pool.size)
  pool.tasks_host = pipe:read("*l")
  pool.tasks_port = tonumber(pipe:read("*l"))
  pool.producer_host = pipe:read("*l")
  pool.producer_port = tonumber(pipe:read("*l"))
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
  create_producer(pool)
  setmetatable(pool, metatable)
  return pool
end

return Pool
