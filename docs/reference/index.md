---
title: Reference manual
---

# Reference manual

This document describes about all features. [Tutorial][tutorial] focuses on easy to understand only about important features. This document focuses on completeness. If you don't read [tutorial][tutorial] yet, read tutorial before read this document.

## Modules {#modules}

LuaWebDriver has only one public modules. It's `web-driver` main module.

  * [`web-driver`][web-driver]: The main module.

## Internal modules {#internal-modules}

LuaWebDriver has internal modules to provide common methods. They aren't exported into public API but you can use them via public classes such as [`web-driver.Element`][element] and [`web-driver.Session`][session].

  * [`web-driver.Searchable`][searchable]: Provides element search related methods.

## Classes {#classes}

LuaWebDriver provides the following classes:

  * [`web-driver.ElementSet`][elementset]: The class for multiple elements.

  * [`web-driver.Element`][element]: The class for handling web elements.

  * [`web-driver.Firefox`][firefox]: The class for WebDriver for Firefox.

  * [`web-driver.Session`][session]: The class for handling WebDriver's session.

  * [`web-driver.ThreadPool`][thread-pool]: The class for handling thread pool. When you use LuaWebDriver with multi-thread, you use this calss.

You can access only [`web-driver.Firefox`][firefox] directly. Other classes are accessible via methods of [`web-driver.Firefox`][firefox].


[tutorial]:../tutorial/

[web-driver]:web-driver.html

[element]:element.html

[session]:session.html

[searchable]:searchable.html

[thread-pool]:thread-pool.html

[elementset]:elementset.html

[firefox]:firefox.html
