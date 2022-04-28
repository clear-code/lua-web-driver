---
title: web-driver.Session
---

# `web-driver.Session` class

## Summary

It's a class for handling WebDriver's session.

It has methods of the following modules:

  * [`web-driver.Element`][element]: The class for handling web elements.
  * [`web-driver.ElementSet`][elementset]: The class for multiple elements.
  * [`web-driver.Searchable`][searchable]: Provides element search related methods.

It means that you can use methods in the modules.

## Instance methods

### `navigate_to(url) -> void` {#navigate-to}

This method moves to the website of the specified the URL.

`url`: Specify the URL of the website you want to move.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
end)
```

### `status_code() -> number` {#status-code}

It returns an HTTP status code as a number.

If request is normally finished, an HTTP status code is 200.
If the request isn't normally finished, an HTTP status code is except for 200.

However, this method may fail.
Because the WebDriver isn't supported this feature.

If this method fail, it returns nil.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(CORRECT_URL)
  local status_code = session:status_code()
  print(status_code)
  -- 200
end)
```

### `request_headers -> {Host="xxxx", Accept-Encoding="xxxx", Connection="xxxx", Accept="xxxx", User-Agent="xxxx", Upgrade-Insecure-Requests="xxxx", Accept-Language="xxxx"}` {#request-headers}

It returns a header of HTTP last request as a table.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  local request_headers = session:request_headers()
  for k,v in pairs(request_headers) do
    print(k,v)
    -- Host	clear-code.gitlab.io
    -- Accept-Encoding	gzip, deflate, br
    -- Connection	keep-alive
    -- Accept	text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
    -- User-Agent	Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0
    -- Upgrade-Insecure-Requests	1
    -- Accept-Language	ja,en-US;q=0.7,en;q=0.3
  end
end)
```

### `url() -> string` {#url}

It returns the URL of current the website as string.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  print(session:url())
  -- https://lua-web-driver.gitlab.io/lua-web-driver/sample/
end)
```

### `forward() -> void` {#forward}

This method traverse one step forwards in the history from the current website.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL1 = "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"
local URL2 = "https://lua-web-driver.gitlab.io/lua-web-driver/sample/button.html"

driver:start_session(function(session)
  session:navigate_to(URL1)
  session:navigate_to(URL2)
  print(session:url())
  --https://lua-web-driver.gitlab.io/lua-web-driver/sample/button.html
  session:back()
  print(session:url())
  --https://lua-web-driver.gitlab.io/lua-web-driver/sample/
  session:forward()
  print(session:url())
  --https://lua-web-driver.gitlab.io/lua-web-driver/sample/button.html
end)
```

### `back() -> void` {#back}

This method traverse one step backs in the history from the current website.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL1 = "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"
local URL2 = "https://lua-web-driver.gitlab.io/lua-web-driver/sample/button.html"

driver:start_session(function(session)
  session:navigate_to(URL1)
  session:navigate_to(URL2)
  print(session:url())
  --https://lua-web-driver.gitlab.io/lua-web-driver/sample/button.html
  session:back()
  print(session:url())
  --https://lua-web-driver.gitlab.io/lua-web-driver/sample/
end)
```

### `refresh() -> void` {#refresh}

This method reloads the current website.

When this method is executed, unsaved values is cleared and updated real-time information.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  local elements = session:css_select('input[name=name]')
  elements:send_keys("This is test")
  print(elements[1].value)
  -- This is test
  session:refresh()
  local refreshed_elements = session:css_select('input[name=name]')
  print(refreshed_elements[1].value)
  -- ""
end)
```

### `title() -> string` {#title}

This method gets title of the current website.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  print(session:title())
  -- This is test html
end)
```

### `window_handle() -> string` {#window-handle}

This method gets the window handle of the current window.

It returns the window handle as string.

The window handles is used to switch multiple windows and identify the window also.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://lua-web-driver.gitlab.io/lua-web-driver/sample/window.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local next_handle = session:window_handles()[2]
  print(session:window_handle())
  -- 2147483649
  session:switch_to_window(next_handle)
  print(session:window_handle())
  -- 2147483656
end)
```

### `close_window() -> {remaining_window_handle1, remaining_window_handle2, ...}` {#close-window}

This method close the current window. It returns handle of remaining window as a table.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://lua-web-driver.gitlab.io/lua-web-driver/sample/window.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  remaining_handles = session:close_window()
  session:switch_to_window(remaining_handles[1])
end)
```

### `switch_to_window(handle) -> void` {#switch-to-window}

This method is a switch to the window of the specify handle.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://lua-web-driver.gitlab.io/lua-web-driver/sample/window.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  remaining_handles = session:close_window()
  session:switch_to_window(remaining_handles[1])
end)
```

### `window_handles() -> {window_handle1, window_handle2, ...}` {#window-handles}

This method gets the window handles of the current session.

It returns the window handles as table.

The window handles is used to switch multiple windows and identify the window also.


Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://lua-web-driver.gitlab.io/lua-web-driver/sample/window.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local window_handles = session:window_handles()
  for _,handle in pairs(window_handles) do
    print(handle)
    --2147483649
    --2147483656
    --2147483653
  end
  print(session:window_handle())
  --2147483649
  session:switch_to_window(window_handles[2])
  --2147483656
  print(session:window_handle())
```

### `maximize_window() -> void` {#maximize-windows}

This method maximizes the current window.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  session:set_window_rect({ height = 500, width = 500, x = 0, y = 0 })
  for k,v in pairs(session:window_rect()) do
    print(k,v)
  end
  -- y	0
  -- width	500
  -- height	500
  -- x	0
  session:maximize_window()
  for k,v in pairs(session:window_rect()) do
    print(k,v)
  end
  -- y	0
  -- width	1366
  -- height	768
  -- x	0
end)
```

### `minimize_window() -> void` {#minimize-window}

This method minimizes the current window.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  session:set_window_rect({ height = 500, width = 500, x = 0, y = 0 })
  for k,v in pairs(session:window_rect()) do
    print(k,v)
  end
  -- y	0
  -- width	500
  -- height	500
  -- x	0
  session:minimize_window()
  for k,v in pairs(session:window_rect()) do
    print(k,v)
  end
  -- y	0
  -- width	0
  -- height	0
  -- x	0
end)
```

### `fullscreen_window() -> {height=xxxx, width=xxxx, x=xxxx, y=xxxx}` {#fullscreen-window}

This method is to fullscreen the current window.
It returns window size and position at the full screen as a table.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  session:set_window_rect({ height = 500, width = 500, x = 0, y = 0 })
  for k,v in pairs(session:window_rect()) do
    print(k,v)
  end
  -- y	0
  -- width	500
  -- height	500
  -- x	0
  session:fullscreen_window()
  for k,v in pairs(session:window_rect()) do
    print(k,v)
  end
  -- y	0
  -- width	1366
  -- height	768
  -- x	0
end)
```

### `window_rect() -> {height=xxxx, width=xxxx, x=xxxx, y=xxxx}` {#window-rect}

This method gets window size and position of a current window.
It return window size and position of the current window as a table.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  session:set_window_rect({ height = 500, width = 500, x = 0, y = 0 })
  for k,v in pairs(session:window_rect()) do
    print(k,v)
  end
  -- y	0
  -- width	500
  -- height	500
  -- x	0
end)
```

### `set_window_rect(rect) -> table` {#set-window-rect}

This method sets window rectangle of the current window.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  session:set_window_rect({ height = 500, width = 500, x = 0, y = 0 })
  for k,v in pairs(session:window_rect()) do
    print(k,v)
  end
  -- y	0
  -- width	500
  -- height	500
  -- x	0
end)
```

### `switch_to_frame(id) -> void` {#switch-to-frame}

`id`: Specify id of a frame of want to switch as a number.

This method switch to the frame of the specified frame id.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://lua-web-driver.gitlab.io/lua-web-driver/sample/frame.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  print(session:title())
  -- This is parent frame
  session:switch_to_frame(0)
  local element = session:find_element("css selector", "p")
  print(element:text())
  -- 1
  print(session:title())
  -- This is test html 1
end)
```

### `switch_to_parent_frame() -> void` {#switch-to-parent-frame}

This method switch to the parent frame of the current frame.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://lua-web-driver.gitlab.io/lua-web-driver/sample/frame.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  print(session:title())
  -- This is parent frame
  session:switch_to_frame(0)
  local element = session:find_element("css selector", "p")
  print(element:text())
  -- 1
  print(session:title())
  -- This is test html 1
  session:switch_to_parent_frame()
  element = session:find_element("css selector", "p")
  print(element:text())
  -- parent
  print(session:title())
  -- This is parent frame
end)
```

### `find_element(strategy, finder) -> web-driver.Element` {#find-element}

This method is find web element by some retrieval methods.

`strategy`: Specify how to search the element. You can set the argument as below.

  * `css selector`: Serch the element by CSS selector.
  * `link text`: Serach the element by Link text selector.
  * `partical link text`: Search the element by Partical link text selector.
  * `tag name`: Search the element by Tag name.
  * `xpath`: Search the element by XPath selector.

`finder`: Specify search the keyword.

It returns the element as [`web-driver.Element`][element].


Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)

  local element = session:find_element("css selector", "#p1")
  element:save_screenshot("element.png")
end)
```

### `find_elements(strategy, finder) -> web-driver.ElementSet` {#find-elements}

This method is find web elements by some retrieval methods.

`strategy`: Specify how to search elements. You can set the argument as below.

  * `css selector`: Serch the element by CSS selector.
  * `link text`: Serach the element by Link text selector.
  * `partical link text`: Search the element by Partical link text selector.
  * `tag name`: Search the element by Tag name.
  * `xpath`: Search the element by XPath selector.

`finder`: Specify search the keyword.

It returns elements as [`web-driver.ElementSet`][elementset].

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)

  local elements = session:find_elements("css selector", 'p')
  for _,v in pairs(elements:texts()) do
    print(v)
-- Hello 1
-- Hello 2
-- Hello 3
  end
end)
```

### `active_element() -> web-driver.Element` {#active-element}

This method gets the active element in the current website as [`web-driver.Element`][element].

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  local text_form = session:active_element()
  text_form:send_keys("This is test")
  print(text_form[1].value)
  -- This is test
end)

```

### `xml() -> string` {#xml}

It returns a current website's source as XML.
You can use this XML as Lua's string.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  local xml = session:xml()
  print(xml)
end)
```

### `execute_script(script, args) -> the return value of given script` {#execute-script}

This method executes specify your java script.
It returns the return value of the given script.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  local script = [[return 1]]
  print(session:execute_script(script))
  -- 1
end)
```

### `execute_script_async(script, args) -> ` {#execute-script-async}

This method executes specify your java script as an asynchronous script.
It returns the return value of the given script.


Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  local script = [[return 1]]
  print(session:execute_script_async(script))
  -- 1
end)
```

### `all_cookies() -> table` {#all-cookies}

This method gets all cookies in the current website.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/cookie.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local cookies = session:all_cookies()
  print(cookies[1].name, cookies[1].value)
  -- data1  123
  print(cookies[2].name, cookies[2].value)
  -- data2  456
end)
```

### `get_cookie(name) -> table` {#get-cookie}

This method gets specify cookie.

`name`: Specify the name of a cookie to add as a string.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/cookie.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local cookie = session:get_cookie("data1")
  print(cookie.name, cookie.value)
  -- data1  123
end)
```

### `add_cookie(cookie) -> void` {#add-cookie}

`cookie`: Specify a cookie to add as a table.

This method adds a specify cookie in the current website.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/cookie.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local cookies = session:all_cookies()
  print(#cookies)
  -- 2
  local cookie = {
    name = "data3",
    value = "789",
  }
  session:add_cookie(cookie)
  cookies = session:all_cookies()
  print(#cookies)
  -- 3
  print(cookies[3].name, cookies[3].value)
  -- data3  789
end)
```

### `delete_cookie(name) -> void` {#delete-cookie}

`name`: Specify the name of a cookie to delete as a string.

This method deletes a specify cookie from the current website.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/cookie.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local cookies = session:all_cookies()
  print(#cookies)
  -- 2
  session:delete_cookie("data1")
  cookies = session:all_cookies()
  print(#cookies)
  -- 1
  print(cookies[1].name, cookies[1].value)
  -- data2  456
end)
```

### `delete_all_cookies() -> void` {#delete-all-cookies}

This method delete all cookies in the current website.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/cookie.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local cookies = session:all_cookies()
  print(#cookies)
  -- 2
  session:delete_all_cookies("data1")
  cookies = session:all_cookies()
  print(#cookies)
  -- 0
end)
```

### `perform_actions(actions) -> void` {#perform-actions}

`actions`: Specify actions as a table.

This method executes together actions specified as an argument.

You refer to specification of [`WebDriver`][web-driver] about how to make actions.

### `release_actions() -> void` {#release-actions}

This method release all the keys and pointer buttons that are currently depressed.

### `dismiss_alert() -> void` {#dismiss-alert}

This method push "Cancel" button on the current dialog.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/confirm.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local element = session:find_element("css selector", "#button")
  element:click()
  session:dismiss_alert()
  element = session:find_element("css selector", "#confirm")
  print(element:text())
  -- Dismiss!
end)
```

### `accept_alert() -> void` {#accept-alert}

This method push "OK" button on the current dialog.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/confirm.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local element = session:find_element("css selector", "#button")
  element:click()
  session:accept_alert()
  element = session:find_element("css selector", "#confirm")
  print(element:text())
  -- Accept!
end)
```

### `alert_text() -> string` {#alert-text}

This method gets text on the current dialog.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/confirm.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local element = session:find_element("css selector", "#button")
  element:click()
  print(session:alert_text())
  -- ok?
end)
```

### `set_alert_text(text) -> void` {#set-alert-text}

`text`: Specify the text of a dialog as a string.

This method sets specify text on the current dialog

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/confirm.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local element = session:find_element("css selector", "#button")
  element:click()
  print(session:alert_text())
  -- ok?
  session:set_alert_text("setting text")
  print(session:alert_text())
  -- setting text
end)
```

### `take_screenshot() -> string` {#take-screenshot}

It returns the screenshot of the current website as a string(this is a png format data).

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)

  local png = element:take_screenshot()
end)

```

### `save_screenshot(filename) -> void` {#save-screenshot}

This method saves in the specific file the screenshot of the current website as PNG format.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  session:save_screenshot("sample.png")
end)

```


## See also

  * [`web-driver.Searchable`][searchable]: Provides element search related methods.

  * [`web-driver.ElementSet`][elementset]: The class for multiple elements.


[searchable]:searchable.html

[elementset]:elementset.html

[element]:element.html

[web-driver]:https://www.w3.org/TR/webdriver1/#actions
