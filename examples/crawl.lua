local web_driver = require("web-driver")
local log = require("log")

if #arg < 1 then
  print(string.format("Usage: %s URL [LOG_LEVEL] [N_THREADS]", arg[0]))
  os.exit(1)
end

print("LuaWebDriver: " .. web_driver.VERSION)

local url = arg[1]
local log_level = arg[2] or "notice"
local n_threads = arg[3]
if n_threads then
  n_threads = tonumber(n_threads)
end
if n_threads == nil or n_threads < 1 then
  n_threads = 2
end

local logger = log.new(log_level)
local function crawler(context)
  local logger = context.logger
  local session = context.session
  local url = context.job
  local prefix = url:match("^https?://[^/]+/")
  logger:debug("Opening...: " .. url)
  session:navigate_to(url)
  local status_code = session:status_code()
  if status_code and status_code ~= 200 then
    logger:notice(string.format("%s: Error: %d",
                                url,
                                status_code))
    return
  end
  logger:notice(string.format("%s: Title: %s",
                              url,
                              session:title()))
  local anchors = session:css_select("a")
  local anchor
  for _, anchor in pairs(anchors) do
    local href = anchor.href
    local normalized_href = href:gsub("#.*$", "")
    logger:notice(string.format("%s: Link: %s (%s): %s",
                                url,
                                href,
                                normalized_href,
                                anchor:text()))
    if normalized_href:sub(1, #prefix) == prefix then
      context.job_pusher:push(normalized_href)
    end
  end
end
local options = {
  logger = logger,
  size = n_threads,
}
local pool = web_driver.ThreadPool.new(crawler, options)
logger.debug("Start crawling: " .. url)
pool:push(url)
pool:join()
logger.debug("Done crawling: " .. url)
