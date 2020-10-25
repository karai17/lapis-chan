local lapis   = require "lapis"
local capture = require("lapis.application").capture_errors_json
local r2      = require("lapis.application").respond_to
--local handle  = require("utils.error").handle
local app     = lapis.Application()
app.__base    = app
app.name      = "api.boards."
app.path      = "/api/boards"

local function handle() end -- FIXME: proper error handler

app:match("boards",        "",                                     capture({ on_error=handle, r2(require "apps.api.boards.boards")        }))
app:match("board",         "/:uri_name",                           capture({ on_error=handle, r2(require "apps.api.boards.board")         }))
app:match("announcements", "/:uri_name/announcements",             capture({ on_error=handle, r2(require "apps.api.boards.announcements") }))
app:match("threads",       "/:uri_name/threads(/pages/:uri_page)", capture({ on_error=handle, r2(require "apps.api.boards.threads")       }))
app:match("archived",      "/:uri_name/threads/archived",          capture({ on_error=handle, r2(require "apps.api.boards.archived")      }))
app:match("posts",         "/:uri_name(/threads/:uri_id)/posts",   capture({ on_error=handle, r2(require "apps.api.boards.posts")         }))
app:match("post",          "/:uri_name/posts/:uri_id",             capture({ on_error=handle, r2(require "apps.api.boards.post")          }))
return app
