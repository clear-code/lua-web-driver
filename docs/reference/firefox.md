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
* `options.get_request_timeout`: Specify timeout of HTTP GET request. Default is `60` second.
* `options.post_request_timeout`: Specify timeout of HTTP POST request. Default is `60` second.
* `options.delete_request_timeout`: Specify timeout of HTTP DELETE request. Default is `60` second.
* `options.http_request_timeout`: Specify timeout of HTTP GET and HTTP POST, HTTP DELETE request. Default is `60` second.
* `options.headless`: Specify whether start the Firefox with the headless mode or not.
  * If this option is `false`, start the Firefox with GUI.
  * If this option isn't set or `true`, start the Firefox with the headless mode.
* `options.arguments`: Specify options of the Firefox with a table.
* `options.args`: It's an alias of `options.arguments`. This option is deprecate. We suggest that you use `options.arguments` instead.
* `options.preferences`: Specify preferences of the Firefox.
  * The setting value of this option is same that can set value by `about:config` page of the Firefox.

Example:

```lua
local web_driver = require("web-driver")

local options = {}
options.host = "192.168.0.1"
options.port = "1111"
local driver = web_driver.Firefox.new(options)
```

Possible options to set in `options.arguments` and `options.args` as see a below.

[Command Line Options](https://developer.mozilla.org/en-US/docs/Mozilla/Command_Line_Options)

### `web-driver.Firefox.start_session(callback) -> return value of callback` {#session-start}

`callback`: Specify your callback function.

It starts a session with the Firefox and calls the given callback function.
It returns the return value of the given callback function.

If you don't set the argument, this method returns a [`web-driver.Session`][session] object.

You can write the processing that you want to execute with the Firefox in the callback function as below.

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

If you set the callback to the argument, the session is deleted automatically after calling the callback function.
If you don't set the argument, you must delete session manually with [`web-driver.Session:delete()`][session-delete].


[firefox]: firefox.html

[session]: session.html

[session-delete]: session.html#delete
