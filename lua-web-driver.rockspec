-- -*- lua -*-

local package_version = "0.0.1"

package = "lua-web-driver"
version = package_version .. "-0"
source = {
  url = "*** please add URL for source tarball, zip or repository here ***"
}
description = {
  summary = "",
  detailed = "",
  homepage = "https://gitlab.com/clear-code/lua-web-driver",
  license = "MIT"
  -- Since 3.0
  -- labels = {"webdriver"},
}
dependencies = {
  "lua-requests",
  "process"
}
build = {
  type = "builtin",
  modules = {},
  copy_directories = {}
}
