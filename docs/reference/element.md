---
title: web-driver.Element
---

# `web-driver.Element` class

## Summary

It's a class for handling web element.

It has methods of the following modules:

  * [`web-driver.Searchable`][searchable]: Provides element search related methods.

It means that you can use methods in the modules.

## Instance methods

### `find_element(strategy, finder) -> web-driver.Element` {#find-element}

This method is find web element by some retrieval methods.

`strategy`: Specify how to search the element. You can set the argument as below.

  * `css selector`: Serch the element by CSS selector.
  * `link text`: Serach the element by Link text selector.
  * `partical link text`: Search the element by Partical link text selector.
  * `tag name`: Search the element by Tag name.
  * `xpath`: Search the element by XPath selector.

`finder`: Specify search the keyword.

It returns the element as [`web-driver.Element`][element].

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)

  local body = session:css_select('body')
  local element = body[1]:find_element("css selector", '#p2')
  print(element:text()) --"Hello 2"
end)
```

### `find_elements(strategy, finder) -> web-driver.ElementSet` {#find-elements}

This method is find web elements by some retrieval methods.

`strategy`: Specify how to search elements. You can set the argument as below.

  * `css selector`: Serch the element by CSS selector.
  * `link text`: Serach the element by Link text selector.
  * `partical link text`: Search the element by Partical link text selector.
  * `tag name`: Search the element by Tag name.
  * `xpath`: Search the element by XPath selector.

`finder`: Specify search the keyword.

It returns elements as [`web-driver.ElementSet`][elementset].

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)

  local body = session:css_select('body')
  local elements = body[1]:find_elements("css selector", 'p')
  for _,v in pairs(elements:texts()) do
    print(v)
-- Hello 1
-- Hello 2
-- Hello 3
  end
end)
```

### `is_selected() -> boolean` {#is-selected}

It returns whether or not the self selected.

If the self is selected, return value of `true` as the boolean.

If the self isn't selected, return value of `false` as the boolean.

Example:

```lua
driver:start_session(function(session)
  session:navigate_to(URL)

  local form = session:css_select('form')
  form[1]:is_selected()
end)
```

### `get_attribute(name) -> boolean or number or string, table` {#get-attribute}

It returns attribute specify the argument.

Type of return value is different by value of attribute.

For example, If value of attribute is true, type of return value is boolean.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/get-attribute.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local elements = session:css_select('p')
  for _, element in ipairs(elements) do
    if element:get_attribute("data-value-type") == "number" then
      print(element:text())
    end
  end
end)
```

This method has syntax sugar as below.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/get-attribute.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local elements = session:css_select('p')
  for _, element in ipairs(elements) do
    if element["data-value-type"] == "number" then -- -> element["data-value-type"] is syntax sugar of Element:get_attribute()
      print(element:text())
    end
  end
end)
```

### `get_property(name) -> boolean or number or string, table` {#get-property}

It returns property specify the argument.

Type of return value is different by a value of a property.

For example, If the value of the property is true, type of return value is boolean.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  local element = session:find_element("css selector", 'input[name=wine]')
  luaunit.assert_equals(element:get_property("checked"), false)
  element:click()
  luaunit.assert_equals(element:get_property("checked"), true)
end)
```

This method has syntax sugar as below.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  local element = session:find_element("css selector", 'input[name=wine]')
  luaunit.assert_equals(element.checked, false)
  element:click()
  luaunit.assert_equals(element.checked, true)
end)
```

### `get_css_value(property_name) -> boolean or number or string, table` {#get-css-value}

It returns css value specify the argument.

Type of return value is different by a value of a css value.

For example, If the value of the css value is string, type of return value is string.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  local element = session:find_element("xpath", '//*[@id="p1"]')
  element:get_css_value("color") -- "rgb(255, 0, 0)"
end)
```

This method has syntax sugar as below.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  local element = session:find_element("xpath", '//*[@id="p1"]')
  element["color"] -- "rgb(255, 0, 0)"
end)
```

### `text() -> string` {#text}

It returns text element of the myself as a string.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  local element_set = session:css_select('#p2')
  local text = element_set:text()
  print(text) -- "Hello 2"
end)
```

### `tag_name() -> string` {#tag-name}

It returns tag name of the myself as a string.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  local element = session:find_element("css selector", '#p2')
  element:tag_name(element_id) -- "p"
end)
```

### `rect() -> string` {#rect}

It returns the dimensions and coordinates of the given web element.

The returned value is a table with the below members:

  * `x`: X axis position of the top-left corner of the web element.
  * `y`: Y axis position of the top-left corner of the web element.
  * `height`: Height of the web element.
  * `width`: Width of the web element.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/move.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local button = session:find_element("css selector", 'input[type=submit]')
  button:rect()
  for k,v in pairs(button:rect()) do
    print(k,v)
    -- y	68
    -- x	8
    -- height	30
    -- width	65
  end
end)
```

### `is_enabled() -> boolean` {#is-enable}

It returns whether or not the self enabled as a boolean.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  local element = session:find_element("css selector", 'input[name=cheese]')
  element:is_enabled() -- false
  element = session:find_element("css selector", "input[name=wine]")
  element:is_enabled() -- true
end)
```

### `click() -> void` {#click}

This method click web element.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/button.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local elements = session:css_select('#announcement')
  elements:click()

  elements = session:css_select('a[name=announcement]')
  local informations_summary = elements:texts()
  for _, summary in ipairs(informations_summary) do
    print(summary)
  end
end)
```

### `clear() -> void` {#clear}

This method clear a content editable element and a resettable element.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  local elements = session:css_select('input[name=name]')
  elements:send_keys("This is test")
  print(elements[1].value) -- "This is test"
  elements[1]:clear()
  print(elements[1].value) -- ""
end)
```

### `send_keys(keys) -> void` {#send-keys}

This method send specify keys to web element.

`keys`: Specify sendding keywords as a string.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  local elements = session:css_select('input[name=name]')
  elements:send_keys("This is test")
  print(elements[1].value) -- "This is test"
end)
```

### `save_screenshot(filename) -> void` {#save-screenshot}

This method saves in the specific file the screenshot of the web element as PNG format.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)

  local element = session:find_element("css selector", "#p1")
  element:save_screenshot("element.png")
end)
```

### `take_screenshot() -> string` {#take-screenshot}

It returns the screenshot of the web element as a string(this is a png format data).

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)

  png = session:find_element("css selector", "#p1")
end)
```

## See also

  * [`web-driver.Searchable`][searchable]: Provides element search related methods.

  * [`web-driver.ElementSet`][elementset]: The class for multiple elements.


[searchable]:searchable.html

[elementset]:elementset.html

[element]:element.html
