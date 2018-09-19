---
title: Install
---

# インストール

このドキュメントでは次のプラットフォーム上でLuaWebDriverをインストールする方法を説明します。

  * [CentOS](#centos)

LuaWebDriverをインストールする前に[geckodriver][geckodriver]と[LuaRocks][luarocks]をインストールしておいてください。

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
