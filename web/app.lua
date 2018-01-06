local lapis      = require "lapis"
local respond_to = require ("lapis.application").respond_to
local app        = lapis.Application()
app:enable("etlua")
app.layout = require "views.layout"

-- Installer
local _, install = pcall(require, "install")
if _ then
	local config_site = require "controllers.config_site"
	app:before_filter(config_site)
	app:match("/", respond_to(install))
	return app
end

-- Before
local config_site = require "controllers.config_site"
local check_auth  = require "controllers.check_auth"
local check_ban   = require "controllers.check_ban"

-- Private
local admin   = require "controllers.admin"
local admin_u = require "controllers.admin_user"
local admin_b = require "controllers.admin_board"
local admin_a = require "controllers.admin_announcement"
local admin_p = require "controllers.admin_page"
local admin_r = require "controllers.admin_report"

-- Public
local index    = require "controllers.index"
local rules    = require "controllers.rules"
local logout   = require "controllers.logout"
local code_404 = require "controllers.code_404"
local board    = require "controllers.board"
local catalog  = require "controllers.catalog"
local archive  = require "controllers.archive"
local thread   = require "controllers.thread"
local page     = require "controllers.page"

-- Handle
app.handle_404 = code_404

-- Before
app:before_filter(config_site)
app:before_filter(check_auth)
app:before_filter(check_ban)

-- Private
app:match("/admin",                           respond_to(admin))
app:match("/admin/:action/user",              respond_to(admin_u))
app:match("/admin/:action/user/:user",        respond_to(admin_u))
app:match("/admin/:action/board",             respond_to(admin_b))
app:match("/admin/:action/board/:board",      respond_to(admin_b))
app:match("/admin/:action/announcement",      respond_to(admin_a))
app:match("/admin/:action/announcement/:ann", respond_to(admin_a))
app:match("/admin/:action/page",              respond_to(admin_p))
app:match("/admin/:action/page/:page",        respond_to(admin_p))
app:match("/admin/:action/report",            respond_to(admin_r))
app:match("/admin/:action/report/:report",    respond_to(admin_r))

-- Public
app:match("/",                            index)
app:match("/404",                         code_404)
app:match("/rules",                       rules)
app:match("/logout",                      logout)
app:match("/board/:board",                respond_to(board))
app:match("/board/:board/catalog",        respond_to(catalog))
app:match("/board/:board/archive",        archive)
app:match("/board/:board/:page",          respond_to(board))
app:match("/board/:board/thread/:thread", respond_to(thread))
app:match("/:page",                       page)

return app
