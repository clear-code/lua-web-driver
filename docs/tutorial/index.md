---
title: Tutorial
---

# Tutorial

This document describes how to use LuaWebDriver step by step. If you don't install LuaWebDriver yet, [install][install] LuaWebDriver before you read this document.

## Start and stop web browser {#start-stop-web-browser}

You need to start WebDriver at first to start web browser.

You can use [`WebDriver.create`][webdriver-create] and [`FirefoxDriver.start`][firefoxdriver-start] to start web browser as below example.
Web browser starts in headless mode with default.

Also you need to stop web browser when you finish your processing.

You can use [`FirefoxDriver.stop`][firefoxdriver-stop] to stop web browser.

Example:

```lua
local WebDriver = require("web-driver")
local driver = WebDriver.create("firefox")

driver:start()
driver:stop()
```

## Visit to a website {#visit-to-website}

You can use [`Session.visit`][session-visit] to visit a specific website with the web browser.

First of all, you make a callback function for visit to a website.
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

## Serialize to website {#serialize-to-website}

You can use [`Session.xml`][session-xml] to serialize a website as XML.

First of all, you visit to a website to serialize as below example.

Second, you call [`Session.xml`][session-xml].

Then you can serialize a current website as XML.
You can use this XML as Lua's string.

Example:

```lua
```

## Take a screenshot {#take-screenshot}

You can use [`Session.screenshot`][session-screenshot] to take a screenshot of current website.
The screenshot is taken in PNG format.

First of all, you visit to a website to serialize as below example.

Second, you call [`Session.screenshot`][session-screenshot].
[`Session.screenshot`][session-screenshot] has one argument.
You specify the file name as the argument of [`Session.screenshot`][session-screenshot].

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

[session-screenshot]:../reference/session.html#screenshot

[reference]:../reference/
