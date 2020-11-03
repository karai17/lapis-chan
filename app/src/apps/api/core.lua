local lapis   = require "lapis"
local capture = require("lapis.application").capture_errors_json
local r2      = require("lapis.application").respond_to
--local handle  = require("utils.error").handle
local app     = lapis.Application()
app.__base    = app
app.name      = "api.core."
app.path      = "/api"

local function handle() end -- FIXME: proper error handler

app:match("root",  "",       capture({ on_error=handle, r2(require "apps.api.core.root")  }))
app:match("login", "/login", capture({ on_error=handle, r2(require "apps.api.core.login") }))

return app
