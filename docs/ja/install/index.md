---
title: Install
---

# インストール

このドキュメントでは次のプラットフォーム上でLuaWebDriverをインストールする方法を説明します。

  * [CentOS](#centos)

  * [macOS](#macos)

LuaWebDriverをインストールする前に、[geckodriver][geckodriver]と[luarocks][luarocks]をインストールしてください。

## CentOS {#centos}

```console
% yum install -y luarocks
% curl -L -O https://github.com/mozilla/geckodriver/releases/download/v{{ site.geckodriver_version }}/geckodriver-v{{ site.geckodriver_version }}-linux64.tar.gz
% tar xf geckodriver-v{{ site.geckodriver_version }}-linux64.tar.gz -C /usr/local/bin
% chmod +x /usr/local/bin/geckodriver
% sudo luarocks install lua-web-driver
```

## macOS {#macos}

```console
% brew install luarocks
% brew install geckodriver
% sudo luarocks install lua-web-driver
```

[geckodriver]:https://github.com/mozilla/geckodriver

[luarocks]:https://luarocks.org/
