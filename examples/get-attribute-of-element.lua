local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/get-attribute.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local elements = session:css_select('p')
  for _, element in ipairs(elements) do
    if element["data-value-type"] == "number" then
      print(element:text())
    end
  end
end)
