---
title: web-driver.Element
---

# `web-driver.Element` クラス

## 概要

Web要素を制御するクラスです。

以下のモジュールのメソッドを持ちます：

  * [`web-driver.Searchable`][searchable]: 要素検索関連のメソッドを提供します。

上述のモジュールのメソッドを使えます。

## インスタンスメソッド

### `find_element(strategy, finder) -> web-driver.Element` {#find-element}

いくつかの検索方法を使って要素を見つけます。

`strategy`: 要素を検索する方法を指定します。引数を以下のように設定できます。

  * `css selector`: CSSセレクターを使って要素を検索します。
  * `link text`: Link text selectorを使って要素を検索します。
  * `partical link text`: Partical link text selectorを使って要素を検索します。
  * `tag name`: Tag名を使って要素を検索します。
  * `xpath`: XPath使って要素を検索します。

`finder`: 検索キーワードを指定します。

要素を[`web-driver.Element`][element]として返却します。

例:

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

複数の要素をいくつかの検索方法で見つけます。

`strategy`: 要素を検索する方法を指定します。引数を以下のように設定できます。

  * `css selector`: CSSセレクターを使って要素を検索します。
  * `link text`: Link text selectorを使って要素を検索します。
  * `partical link text`: Partical link text selectorを使って要素を検索します。
  * `tag name`: Tag名を使って要素を検索します。
  * `xpath`: XPath使って要素を検索します。

`finder`: 検索キーワードを指定します。

要素を[`web-driver.ElementSet`][elementset]として返します。

例:

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

自分自身が選択されているかどうかを返します。

選択されている場合は、booleanとして、`true`を返します。

選択されていない場合は、booleanとして、`false`を返します。

例:

```lua
driver:start_session(function(session)
  session:navigate_to(URL)

  local form = session:css_select('form')
  form[1]:is_selected()
end)
```

### `get_attribute(name) -> boolean or number or string, table` {#get-attribute}

引数で指定した属性を返します。

戻り値の型は属性値によって異なります。

例えば、属性値がtrueだった場合、戻り値の型はbooleanになります。

例:

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

このメソッドは以下のようなシンタックスシュガーがあります。

例:

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

引数で指定したプロパティを返します。

戻り値の方は、プロパティ値によって異なります。

例えば、プロパティの値がtrueだった場合、戻り地の型はbooleanになります。

例:

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

このメソッドは以下のようなシンタックスシュガーがあります。

例:

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

引数に指定したCSSの値を返します。

戻り値の型は、CSSの値によって異なります。

例えば、CSSの値が文字列だった場合、戻り値の型はstringになります。

例:

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

このメソッドは以下のようなシンタックスシュガーがあります。

例:

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

自分自身のテキスト要素を文字列として返します。

例:

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

自分自身のタグ名を文字列として返します。

例:

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

指定された要素の寸法と座標を返します。

返される値は、以下のメンバーを持つテーブルです：

  * `x`: 要素の左上隅のX軸の位置。
  * `y`: 要素の左上隅のY軸の位置。
  * `height`: 要素の高さ。
  * `width`: 要素の幅。

例:

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

自分自身が有効かどうかを返します。

例:

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

要素をクリックします。

例:

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

編集可能な要素やリセット可能な要素の内容を消します。

例:

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

指定されたキーを要素へ送信します。

`keys`: 送信キーワードを文字列として指定します。

例:

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

要素のスクリーンショットをPNG形式で指定したファイルに保存します。

例:

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

要素のスクリーンショットを文字列(PNG形式のデータ)として返します。

例:

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

## 参照

  * [`web-driver.Searchable`][searchable]: 要素検索関連のメソッドを提供します。

  * [`web-driver.ElementSet`][elementset]: 複数の要素を扱うクラスです。


[searchable]:searchable.html

[elementset]:elementset.html

[element]:element.html
