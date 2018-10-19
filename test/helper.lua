local process = require("process")
local http_request = require("http.request")

local helper = {}

helper.PNG_HEADER = { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A }

function helper.start_server()
  local server = process.exec("ruby", { "-run", "-e", "httpd", "--", "--port", "10080", "test/fixtures" })
  local url = "http://127.0.0.1:10080/index.html"
  while true do
    local success, why = pcall(function()
      http_request.new_from_uri(url):go()
    end)
    if success then
      break
    end
    process.nsleep(1000)
  end
  return server
end

return helper
