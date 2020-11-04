local lapis   = require "lapis"
local capture = require("lapis.application").capture_errors_json
local r2      = require("lapis.application").respond_to
local handle  = require("utils.error").handle
local app     = lapis.Application()
app.__base    = app
app.name      = "api.bans."
app.path      = "/api/bans"

app:match("bans",    "",            capture({ on_error=handle, r2(require "apps.api.bans.bans")    }))
app:match("ban",     "/:uri_ban",   capture({ on_error=handle, r2(require "apps.api.bans.ban")     }))
app:match("bans_ip", "/ip/:uri_ip", capture({ on_error=handle, r2(require "apps.api.bans.bans_ip") }))

return app
