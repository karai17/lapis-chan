local lapis = require "lapis"
local r2    = require("lapis.application").respond_to
local app   = lapis.Application()

app.__base     = app
app.name       = "web.boards."
app.path       = "/board"
app.handle_404 = require "apps.web.global.code_404"

app:match("board",   "/:board(/page/:page)",                r2(require "apps.web.boards.board"))
app:match("catalog", "/:board/catalog",                     r2(require "apps.web.boards.catalog"))
app:match("archive", "/:board/archive",                     require "apps.web.boards.archive")
app:match("thread",  "/:board/thread/:thread(#:anchor:id)", r2(require "apps.web.boards.thread"))

return app
