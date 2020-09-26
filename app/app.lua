local lapis = require "lapis"
local r2    = require("lapis.application").respond_to
local app   = lapis.Application()
app:enable("etlua")
app.layout = require "views.layout"

-- Installer
local _, install = pcall(require, "install")
if _ then
	local config_site = require "controllers.config_site"
	app:before_filter(config_site)
	app:match("/", r2(install))
	return app
end

-- Handle
app.handle_404 = require "controllers.code_404"

-- Before
app:before_filter(require "controllers.config_site")
app:before_filter(require "controllers.check_auth")
app:before_filter(require "controllers.check_ban")

-- Private
app:match("admin",               "/admin",                             r2(require "controllers.admin"))
app:match("admin_users",         "/admin/:action/user(/:user)",        r2(require "controllers.admin_user"))
app:match("admin_boards",        "/admin/:action/board(/:board)",      r2(require "controllers.admin_board"))
app:match("admin_announcements", "/admin/:action/announcement(/:ann)", r2(require "controllers.admin_announcement"))
app:match("admin_pages",         "/admin/:action/page(/:page)",        r2(require "controllers.admin_page"))
app:match("admin_reports",       "/admin/:action/report(/:report)",    r2(require "controllers.admin_report"))

-- Public
app:match("index",   "/",                                         require "controllers.index")
app:match("c404",    "/404",                                      require "controllers.code_404") -- FIXME: remove this route
app:match("rules",   "/rules",                                    require "controllers.rules")
app:match("faq",     "/faq",                                      require "controllers.rules") -- FIXME: need a faq page
app:match("logout",  "/logout",                                   require "controllers.logout")
app:match("page",    "/:page",                                    require "controllers.page")
app:match("board",   "/board/:board(/page/:page)",                r2(require "controllers.board"))
app:match("catalog", "/board/:board/catalog",                     r2(require "controllers.catalog"))
app:match("archive", "/board/:board/archive",                     require "controllers.archive")
app:match("thread",  "/board/:board/thread/:thread(#:anchor:id)", r2(require "controllers.thread"))

return app
