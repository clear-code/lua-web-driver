local process = require("process")
local socket = require("socket")

local Logger = require("web-driver/logger")

local Geckodriver = {}

local methods = {}
local metatable = {}

function metatable.__index(geckodriver, key)
  return methods[key]
end

local function log_level_from_geckodriver(geckodriver_log_level)
  local logger_log_level = geckodriver_log_level
  if logger_log_level == "WARN" then
    logger_log_level = "WARNING"
  end
  return Logger.LEVELS[logger_log_level] or
    error("web-driver: geckodriver: unknown log level: " ..
            geckodriver_log_level)
end

function methods:log_lines(prefix, lines)
  local last_timestamp
  local last_component
  local last_level
  for line in string.gmatch(lines, "[^\n]+") do
    local timestamp, component, level =
      string.match(line, "^(%d+)\t([%a.:]+)\t(%a+)\t")
    if timestamp then
      local message = line:sub(1 + #timestamp + 1 + #component + 1 + #level + 1)
      self.firefox.logger:log(log_level_from_geckodriver(level),
                              prefix ..
                                timestamp .. ": " ..
                                component .. ": " ..
                                message)
      last_timestamp = timestamp
      last_component = component
      last_level = level
    elseif last_timestamp then
      self.firefox.logger:log(log_level_from_geckodriver(last_level),
                              prefix ..
                                last_timestamp .. ": " ..
                                last_component .. ": " ..
                                line)
    else
      self.firefox.logger:log(self.firefox.logger:level(),
                              prefix ..
                                "0: " ..
                                "Firefox: " ..
                                line)
    end
  end
end

function methods:log_output(input, label, reader)
  local data = ""
  local read_inputs = {
    {
      getfd = function() return input; end,
    },
  }
  while true do
    local readable_inputs, _ = socket.select(read_inputs, {}, 0)
    if #readable_inputs == 0 then
      break
    end
    local readable_input = readable_inputs[1]
    local chunk, err, again = reader()
    if not chunk then
      break
    end
    data = data .. chunk
  end
  if #data > 0 then
    self:log_lines("web-driver: " .. label .. ": ", data)
  end
end

function methods:log_outputs()
  local stdio, stdout, stderr = self.process:fds()
  self:log_output(stdout, "stdout", function() return self.process:stdout() end)
  self:log_output(stderr, "stderr", function() return self.process:stderr() end)
end

function methods:kill()
  local timeout = 5
  local n_tries = 100
  local sleep_ns_per_trie = (timeout / n_tries) * (10 ^ 6)
  local finished = false
  self.process:kill()
  for i = 1, n_tries do
    local status, err = process.waitpid(self.process:pid(), process.WNOHANG)
    if status then
      finished = true
      break
    end
    self:log_outputs()
    process.nsleep(sleep_ns_per_trie)
  end
  if not finished then
    local SIGKILL = 9
    self.process:kill(SIGKILL)
    self:log_outputs()
    process.waitpid(self.process:pid())
  end
end

function methods:ensure_running()
  local timeout = self.firefox.start_timeout
  local n_tries = 100
  local sleep_ns_per_trie = (timeout / n_tries) * (10 ^ 6)
  for i = 1, n_tries do
    local success, _ = pcall(function() return self.firefox.client:status() end)
    if success then
      return true
    end
    local status, err = process.waitpid(self.process:pid(), process.WNOHANG)
    if status then
      error("web-driver: geckodriver: " ..
              "Failed to run: <" .. self.command .. ">")
    end
    self:log_output()
    process.nsleep(sleep_ns_per_trie)
  end

  self:kill()
  error("web-driver: geckodriver: " ..
          "Failed to run in " .. timeout .. " seconds: " ..
          "<" .. self.command .. ">")
end

function methods:start(callback)
  local geckodriver_process, err = process.exec(self.command, self.args)
  if err then
    error("web-driver: geckodriver: " ..
            "Failed to execute: <" .. self.command .. ">: " ..
            err)
  end
  self.process = geckodriver_process
  self:ensure_running()
  if callback then
    local success, return_value = pcall(callback, self)
    self:stop()
    if not success then
      error(err)
    end
    return return_value
  end
end

function methods:stop()
  if not self.process then
    return
  end
  self:kill()
end

local function build_args(firefox)
  local args = {
    "--host", firefox.client.host,
    "--port", firefox.client.port
  }
  if firefox.log_level then
    table.insert(args, "--log")
    table.insert(args, firefox.log_level)
  end
  return args
end

function Geckodriver.new(firefox)
  local geckodriver = {
    firefox = firefox,
    command = "geckodriver",
    args = build_args(firefox),
    process = nil,
  }
  setmetatable(geckodriver, metatable)
  return geckodriver
end

return Geckodriver
