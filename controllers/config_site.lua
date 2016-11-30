local config = require("lapis.config").get()
local i18n   = require "i18n"
local lfs    = require "lfs"

return function(self)
	-- Set basic information
	self.software  = "Lapis-chan"
	self.version   = "1.2.5"
	self.site_name = config.site_name
	self.text_size = _G.text_size

	-- Get localization files
	self.locales = {}
	for file in lfs.dir("locale") do
		local name, ext = string.match(file, "^(.+)(%..+)$")
		if ext == ".lua" then
			table.insert(self.locales, name)
		end
	end

	-- Set localization
	if self.params.locale then
		self.session.locale = self.params.locale
	end

	i18n.setLocale(self.session.locale or "en")
	i18n.loadFile("locale/en.lua")
	if i18n.getLocale() ~= "en" then
		i18n.loadFile("locale/" .. i18n.getLocale() .. ".lua")
	end
	self.i18n = i18n

	-- Static
	self.static_url  = "/static/%s"
	self.files_url   = "/static/%s/%s"
	self.styles_url  = "/static/styles/%s.css"
	self.scripts_url = "/static/scripts/%s.js"
	self.styles_dir  = "./static/styles"

	-- Private
	self.admin_url               = "/admin"
	self.admin_users_url         = "/admin/%s/user"
	self.admin_user_url          = "/admin/%s/user/%s"
	self.admin_boards_url        = "/admin/%s/board"
	self.admin_board_url         = "/admin/%s/board/%s"
	self.admin_announcements_url = "/admin/%s/announcement"
	self.admin_announcement_url  = "/admin/%s/announcement/%s"
	self.admin_pages_url         = "/admin/%s/page"
	self.admin_page_url          = "/admin/%s/page/%s"
	self.admin_reports_url       = "/admin/%s/report"
	self.admin_report_url        = "/admin/%s/report/%s"

	-- Public
	self.c404_url       = "/404"
	self.rules_url      = "/rules"
	self.faq_url        = "/faq"
	self.login_url      = "/login"
	self.logout_url     = "/logout"
	self.board_url      = "/board/%s"
	self.catalog_url    = "/board/%s/catalog"
	self.archive_url    = "/board/%s/archive"
	self.board_page_url = "/board/%s/%d"
	self.thread_url     = "/board/%s/thread/%d"
	self.post_url       = "/board/%s/thread/%d#p%d"
	self.reply_url      = "/board/%s/thread/%d#q%d"
	self.remix_url      = "/board/%s/thread/%d#r%d"
	self.page_url       = "/%s"

	function self:format_url(pattern, ...)
		return self:build_url(string.format(pattern, ...))
	end
end
