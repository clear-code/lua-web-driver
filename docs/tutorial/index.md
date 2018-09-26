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

## Move to website {#move-to-website}

You can use [`Session.back`][session-back] and [`Session.forward`][session-forward] to move a website.

If you want to back to the previous website, you call [`Session.back`][session-back].
If you want to go to next the website, you call [`Session.forward`][session-forward].

Example:

```lua
```

## Button operation on website {#button-operation-on-website}

You can use [`Session.accept_alert`][session-accept-alert] and [`Session.dismiss_alert`][session-dismiss-alert] to button operation on website.

First of all, you visit a website to button operation as below example.

Second, If you want to push a "OK" button, you call [`Session.accept_alert`][session-accept-alert].

If you want to push a "Cancel" button, you call [`Session.dismiss_alert`][session-dismiss-alert].

Example:

```lua

```

Also, if you want to operation button on the specific dialog, you can use [`Session.find_element`][session-find-element] to specify dialog as below example.
[`Session.find_element`][session-find-element] is get specify element with css selector as below.

Example:

```lua

```

## Input string into specific a form {#input-string-into-form}

You can use [`Element.send_keys`][element-send-keys] to input string into specific a form.

First of all, you visit a website to input string into a form.

Second, you get element object for inputting string with [`Session.find_element`][session-find-element]."
In this example get element object with the CSS selector, however, you can also get it using the XPath.

Third, you call [`Element.send_keys`][element-send-keys] of acquired element object.
You specify input string as the argument of [`Element.send_keys`][element-send-keys].

Example:

```lua
```

## Get attribute of element {#get-attribute-element}

You can use [`Element.get_attribute`][element-get-attribute] to get attribute of specific element.

First of all, you get element object for getting attribute with [`Session.find_element`][session-find-element].

Second, you call [`Element.get_attribute`][element-get-attribute] of acquired element object.
You specify attribute name as the argument of [`Element.get_attribute`][element-get-attribute].
You can use acquired value of the attribute as Lua's string.

Example:

```lua
```

## Get text of element {#get-text-element}

You can use [`Element.get_text`][element-get-text] to get text of sepecific element.

First of all, you get element object for getting text with [`Session.find_element`][session-find-element].

Second, you call [`Element.get_text`][element-get-text] of acquired element object.
You can use acquired value of the test as Lua's string.

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

[session-back]:../reference/session.html#back

[session-forward]:../reference/session.html#forward

[session-accept-alert]:../reference/session.html#accept_alert

[session-dismiss-alert]:../reference/session.html#dismiss_alert

[session-find-element]:../reference/session.html#find_element

[element-send-keys]:../reference/element.html#send_keys

[element-get-attribute]:../reference/element.html#get_attribute

[element-get-text]:../reference/element.html#text

[reference]:../reference/
