local IPCProtocol = {}

function IPCProtocol.write(socket, task)
  if task then
    socket:write(task)
    socket:flush()
  end
  socket:shutdown("w")
  socket:read("*a") -- Wait "GOT"
  socket:close()
end

function IPCProtocol.read(socket)
  local data = socket:read("*a")
  socket:write("GOT")
  socket:flush()
  socket:shutdown("w")
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
