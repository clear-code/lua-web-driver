local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/move.html"

driver:start_session(function(session)
  session:navigate_to(URL)

  local text_form = session:find_element("css selector", 'input[name=username]')
  text_form:send_keys("username")
  local password_form = session:find_element("css selector", 'input[name=password]')
  password_form:send_keys("password")

  local button = session:find_element("css selector", "#button")
  button:click()

  local link = session:find_element("css selector", "a[name=1]")
  link:click()
  local element = session:find_element("css selector", "p")
  print(element:text())
end)
