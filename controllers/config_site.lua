local config = require("lapis.config").get()
local i18n   = require "i18n"

return function(self)
	-- Set localization
	i18n.setLocale(self.session.locale or "en")
	i18n.loadFile("locale/" .. i18n.getLocale() .. ".lua")
	self.i18n = i18n

	self.software  = config.software
	self.version   = config.version
	self.site_name = config.site_name

	if config.subdomains then
		local host        = ngx.var.host
		local pattern     = "(%w-%.)(%w+%.%w+)"
		local sub, domain = host:match(pattern)

		if sub then
			self.index_url = domain .. "/"
		else
			self.index_url = host .. "/"
		end

		self.boards_url  = "//boards." .. self.index_url
		self.static_url  = "//static." .. self.index_url
	else
		self.index_url   = "/"
		self.boards_url  = self.index_url  .. "board/"
		self.static_url  = self.index_url  .. "static/"
	end

	self.c404_url    = self.index_url  .. "404"
	self.admin_url   = self.index_url  .. "admin/"
	self.login_url   = self.index_url  .. "login"
	self.logout_url  = self.index_url  .. "logout"
	self.styles_url  = self.static_url .. "styles/"
	self.scripts_url = self.static_url .. "scripts/"
end
