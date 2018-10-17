---
title: web-driver.Firefox
---

# `web-driver.Firefox` class

## Summary

It's a class for the WebDriver for Firefox.

You can start a session with the Firefox via geckodriver.

## Class methods

### `web-driver.Firefox.new(options) -> web-driver.Firefox` {#new}

`options`: Startup option of the Firefox.

It create new [`web-driver.Firefox`][firefox] object.

You can specify startup options as below.

* `options.host`: Specify hostname to connect. The default value is `"127.0.0.1"`.
* `options.port`: Specify port number to connect. The default value is `"4444"`.
* `options.args`: Specify options of the Firefox with a table. The default value is `{ "-headless" }`.

Example:

```lua
local web_driver = require("web-driver")

local options = {}
options.host = "192.168.0.1"
options.port = "1111"
local driver = web_driver.Firefox.new(options)
```

Possible options to set in `options.args` as see a below.

[Command Line Options](https://developer.mozilla.org/en-US/docs/Mozilla/Command_Line_Options)

### `web-driver.Firefox.session_start(callback) -> return value of callback` {#session-start}

`callback`: Your callback function.

It starts a session with the Firefox and calls the given callback function.
It returns the return value of the given callback function.

You can write the processing that you want to execute with the Firefox in the callback function.

Here is an example to start a session and navigate to a website:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

-- Start session with the Firefox
driver:start_session(function(session)
--Navigate to a website
  session:navigate_to(URL)
end)
```


[firefox]:firefox.html
