---
title: News
---

# News

## 0.1.0: 2018-10-25 {#version-0-1-0}

### Fixes

  * Fixed a bug that `start_timeout` is ignored.

## 0.0.9: 2018-10-24 {#version-0-0-9}

### Fixes

  * Fixed a bug that missing a need file in a package.

## 0.0.8: 2018-10-23 {#version-0-0-8}

### Fixes

  * Fixed a bug again that multi-thread doesn't work on macOS.

## 0.0.7: 2018-10-23 {#version-0-0-7}

### Improvements

  * Supported action:
    * [`web-driver.Session:perform_actions()`][session-perform-actions] Added.
    * [`web-driver.Session:release_actions()`][session-release-actions] Added.
  * [`web-driver.Session:status_code()`][session-status-code] Added.

### Fixes

  * Fixed a bug that multi-thread doesn't work on macOS.

## 0.0.6: 2018-10-19 {#version-0-0-6}

### Improvements

  * Modify return value of below methods.
    * [`web-driver.Element:click()`][element-click]
    * [`web-driver.Element:clear()`][element-clear]
    * [`web-driver.Session:back()`][session-back]
    * [`web-driver.Session:forward()`][session-forward]
    * [`web-driver.Session:refresh()`][session-refresh]
    * [`web-driver.Session:close_window()`][session-close-window]
    * [`web-driver.Session:switch_to_window()`][session-switch-to-window]
    * [`web-driver.Session:fullscreen_window()`][session-fullscreen-window]
    * [`web-driver.Session:set_window_rect()`][session-set-window-rect]
    * [`web-driver.Session:switch_to_frame()`][session-switch-to-frame]
    * [`web-driver.Session:switch_to_parent_frame()`][session-switch-to-parent-frame]
    * [`web-driver.Session:add_cookie()`][session-add-cookie]
    * [`web-driver.Session:delete_cookie()`][session-delete-cookie]
    * [`web-driver.Session:delete_all_cookie()`][session-delete-all-cookie]
    * [`web-driver.Session:dismiss_alert()`][session-dismiss-alert]
    * [`web-driver.Session:accept_alert()`][session-accept-alert]
    * [`web-driver.Session:set_alert_text()`][session-set-alert-text]

  * `Web-driver.Session:execute_script_async()`: deleted.
    * Because unified [`web-driver.Session:execute_script()`][session-execute-script] and `web-driver.Session:execute_script_async()`.

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

[element-click]: ../reference/element.html#click

[element-clear]: ../reference/element.html#clear

[session-back]: ../reference/session.html#back

[session-forward]: ../reference/session.html#forward

[session-refresh]: ../reference/session.html#refresh

[session-close-window]: ../reference/session.html#close-window

[session-switch-to-window]: ../reference/session.html#switch-to-window

[session-fullscreen-window]: ../reference/session.html#fullscreen-window

[session-set-window-rect]: ../reference/session.html#set-window-rect

[session-switch-to-frame]: ../reference/session.html#switch-to-frame

[session-switch-to-parent-frame]: ../reference/session.html#switch-to-parent-frame

[session-add-cookie]: ../reference/session.html#add-cookie

[session-delete-cookie]: ../reference/session.html#delete-cookie

[session-delete-all-cookie]: ../reference/session.html#delete-all-cookie

[session-dismiss-alert]: ../reference/session.html#dismiss-alert

[session-accept-alert]: ../reference/session.html#accept-alert

[session-set-alert-text]: ../reference/session.html#set-alert-text

[session-execute-script]: ../reference/session.html#execute-script

[session-content-type]: ../reference/session.html#content-type

[session-perform-actions]: ../reference/session.html#perform-actions

[session-release-actions]: ../reference/session.html#release-actions

[session-status-code]: ../reference/session.html#status-code

[elementset-send_keys]: ../reference/elementset.html#send-keys

[elementset-click]: ../reference/elementset.html#click

[elementset-texts]: ../reference/elementset.html#texts

[elementset]: ../reference/elementset.html

[searchable]: ../reference/searchable.html
