#!/bin/bash

brew install geckodriver

LUAROCKS="sudo -H luarocks --tree=$(brew --prefix) --lua-dir=$(brew --prefix luajit)"
${LUAROCKS} install web-driver CRYPTO_DIR=$(brew --prefix openssl) OPENSSL_DIR=$(brew --prefix openssl)
