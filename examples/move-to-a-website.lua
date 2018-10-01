local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/move.html"

driver:start_session(function(session)
  session:navigate_to(URL)

  local text_form = session:css_select('input[name=username]')
  text_form:send_keys("username")
  local password_form = session:css_select('input[name=password]')
  password_form:send_keys("password")

  local button = session:css_select("#button")
  button:click()

  local link = session:link_search ("1")
  link:click()
  local elements = session:css_select("p")
  print(elements:text())
end)
