---
title: Install
---

# インストール

このドキュメントでは次のプラットフォーム上でLuaWebDriverをインストールする方法を説明します。

  * [CentOS](#centos)

  * [macOS](#macos)

## CentOS {#centos}

```console
% yum install -y gcc gcc-c++ firefox lua-devel luajit-devel luarocks openssl-devel
% curl -L -O https://github.com/mozilla/geckodriver/releases/download/v{{ site.geckodriver_version }}/geckodriver-v{{ site.geckodriver_version }}-linux64.tar.gz
% tar xf geckodriver-v{{ site.geckodriver_version }}-linux64.tar.gz -C /usr/local/bin
% chmod +x /usr/local/bin/geckodriver
% sudo luarocks install web-driver
```

## macOS {#macos}

```console
% brew install luajit
% brew install luarocks
% brew install geckodriver
% sudo -H luarocks --tree=$(brew --prefix) --lua-dir=$(brew --prefix luajit) install web-driver CRYPTO_DIR=$(brew --prefix openssl) OPENSSL_DIR=$(brew --prefix openssl)
```
