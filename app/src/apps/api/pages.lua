local lapis   = require "lapis"
local capture = require("lapis.application").capture_errors_json
local r2      = require("lapis.application").respond_to
local handle  = require("utils.error").handle
local app     = lapis.Application()
app.__base    = app
app.name      = "api.pages."
app.path      = "/api/pages"

app:match("pages", "",           capture({ on_error=handle, r2(require "apps.api.pages.pages") }))
app:match("page",  "/:uri_page", capture({ on_error=handle, r2(require "apps.api.pages.page")  }))

return app
