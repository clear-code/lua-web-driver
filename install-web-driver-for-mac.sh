#!/bin/bash

GECKODRIVER_VERSION="0.22.0"
curl -L -O https://github.com/mozilla/geckodriver/releases/download/v${GECKODRIVER_VERSION}/geckodriver-v${GECKODRIVER_VERSION}-macos.tar.gz
tar xf geckodriver-v${GECKODRIVER_VERSION}-macos.tar.gz -C /usr/local/bin
chmod +x /usr/local/bin/geckodriver

LUAROCKS="sudo -H luarocks --tree=$(brew --prefix) --lua-dir=$(brew --prefix luajit)"
${LUAROCKS} install web-driver CRYPTO_DIR=$(brew --prefix openssl) OPENSSL_DIR=$(brew --prefix openssl)
