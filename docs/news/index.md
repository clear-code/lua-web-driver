---
title: News
---

# News

## 0.0.5: 2018-10-18 {#version-0-0-5}

### Improvements

  * Supported multithread.
    * [`web-driver.ThreadPool`][thread-pool]: Added.

  * [`Web-driver.Session:content_type()`][session-content-type]: Added.

  * Used http and lunajson module instead of lua-requests
    * Because lua-requests and cqueues are conflicted.

## 0.0.4: 2018-10-16 {#version-0-0-4}

### Improvements

  * Modified all default timeout to 60s

### Fixes

  * Fixed a bug that set a wrong timeout of GET, POST and DELETE request.

## 0.0.3: 2018-10-16 {#version-0-0-3}

### Improvements

  * Supported for changeing request(POST, GET and DELETE) timeout by options and environment variable.

  * Supported logger.

  * Added install script for macOS.

  * Updated geckodriver version(0.23.0).

### Fixes

  * Fixed install document.

## 0.0.2: 2018-10-02 {#version-0-0-2}

### Improvements

  * Added sample codes.

  * Added tutorials.

  * [`web-driver.ElementSet:send_keys()`][elementset-send_keys]: Added.

  * [`web-driver.ElementSet:click()`][elementset-click]: Added.

  * [`web-driver.ElementSet:texts()`][elementset-texts]: Added.

  * [`web-driver.ElementSet`][elementset]: Added.

  * [`web-driver.Searchable`][searchable]: Added.

## 0.0.1: 2018-09-26 {#version-0-0-1}

The first release!!!


[thread-pool]: ../reference/thread-pool.html

[session-content-type]: ../reference/session.html#content-type

[elementset-send_keys]: ../reference/elementset.html#send-keys

[elementset-click]: ../reference/elementset.html#click

[elementset-texts]: ../reference/elementset.html#texts

[elementset]: ../reference/elementset.html

[searchable]: ../reference/searchable.html
