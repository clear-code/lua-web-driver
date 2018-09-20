local process = require("process")
local requests = require("requests")
local inspect = require("inspect")

local helper = {}

helper.PNG_HEADER = { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A }

function helper.p(root, options)
  print(inspect.inspect(root, options))
end

helper.capabilities = {
  args = { "-headless" }
}

function helper.start_server()
  local server = process.exec("ruby", { "-run", "-e", "httpd", "--", "--port", "10080", "test/fixtures" })
  local success, response
  while true do
    success, response = pcall(requests.get, "http://localhost:10080/index.html")
    if success then
      break
    end
    process.nsleep(1000)
  end
  return server
end

return helper
