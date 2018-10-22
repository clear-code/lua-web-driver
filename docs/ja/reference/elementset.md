---
title: web-driver.ElementSet
---

# `web-driver.ElementSet` クラス

## 概要

複数の要素を制御するためのクラスです。

以下のモジュールのメソッドを持ちます：

  * [`web-driver.Searchable`][searchable]: 要素検索関連のメソッドを提供します。

上述のモジュールのメソッドを使えます。

## インスタンスメソッド

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

[`web-driver.ElementSet:texts()`][elementset-texts]のエイリアスです。

戻り値の型が文字列であることが唯一の違いです。

### `texts() -> {element[1].text(), element[2].text(), ...}` {#texts}

自分自身のテキスト要素をテーブルとして返します。

例:

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

### `get_attribute(name) -> table` {#get_attribute}

`name`: 属性名を指定します。

それぞれの要素の指定した属性の値を返します。

例:

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

このメソッドは、指定した[`web-driver.Element`][element]を[`web-driver.ElementSet`][elementset]へ挿入します。

2番目の引数がnilの場合は、最初の引数が挿入される要素になります。

2番目の引数がnilでない場合hあ、最初の引数が挿入位置、2番目の引数が挿入される要素になります。

例:

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

このメソッドは、[`web-driver.ElemetSet`][elementset]から、指定した[`web-driver.Element`][element]を削除します。

引数の型が数値の場合は、引数は削除位置になります。

引数の型が数値でない場合は、引数は削除される要素になります。

削除した要素を[`web-driver.ElementSet`][elementset]として返します。

例:

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

このメソッドは、指定した[`web-driver.ElementSet`][elementset]をマージします。

指定した[`web-driver.ElemetSet`][elementset]をマージした後の[`web-driver.ElementSet`][elementset]を返します。

例:

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

### `send_keys(keys) -> void` {#send-keys}

要素に指定したキーを送信します。

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

## 参照

  * [`web-driver.Searchable`][searchable]: 要素検索関連のメソッドを提供します。

  * [`web-driver.Element`][element]: 要素を取り扱うためのクラスです。


[searchable]:searchable.html

[elementset]:elementset.html

[elementset-texts]:elementset.html#texts

[element]:element.html

