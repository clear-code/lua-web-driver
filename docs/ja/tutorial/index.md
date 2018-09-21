---
title: チュートリアル
---

# チュートリアル

このドキュメントは、LuaWebDriverの使い方を段階的に説明しています。まだ、LuaWebDriverを[インストール][install]していない場合は、このドキュメントを読む前にLuaWebDriverを[インストール][install]してください。

## Webブラウザーの起動と停止 {#start-stop-web-browser}

Webブラウザーを起動するには、まず最初にWebDriverを起動します。

以下のように、[`WebDriver.create`][webdriver-create]と[`FirefoxDriver.start`][firefoxdriver-start]を使って、Webブラウザーを起動できます。
Webブラウザーはデフォルトでヘッドレスモードで起動します。

また、処理が終了したらWebブラウザーを停止する必要があります。

[`FirefoxDriver.stop`][firefoxdriver-stop]を使って、Webブラウザーを停止できます。

例:

```lua
local WebDriver = require("web-driver")
local driver = WebDriver.create("firefox")

driver:start()
driver:stop()
```

## Webサイトへのアクセス

[`Session.visit`][session-visit]を使って、Webブラウザーで特定のWebサイトへアクセスできます。

まず最初に、Webサイトへアクセスするためのコールバック関数を作成します。
[`Session.visit`][session-visit]の引数としてURLを指定します。

次に、[`Session.start`][session-start]の引数としてコールバックを指定し、[`Session.start`][session-start]を呼び出します。
セッションはコールバックを呼び出した後、自動的に破棄されます。

例:

```lua
local WebDriver = require("web-driver")
local driver = WebDriver.create("firefox")

-- コールバックを作成する
function callback(session)
-- Session.visitの引数としてURLを指定する
  session:visit("https://www.google.com/")
end

driver:start()
-- Session.startの引数としてコールバックを指定する
driver:start_session(callback)
driver:stop()
```

## Wbeサイトのシリアライズ {#serialize-to-website}

[`Session.xml`][session-xml]を使ってWebサイトをXMLとしてシリアライズできます。

まずはじめに、以下の例のようにシリアライズするWebサイトへアクセスします。

次に、[`Session.xml`][session-xml]を呼び出します。

そうすると、現在のWebサイトをXMLとしてシリアライズできます。このXMLはLuaの文字列として使えます。

例:

```lua
```

## Next step {#next-step}

Now, you knew all major LuaWebDriver features! If you want to understand each feature, see [reference manual][reference] for each feature.


[install]:../install/

[webdriver-create]:../reference/webdriver.html#create

[firefoxdriver-start]:../reference/firefoxdriver.html#start

[firefoxdriver-stop]:../reference/firefoxdriver.html#stop

[session-start]:../reference/session.html#start

[session-visit]:../reference/session.html#visit

[session-xml]:../reference/session.html#xml

[reference]:../reference/
