local lapis = require "lapis"
local r2    = require("lapis.application").respond_to
local app   = lapis.Application()

app.__base     = app
app.name       = "web.boards."
app.path       = "/board"
app.handle_404 = require "apps.web.global.code_404"

app:before_filter(require "apps.web.global.config_site")
app:before_filter(require "apps.web.global.check_auth")
app:before_filter(require "apps.web.global.check_ban")

app:match("board",   "/:uri_short_name(/page/:page)",                r2(require "apps.web.boards.board"))
app:match("catalog", "/:uri_short_name/catalog",                     r2(require "apps.web.boards.catalog"))
app:match("archive", "/:uri_short_name/archive",                     require "apps.web.boards.archive")
app:match("thread",  "/:uri_short_name/thread/:thread(#:anchor:id)", r2(require "apps.web.boards.thread"))

return app
