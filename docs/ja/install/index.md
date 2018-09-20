---
title: Install
---

# インストール

このドキュメントでは次のプラットフォーム上でLuaWebDriverをインストールする方法を説明します。

  * [CentOS](#centos)

  * [macOS](#macos)

LuaWebDriverをインストールする前に[geckodriver][geckodriver]と[LuaRocks][luarocks]をインストールしておいてください。

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
% curl -O http://luarocks.github.io/luarocks/releases/luarocks-{{ site.luarocks_version }}.tar.gz
% tar xf luarocks-{{ site.luarocks_version }}.tar.gz
% cd luarocks-{{ site.luarocks_version }}
% make build
% sudo make install

% curl -L -O https://github.com/mozilla/geckodriver/releases/download/v{{ site.geckodriver_version }}/geckodriver-v{{ site.geckodriver_version }}-macos.tar.gz
% tar xf geckodriver-v{{ site.geckodriver_version }}-macos.tar.gz -C /usr/local/bin
% chmod +x /usr/local/bin/geckodriver

% sudo luarocks install lua-web-driver
```

[geckodriver]:https://github.com/mozilla/geckodriver

[luarocks]:https://luarocks.org/
