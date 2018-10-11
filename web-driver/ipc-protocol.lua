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

return IPCProtocol
