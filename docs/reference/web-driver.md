---
title: web-driver
---

# `web-driver` module

## Summary

It's the main module.

## Module variables

### `VERSION` {#version}

It has the version of LuaWebDriver as Lua's string.
You can output LuaWebDriver's version to stdout as below.

Example:

```lua
local web_driver = require("web-driver")
print(web_driver.VERSION)
```

### `Firefox` {#firefox}

It has the WebDriver for Firefox object.
You can create [`web-driver.Firefox`][firefox] object via this variable as below.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()
```

## See also

  * [web-driver.Firefox][firefox]


[firefox]:firefox.html
