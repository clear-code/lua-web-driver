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

## Next step {#next-step}

Now, you knew all major LuaWebDriver features! If you want to understand each feature, see [reference manual][reference] for each feature.


[install]:../install/

[webdriver-create]:../reference/webdriver.html#create

[firefoxdriver-start]:../reference/firefoxdriver.html#start

[firefoxdriver-stop]:../reference/firefoxdriver.html#stop

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

[reference]:../reference/
