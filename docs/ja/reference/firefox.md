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

新しい[`web-driver.Firefox`][firefox]を作成します。

以下のように起動オプションを指定できます。

* `options.host`: ホストを指定します。デフォルトは、127.0.0.1です。
* `options.port`: ポートを指定します。デフォルトは、4444です。
* `options.args`: Firefoxのオプションをテーブルで指定します。デフォルトは、`{ -headless }`です。

例:

```lua
local web_driver = require("web-driver")

local options = {}
options.host = "192.168.0.1"
options.port = "1111"
local driver = web_driver.Firefox.new(options)
```

`options.args`に設定可能なオプションは、以下を参照してください。

[コマンドラインオプション](https://developer.mozilla.org/en-US/docs/Mozilla/Command_Line_Options)

### `web-driver.Firefox.session_start(callback) -> return value of callback` {#session-start}

`callback`: コールバック関数。

Firefoxとのセッションを開始し、与えられたコールバック関数を呼び出します。与えられたコールバック関数の戻り値を返します。

コールバック関数には、Firefoxで実行したい処理を記述できます。

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


[firefox]:firefox.html
