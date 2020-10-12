local lapis    = require "lapis"
local r2       = require("lapis.application").respond_to
local app      = lapis.Application()
app.__base     = app
app.name       = "web.admin."
app.path       = "/admin"
app.handle_404 = require "apps.web.internal.code_404"

app:match("index",         "",                             r2(require "apps.web.admin.index"))
app:match("users",         "/:action/user(/:user)",        r2(require "apps.web.admin.user"))
app:match("boards",        "/:action/board(/:uri_name)",      r2(require "apps.web.admin.board"))
app:match("announcements", "/:action/announcement(/:ann)", r2(require "apps.web.admin.announcement"))
app:match("pages",         "/:action/page(/:page)",        r2(require "apps.web.admin.page"))
app:match("reports",       "/:action/report(/:report)",    r2(require "apps.web.admin.report"))

return app
