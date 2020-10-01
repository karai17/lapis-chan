local lapis   = require "lapis"
local capture = require("lapis.application").capture_errors_json
local r2      = require("lapis.application").respond_to
--local handle  = require("utils.error").handle
local app     = lapis.Application()

local function handle() end -- FIXME: proper error handler

app.__base = app
app.name   = "api.boards."
app.path   = "/api/boards"

app:match("boards", "",                 capture({ on_error=handle, r2(require "apps.api.boards.boards") }))
app:match("board",  "/:uri_short_name", capture({ on_error=handle, r2(require "apps.api.boards.board")  }))

return app
