local lapis   = require "lapis"
local capture = require("lapis.application").capture_errors_json
local r2      = require("lapis.application").respond_to
local handle  = require("utils.error").handle
local app     = lapis.Application()
app.__base    = app
app.name      = "api.announcements."
app.path      = "/api/announcements"

app:match("announcements", "",                   capture({ on_error=handle, r2(require "apps.api.announcements.announcements") }))
app:match("announcement",  "/:uri_announcement", capture({ on_error=handle, r2(require "apps.api.announcements.announcement")  }))
app:match("global",        "/global",            capture({ on_error=handle, r2(require "apps.api.announcements.global")        }))

return app
