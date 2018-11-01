---
title: web-driver.ThreadPool
---

# `web-driver.ThreadPool` クラス

## 概要

スレッドプールを制御するためのクラスです。

このクラスは、スレッドプールとジョブキューを作成し、ジョブをスレッドに割り当てます。

## クラスメソッド

### `web-driver.ThreadPool.new(consumer, options) -> web-driver.ThreadPool` {#new}

`consumer`: ジョブを実行する関数を指定します。

`options`: スレッドプールのオプションを指定します。

[`web-driver.ThreadPool`][thread-pool]オブジェクトを新しく作成します。

以下のオプションを指定できます。

* `options.size`: スレッドプールのサイズを数値で指定します。デフォルト値は、4です。
* `options.logger`: [`Logger`][logger]オブジェクトを指定します。
* `options.max_n_failures`: ジョブの失敗回数の最大を指定します。この回数までジョブを再試行します。デフォルト値は3です。
* `options.unique_job`: ジョブの重複を許すかどうかをブール値として指定します。デフォルト値はtrueです。
  * falseを指定した場合は、重複したジョブを登録できます。
* `options.finish_on_empty`: ジョブが空になった時スレッドを終了するかどうかを指定します。デフォルト値は、trueです。
  * falseを設定した場合は、ジョブが空になってもスレッドは終了しません。

## インスタンスメソッド

### `push(task) -> void` {#push}

`task`: 登録するジョブを指定します。

このメソッドは、ジョブをキューに登録します。例えば、登録するジョブにはクロールするWebサイトのURLを指定することをおすすめします。

登録したジョブは、以下のように[`web-driver.ThreadPool.new()`][thread-pool-new]の引数の`consumer`内で、`context.job`で参照できます。

例:

```lua
local web_driver = require("web-driver")
local log = require("log")

if #arg < 1 then
  print(string.format("Usage: %s URL [LOG_LEVEL] [N_THREADS]", arg[0]))
  os.exit(1)
end

print("LuaWebDriver: " .. web_driver.VERSION)

local url = arg[1]
local log_level = arg[2] or "notice"
local n_threads = arg[3]
if n_threads then
  n_threads = tonumber(n_threads)
end
if n_threads == nil or n_threads < 1 then
  n_threads = 2
end

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

### `join() -> void` {#join}

このメソッドは、スレッドを開始し、[`web-driver.ThreadPool.new()`][thread-pool-new]の引数の`consumer`を実行します。
このメソッドは、各スレッドの終了処理も実行します。

したがって、このメソッドは、全てのスレッドの実行が終了した時に戻ります。


[thread-pool]: thread-pool.html

[thread-pool-new]: thread-pool.html#new

[logger]: ../tutorial/#logger

[session-delete]: session.html#delete
