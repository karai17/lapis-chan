local lapis   = require "lapis"
local capture = require("lapis.application").capture_errors_json
local r2      = require("lapis.application").respond_to
--local handle  = require("utils.error").handle
local app     = lapis.Application()
app.__base    = app
app.name      = "api.posts."
app.path      = "/api/posts"

local function handle() end -- FIXME: proper error handler

app:match("post", "/:uri_id", capture({ on_error=handle, r2(require "apps.api.posts.post") }))

return app
