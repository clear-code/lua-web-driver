---
title: チュートリアル
---

# チュートリアル

このドキュメントは、LuaWebDriverの使い方を段階的に説明しています。まだ、LuaWebDriverを[インストール][install]していない場合は、このドキュメントを読む前にLuaWebDriverを[インストール][install]してください。

## Webブラウザーの起動と停止 {#start-stop-web-browser}

Webブラウザーを起動するには、まず最初にWebDriverを起動します。

以下のように、[`FirefoxDriver.start`][firefoxdriver-start]を使って、Webブラウザーを起動できます。
Webブラウザーはデフォルトでヘッドレスモードで起動します。

また、処理が終了したらWebブラウザーを停止する必要があります。

[`FirefoxDriver.stop`][firefoxdriver-stop]を使って、Webブラウザーを停止できます。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

driver:start()
driver:stop()
```

## Webサイトへのアクセス

[`Session.navigate_to`][session-navigate-to]を使って、Webブラウザーで特定のWebサイトへアクセスできます。

まず最初に、Webサイトへアクセスするためのコールバック関数を作成します。
[`Session.navigate_to`][session-navigate-to]の引数としてURLを指定します。

次に、[`Firefox.start_session`][firefox-start-session]の引数としてコールバックを指定し、[`Firefox.start_session`][firefox-start-session]を呼び出します。
セッションはコールバックを呼び出した後、自動的に破棄されます。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

-- コールバックを作成する
function callback(session)
-- Session.navigate_toの引数としてURLを指定する
  session:navigate_to("https://www.google.com/")
end

driver:start()
-- Firefox.start_sessionの引数としてコールバックを指定する
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
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

-- コールバックを作成する
function callback(session)
-- Session.navigate_toの引数としてURLを指定する
  session:navigate_to("https://www.google.com/")
-- 現在のWebサイトをXMLとしてシリアライズする
  local xml = session:xml()
  print(xml)
end

driver:start()
driver:start_session(callback)
driver:stop()
```

## スクリーンショットの取得 {#take-screenshot}

[`Session.take_screenshot`][session-take-screenshot]を使って現在のWebサイトのスクリーンショットを取得できます。
スクリーンショットは、PNG形式で取得されます。

まずはじめに、以下の例のようにシリアライズするWebサイトへアクセスします。

次に、[`Session.take_screenshot`][session-take-screenshot]を呼び出します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

-- コールバックを作成する
function callback(session)
-- Session.navigate_toの引数としてURLを指定する
  session:navigate_to("https://www.google.com/")
-- PNGフォーマットでスクリーンショットを取得する
  local png = session:take_screenshot()
  io.output("sample.png")
  io.write(png)
end

driver:start()
driver:start_session(callback)
driver:stop()
```

## Webサイトの移動 {#move-on-website}

以下の機能を使って、Webサイトの移動ができます。

* ボタン操作
* チェックボックス操作
* リンククリック

この例では、ログインして、リンクをクリックしてテキストを取得します。

まず最初に、対象のWebサイトへアクセスします。

次に、このWebサイトは認証が必要なので、ユーザー名とパスワードを入力します。[`Session.find_element`][session-find-element]と[`Element.send_keys`][element-send-keys]を使って、ユーザー名とパスワードを入力できます。[`Session.find_element`] [session-find-element]でユーザー名とパスワードを入力する要素オブジェクトを取得します。この例では、CSSセレクタで要素オブジェクトを取得しますが、XPathを使用して取得することもできます。取得した要素オブジェクトの[`Element.send_keys`][element-send-keys]を呼び出します。[`Element.send_keys`] [element-send-keys]の引数として入力文字列を指定します。

次に、[`Session.find_element`] [session-find-element]と[` Element.click`][element-click]でチェックボックスをチェックします。[`Session.find_element`] [session-find-element]でチェックボックスオブジェクトを取得します。この例では、CSSセレクタでチェックボックスを取得しますが、XPathを使用して取得することもできます。取得したチェックボックスオブジェクトの[Element.click`] [element-click]を呼び出します。

次に、[`Session.find_element`] [session-find-element]と[` Element.click`] [element-click]でログインボタンを押します。

次に、[`Session.find_element`] [session-find-element]と[` Element.click`] [element-click]を使ってログインした後のWebサイトのリンクをクリックします。

次に、[`Element.get_text`] [element-get-text]で移動後のWebサイトの特定の要素のテキストを取得します。[`Session.find_element`][session-find-element]を使って、テキストを取得するための要素オブジェクトを取得します。次に、取得した要素オブジェクトの[`Element.get_text`][element-get-text]を呼び出します。取得したテキストの値は、Luaの文字列として使えます。

例:

```lua
```

## 特定のフォームのボタン操作 {#button-operation-on-specific-form}

[`Session.find_element`][session-find-element]と[`Element.click`][element-click]を使って、特定のフォームのボタンを操作できます。

まずはじめに、以下の例のようにボタンを操作するWebサイトへアクセスします。

次に、[`Session.find_element`][session-find-element]を使って、ボタン操作をするための要素オブジェクトを取得します。
この例では、CSS selectorで取得していますが、XPathを使って取得することもできます。

次に、取得した要素オブジェクトの[`Element.click`][element-click]を呼び出します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

-- コールバックを作成する
local callback = function(session)
-- Session.navigate_toの引数としてURLを指定する
  session:navigate_to("http://localhost:10080/confirm.html")
-- ボタン操作をする要素オブジェクトを取得する
  local element = session:find_element("css selector", "#button")
-- 取得したボタンをクリックする
  element:click()
end

driver:start()
driver:start_session(callback)
driver:stop()
```

## 特定のフォームへの文字列入力 {#input-string-into-form}

[`Element.send_keys`][element-send-keys]を使って、特定のフォームに文字列を入力できます。

まずはじめに、フォームに文字列を入力するWebサイトへアクセスします。

次に、[`Session.find_element`][session-find-element]を使って、文字列を入力するための要素オブジェクトを取得します。この例では、CSS selectorで取得していますが、XPathを使って取得することもできます。

次に、取得した要素オブジェクトの[`Element.send_keys`][element-send-keys]を呼び出します。[`Element.send_keys`][element-send-keys]の引数には、入力文字列を指定します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

-- コールバックを作成する
local callback = function(session)
-- Session.navigate_toの引数としてURLを指定する
  session:navigate_to("http://localhost:10080/index.html")
-- 文字列を入力する要素オブジェクトを取得する
  local element = session:find_element("css selector", 'input[name=name]')
-- フォームに文字列を入力する
  element:send_keys("This is test")
end

driver:start()
driver:start_session(callback)
driver:stop()
```

## 要素の属性の取得 {#get-attribute-element}

[`Element.get_attribute`][element-get-attribute]を使って特定の要素の属性を取得できます。

まずはじめに、[`Session.find_element`][session-find-element]を使って、属性を取得するための要素オブジェクトを取得します。

次に、取得した要素オブジェクトの[`Element.get_attribute`][element-get-attribute]を呼び出します。[`Element.get_attribute`][element-get-attribute]の引数には、属性名を指定します。取得した属性値は、Luaの文字列として使えます。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

-- コールバックを作成する
local callback = function(session)
-- Session.navigate_toの引数としてURLを指定する
  session:navigate_to("http://localhost:10080/index.html")
-- 属性を取得する要素オブジェクトを取得する
  local element = session:find_element("css selector", "input[name=wine]")
-- 取得した要素オブジェクトの属性を取得する
  local name = element:get_attribute("name")
  local type = element:get_attribute("type")
  print(name, type)
end

driver:start()
driver:start_session(callback)
driver:stop()
```

## 要素のテキストの取得 {#get-attribute-element}

[`Element.text`][element-text]を使って特定の要素のテキストを取得できます。

まずはじめに、[`Session.find_element`][session-find-element]を使って、テキストを取得するための要素オブジェクトを取得します。

次に、取得した要素オブジェクトの[`Element.text`][element-text]を呼び出します。取得したテキストの値は、Luaの文字列として使えます。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

-- コールバックを作成する
local callback = function(session)
-- Session.navigate_toの引数としてURLを指定する
  session:navigate_to("http://localhost:10080/confirm.html")
-- テキストを取得する要素オブジェクトを取得する
  local element = session:find_element("css selector", '#p2')
-- 取得した要素オブジェクトのテキストを取得する
  local text = element:text()
  print(text)
end

driver:start()
driver:start_session(callback)
driver:stop()
```

## Next step {#next-step}

Now, you knew all major LuaWebDriver features! If you want to understand each feature, see [reference manual][reference] for each feature.


[install]:../install/

[webdriver-create]:../reference/webdriver.html#create

[firefoxdriver-start]:../reference/firefoxdriver.html#start

[firefoxdriver-stop]:../reference/firefoxdriver.html#stop

[firefox-start-session]:../reference/firefox.html#start_session

[session-navigate-to]:../reference/session.html#navigate_to

[session-xml]:../reference/session.html#xml

[session-take-screenshot]:../reference/session.html#take_screenshot

[session-back]:../reference/session.html#back

[session-forward]:../reference/session.html#forward

[session-accept-alert]:../reference/session.html#accept_alert

[session-dismiss-alert]:../reference/session.html#dismiss_alert

[session-find-element]:../reference/session.html#find_element

[element-send-keys]:../reference/element.html#send_keys

[element-click]:../reference/element.html#click

[element-get-attribute]:../reference/element.html#get_attribute

[element-text]:../reference/element.html#text

[reference]:../reference/
