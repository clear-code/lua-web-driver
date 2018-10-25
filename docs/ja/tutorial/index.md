---
title: チュートリアル
---

# チュートリアル

このドキュメントは、LuaWebDriverの使い方を段階的に説明しています。まだ、LuaWebDriverを[インストール][install]していない場合は、このドキュメントを読む前にLuaWebDriverを[インストール][install]してください。

## Webサイトへのアクセス

[`Session:navigate_to`][session-navigate-to]を使って、Webブラウザーで特定のWebサイトへアクセスできます。

まず最初に、Webサイトへアクセスするためのコールバック関数を作成します。
[`Session:navigate_to`][session-navigate-to]の引数としてURLを指定します。

次に、[`Firefox:start_session`][firefox-start-session]の引数としてコールバックを指定し、[`Firefox:start_session`][firefox-start-session]を呼び出します。
セッションはコールバックを呼び出した後、自動的に破棄されます。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/"

-- コールバックの作成とセッションの開始
driver:start_session(function(session)
  session:navigate_to(URL)
end)
```

## Wbeサイトのシリアライズ {#serialize-to-website}

[`Session:xml`][session-xml]を使ってWebサイトをXMLとしてシリアライズできます。

まずはじめに、以下の例のようにシリアライズするWebサイトへアクセスします。

次に、[`Session:xml`][session-xml]を呼び出します。

そうすると、現在のWebサイトをXMLとしてシリアライズできます。このXMLはLuaの文字列として使えます。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

-- コールバックの作成とセッションの開始
driver:start_session(function(session)
  session:navigate_to(URL)
-- 現在のWebサイトをXMLとしてシリアライズする
  local xml = session:xml()
  print(xml)
end)
```

## スクリーンショットの取得 {#save-screenshot}

[`Session:save_screenshot`][session-save-screenshot]を使って現在のWebサイトのスクリーンショットを取得できます。
スクリーンショットは、PNG形式で取得されます。

まずはじめに、以下の例のようにスクリーンショットを取得するWebサイトへアクセスします。

次に、[`Session:save_screenshot`][session-save-screenshot]を呼び出します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
-- PNG形式でスクリーンショットを保存します
  session:save_screenshot("sample.png")
end)
```

## Webサイトの移動 {#move-on-website}

以下の機能を使って、Webサイトの移動ができます。

* ボタン操作
* チェックボックス操作
* リンククリック

この例では、ログインして、リンクをクリックしてテキストを取得します。

まず最初に、対象のWebサイトへアクセスします。

次にこのWebサイトは認証が必要なので、ユーザー名とパスワードを入力します。
[`Session:css_select`][session-css-select]と[`ElementSet:send_keys`][elementset-send-keys]を使ってユーザー名とパスワードを入力できます。


ユーザー名とパスワードを入力するための要素を[`Session:css_select`][session-css-select]を使って取得します。
この例では、CSSセレクターを使って要素を取得していますが、[`Session:xpath_search`][session-xpath-search]でXpathを使った取得もできます。

次に、取得した要素オブジェクトの[`ElementSet:send_keys`][elementset-send-keys]を呼び出します。[`ElementSet:send_keys`][elementset-send-keys]の引数には、入力文字列を指定します。

次に、[`Session:css_select`] [session-css-select]と[`ElementSet:click`][elementset-click]でログインボタンを押します。

次に、[`Session:link_search`] [session-link-search]と[`ElementSet:click`][elementset-click]を使ってログインした後のWebサイトのリンクをクリックします。

次に、[`ElementSet:text`][elementset-text]で移動後のWebサイトの特定の要素のテキストを取得します。
[`Session:css_select`][session-css-select]を使って、テキストを取得する要素を取得します。
取得した要素の[`ElementSet:text`][elementset-text]を呼び出します。
取得したテキストの値はLuaの文字列として使えます。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/move.html"

-- コールバックの作成とセッションの開始
driver:start_session(function(session)
  session:navigate_to(URL)

-- Webサイト内のフォームを取得
  local form = session:css_select('form')
-- ユーザー名を入力するためのフォームを取得
  local text_form = form:css_select('input[name=username]')
-- フォームにユーザー名を入力
  text_form:send_keys("username")
-- パスワードを入力するためのフォームを取得
  local password_form = form:css_select('input[name=password]')
-- フォームにパスワードを入力
  password_form:send_keys("password")

-- ユーザー名とパスワードを送信するためのボタンを取得
  local button = form:css_select("input[type=submit]")
-- ユーザー名とパスワードを送信
  button:click()

-- リンク操作をするための要素オブジェクトを取得
  local link = session:link_search ("1")
-- リンクをクリック
  link:click()
  local elements = session:css_select("p")
-- 取得した要素のテキストを取得
  print(elements:text())
end)
```

## 特定のフォームのボタン操作 {#button-operation-on-specific-form}

[`Session:css_select`][session-css-select]と[`ElementSet:click`][elementset-click]を使って、特定のフォームのボタンを操作できます。

まずはじめに、以下の例のようにボタンを操作するWebサイトへアクセスします。

次に、[`Session:css_select`][session-css-select]を使って、ボタン操作をするための要素オブジェクトを取得します。
この例では、CSSセレクターで取得していますが、XPathを使って取得することもできます。

次に、取得した要素オブジェクトの[`ElementSet:click`][elementset-click]を呼び出します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/button.html"

-- コールバックの作成ｔおセッションの開始
driver:start_session(function(session)
  session:navigate_to(URL)
-- ボタン操作をするための要素を取得
  local elements = session:css_select('#announcement')
-- 取得したボタンをクリック
  elements:click()

-- 移動後のWebサイトの要素のテキストを取得
  elements = session:css_select('a[name=announcement]')
  local informations_summary = elements:texts()
  for _, summary in ipairs(informations_summary) do
    print(summary)
  end
end)
```

## 特定のフォームへの文字列入力 {#input-string-into-form}

[`ElementSet:send_keys`][elementset-send-keys]を使って、特定のフォームに文字列を入力できます。

まずはじめに、フォームに文字列を入力するWebサイトへアクセスします。

次に、[`Session:css_select`][session-css-select]を使って、文字列を入力するための要素オブジェクトを取得します。この例では、CSSセレクターで取得していますが、XPathを使って取得することもできます。

次に、取得した要素オブジェクトの[`ElementSet:send_keys`][elementset-send-keys]を呼び出します。[`ElementSet:send_keys`][elementset-send-keys]の引数には、入力文字列を指定します。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/index.html"

-- コールバックの作成とセッションの開始
driver:start_session(function(session)
  session:navigate_to(URL)
-- 文字列を入力するための要素を取得
  local elements = session:css_select('input[name=name]')
-- フォームに文字列を入力
  elements:send_keys("This is test")
  print(elements[1].value)
end)
```

## 要素の属性の取得 {#get-attribute-element}

[`Element:get_attribute`][element-get-attribute]を使って特定の要素の属性を取得できます。

まずはじめに、[`Session:css_select`][session-css-select]を使って、属性を取得するための要素オブジェクトを取得します。

次に、取得した要素オブジェクトの[`Element:get_attribute`][element-get-attribute]を呼び出します。[`Element:get_attribute`][element-get-attribute]の引数には、属性名を指定します。取得した属性値は、Luaの文字列として使えます。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/get-attribute.html"

-- コールバックの作成とセッションの開始
driver:start_session(function(session)
  session:navigate_to(URL)
-- 属性取得するための要素を取得
  local elements = session:css_select('p')
  for _, element in ipairs(elements) do
-- 取得した要素の属性を取得
    if element["data-value-type"] == "number" then
      print(element:text())
    end
  end
end)
```

## 要素のテキストの取得 {#get-attribute-element}

[`ElementSet:text`][elementset-text]を使って特定の要素のテキストを取得できます。

まずはじめに、[`Session:css_select`][session-css-select]を使って、テキストを取得するための要素オブジェクトを取得します。

次に、取得した要素オブジェクトの[`ElementSet:text`][elementset-text]を呼び出します。取得したテキストの値は、Luaの文字列として使えます。

例:

```lua
local web_driver = require("web-driver")
local driver = web_driver.Firefox.new()

local URL = "https://clear-code.gitlab.io/lua-web-driver/sample/"

-- コールバックの作成とセッションの開始
driver:start_session(function(session)
  session:navigate_to(URL)
-- テキストを取得するための要素を取得
  local element_set = session:css_select('#p2')
-- 取得した要素のテキストを取得
  local text = element_set:text()
  print(text)
end)
```

## ロガー {#logger}

LuaWebDriverはロガーに[`lua-log`][lua-log]を使っています。

呼び出し元で作成したロガーオブジェクトを[`web-driver.Firefox.new()`][firefox-new]の引数に渡すことで、呼び出し元と同じロガーオブジェクトを使えます。

使用できるログレベルは以下です。
* emergency
* alert
* fatal
* error
* warning
* notice
* info
* debug
* trace

上記のログレベルは文字列として指定します。

例:

```
local web_driver = require("web-driver")
local log = require("log")


local logger = log.new("trace")
local options = { logger = logger }
local driver = web_driver.Firefox.new(options)

local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

driver:start_session(function(session)
  session:navigate_to(URL)
end)
```

LuaWebDriverをマルチスレッドで使う場合は、[`web-driver.ThreadPool.new()`][thread-pool-new]の引数にロガーオブジェクトを渡します。

例:

```
local web_driver = require("web-driver")
local log = require("log")

local url =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"
local log_level = "trace"
local n_threads = 2

local logger = log.new(log_level)
local function crawler(context)
  local logger = context.logger
  local session = context.session
  local url = context.job
  local prefix = url:match("^https?://[^/]+/")
  logger:debug("Opening...: " .. url)
  session:navigate_to(url)
  local status_code = session:status_code()
  if status_code and status_code ~= 200 then
    logger:notice(string.format("%s: Error: %d",
                                url,
                                status_code))
    return
  end
  logger:notice(string.format("%s: Title: %s",
                              url,
                              session:title()))
  local anchors = session:css_select("a")
  local anchor
  for _, anchor in pairs(anchors) do
    local href = anchor.href
    local normalized_href = href:gsub("#.*$", "")
    logger:notice(string.format("%s: Link: %s (%s): %s",
                                url,
                                href,
                                normalized_href,
                                anchor:text()))
    if normalized_href:sub(1, #prefix) == prefix then
      context.job_pusher:push(normalized_href)
    end
  end
end
local options = {
  logger = logger,
  size = n_threads,
}
local pool = web_driver.ThreadPool.new(crawler, options)
logger.debug("Start crawling: " .. url)
pool:push(url)
pool:join()
logger.debug("Done crawling: " .. url)
```

以下のように環境変数でログレベルを設定することもできます。

例:

```
export LUA_WEB_DRIVER_LOG_LEVEL="trace"
```

環境変数もロガーオブジェクトも設定しない場合、LuaWebDriverは、Firefoxとgeckodriverのログを"info"レベルで出力します。

## マルチスレッド {#multi-thread}

複数のスレッドでLuaWebDriverを使えます。LuaWebDriverを複数のスレッドで使うためには、以下のように[`web-driver.ThreadPool`][thread-pool]オブジェクトを使う必要があります。

以下の例では、[`web-driver.ThreadPool:push()`][thread-pool-push]の引数に与えられたURLを起点にWebページをクロールします。

例:

```lua
local web_driver = require("web-driver")
local log = require("log")


local URL =
  "https://clear-code.gitlab.io/lua-web-driver/sample/"

local log_level = "notice"

local logger = log.new(log_level)
local function crawler(context)
  local web_driver = require("web-driver")
  local logger = context.logger
  local session = context.session
  local url = context.job
  local prefix = url:match("^https?://[^/]+/")
  logger:debug("Opening...: " .. url)
  session:navigate_to(url)
  logger:notice(string.format("%s: Title: %s",
                              url,
                              session:title()))
  local anchors = session:css_select("a")
  local anchor
  for _, anchor in pairs(anchors) do
    local href = anchor.href
    local normalized_href = href:gsub("#.*$", "")
    logger:notice(string.format("%s: Link: %s (%s): %s",
                                url,
                                href,
                                normalized_href,
                                anchor:text()))
    if normalized_href:sub(1, #prefix) == prefix then
      context.job_pusher:push(normalized_href)
    end
  end
end
local pool = web_driver.ThreadPool.new(crawler, {logger = logger})
logger.debug("Start crawling: " .. URL)
pool:push(URL)
pool:join()
logger.debug("Done crawling: " .. URL)
```

[`web-driver.ThreadPool.new()`][thread-pool-new]の引数に与えられた関数内に実行したい処理を書くことができます。

[`web-driver.ThreadPool.new()`][thread-pool-new]の引数に与えられた関数内で[`web-driver.JobPusher:push()`][job-pusher-push](上の例では、`context.job_pusher:push()`です。)を呼び出すことによって、空いているスレッドがジョブを順に処理します。

[`web-driver.ThreadPool.new()`][thread-pool-new]の引数に与えられる関数の引数の数は1つです。(上の例で、[`web-driver.ThreadPool.new()`][thread-pool-new]の引数に与えられる関数は`crawler`です。)
この引数は、Webページをクロールするための情報が入っています。(上の例では、この引数は`context`です。)


同じジョブを登録した場合、LuaWebDriverはデフォルトで同じジョブを無視します。

ジョブは、文字列のみ受け取れます。ジョブには、URLを与えることをおすすめします。


失敗したジョブは自動的にリトライします。リトライ回数はデフォルトで3回です。


以下のように[`web-driver.ThreadPool.new()`][thread-pool-new]の引数として、リトライ回数を指定することもできます。

例:

```lua
local pool = web_driver.ThreadPool.new(crawler, {max_n_failures = 5})
```

LuaWebDriverを複数のスレッドで使うには、以下のような注意が必要です。

* 現在、スレッド起動時にLuaWebDriverがクラッシュすることがあります。
  * この問題は、`libpthread.so`を`LD_PRELOAD`に指定することで解消する可能性があります。

* LuaWebDriverは各スレッド間で共通の情報を持ちません。
  * もし、各スレッドで共通の情報を使いたい場合は、環境変数を使うか共通の情報を保存したファイルを読み込んで下さい。
  * 例えば、既知の情報(ログイン情報等)は、ファイルに保存し、そのファイルをスレッド内で読み込むことでアクセスしやすくなります。

* 基本的に1回の呼び出し毎に1つのWebページを処理する想定ですが、ログインが必要なWebページを処理する場合は、同じスレッドでログイン後の処理も実行したほうが良いです。
  * スレッド内でセッションを再使用することで、ログイン状態を維持しているためです。

* [`web-driver.ThreadPool.new()`][thread-pool-new]の引数として与えられる関数は、その関数の外部の情報を参照してはいけません。

* スレッドは作りすぎないほうが良いです。スレッド毎にFirefoxを起動するので、動作が遅くなるためです。
  * スレッド数の目安は、物理CPUがコア数の1/3です。

* LuaWebDriverは、ジョブを中断できません。
  * `luajit`プロセスを途中で終了した場合、ジョブは最初から実行されます。ジョブの重複チェックもリセットされます。

* 各スレッドを終了する処理は特に実装する必要はありません。[`web-driver.ThreadPool:join()`][thread-pool-join]内で各スレッドの終了処理を実行しているためです。

## 次のステップ {#next-step}

これで、LuaWebDriverのすべての主な機能を学びました！それぞれの機能をより理解したい場合は、各機能の[リファレンスマニュアル][reference]を見てください。


[lua-log]:https://github.com/moteus/lua-log

[install]:../install/

[webdriver-create]:../reference/webdriver.html#create

[firefoxdriver-start]:../reference/firefoxdriver.html#start

[firefoxdriver-stop]:../reference/firefoxdriver.html#stop

[firefox-new]:../reference/firefox.html#new

[firefox-start-session]:../reference/firefox.html#start_session

[session-navigate-to]:../reference/session.html#navigate_to

[session-xml]:../reference/session.html#xml

[session-save-screenshot]:../reference/session.html#save_screenshot

[session-back]:../reference/session.html#back

[session-forward]:../reference/session.html#forward

[session-accept-alert]:../reference/session.html#accept_alert

[session-dismiss-alert]:../reference/session.html#dismiss_alert

[session-css-select]:../reference/session.html#css_select

[session-xpath-search]:../reference/session.html#xpath_search

[session-link-search]:../reference/session.html#link_search

[elementset-send-keys]:../reference/elementset.html#send_keys

[elementset-click]:../reference/elementset.html#click

[elementset-text]:../reference/elementset.html#text

[element-get-attribute]:../reference/element.html#get_attribute

[element-text]:../reference/element.html#text

[thread-pool]:../reference/thread-pool.html

[thread-pool-new]:../reference/thread-pool.html#new

[thread-pool-push]:../reference/thread-pool.html#push

[thread-pool-join]:../reference/thread-pool.html#join

[job-pusher-push]:../reference/job-pusher.html#push

[reference]:../reference/
