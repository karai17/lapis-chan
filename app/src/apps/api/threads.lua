local lapis   = require "lapis"
local capture = require("lapis.application").capture_errors_json
local r2      = require("lapis.application").respond_to
--local handle  = require("utils.error").handle
local app     = lapis.Application()
app.__base    = app
app.name      = "api.threads."
app.path      = "/api/threads"

local function handle() end -- FIXME: proper error handler

app:match("thread", "/:uri_id",                        capture({ on_error=handle, r2(require "apps.api.threads.thread")  }))
app:match("modify", "/:uri_id/:uri_action/:uri_value", capture({ on_error=handle, r2(require "apps.api.threads.modify")  }))
app:match("posts",  "/:uri_id/posts",                  capture({ on_error=handle, r2(require "apps.api.threads.posts")   }))

return app
