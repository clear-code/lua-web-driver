---
title: web-driver.Searchable
---

# `web-driver.Searchable` module

## Summary

It provides features that search element by some retrieval methods.

You can specify how to search the element as below.

  * `css selector`: Serch the element by CSS selector.
  * `link text`: Serach the element by Link text selector.
  * `partical link text`: Search the element by Partical link text selector.
  * `tag name`: Search the element by Tag name.
  * `xpath`: Search the element by XPath selector.

## Methods

### `search(xpath) -> web-driver.ElementSet` {#search}

It's an alias of [`xpath_search`][xpath-search].
This method exist fot compatibility with [`XMLua.Searchable:search()`][xmlua-searchable-search]

### `css_select(selectors) -> web-driver.ElementSet` {#css-selector-search}

It searches elements by css selector and returns as [`web-driver.ElementSet`][elementset] object.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)

  local elements = session:css_select('p')
  for _,v in pairs(elements:texts()) do
    print(v)
-- Hello 1
-- Hello 2
-- Hello 3
  end
end)
```

### `xpath_search(xpath) -> web-driver.ElementSet` {#xpath-search}

It searches elements by XPath and returns as [`web-driver.ElementSet`][elementset] object.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)

  local elements = session:search('/html/body/p')
  print(elements[1]:text())
  -- 1
end)
```

### `link_serach(text) -> web-driver.ElementSet` {#link-search}

It searches elements by link search and returns as [`web-driver.ElementSet`][elementset] object.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/link.html"

driver:start_session(function(session)
  session:navigate_to(URL)

  local links = session:link_search("1")
  links[1]:click()
  local elements = session:css_select("p")
  print(elements:text())
  -- 1
end)
```

### `partial_link_serach(substring) -> web-driver.ElementSet` {#partial-link-search}

It searches elements by partial link search and returns as [`web-driver.ElementSet`][elementset] object.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/announcement.html"

driver:start_session(function(session)
  session:navigate_to(URL)

  local links = session:partial_link_search("anno")
  links[1]:click()
  local elements = session:css_select("p")
  print(elements:text())
  -- 1
end)
```

### `tag_name(name) -> web-driver.ElementSet` {#tag-name-search}

It searches elements by tag name and returns as [`web-driver.ElementSet`][elementset] object.

Example:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://lua-web-driver.gitlab.io/lua-web-driver/sample/1.html"

driver:start_session(function(session)
  session:navigate_to(URL)

  local p = session:tag_name("p")
  print(p[1]:text())
  -- 1
end)
```

## See also

  * [`web-driver.ElementSet`][elementset]: The class for multiple elements.


[xmlua-searchable-search]:https://clear-code.github.io/xmlua/ja/reference/searchable.html#search

[xpath]:https://www.w3.org/TR/xpath/

[search]:#search

[xpath-search]:#xpath-search

[css-selectors]:https://www.w3.org/TR/selectors-3/

[elementset]:elementset.html
