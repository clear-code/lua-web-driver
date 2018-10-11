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
  local data = socket:read("*a")
  local return_value = data
  local success = true
  if callback then
    success, return_value = callback(data)
  end
  if success then
    socket:write("SUCCESS")
  else
    socket:write("ERROR")
  end
  socket:flush()
  socket:shutdown("w")
  socket:close()
  return return_value
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
