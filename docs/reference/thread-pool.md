---
title: web-driver.ThreadPool
---

# `web-driver.ThreadPool` class

## Summary

It's a class for handling a thread pool.

This class make thread pool and a job queue and assign a job to thread.

## Class methods

### `web-driver.ThreadPool.new(consumer, options) -> web-driver.ThreadPool` {#new}

`consumer`: Specify a function to execute a job.

`options`: Specify thread pool options.

It create new [`web-driver.ThreadPool`][thread-pool] object.

You can specify options as below.

* `options.size`: Specify thread pool size as a number. The default value is 4.
* `options.logger`: Specify [`Logger`][logger] object.
* `options.max_n_failures`: Specify max number of job failures as a number. A job is retried until this number of times. The default value is 3.
* `options.unique_job`: Specify whether allow duplicate a job or not as a boolean. The default value is true.
  * If you set false, you can register duplicate job.
* `options.finish_on_empty`: Specify whether end thread or not when jobs are empty as a boolean. The default value is true.
  * If you set false, a thread doesn't end even when jobs are empty.

## Instance methods

### `push(task) -> void` {#push}

`task`: Specify a job to register.

This method register a job in a queue. For example, we recommend specifying URL of a website to crawl to a job to register.

You can reference registered a job wiht `context.job` in `consumer` of argument of [`web-driver.ThreadPool.new()`][thread-pool-new] as below.

Example:

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

This method start thread and execute `consumer` of argument of [`web-driver.ThreadPool.new()`][thread-pool-new].
This method executes also end processing of each thread.

So, this method returns when finished execute of all thread.


[thread-pool]: thread-pool.html

[thread-pool-new]: thread-pool.html#new

[logger]: ../tutorial/#logger

[session-delete]: session.html#delete
