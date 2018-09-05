# LuaWebDriver

This is a browser automation library using [WebDriver](https://www.w3.org/TR/webdriver/) API.
Currently, this library supports [geckodriver](https://github.com/mozilla/geckodriver) only.

## Installation

Use [LuaRocks](https://luarocks.org/).

```
$ luarocks install lua-web-driver
```

## Usage

```lua
local WebDriver = require("web-driver")

local driver = WebDriver.create("firefox")

function callback(session)
  session:visit("http://example.com")
  local elements = session:css("a")
  element[0]:click()
  print(session:source())
end

driver:start()
driver:start_session(callback)
driver:stop()
```

## License

MIT License. See LICENSE file.
