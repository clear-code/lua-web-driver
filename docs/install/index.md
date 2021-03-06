---
title: Install
---

# Install

This document how to install LuaWebDriver on the following platforms:

  * [CentOS](#centos)

  * [macOS](#macos)

## CentOS {#centos}

```console
% yum install -y gcc gcc-c++ firefox lua-devel luajit-devel luarocks make openssl-devel
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
