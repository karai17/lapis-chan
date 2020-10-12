local lapis    = require "lapis"
local r2       = require("lapis.application").respond_to
local app      = lapis.Application()
app.__base     = app
app.name       = "web.boards."
app.path       = "/board"
app.handle_404 = require "apps.web.internal.code_404"

app:match("board",   "/:uri_name(/page/:page)",                r2(require "apps.web.boards.board"))
app:match("catalog", "/:uri_name/catalog",                     r2(require "apps.web.boards.catalog"))
app:match("archive", "/:uri_name/archive",                     require "apps.web.boards.archive")
app:match("thread",  "/:uri_name/thread/:thread(#:anchor:id)", r2(require "apps.web.boards.thread"))

return app
