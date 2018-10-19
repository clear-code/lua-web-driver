local process = require("process")
local http_request = require("http.request")
local socket = require("socket")

local LogLevel = require("web-driver/log-level")
local pp = require("web-driver/pp")

local Geckodriver = {}
Geckodriver.log_prefix = "web-driver: geckodriver"

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
  return LogLevel[logger_log_level] or
    error(string.format("%s: Unknown geckodriver log level: <%s>",
                        Geckodriver.log_prefix,
                        geckodriver_log_level))
end

local function log_level_from_firefox(firefox_log_level)
  if firefox_log_level == "E" then -- TODO: Really?
    return LogLevel.ERROR
  elseif firefox_log_level == "I" then
    return LogLevel.INFO
  elseif firefox_log_level == "D" then
    return LogLevel.DEBUG
  elseif firefox_log_level == "V" then
    return LogLevel.TRACE
  else
    error(string.format("%s: Unknown Firefox log level: <%s>",
                        Geckodriver.log_prefix,
                        firefox_log_level))
  end
end

local function format_log_message(prefix, timestamp, component, message)
  local time = os.date("*t", timestamp / (10 ^ 6))
  local micro_second = timestamp % (10 ^ 6)
  return string.format("%s: %04d-%02d-%02dT%02d:%02d:%02d.%06d: %s: %s",
                       prefix,
                       time.year,
                       time.month,
                       time.day,
                       time.hour,
                       time.min,
                       time.sec,
                       micro_second,
                       component,
                       message)
end

function methods:process_firefox_http_log(message)
  if self.firefox_log_context.in_http_request then
    local last_connection_log = self.connection_logs[#self.connection_logs]
    if message == "]" then
      self.firefox_log_context.in_http_request = false
    elseif not last_connection_log.method then
      last_connection_log.method, last_connection_log.path =
        message:match("^  ([^ ]+) ([^ ]+) ")
    else
      local name, value = message:match("^  ([^:]+): (.*)$")
      if name:lower() == "host" then
        last_connection_log.host = value
      end
      last_connection_log.request_headers[name] = value
    end
  elseif self.firefox_log_context.in_http_response then
    local last_connection_log = self.connection_logs[#self.connection_logs]
    if message == "]" then
      self.firefox_log_context.in_http_response = false
    elseif message:sub(1, 7) == "  HTTP/" then
      last_connection_log.status_code = tonumber(message:match("^  [^ ]+ (%d+)"))
    elseif message == "    OriginalHeaders" then
      self.firefox_log_context.in_original_response_headers = true
    else
      local response_headers
      if self.firefox_log_context.in_original_response_headers then
        response_headers = last_connection_log.original_response_headers
      else
        response_headers = last_connection_log.response_headers
      end
      local name, value = message:match("^  ([^:]+): (.*)$")
      response_headers[name] = value
    end
  else
    if message == "http request [" then
      self.firefox_log_context.in_http_request = true
      table.insert(self.connection_logs, {
        method = nil,
        host = nil,
        path = nil,
        request_headers = {},
      })
    elseif message == "http response [" then
      self.firefox_log_context.in_http_response = true
      self.firefox_log_context.in_original_response_headers = false
      local last_connection_log = self.connection_logs[#self.connection_logs]
      last_connection_log.status_code = nil
      last_connection_log.response_headers = {}
      last_connection_log.original_response_headers = {}
    end
  end
end

function methods:log_firefox_line(prefix, line)
  local year, month, day, hour, minute, second, micro_second, context, firefox_log_level, firefox_component, message =
    line:match("^(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)%.(%d+) UTC %- " ..
                 "%[([^%]]+)%]: (.)/([^ ]+) (.*)$")
  if year then
    -- TODO: Convert UTC to local time
    local time = {
      year = tonumber(year),
      month = tonumber(month),
      day = tonumber(day),
      hour = tonumber(hour),
      min = tonumber(minute),
      sec = tonumber(second),
      isdst = false,
    }
    local timestamp = os.time(time) * (10 ^ 6) + tonumber(micro_second)
    local component = string.format("Firefox: %s: %s",
                                    context,
                                    firefox_component)
    local log_level = log_level_from_firefox(firefox_log_level)
    if log_level == LogLevel.INFO and firefox_component == "nsHttp" then
      self:process_firefox_http_log(message)
    end
    self.firefox.logger:log(log_level,
                            format_log_message(prefix,
                                               timestamp,
                                               component,
                                               message))
  else
    self.firefox.logger:log(self.firefox.logger:level(),
                            format_log_message(prefix,
                                               0,
                                               "Firefox",
                                               line))
  end
end

function methods:log_lines(prefix, lines)
  local last_timestamp
  local last_component
  local last_level
  for line in lines:gmatch("[^\n]+") do
    local timestamp_string, component, level =
      line:match("^(%d+)\t([%a.:]+)\t(%a+)\t")
    if timestamp_string then
      local message = line:sub(1 +
                                 #timestamp_string + 1 +
                                 #component + 1 +
                                 #level + 1)
      local timestamp = tonumber(timestamp_string) * (10 ^ 3)
      self.firefox.logger:log(log_level_from_geckodriver(level),
                              format_log_message(prefix,
                                                 timestamp,
                                                 component,
                                                 message))
      last_timestamp = timestamp
      last_component = component
      last_level = level
    elseif last_timestamp then
      self.firefox.logger:log(log_level_from_geckodriver(last_level),
                              format_log_message(prefix,
                                                 last_timestamp,
                                                 last_component,
                                                 line))
    else
      self:log_firefox_line(prefix, line)
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
    self:log_lines(Geckodriver.log_prefix .. ": " .. label, data)
  end
end

function methods:log_outputs()
  local stdio, stdout, stderr = self.process:fds()
  self:log_output(stdout, "stdout", function() return self.process:stdout() end)
  self:log_output(stderr, "stderr", function() return self.process:stderr() end)
end

function methods:clear_connection_logs()
  self.connection_logs = {}
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
  local sleep_ns_per_try = (timeout / n_tries) * (10 ^ 9)
  local url = string.format("http://%s:%d/status",
                            self.firefox.client.host,
                            self.firefox.client.port)
  local request = http_request.new_from_uri(url)
  for i = 1, n_tries do
    local headers, stream = request:go()
    if headers then
      stream:shutdown()
      return true
    end
    local status, why = process.waitpid(self.process:pid(), process.WNOHANG)
    if why then
      local message = string.format("%s: Failed to run: <%s>: %s",
                                    Geckodriver.log_prefix,
                                    self.command,
                                    why)
      self.firefox.logger:error(message)
      self.firefox.logger:traceback("error")
      error(message)
    end
    self:log_outputs()
    process.nsleep(sleep_ns_per_try)
  end

  self:kill()
  local message = string.format("%s: Failed to run in %d seconds: <%s>",
                                Geckodriver.log_prefix,
                                timeout,
                                self.command)
  self.firefox.logger:error(message)
  self.firefox.logger:traceback("error")
  error(message)
end

function methods:start(callback)
  local geckodriver_process, why = process.exec(self.command, self.args)
  if why then
    local message = string.format("%s: Failed to execute: <%s>: %s",
                                  Geckodriver.log_prefix,
                                  self.command,
                                  why)
    self.firefox.logger:error(message)
    self.firefox.logger:traceback("error")
    error(message)
  end
  self.process = geckodriver_process
  self:ensure_running()
  if callback then
    local success, return_value = pcall(callback, self)
    self:stop()
    if not success then
      why = return_value
      local message = string.format("%s: Failed in start callback: %s",
                                    Geckodriver.log_prefix,
                                    why)
      self.firefox.logger:error(message)
      self.firefox.logger:traceback("error")
      error(message)
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
    firefox_log_context = {
      in_http_request = false,
      in_http_response = false,
    },
    connection_logs = {},
  }
  setmetatable(geckodriver, metatable)
  return geckodriver
end

return Geckodriver
