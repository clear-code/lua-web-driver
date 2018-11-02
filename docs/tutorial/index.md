---
title: Tutorial
---

# Tutorial

This document describes how to use LuaWebDriver step by step. If you don't install LuaWebDriver yet, [install][install] LuaWebDriver before you read this document.

## Visit to a website {#visit-to-website}

You can use [`Session:navigate_to`][session-navigate-to] to visit a specific website with the web browser.

First of all, you make a callback function for visit to a website.
You specify the URL as the argument of [`Session:navigate_to`][session-navigate-to]

Second, you specify your callback as the argument of [`Firefox:start_session`][firefox-start-session] and call [`Firefox:start_session`][firefox-start-session].
the session is destroyed auto after calling your callback.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/"

-- Make your callback and start session
driver:start_session(function(session)
  session:navigate_to(URL)
end)
```

## Serialize to website {#serialize-to-website}

You can use [`Session:xml`][session-xml] to serialize a website as XML.

First of all, you visit to a website to serialize as below example.

Second, you call [`Session:xml`][session-xml].

Then you can serialize a current website as XML.
You can use this XML as Lua's string.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

-- Make your callback and start session
driver:start_session(function(session)
  session:navigate_to(URL)
-- Serialize a current website as XML.
  local xml = session:xml()
  print(xml)
end)
```

## Save a screenshot {#save-screenshot}

You can use [`Session:save_screenshot`][session-save-screenshot] to save a screenshot of current website.
The screenshot is saved in PNG format.

First of all, you visit to a website to save a screenshot as below example.

second, you call [`Session:save_screenshot`][session-save-screenshot].

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
-- Save screenshot in PNG format
  session:save_screenshot("sample.png")
end)
```

## Move on website {#move-on-website}

You can move on a website with below features.

* Button operation
* Checkbox operation
* Click link

In this example take turns at login and link click, get a text.

First of all, you visit a target website.

Second, you input user name and password, because of this the web site needs authentication.
you can input user name and password with [`Session:css_select`][session-css-select] and [`ElementSet:send_keys`][elementset-send-keys]."

you get element object for inputting user name and password with [`Session:css_select`][session-css-select].
In this example get element object with the CSS selector, however, you can also get it using the XPath with [`Session:xpath_search`][session-xpath-search].

you call [`ElementSet:send_keys`][elementset-send-keys] of acquired elementset object.
You specify input string as the argument of [`ElementSet:send_keys`][elementset-send-keys].

Third, you push login button with [`Session:css_select`][session-css-select] and [`ElementSet:click`][elementset-click].

Fourth, you click link on website in after login with [`Session:link_search`][session-link-search] and [`ElementSet:click`][elementset-click].

Fifth, you get text of specific element in after moved web site with [`ElementSet:text`][elementset-text].
You get element object for getting text with [`Session:css_select`][session-css-select].
you call [`ElementSet:text`][elementset-text] of acquired elementset object.
You can use acquired value of the text as Lua's string.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/move.html"

-- Make your callback and start session
driver:start_session(function(session)
  session:navigate_to(URL)

-- Get forms in a website
  local form = session:css_select('form')
-- Get form for inputting username
  local text_form = form:css_select('input[name=username]')
-- Input username to form
  text_form:send_keys("username")
-- Get form for inputting password
  local password_form = form:css_select('input[name=password]')
-- Input password to form
  password_form:send_keys("password")

-- Get button for submitting username and password
  local button = form:css_select("input[type=submit]")
-- Submit username and password
  button:click()

-- Get element object for link operating
  local link = session:link_search ("1")
-- Click the link
  link:click()
  local elements = session:css_select("p")
-- Get text of acquired element
  print(elements:text())
end)
```

## Button operation on a specific form {#button-operation-on-specific-form}

You can use [`Session:css_select`][session-css-select] and [`ElementSet:click`][elementset-click] to button operation on a specific form.

First of all, you visit a website to button operation as below example.

Second, you get element object for button operating with [`Session:css_select`][session-css-select]."
In this example get element object with the CSS selector, however, you can also get it using the XPath.

Third, you call [`ElementSet:click`][elementset-click] of acquired element object.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/button.html"

-- Make your callback and start session
driver:start_session(function(session)
  session:navigate_to(URL)
-- Get elementset object for button operating
  local elements = session:css_select('#announcement')
-- Click the acquired button object
  elements:click()

--Get text of specific element in after moved web site
  elements = session:css_select('a[name=announcement]')
  local informations_summary = elements:texts()
  for _, summary in ipairs(informations_summary) do
    print(summary)
  end
end)
```

## Input string into specific a form {#input-string-into-form}

You can use [`ElementSet:send_keys`][elementset-send-keys] to input string into specific a form.

First of all, you visit a website to input string into a form.

Second, you get element object for inputting string with [`Session:css_select`][session-css-select]."
In this example get element object with the CSS selector, however, you can also get it using the XPath.

Third, you call [`ElementSet:send_keys`][elementset-send-keys] of acquired element object.
You specify input string as the argument of [`ElementSet:send_keys`][elementset-send-keys].

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/index.html"

-- Make your callback and start session
driver:start_session(function(session)
  session:navigate_to(URL)
-- Get elementset object for inputting string
  local elements = session:css_select('input[name=name]')
-- Input string to form
  elements:send_keys("This is test")
  print(elements[1].value)
end)
```

## Get attribute of element {#get-attribute-element}

You can use [`Element:get_attribute`][element-get-attribute] to get attribute of specific element.

First of all, you get element object for getting attribute with [`Session:css_select`][session-css-select].

Second, you call [`Element:get_attribute`][element-get-attribute] of acquired element object.
You specify attribute name as the argument of [`Element:get_attribute`][element-get-attribute].
You can use acquired value of the attribute as Lua's string.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/get-attribute.html"

-- Make your callback and start session
driver:start_session(function(session)
  session:navigate_to(URL)
-- Get elementset object for getting attribute
  local elements = session:css_select('p')
  for _, element in ipairs(elements) do
-- Get attribute of acquired element
    if element["data-value-type"] == "number" then
      print(element:text())
    end
  end
end)
```

## Get text of element {#get-text-element}

You can use [`ElementSet:text`][elementset-text] to get text of sepecific element.

First of all, you get element object for getting text with [`Session:css_select`][session-css-select].

Second, you call [`ElementSet:text`][elementset-text] of acquired element object.
You can use acquired value of the test as Lua's string.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/"

-- Make your callback and start session
driver:start_session(function(session)
  session:navigate_to(URL)
-- Get elementset object for getting text
  local element_set = session:css_select('#p2')
-- Get text of acquired element
  local text = element_set:text()
  print(text)
end)
```

## Customize of a user agent

You can customize a user agent of a web browser by option of [`web-driver.Firefox.new()`][firefox-new].
For example, this feature useful when crawling websites for a smartphone.

First of all, you set user agent to `options.preferences` as string.

Second, you set the `options` to argument of [`web-driver.Firefox.new()`][firefox-new] and call.

Here is an example customizing user agent to iPhone's user agent.

Example:

```lua
local web_driver = require("web-driver")

local user_agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 10_2 like Mac OS X)"..
                   " "..
                   "AppleWebKit/602.3.12 (KHTML, like Gecko)"..
                   " "..
                   "Version/10.0 Mobile/14C92 Safari/602.1"
local options = {
  preferences = {
    ["general.useragent.override"] = user_agent,
  }
}
local driver = web_driver.Firefox.new(options)

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  print(session:request_headers()["User-Agent"])
  -- Mozilla/5.0 (iPhone; CPU iPhone OS 10_2 like Mac OS X) AppleWebKit/602.3.12 (KHTML, like Gecko) Version/10.0 Mobile/14C92 Safari/602.1
end)
```

If you use LuaWebDriver with multi-thread, you can customize a user agent by setting `options.preferences` to argument of [`web-driver.ThreadPool.new()`][thread-pool-new] as below example.

```lua
local web_driver = require("web-driver")
local log = require("log")

local url =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"
local log_level = "info"
local n_threads = 2

local logger = log.new(log_level)
local function crawler(context)
  local logger = context.logger
  local session = context.session
  local url = context.job
  local prefix = url:match("^https?://[^/]+/")
  logger:debug("Opening...: " .. url)
  session:navigate_to(url)
  local status_code = session:status_code()
  if status_code and status_code ~= 200 then
    logger:notice(string.format("%s: Error: %d",
                                url,
                                status_code))
    return
  end
  logger:notice(string.format("%s: Title: %s",
                              url,
                              session:title()))
  local anchors = session:css_select("a")
  local anchor
  for _, anchor in pairs(anchors) do
    local href = anchor.href
    local normalized_href = href:gsub("#.*$", "")
    logger:notice(string.format("%s: Link: %s (%s): %s",
                                url,
                                href,
                                normalized_href,
                                anchor:text()))
    if normalized_href:sub(1, #prefix) == prefix then
      context.job_pusher:push(normalized_href)
    end
  end
end

local user_agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 10_2 like Mac OS X)"..
                   " "..
                   "AppleWebKit/602.3.12 (KHTML, like Gecko)"..
                   " "..
                   "Version/10.0 Mobile/14C92 Safari/602.1"
local options = {
  logger = logger,
  size = n_threads,
  firefox_options = {
    preferences = {
      ["general.useragent.override"] = user_agent,
    },
  }
}
local pool = web_driver.ThreadPool.new(crawler, options)
logger.debug("Start crawling: " .. url)
pool:push(url)
pool:join()
logger.debug("Done crawling: " .. url)
```

## Logger {#logger}

LuaWebDriver has used [`lua-log`][lua-log] to the logger.

You can use the same logger object as the caller by making the logger object at the caller and passing the logger object to as an argument [`web-driver.Firefox.new()`][firefox-new].

You can use log level below.
* emergency
* alert
* fatal
* error
* warning
* notice
* info
* debug
* trace

The above log level specifies as a string.

Example:

```lua
local web_driver = require("web-driver")
local log = require("log")


local logger = log.new("trace")
local options = { logger = logger }
local driver = web_driver.Firefox.new(options)

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
end)
```

If you use LuaWebDriver with multi-thread, pass the logger object to as an argument of a [`web-driver.ThreadPool.new()`][thread-pool-new].

Example:

```lua
local web_driver = require("web-driver")
local log = require("log")

local url =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"
local log_level = "trace"
local n_threads = 2

local logger = log.new(log_level)
local function crawler(context)
  local logger = context.logger
  local session = context.session
  local url = context.job
  local prefix = url:match("^https?://[^/]+/")
  logger:debug("Opening...: " .. url)
  session:navigate_to(url)
  local status_code = session:status_code()
  if status_code and status_code ~= 200 then
    logger:notice(string.format("%s: Error: %d",
                                url,
                                status_code))
    return
  end
  logger:notice(string.format("%s: Title: %s",
                              url,
                              session:title()))
  local anchors = session:css_select("a")
  local anchor
  for _, anchor in pairs(anchors) do
    local href = anchor.href
    local normalized_href = href:gsub("#.*$", "")
    logger:notice(string.format("%s: Link: %s (%s): %s",
                                url,
                                href,
                                normalized_href,
                                anchor:text()))
    if normalized_href:sub(1, #prefix) == prefix then
      context.job_pusher:push(normalized_href)
    end
  end
end
local options = {
  logger = logger,
  size = n_threads,
}
local pool = web_driver.ThreadPool.new(crawler, options)
logger.debug("Start crawling: " .. url)
pool:push(url)
pool:join()
logger.debug("Done crawling: " .. url)
```

You can also set log level with environment value as below.

Example:

```
export LUA_WEB_DRIVER_LOG_LEVEL="trace"
```

If you are not set logger object and environment value, LuaWebDriver output the Firefox's log and geckodriver's log with "info" level.

## Multithread {#multi-thread}

You can use LuaWebDriver with multiple threads. You need use [`web-driver.ThreadPool`][thread-pool] object for using LuaWebDriver with multiple threads as below.

Here is an example crawl on web pages with a URL given to argument of [`web-driver.ThreadPool:push()`][thread-pool-push] as the start point.

Example:

```lua
local web_driver = require("web-driver")
local log = require("log")


local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

local log_level = "notice"

local logger = log.new(log_level)
local function crawler(context)
  local web_driver = require("web-driver")
  local logger = context.logger
  local session = context.session
  local url = context.job
  local prefix = url:match("^https?://[^/]+/")
  logger:debug("Opening...: " .. url)
  session:navigate_to(url)
  logger:notice(string.format("%s: Title: %s",
                              url,
                              session:title()))
  local anchors = session:css_select("a")
  local anchor
  for _, anchor in pairs(anchors) do
    local href = anchor.href
    local normalized_href = href:gsub("#.*$", "")
    logger:notice(string.format("%s: Link: %s (%s): %s",
                                url,
                                href,
                                normalized_href,
                                anchor:text()))
    if normalized_href:sub(1, #prefix) == prefix then
      context.job_pusher:push(normalized_href)
    end
  end
end
local pool = web_driver.ThreadPool.new(crawler, {logger = logger})
logger.debug("Start crawling: " .. URL)
pool:push(URL)
pool:join()
logger.debug("Done crawling: " .. URL)
```

You can write the processing you want to execute in the function given to argument of [`web-driver.ThreadPool.new()`][thread-pool-new].

By executing [`web-driver.JobPusher:push()`][job-pusher-push] ([`web-driver.JobPusher:push()`][job-pusher-push] is `context.job_pusher:push()` in the above example) in a function given to argument of [`web-driver.ThreadPool.new()`][thread-pool-new], the idle thread executes job one by one.

Number of argument of a function given to argument of [`web-driver.ThreadPool.new()`][thread-pool-new] is one. (The function given to argument of [`web-driver.ThreadPool.new()`][thread-pool-new] is `crawler` in the above example.)
This argument has all informations for crawl on web pages. (The argument is `context` in the above example.)


If you register the same job, LuaWebDriver ignores the same job by default.

A job only recives the string. We suggest give URL to the job.


A failed job retry automatically. A Number of retries are three by default.
If a job failed beyond the number of retries, LuaWebDriver deletes it.

You can also specify the number of retries as an argument of [`web-driver.ThreadPool.new()`][thread-pool-new] as below.

Example:

```lua
local pool = web_driver.ThreadPool.new(crawler, {max_n_failures = 5})
```

Some notes as below for use LuaWebDriver with multiple threads

* When starting a thread, LuaWebDriver currently sometimes crash.
  * This problem might resolve by specifying `libpthread.so` to `LD_PRELOAD`.

* LuaWebDriver has not common information between each thread.
  * If you want to use common information in each thread, you use environment value or read a file saved common information.
  * For example, known information (like login information etc) is saved a file and it becomes easy to access by reading that file in the thread.

* We have supposed execute one web page every one call basically. But if you processing a web page requiring a login, you should also do the after login processing on the same thread.
  * Because it keeps login status by reusing session in the thread.

* A function given to argument of [`web-driver.ThreadPool.new()`][thread-pool-new] must not reference information of external of one.

* You should not make too many threads. Because eache thread becomes slow due to start the Firefox every each thread.
  * Guide to the number of a thread is one-third of the number of physical CPU core.

* LuaWebDriver can't resume a job.
  * If you quit `luajit` process in the middle, the job executes from the beginning. A check of a duplicate job is reset also.

* You need not implement end processing for each thread especially. Because if end processing for each thread execute in [`web-driver.ThreadPool:join()`][thread-pool-join].

## Next step {#next-step}

Now, you knew all major LuaWebDriver features! If you want to understand each feature, see [reference manual][reference] for each feature.


[lua-log]:https://github.com/moteus/lua-log

[install]:../install/

[webdriver-create]:../reference/webdriver.html#create

[firefoxdriver-start]:../reference/firefoxdriver.html#start

[firefoxdriver-stop]:../reference/firefoxdriver.html#stop

[firefox-new]:../reference/firefox.html#new

[firefox-start-session]:../reference/firefox.html#start_session

[session-navigate-to]:../reference/session.html#navigate_to

[session-xml]:../reference/session.html#xml

[session-save-screenshot]:../reference/session.html#save_screenshot

[session-back]:../reference/session.html#back

[session-forward]:../reference/session.html#forward

[session-accept-alert]:../reference/session.html#accept_alert

[session-dismiss-alert]:../reference/session.html#dismiss_alert

[session-css-select]:../reference/session.html#css_select

[session-xpath-search]:../reference/session.html#xpath_search

[session-link-search]:../reference/session.html#link_search

[elementset-send-keys]:../reference/elementset.html#send_keys

[elementset-click]:../reference/elementset.html#click

[elementset-text]:../reference/elementset.html#text

[element-get-attribute]:../reference/element.html#get_attribute

[element-text]:../reference/element.html#text

[thread-pool]:../reference/thread-pool.html

[thread-pool-new]:../reference/thread-pool.html#new

[thread-pool-push]:../reference/thread-pool.html#push

[thread-pool-join]:../reference/thread-pool.html#join

[job-pusher-push]:../reference/job-pusher.html#push

[reference]:../reference/
