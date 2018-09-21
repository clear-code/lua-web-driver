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

## スクリーンショットの取得 {#take-screenshot}

[`Session.screenshot`][session-screenshot]を使って現在のWebサイトのスクリーンショットを取得できます。
スクリーンショットは、PNG形式で取得されます。

まずはじめに、以下の例のようにシリアライズするWebサイトへアクセスします。

次に[`Session.screenshot`][session-screenshot]を呼び出します。
[`Session.screenshot`][session-screenshot]の引数は1つです。
[`Session.screenshot`][session-screenshot]の引数はファイル名を指定します。

例:

```lua
```

## Webサイト上のボタン操作


[`Session.accept_alert`][session-accept-alert]と[`Session.dismiss_alert`][session-dismiss-alert]を使って、Webサイト上のボタンを操作できます。

まずはじめに、以下の例のようにボタンを操作するWebサイトへアクセスします。

次に、"OK"ボタンを押したい場合は、[`Session.accept_alert`][session-accept-alert]を呼び出します。

"Cancel"ボタンを押したい場合は、[``Session.dismiss_alert][session-dismiss-alert]を呼び出します。

例:

```lua

```

また、[`Session.find_element`][session-find-element]を使って、特定のダイアログ上のボタンを操作できます。
[`Session.find_element`][session-find-element]は、以下のようにCSSセレクタを使って、特定の要素を取得できます。

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

[session-screenshot]:../reference/session.html#screenshot

[session-accept-alert]:../reference/session.html#accept_alert

[session-dismiss-alert]:../reference/session.html#dismiss_alert

[session-find-element]:../reference/session.html#find_element

[reference]:../reference/
