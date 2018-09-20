---
title: チュートリアル
---

# チュートリアル

このドキュメントは、LuaWebDriverの使い方を段階的に説明しています。まだ、LuaWebDriverを[インストール][install]していない場合は、このドキュメントを読む前にLuaWebDriverを[インストール][install]してください。

## Webブラウザーの起動と停止 {#start-stop-web-browser}

Webブラウザーを起動するには、まず最初にWebDriverを起動します。

以下のように、[`WebDriver.create`][webdriver-create]と[`FirefoxDriver.start`][firefoxdriver-start]を使って、Webブラウザーを起動できます。

また、処理が終了したらWebブラウザーを停止する必要があります。

[`FirefoxDriver.stop`][firefoxdriver-stop]を使って、Webブラウザーを停止できます。

例:

```lua
local WebDriver = require("web-driver")
local driver = WebDriver.create("firefox")

driver:start()
driver:stop()
```

以下の例のように、Webブラウザーをヘッドレスモードで起動することもできます。

ブラウザーオプションは、argsキーの値として設定する必要があることに注意してください。

例:

```lua
local WebDriver = require("web-driver")

-- ブラウザーオプションをLuaのテーブルとして作成します
-- ブラウザーオプションは、argsキーの値として設定する必要があります
local options = {
  args = { "-headless" }
}

local driver = WebDriver.create("firefox", browser_options)

driver:start()
driver:stop()
```

## Next step {#next-step}

Now, you knew all major LuaWebDriver features! If you want to understand each feature, see [reference manual][reference] for each feature.


[install]:../install/

[webdriver-create]:../reference/webdriver.html#create

[firefoxdriver-start]:../reference/firefoxdriver.html#start

[firefoxdriver-stop]:../reference/firefoxdriver.html#stop

[reference]:../reference/
