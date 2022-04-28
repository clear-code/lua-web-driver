---
title: web-driver.Searchable
---

# `web-driver.Searchable` モジュール

## 概要

いくつかの検索方法を使って、要素を検索する機能を提供します。

以下のように要素を検索する方法を指定できます。

  * `css selector`: CSSセレクターを使って要素を検索します。
  * `link text`: Link text selectorを使って要素を検索します。
  * `partical link text`: Partical link text selectorを使って要素を検索します。
  * `tag name`: Tag名を使って要素を検索します。
  * `xpath`: XPath使って要素を検索します。

## メソッド

### `search(xpath) -> web-driver.ElementSet` {#search}

[`xpath_search`][xpath-search]のエイリアスです。このメソッドは、[`XMLua.Searchable:search()`][xmlua-searchable-search]との互換のためにあります。

### `css_select(selectors) -> web-driver.ElementSet` {#css-selector-search}

CSSセレクターを使って要素を検索し、[`web-driver.ElementSet`][elementset]オブジェクトとして返します。

例:

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

XPathを使って要素を検索し[`web-driver.ElementSet`][elementset]オブジェクトとして返します。

例:

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

Link text selectorを使って要素を検索し、[`web-driver.ElementSet`][elementset]オブジェクトとして返します。

例:

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

Partial link text selectorを使って要素を検索し、[`web-driver.ElementSet`][elementset]オブジェクトとして返します。

例:

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

タグ名を使って要素を検索し、[`web-driver.ElementSet`][elementset]オブジェクトとして返します。

例:

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

## 参照

  * [`web-driver.ElementSet`][elementset]: 複数の要素を扱うクラスです。


[xmlua-searchable-search]:https://clear-code.github.io/xmlua/ja/reference/searchable.html#search

[xpath]:https://www.w3.org/TR/xpath/

[search]:#search

[xpath-search]:#xpath-search

[css-selectors]:https://www.w3.org/TR/selectors-3/

[elementset]:elementset.html
