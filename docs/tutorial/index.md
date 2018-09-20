---
title: Tutorial
---

# Tutorial

This document describes how to use LuaWebDriver step by step. If you don't install LuaWebDriver yet, [install][install] LuaWebDriver before you read this document.

## Start and stop web browser {#start-stop-web-browser}

You need to start WebDriver at first to start web browser.

You can use [`WebDriver.create`][webdriver-create] and [`FirefoxDriver.start`][firefoxdriver-start] to start web browser as below example.

Also you need to stop web browser when you finish your processing.

You can use [`FirefoxDriver.stop`][firefoxdriver-stop] to stop web browser.

Example:

```lua
local WebDriver = require("web-driver")
local driver = WebDriver.create("firefox")

driver:start()
driver:stop()
```

You can also start web browser as headless mode as below example.

Note that browser options must set as value of args key.

Example:

```lua
local WebDriver = require("web-driver")

-- Make browser options as Lua's table
-- Browser options must set as value of args key
local options = {
  args = { "-headless" }
}

local driver = WebDriver.create("firefox", browser_options)

driver:start()
driver:stop()
```

## Next step {#next-step}

Now, you knew all major LuaWebDriver features! If you want to understand each feature, see [reference manual][reference] for each feature.


[install]:../install/

[webdriver-create]:../reference/webdriver.html#create

[firefoxdriver-start]:../reference/firefoxdriver.html#start

[firefoxdriver-stop]:../reference/firefoxdriver.html#stop

[reference]:../reference/
