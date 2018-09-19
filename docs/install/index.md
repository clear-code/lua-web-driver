---
title: Install
---

# Install

This document how to install LuaWebDriver on the following platforms:

  * [CentOS](#centos)

You must install [geckodriver][geckodriver] and [LuaRocks][luarocks] before installing LuaWebDriver.

## CentOS {#centos}

```console
% yum install -y luarocks
% curl -L -O https://github.com/mozilla/geckodriver/releases/download/v${GECKODRIVER_VERSION}/geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz
% tar xf geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz -C /usr/local/bin
% chmod +x /usr/local/bin/geckodriver
% sudo luarocks install lua-web-driver
```

[geckodriver]:https://github.com/mozilla/geckodriver

[luarocks]:https://luarocks.org/
