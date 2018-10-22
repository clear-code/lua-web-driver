local cqueues = require("cqueues")
local http_request = require("http.request")
local posix_spawn = require("spawn.posix")
local unix = require("unix")

local LogLevel = require("web-driver/log-level")
local pp = require("web-driver/pp")

local Geckodriver = {}
Geckodriver.log_prefix = "web-driver: geckodriver"

local methods = {}
local metatable = {}

if not os.getenv("MOZ_LOG") then
  -- For implementing Session:status_code
  local ffi = require("ffi")
  ffi.cdef("int setenv(const char *name, const char *value, int overwrite);")
  ffi.C.setenv("MOZ_LOG", "timestamp,sync,nsHttp:3", 1)
end

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
  if self.log_context.firefox.in_http_request then
    local last_connection_log = self.connection_logs[#self.connection_logs]
    if message == "]" then
      self.log_context.firefox.in_http_request = false
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
  elseif self.log_context.firefox.in_http_response then
    local last_connection_log = self.connection_logs[#self.connection_logs]
    if message == "]" then
      self.log_context.firefox.in_http_response = false
    elseif message:sub(1, 7) == "  HTTP/" then
      last_connection_log.status_code = tonumber(message:match("^  [^ ]+ (%d+)"))
    elseif message == "    OriginalHeaders" then
      self.log_context.firefox.in_original_response_headers = true
    else
      local response_headers
      if self.log_context.firefox.in_original_response_headers then
        response_headers = last_connection_log.original_response_headers
      else
        response_headers = last_connection_log.response_headers
      end
      local name, value = message:match("^  ([^:]+): (.*)$")
      response_headers[name] = value
    end
  else
    if message == "http request [" then
      self.log_context.firefox.in_http_request = true
      table.insert(self.connection_logs, {
        method = nil,
        host = nil,
        path = nil,
        request_headers = {},
      })
    elseif message == "http response [" then
      local last_connection_log = self.connection_logs[#self.connection_logs]
      if last_connection_log then
        self.log_context.firefox.in_http_response = true
        self.log_context.firefox.in_original_response_headers = false
        last_connection_log.status_code = nil
        last_connection_log.response_headers = {}
        last_connection_log.original_response_headers = {}
      end
    end
  end
end

function methods:log_firefox_line(prefix, context, line)
  local year, month, day, hour, minute, second, micro_second, log_context, firefox_log_level, firefox_component, message =
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
                                    log_context,
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
  elseif context.last.timestamp then
    local last = context.last
    self.firefox.logger:log(log_level_from_geckodriver(last.level),
                            format_log_message(prefix,
                                               last.timestamp,
                                               last.component,
                                               line))
  else
    self.firefox.logger:log(self.firefox.logger:level(),
                            format_log_message(prefix,
                                               0,
                                               "Firefox",
                                               line))
  end
end

function methods:log_line(prefix, context, line)
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
    context.last.timestamp = timestamp
    context.last.component = component
    context.last.level = level
  else
    self:log_firefox_line(prefix, context, line)
  end
end

local function create_pollable(input)
  return {
    pollfd = function() return unix.fileno(input) end,
    events = function() return "r" end,
  }
end

function methods:correct_log(input_type)
  local input = self.process[input_type]
  local pollable = create_pollable(input)
  while true do
    local ready = cqueues.poll(pollable)
    if type(ready) == "table" then
      local line = input:read("*l")
      if not line then
        input:close()
        break
      end
      self:log_line(Geckodriver.log_prefix .. ": " .. input_type,
                    self.log_context[input_type],
                    line)
    else
      if not self.process.id then
        break
      end
    end
  end
end

function methods:clear_connection_logs()
  self.connection_logs = {}
  self.log_context.firefox.in_http_request = false
  self.log_context.firefox.in_http_response = false
end

function methods:start_log_correctors()
  self.firefox.loop:wrap(function()
    local success, why = pcall(function() self:correct_log("stdout") end)
    self.process.stdout = nil
    if not success then
      self.firefox.logger:error(string.format("%s: %s: %s",
                                              Geckodriver.log_prefix,
                                              "Failed to log stdout",
                                              why))
    end
  end)
  self.firefox.loop:wrap(function()
    local success, why = pcall(function() self:correct_log("stderr") end)
    self.process.stderr = nil
    if not success then
      self.firefox.logger:error(string.format("%s: %s: %s",
                                              Geckodriver.log_prefix,
                                              "Failed to log stderr",
                                              why))
    end
  end)
end

function methods:wait_log()
  local stdout_pollable = create_pollable(self.process.stdout)
  local stderr_pollable = create_pollable(self.process.stderr)
  while true do
    local ready = cqueues.poll(stdout_pollabel, stderr_pollable, 0.1)
    if type(ready) ~= "table" then
      break
    end
    local success, why, error_context = self.firefox.loop:step()
    if not success then
      local message = string.format("%s: %s: %s: %s",
                                    Geckodriver.log_prefix,
                                    "Failed to wait log",
                                    why,
                                    error_context)
      self.firefox.logger:error(message)
    end
  end
end

function methods:create_pipe()
  local success, input, output = pcall(unix.fpipe, "e")
  if not success then
    local why = input
    local errno = output
    local message = string.format("%s: Failed to create pipe: %s: <%d>",
                                  Geckodriver.log_prefix,
                                  why,
                                  errno)
    self.firefox.logger:error(message)
    self.firefox.logger:traceback("error")
    error(message)
  end
  return input, output
end

function methods:create_spawn_file_actions()
  local file_actions, why, errno = posix_spawn.new_file_actions()
  if not file_actions then
    local message = string.format("%s: %s: %s: <%d>",
                                  Geckodriver.log_prefix,
                                  "Failed to create spawn file actions",
                                  why,
                                  errno)
    self.firefox.logger:error(message)
    self.firefox.logger:traceback("error")
    error(message)
  end
  local stdout, child_stdout = self:create_pipe()
  self.process.stdout = stdout
  self.process.child_stdout = child_stdout
  local stderr, child_stderr = self:create_pipe()
  self.process.stderr = stderr
  self.process.child_stderr = child_stderr
  file_actions:addclose(0)
  file_actions:adddup2(unix.fileno(child_stdout), 1)
  file_actions:adddup2(unix.fileno(child_stderr), 2)
  return file_actions
end

function methods:create_spawn_attributes()
  local attributes, why, errno = posix_spawn.new_attr()
  if not attributes then
    local message = string.format("%s: %s: %s: <%d>",
                                  Geckodriver.log_prefix,
                                  "Failed to create spawn attributes",
                                  why,
                                  errno)
    self.firefox.logger:error(message)
    self.firefox.logger:traceback("error")
    error(message)
  end
  attributes:setpgroup(0)
  return attributes
end

function methods:spawn()
  local file_actions = self:create_spawn_file_actions()
  local attributes = self:create_spawn_attributes()
  local args = {self.command}
  local i, arg
  for i, arg in ipairs(self.args) do
    table.insert(args, arg)
  end
  local env = nil
  local success, pid, why, errno =
    pcall(posix_spawn.spawnp,
          self.command,
          file_actions,
          attributes,
          args,
          env)
  self.process.child_stdout:close()
  self.process.child_stdout = nil
  self.process.child_stderr:close()
  self.process.child_stderr = nil
  if not pid then
    self.process.stdout:close()
    self.process.stdout = nil
    self.process.stderr:close()
    self.process.stderr = nil
    local message = string.format("%s: Failed to execute: <%s>: %s: <%d>",
                                  Geckodriver.log_prefix,
                                  self.command,
                                  why,
                                  errno)
    self.firefox.logger:error(message)
    self.firefox.logger:traceback("error")
    error(message)
  end
  self.process.id = pid
  self:start_log_correctors()
end

function methods:kill_process_raw(pid, signal)
  local success, why = pcall(unix.kill, pid, signal)
  if not success then
    local message = string.format("%s: Failed to kill process: <%d>: <%d>: %s",
                                  Geckodriver.log_prefix,
                                  pid,
                                  signal,
                                  why)
    self.firefox.logger:error(message)
    self.firefox.logger:traceback("error")
    error(message)
  end
end

function methods:kill_process(force)
  local pid, signal
  if force then
    self:kill_process_raw(-self.process.id, unix.SIGKILL)
    self:kill_process_raw(self.process.id, unix.SIGKILL)
  else
    self:kill_process_raw(self.process.id, unix.SIGTERM)
  end
end

function methods:check_process_status(wait)
  local flags = 0
  if not wait then
    flags = unix.WNOHANG
  end
  local success, pid, status, exit_code =
    pcall(unix.waitpid, self.process.id, flags)
  if not success then
    local why = pid
    local message = string.format("%s: Failed to run waitpid(): %s",
                                  Geckodriver.log_prefix,
                                  why)
    self.firefox.logger:error(message)
    self.firefox.logger:traceback("error")
    error(message)
  end
  if pid == self.process.id then
    self.process.id = nil
    while self.process.stdout or self.process.stderr do
      local success, why, error_context = self.firefox.loop:loop()
      if success then
        break
      else
        local message = string.format("%s: %s: %s: %s",
                                      Geckodriver.log_prefix,
                                      "Failed to wait log on exit",
                                      why,
                                      error_context)
        self.firefox.logger:error(message)
      end
    end
    return status, exit_code
  else
    return "running", nil
  end
end

function methods:kill()
  local timeout = 5
  local n_tries = 100
  local sleep_per_try = (timeout / n_tries)
  self:kill_process(false)
  for i = 1, n_tries do
    local status, exit_code = self:check_process_status(false)
    if exit_code then
      return
    end
    local success, why, error_context = self.firefox.loop:loop(sleep_per_try)
    if not success then
      local message = string.format("%s: %s: %s: %s",
                                    Geckodriver.log_prefix,
                                    "Failed to wait stopping geckodriver",
                                    why,
                                    error_context)
      self.firefox.logger:error(message)
    end
  end

  self:kill_process(true)
  self:check_process_status(true)
end

function methods:ensure_running()
  local timeout = self.firefox.start_timeout
  local n_tries = 100
  local sleep_per_try = (timeout / n_tries)
  local url = string.format("http://%s:%d/status",
                            self.firefox.client.host,
                            self.firefox.client.port)
  local request = http_request.new_from_uri(url)
  for i = 1, n_tries do
    local status, exit_code = self:check_process_status(false)
    if exit_code then
      local message = string.format("%s: Failed to run: <%s>: <%s>: <%d>",
                                    Geckodriver.log_prefix,
                                    self.command,
                                    status,
                                    exit_code)
      self.firefox.logger:error(message)
      self.firefox.logger:traceback("error")
      error(message)
    end
    local done = false
    local connected = false
    self.firefox.loop:wrap(function()
      local headers, stream = request:go()
      if headers then
        connected = true
        stream:shutdown()
      end
      done = true
    end)
    while not done do
      local success, why, error_context = self.firefox.loop:step()
      if not success then
        local message = string.format("%s: %s: %s: %s",
                                      Geckodriver.log_prefix,
                                      "Failed to connect to geckodriver",
                                      why,
                                      error_context)
        self.firefox.logger:error(message)
      end
    end
    if connected then
      return true
    end
    local success, why, error_context = self.firefox.loop:loop(sleep_per_try)
    if not success then
      local message = string.format("%s: %s: %s: %s",
                                    Geckodriver.log_prefix,
                                    "Failed to wait running geckodriver",
                                    why,
                                    error_context)
      self.firefox.logger:error(message)
    end
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
  self:spawn()
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
  if not self.process.id then
    return
  end
  self:kill()
end

local function build_args(firefox)
  local args = {
    "--host", firefox.client.host,
    "--port", tostring(firefox.client.port),
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
    process = {
      id = nil,
    },
    log_context = {
      stdout = {
        last = {
          timestamp = nil,
          component = nil,
          level = nil,
        },
      },
      stderr = {
        last = {
          timestamp = nil,
          component = nil,
          level = nil,
        },
      },
      firefox = {
        in_http_request = false,
        in_http_response = false,
      },
    },
    connection_logs = {},
  }
  setmetatable(geckodriver, metatable)
  return geckodriver
end

return Geckodriver
