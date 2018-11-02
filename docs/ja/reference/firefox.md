---
title: web-driver.Firefox
---

# `web-driver.Firefox` クラス

## 概要

Firefox用のWebDriverクラスです。

geckodriver経由でFirefoxとのセッションを開始できます。

## クラスメソッド

### `web-driver.Firefox.new(options) -> web-driver.Firefox` {#new}

`options`: Firefoxの起動オプション

新しい[`web-driver.Firefox`][firefox]オブジェクトを作成します。

以下のように起動オプションを指定できます。

* `options.host`: ホストを指定します。デフォルトは、`"127.0.0.1"`です。
* `options.port`: ポートを指定します。デフォルトは、`"4444"`です。
* `options.get_request_timeout`: HTTP GET リクエストのタイムアウトを指定します。デフォルトは`60`秒です。
* `options.post_request_timeout`: HTTP POST リクエストのタイムアウトを指定します。デフォルトは`60`秒です。
* `options.delete_request_timeout`: HTTP DELETE リクエストのタイムアウトを指定します。デフォルトは`60`秒です。
* `options.http_request_timeout`: HTTP GET と HTTP POST、HTTP DELETEリクエストのタイムアウトを指定します。デフォルトは`60`秒です。
* `options.headless`: Firefoxをヘッドレスモードで起動するかどうかを指定します。
  * このオプションが`false`の場合、FirefoxはGUIで起動します。
  * このオプションを設定しないか`true`を設定した場合、Firefoxはヘッドレスモードで起動します。
* `options.arguments`: Firefoxのオプションをテーブルで指定します。
* `options.args`: `options.arguments`のエイリアスです。このオプションは非推奨です。代わりに`options.arguments`を使うことをおすすめします。
* `options.preferences`: Firefoxの設定を指定します。
  * このオプションの設定値は、Firefoxの`about:config`ページで設定できる値と同じです。

例:

```lua
local web_driver = require("web-driver")

local options = {}
options.host = "192.168.0.1"
options.port = "1111"
local driver = web_driver.Firefox.new(options)
```

`options.arguments`と`options.args`に設定可能なオプションは、以下を参照してください。

[コマンドラインオプション](https://developer.mozilla.org/ja/docs/Mozilla/Command_Line_Options)

### `web-driver.Firefox.start_session(callback) -> コールバック関数の戻り値` {#session-start}

`callback`: コールバック関数を指定します。

Firefoxとのセッションを開始し、与えられたコールバック関数を呼び出します。与えられたコールバック関数の戻り値を返します。

引数を設定しない場合、このメソッドは[`web-driver.Session`][session]オブジェクトを返します。

コールバック関数には、以下のようにFirefoxで実行したい処理を記述できます。

ここでは、セッションを開始し、Webサイトへ移動する例を示します: 

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

-- Firefoxとのセッションを開始
driver:start_session(function(session)
-- Webサイトへ移動
  session:navigate_to(URL)
end)
```

引数にコールバック関数を設定した場合は、セッションはコールバック関数を呼び出した後、自動的に削除されます。引数を設定しない場合は、[`web-driver.Session:delete()`][session-delete]を使って手動でセッションを削除する必要があります。


[firefox]: firefox.html

[session]: session.html

[session-delete]: session.html#delete
