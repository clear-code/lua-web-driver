---
title: Tutorial
---

# Tutorial

This document describes how to use LuaWebDriver step by step. If you don't install LuaWebDriver yet, [install][install] LuaWebDriver before you read this document.

## Start and stop Web browser {#start-stop-web-browser}

You need to start WebDriver at first to start Web browser.

You can use [`WebDriver.create`][webdriver-create] and [`FirefoxDriver.start`][firefoxdriver-start] to start Web browser as below example.
Web browser starts in headless mode with default.

Also you need to stop Web browser when you finish your processing.

You can use [`FirefoxDriver.stop`][firefoxdriver-stop] to stop Web browser.

Example:

```lua
local WebDriver = require("web-driver")
local driver = WebDriver.create("firefox")

driver:start()
driver:stop()
```

## Visit to a Website {#visit-to-website}

You can use [`Session.visit`][session-visit] to visit a specific Website with the Web browser.

First of all, you make a callback function for visit to a Website.
You specify the URL as the argument of [`Session.visit`][session-visit]

Second, you specify your callback as the argument of [`Session.start`][session-start] and call [`Session.start`][session-start].
the session is destroyed auto after calling your callback.

Example:

```lua
local WebDriver = require("web-driver")
local driver = WebDriver.create("firefox")

-- Make your callback
function callback(session)
-- Specify the URL as the argument of Session.visit
  session:visit("https://www.google.com/")
end

driver:start()
-- Specify your callback as the argument of Session.start
driver:start_session(callback)
driver:stop()
```

## Serialize to Website {#serialize-to-website}

You can use [`Session.xml`][session-xml] to serialize a Website as XML.

First of all, you visit to a Website to serialize as below example.

Second, you call [`Session.xml`][session-xml].

Then you can serialize a current Website as XML.
You can use this XML as Lua's string.

Example:

```lua
```

## Next step {#next-step}

Now, you knew all major LuaWebDriver features! If you want to understand each feature, see [reference manual][reference] for each feature.


[install]:../install/

[webdriver-create]:../reference/webdriver.html#create

[firefoxdriver-start]:../reference/firefoxdriver.html#start

[firefoxdriver-stop]:../reference/firefoxdriver.html#stop

[session-start]:../reference/session.html#start

[session-visit]:../reference/session.html#visit

[session-xml]:../reference/session.html#xml

[reference]:../reference/
