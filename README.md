# LuaWebDriver

https://clear-code.gitlab.io/lua-web-driver/

This is a browser automation library using [WebDriver](https://www.w3.org/TR/webdriver/) API.
Currently, this library supports [geckodriver](https://github.com/mozilla/geckodriver) only.

## Installation

Use [LuaRocks](https://luarocks.org/).

```
$ luarocks install web-driver
```

## Usage

```lua
local web_driver = require("web-driver")

local firefox = web_driver.Firefox.new(''')

function callback(session)
  session:visit("http://example.com")
  local elements = session:css("a")
  element[0]:click()
  print(session:source())
end

firefox:start()
firefox:start_session(callback)
firefox:stop()
```

## License

MIT License. See LICENSE file.
