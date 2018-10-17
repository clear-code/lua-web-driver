---
title: web-driver
---

# `web-driver` モジュール

## 概要

メインモジュールです。

## モジュール変数

### `VERSION` {#version}

Luaの文字列としてLuaWebDriverのバージョンを持っています。以下のように標準出力にLuaWebDriverのバージョンを出力できます。

例:

```lua
local web_driver = require("web-driver")
print(web_driver.VERSION)
```

### `Firefox` {#firefox}

Firefox用の WebDriverオブジェクトを持っています。以下のように、この変数経由で[`web_driver.Firefox`][firefox]オブジェクトを作成できます。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()
```

### `ThreadPool` {#thread-pool}

スレッドプールオブジェクトです。マルチスレッドで実行する際に使用します。

このオブジェクトの詳細については、 [`web-driver.ThreadPool`][thread-pool] を参照して下さい。

## 参照

  * [web-driver.Firefox][firefox]

  * [web-driver.ThreadPool][thread-pool]


[firefox]:firefox.html

[thread-pool]:thread-pool.html
