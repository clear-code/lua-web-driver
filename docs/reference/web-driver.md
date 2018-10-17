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

### `ThreadPool` {#thread-pool}

It is a thread pool object.
You use this object when executing for multithread.

For more informations about this object, see [`web-driver.ThreadPool`][thread-pool].

## See also

  * [web-driver.Firefox][firefox]

  * [web-driver.ThreadPool][thread-pool]


[firefox]:firefox.html

[thread-pool]:thread-pool.html
