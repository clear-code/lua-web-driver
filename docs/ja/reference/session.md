---
title: web-driver.Session
---

# `web-driver.Session` クラス

## 概要

WebDriverのセッションを制御するクラスです。

以下のモジュールのメソッドを持ちます：

  * [`web-driver.Element`][element]: 要素の制御をするクラスです。
  * [`web-driver.ElementSet`][elementset]: 複数の要素を制御するクラスです。
  * [`web-driver.Searchable`][searchable]: 要素の検索関連のメソッドを提供します。

上述のモジュールのメソッドを使えます。

## インスタンスメソッド

### `navigate_to(url) -> void` {#navigate-to}

このメソッドは指定したURLのWebサイトへ移動します。

`url`: 移動したいWebサイトのURLを指定します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
end)
```

### `url() -> string` {#url}

現在のWebサイトのURLを文字列として返します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  print(session:url())
  -- https://clear-code.gitlab.io/lua-web-driver/sample/
end)
```

### `forward() -> void` {#forward}

現在のWebサイトから履歴を1つ先へ辿ります。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL1 = "https://clear-code.gitlab.io/lua-web-driver/sample/"
local URL2 = "https://clear-code.gitlab.io/lua-web-driver/sample/button.html"

driver:start_session(function(session)
  session:navigate_to(URL1)
  session:navigate_to(URL2)
  print(session:url())
  --https://clear-code.gitlab.io/lua-web-driver/sample/button.html
  session:back()
  print(session:url())
  --https://clear-code.gitlab.io/lua-web-driver/sample/
  session:forward()
  print(session:url())
  --https://clear-code.gitlab.io/lua-web-driver/sample/button.html
end)
```

### `back() -> void` {#back}

現在のWebサイトから履歴を1つ後ろへ辿ります。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL1 = "https://clear-code.gitlab.io/lua-web-driver/sample/"
local URL2 = "https://clear-code.gitlab.io/lua-web-driver/sample/button.html"

driver:start_session(function(session)
  session:navigate_to(URL1)
  session:navigate_to(URL2)
  print(session:url())
  --https://clear-code.gitlab.io/lua-web-driver/sample/button.html
  session:back()
  print(session:url())
  --https://clear-code.gitlab.io/lua-web-driver/sample/
end)
```

### `refresh() -> void` {#refresh}

現在のWebサイトをリロードします。

このメソッドを実行した時に、保存していない値はクリアされ、リアルタイムの情報は更新されます。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  local elements = session:css_select('input[name=name]')
  elements:send_keys("This is test")
  print(elements[1].value)
  -- This is test
  session:refresh()
  local refreshed_elements = session:css_select('input[name=name]')
  print(refreshed_elements[1].value)
  -- ""
end)
```

### `title() -> string` {#title}

現在のWebサイトのタイトルを取得します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  print(session:title())
  -- This is test html
end)
```

### `window_handle() -> string` {#window-handle}

現在のウインドウのウインドウハンドルを取得します。

文字列としてウインドウハンドルを返します。

このウインドウハンドルは、複数のウインドウを切り替えたり、ウインドウを特定したりするのに使います。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/window.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local next_handle = session:window_handles()[2]
  print(session:window_handle())
  -- 2147483649
  session:switch_to_window(next_handle)
  print(session:window_handle())
  -- 2147483656
end)
```

### `close_window() -> {remaining_window_handle1, remaining_window_handle2, ...}` {#close-window}

現在のウインドウをクローズします。残っているウインドウのハンドルをテーブルとして返します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/window.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  remaining_handles = session:close_window()
  session:switch_to_window(remaining_handles[1])
end)
```

### `switch_to_window(handle) -> void` {#switch-to-window}

指定したハンドルのウインドへ切り替えます。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/window.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  remaining_handles = session:close_window()
  session:switch_to_window(remaining_handles[1])
end)
```

### `window_handles() -> {window_handle1, window_handle2, ...}` {#window-handles}

現在のセッションのウインドウハンドルを取得します。

テーブルとして、ウインドウハンドルを返します。

このウインドウハンドルは、複数のウインドウを切り替えたり、ウインドウを特定したりするのに使います。


例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/window.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local window_handles = session:window_handles()
  for _,handle in pairs(window_handles) do
    print(handle)
    --2147483649
    --2147483656
    --2147483653
  end
  print(session:window_handle())
  --2147483649
  session:switch_to_window(window_handles[2])
  --2147483656
  print(session:window_handle())
```

### `maximize_window() -> void` {#maximize-windows}

現在のウインドウを最大化します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  session:set_window_rect({ height = 500, width = 500, x = 0, y = 0 })
  for k,v in pairs(session:window_rect()) do
    print(k,v)
  end
  -- y	0
  -- width	500
  -- height	500
  -- x	0
  session:maximize_window()
  for k,v in pairs(session:window_rect()) do
    print(k,v)
  end
  -- y	0
  -- width	1366
  -- height	768
  -- x	0
end)
```

### `minimize_window() -> void` {#minimize-window}

現在のウインドウを最小化します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  session:set_window_rect({ height = 500, width = 500, x = 0, y = 0 })
  for k,v in pairs(session:window_rect()) do
    print(k,v)
  end
  -- y	0
  -- width	500
  -- height	500
  -- x	0
  session:minimize_window()
  for k,v in pairs(session:window_rect()) do
    print(k,v)
  end
  -- y	0
  -- width	0
  -- height	0
  -- x	0
end)
```

### `fullscreen_window() -> {height=xxxx, width=xxxx, x=xxxx, y=xxxx}` {#fullscreen-window}

現在のウインドウをフルスクリーンにします。フルスクリーン時のウインドウのサイズと位置をテーブルとして返します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  session:set_window_rect({ height = 500, width = 500, x = 0, y = 0 })
  for k,v in pairs(session:window_rect()) do
    print(k,v)
  end
  -- y	0
  -- width	500
  -- height	500
  -- x	0
  session:fullscreen_window()
  for k,v in pairs(session:window_rect()) do
    print(k,v)
  end
  -- y	0
  -- width	1366
  -- height	768
  -- x	0
end)
```

### `window_rect() -> {height=xxxx, width=xxxx, x=xxxx, y=xxxx}` {#window-rect}

現在のウインドウのサイズと位置を取得します。現在のウインドウのサイズと位置をテーブルとして返します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  session:set_window_rect({ height = 500, width = 500, x = 0, y = 0 })
  for k,v in pairs(session:window_rect()) do
    print(k,v)
  end
  -- y	0
  -- width	500
  -- height	500
  -- x	0
end)
```

### `set_window_rect(rect) -> table` {#set-window-rect}

現在のウインドウのサイズを設定します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  session:set_window_rect({ height = 500, width = 500, x = 0, y = 0 })
  for k,v in pairs(session:window_rect()) do
    print(k,v)
  end
  -- y	0
  -- width	500
  -- height	500
  -- x	0
end)
```

### `switch_to_frame(id) -> void` {#switch-to-frame}

`id`: 切り替えたいフレームのIDを数字として指定します。

指定したIDのフレームへ切り替えます。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/frame.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  print(session:title())
  -- This is parent frame
  session:switch_to_frame(0)
  local element = session:find_element("css selector", "p")
  print(element:text())
  -- 1
  print(session:title())
  -- This is test html 1
end)
```

### `switch_to_parent_frame() -> void` {#switch-to-parent-frame}

現在のフレームの親フレームに切り替えます。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/frame.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  print(session:title())
  -- This is parent frame
  session:switch_to_frame(0)
  local element = session:find_element("css selector", "p")
  print(element:text())
  -- 1
  print(session:title())
  -- This is test html 1
  session:switch_to_parent_frame()
  element = session:find_element("css selector", "p")
  print(element:text())
  -- parent
  print(session:title())
  -- This is parent frame
end)
```

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

  local element = session:find_element("css selector", "#p1")
  element:save_screenshot("element.png")
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

  local elements = session:find_elements("css selector", 'p')
  for _,v in pairs(elements:texts()) do
    print(v)
-- Hello 1
-- Hello 2
-- Hello 3
  end
end)
```

### `active_element() -> web-driver.Element` {#active-element}

現在のWebサイトでアクティブな要素を[`web-driver.Element`][element]として返します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  local text_form = session:active_element()
  text_form:send_keys("This is test")
  print(text_form[1].value)
  -- This is test
end)

```

### `xml() -> string` {#xml}

現在のWebサイトのソースをXMLとして返します。このXMLはLuaの文字列として使えます。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  local xml = session:xml()
  print(xml)
end)
```

### `execute_script(script, args) -> the return value of given script` {#execute-script}

指定したJavascriptを実行します。与えられたスクリプトの戻り値を返します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  local script = [[return 1]]
  print(session:execute_script(script))
  -- 1
end)
```

### `execute_script_async(script, args) -> ` {#execute-script-async}

指定したJavascriptを非同期なスクリプトとして実行します。与えられたスクリプトの戻り値を返します。


例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  local script = [[return 1]]
  print(session:execute_script_async(script))
  -- 1
end)
```

### `all_cookies() -> table` {#all-cookies}

現在のWebサイトの全てのクッキーを取得します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/cookie.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local cookies = session:all_cookies()
  print(cookies[1].name, cookies[1].value)
  -- data1  123
  print(cookies[2].name, cookies[2].value)
  -- data2  456
end)
```

### `get_cookie(name) -> table` {#get-cookie}

指定したクッキーを取得します。

`name`: 取得したいクッキーの名前を文字列で指定します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/cookie.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local cookie = session:get_cookie("data1")
  print(cookie.name, cookie.value)
  -- data1  123
end)
```

### `add_cookie(cookie) -> void` {#add-cookie}

`cookie`: 追加するクッキーをテーブルとして指定します。

現在のWebサイトへ指定したクッキーを追加します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/cookie.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local cookies = session:all_cookies()
  print(#cookies)
  -- 2
  local cookie = {
    name = "data3",
    value = "789",
  }
  session:add_cookie(cookie)
  cookies = session:all_cookies()
  print(#cookies)
  -- 3
  print(cookies[3].name, cookies[3].value)
  -- data3  789
end)
```

### `delete_cookie(name) -> void` {#delete-cookie}

`name`: 削除するクッキーの名前を文字列として指定します。

指定したクッキーを現在のWebサイトから削除します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/cookie.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local cookies = session:all_cookies()
  print(#cookies)
  -- 2
  session:delete_cookie("data1")
  cookies = session:all_cookies()
  print(#cookies)
  -- 1
  print(cookies[1].name, cookies[1].value)
  -- data2  456
end)
```

### `delete_all_cookies() -> void` {#delete-all-cookies}

現在のWebサイトの全てのクッキーを削除します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/cookie.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local cookies = session:all_cookies()
  print(#cookies)
  -- 2
  session:delete_all_cookies("data1")
  cookies = session:all_cookies()
  print(#cookies)
  -- 0
end)
```

### `dismiss_alert() -> void` {#dismiss-alert}

現在のダイアログの"Cancel"ボタンを押下します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/confirm.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local element = session:find_element("css selector", "#button")
  element:click()
  session:dismiss_alert()
  element = session:find_element("css selector", "#confirm")
  print(element:text())
  -- Dismiss!
end)
```

### `accept_alert() -> void` {#accept-alert}

現在のダイアログの"OK"ボタンを押下します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/confirm.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local element = session:find_element("css selector", "#button")
  element:click()
  session:accept_alert()
  element = session:find_element("css selector", "#confirm")
  print(element:text())
  -- Accept!
end)
```

### `alert_text() -> string` {#alert-text}

現在のダイアログのテキストを取得します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/confirm.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local element = session:find_element("css selector", "#button")
  element:click()
  print(session:alert_text())
  -- ok?
end)
```

### `set_alert_text(text) -> void` {#set-alert-text}

`text`: ダイアログのテキストを文字列として指定します。

現在のダイアログに指定したテキストを設定します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/confirm.html"

driver:start_session(function(session)
  session:navigate_to(URL)
  local element = session:find_element("css selector", "#button")
  element:click()
  print(session:alert_text())
  -- ok?
  session:set_alert_text("setting text")
  print(session:alert_text())
  -- setting text
end)
```

### `take_screenshot() -> string` {#take-screenshot}

現在のWebサイトのスクリーンショットを文字列(PNG形式のデータ)として返します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)

  local png = element:take_screenshot()
end)

```

### `save_screenshot(filename) -> void` {#save-screenshot}

現在のWebサイトのスクリーンショットをPNG形式で指定したファイルに保存します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
  session:save_screenshot("sample.png")
end)

```


## 参照

  * [`web-driver.Searchable`][searchable]: 要素検索関連のメソッドを提供します。

  * [`web-driver.ElementSet`][elementset]: 複数の要素を扱うクラスです。


[searchable]:searchable.html

[elementset]:elementset.html

[element]:element.html
