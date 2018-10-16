local luaunit = require("luaunit")
local Firefox = require("web-driver/firefox")

TestFirefox = {}

function TestFirefox:test_default_options()
  local firefox = Firefox.new()
  luaunit.assert_equals(firefox.client.base_url, "http://127.0.0.1:4444/")
end

function TestFirefox:test_set_both_request_timeout_options()
  local firefox = Firefox.new({
                                get_request_timeout = 11,
                                post_request_timeout = 12,
                                delete_request_timeout = 13,
                                http_request_timeout = 20,
                              })
  luaunit.assert_equals({
                          firefox.client.get_request_timeout,
                          firefox.client.post_request_timeout,
                          firefox.client.delete_request_timeout,
                        },
                        {
                          11,
                          12,
                          13,
                        })
end

function TestFirefox:test_set_only_http_request_timeout_option()
  local firefox = Firefox.new({
                                http_request_timeout = 20,
                              })
  luaunit.assert_equals({
                          firefox.client.get_request_timeout,
                          firefox.client.post_request_timeout,
                          firefox.client.delete_request_timeout,
                        },
                        {
                          20,
                          20,
                          20,
                        })
end

function TestFirefox:test_set_only_each_request_timeout_option()
  local firefox = Firefox.new({
                                get_request_timeout = 11,
                                post_request_timeout = 12,
                                delete_request_timeout = 13,
                              })
  luaunit.assert_equals({
                          firefox.client.get_request_timeout,
                          firefox.client.post_request_timeout,
                          firefox.client.delete_request_timeout,
                        },
                        {
                          11,
                          12,
                          13,
                        })
end

function TestFirefox:test_not_set_request_timeout_options()
  local firefox = Firefox.new()
  luaunit.assert_equals({
                          firefox.client.get_request_timeout,
                          firefox.client.post_request_timeout,
                          firefox.client.delete_request_timeout,
                        },
                        {
                          60,
                          60,
                          60,
                        })
end
