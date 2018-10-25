---
title: web-driver.ElementSet
---

# `web-driver.ElementSet` class

## Summary

It's a class for handling web elements.

It has methods of the following modules:

  * [`web-driver.Searchable`][searchable]: Provides element search related methods.

It means that you can use methods in the modules.

## Instance methods

### `find_elements(strategy, finder) -> web-driver.ElementSet` {#find-elements}

This method is find web elements by some retrieval methods.

`strategy`: Specify how to search the element. You can set the argument as below.

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
  local elements = body:find_elements("css selector", 'p')
  for _,v in pairs(elements:texts()) do
    print(v)
-- Hello 1
-- Hello 2
-- Hello 3
  end
end)
```

### `text() -> string` {#text}

This method returns text that concatenated text of each element as one string.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)

  local body = session:css_select('body')
  local elements = body:find_elements("css selector", 'p')
  print(elements:text())
-- Hello 1Hello 2Hello 3
end)
```

### `texts() -> {elements[1].text(), elements[2].text(), ...}` {#texts}

It returns text of the myself as a table.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)

  local body = session:css_select('body')
  local elements = body:find_elements("css selector", 'p')
  for _,v in pairs(elements:texts()) do
    print(v)
-- Hello 1
-- Hello 2
-- Hello 3
  end
end)
```

### `get_attribute(name) -> {elements[1]["name"], elements[2]["name"], ...}` {#get_attribute}

`name`: Specify the attribute name.

It returns the value of the specified attribute in each element.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)

  local body = session:css_select('body')
  local elements = body:find_elements("css selector", 'p')
  for _,v in pairs(elements:get_attribute("id")) do
    print(v)
-- p1
-- p2
-- p3
  end
end)
```

### `insert(element_or_position, element) -> void` {#insert}

This method inserts specify [`web-driver.Element`][element] into [`web-driver.ElementSet`][elementset].

If the second argument is nil, the first argument is the element to be inserted.

If the second argument is not nil, the first argument is the insert position and the second argument is the element to be inserted.

If you don't specify the insert position, element is added on to the end.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)

  local p = session:css_select('p')
  local checkbox = session:find_element("css selector", 'input[name=cheese]')
  p:insert(1, checkbox)
  print(p[1].name) -- cheese
end)
```

### `remove(element_or_position) -> web-driver.ElementSet` {#remove}

This method remove specify [`web-driver.Element`][element] from [`web-driver.ElementSet`][elementset].

If type of the argument is number, it is remove position.

If type of the argument is not number, it is the element to be removed.

It returns the removed element as [`web-driver.Element`][element].
If the element to remove is not found in [`web-driver.ElementSet`][elementset], it returns is nil.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)

  local elements = session:css_select('p')
  for _,v in pairs(elements:texts()) do
    print(v)
-- Hello 1
-- Hello 2
-- Hello 3
  end
  elements:remove(2)
  for _,v in pairs(elements:texts()) do
    print(v)
-- Hello 1
-- Hello 3
  end
end)
```

### `merge(element_set) -> web-driver.ElementSet` {#merge}

This method merge specify [`web-driver.ElementSet`][elementset].

It returns [`web_driver.ElementSet`][elementset] after merging the specified [`web-driver.ElementSet`][elementset].

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)

  local p = session:css_select('p')
  for _,v in pairs(p:texts()) do
    print(v)
-- Hello 1
-- Hello 2
-- Hello 3
  end

  local label = session:css_select('label')
  for _,v in pairs(label:texts()) do
    print(v)
-- Cheese
-- Wine
  end

  merged_element = p:merge(label)
  for _,v in pairs(merged_element:texts()) do
    print(v)
-- Hello 1
-- Hello 2
-- Hello 3
-- Cheese
-- Wine
  end
end)
```

### `click() -> void` {#click}

This method click web elements.

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

### `send_keys(keys) -> void` {#send-keys}

This method send specify keys to web elements.

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

## See also

  * [`web-driver.Searchable`][searchable]: Provides element search related methods.

  * [`web-driver.Element`][element]: The class for handling web elements.


[searchable]:searchable.html

[elementset]:elementset.html

[elementset-texts]:elementset.html#texts

[element]:element.html

