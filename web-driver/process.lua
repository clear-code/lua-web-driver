local unix = require("unix")

local pp = require("web-driver/pp")

local Process = {}
Process.log_prefix = "web-driver: Process"

local methods = {}
local metatable = {}

function metatable.__index(geckodriver, key)
  return methods[key]
end

function methods:create_pipe()
  local success, input, output = pcall(unix.fpipe, "e")
  if not success then
    local why = input
    local errno = output
    local message = string.format("%s: Failed to create pipe: %s: <%d>",
                                  Process.log_prefix,
                                  why,
                                  errno)
    self.logger:error(message)
    self.logger:traceback("error")
    error(message)
  end
  return input, output
end

function methods:spawn()
  local stdout, child_stdout = self:create_pipe()
  self.stdout = stdout
  self.child_stdout = child_stdout
  local stderr, child_stderr = self:create_pipe()
  self.stderr = stderr
  self.child_stderr = child_stderr
  local pid = unix.fork()
  if pid == 0 then
    local args = {self.command}
    local i, arg
    for i, arg in ipairs(self.arguments) do
      table.insert(args, arg)
    end
    stdout:close()
    stderr:close()
    local dev_null = io.open("/dev/null", "r")
    unix.dup2(unix.fileno(dev_null), 0)
    unix.dup2(unix.fileno(child_stdout), 1)
    unix.dup2(unix.fileno(child_stderr), 2)
    unix.setsid()
    unix.execvp(self.command, args)
    unix._exit(1)
  end
  self.child_stdout:close()
  self.child_stdout = nil
  self.child_stderr:close()
  self.child_stderr = nil
  self.id = pid
end

function methods:kill_raw(pid, signal)
  local success, why = pcall(unix.kill, pid, signal)
  if not success then
    local message = string.format("%s: %s: <%s>: <%d>: <%d>: %s",
                                  Process.log_prefix,
                                  "Failed to kill",
                                  self.command,
                                  pid,
                                  signal,
                                  why)
    self.logger:error(message)
    self.logger:traceback("error")
    error(message)
  end
end

function methods:kill(force)
  if force then
    self:kill_raw(-self.id, unix.SIGKILL)
    unix.kill(self.id, unix.SIGKILL)
  else
    self:kill_raw(self.id, unix.SIGTERM)
  end
end

function methods:check(wait)
  local flags = 0
  if not wait then
    flags = unix.WNOHANG
  end
  local success, pid, status, exit_code = pcall(unix.waitpid, self.id, flags)
  if not success then
    local why = pid
    local message = string.format("%s: %s: <%s>: %s",
                                  Process.log_prefix,
                                  "Failed to run waitpid()",
                                  self.command,
                                  why)
    self.logger:error(message)
    self.logger:traceback("error")
    error(message)
  end
  if pid == self.id then
    self.id = nil
    return status, exit_code
  else
    return "running", nil
  end
end

function Process.new(command, arguments, logger)
  local process = {
    command = command,
    arguments = arguments,
    logger = logger,
    id = nil,
    stdout = nil,
    stderr = nil,
  }
  setmetatable(process, metatable)
  return process
end

return Process
