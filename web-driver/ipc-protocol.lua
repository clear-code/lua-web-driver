local IPCProtocol = {}

function IPCProtocol.write(socket, task)
  if task then
    socket:write(task)
    socket:flush()
  end
  socket:shutdown("w")
  local status = socket:read("*a")
  socket:close()
  return status == "SUCCESS"
end

function IPCProtocol.read(socket, callback)
  local read_success, data = pcall(function() return socket:read("*a") end)
  if not read_success then
    local why = data
    -- TODO: Report why?
    data = nil
  end
  local success = read_success
  if callback then
    success = callback(data)
  end
  if success then
    socket:write("SUCCESS")
  else
    socket:write("ERROR")
  end
  if read_success then
    socket:flush()
    socket:shutdown("w")
  end
  socket:close()
  return data
end

function IPCProtocol.log(socket, level, message)
  IPCProtocol.write(socket, level .. "\n" .. message)
end

function IPCProtocol.receive_log(socket)
  local level = socket:read("*l")
  if not level then
    return nil, nil
  end
  local message = IPCProtocol.read(socket)
  return level, message
end

return IPCProtocol
