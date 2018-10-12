local web_driver = require("web-driver")
local log = require("log")

if #arg < 1 then
  print(string.format("Usage: %s URL [LOG_LEVEL]", arg[0]))
  os.exit(1)
end

local url = arg[1]
local log_level = arg[2] or "notice"

local logger = log.new(log_level)
local function crawler(context)
  local web_driver = require("web-driver")
  local logger = context.logger
  local options = {
    port = 4444 + context.id,
    logger = logger,
  }
  local driver = web_driver.Firefox.new(options)
  local url = context.job
  logger:debug("Opening...: " .. url)
  driver:start_session(function(session)
    session:navigate_to(url)
    logger:notice(string.format("%s: Title: %s",
                                url,
                                session:title()))
    local anchors = session:css_select("a")
    local anchor
    for _, anchor in pairs(anchors) do
      local href = anchor.href
      logger:notice(string.format("%s: Link: %s: %s",
                                  url,
                                  href,
                                  anchor:text()))
      -- context.job_pusher:push(href)
    end
  end)
end
local pool = web_driver.Pool.new(crawler, {logger = logger})
logger.debug("Start crawling: " .. url)
pool:push(url)
pool:join()
logger.debug("Done crawling: " .. url)
