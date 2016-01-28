local config = require("lapis.config").get()
local i18n   = require "i18n"
local lfs    = require "lfs"

return function(self)
	-- Set basic information
	self.software  = "Lapis-chan"
	self.version   = "1.1.1"
	self.site_name = config.site_name
	self.text_size = text_size

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
	i18n.loadFile("locale/" .. i18n.getLocale() .. ".lua")
	self.i18n = i18n

	-- Set base URLs
	if config.subdomains then
		local host        = ngx.var.host
		local pattern     = "(%w-%.)(%w+%.%w+)"
		local sub, domain = host:match(pattern)

		if sub then
			self.index_url = domain .. "/"
		else
			self.index_url = host .. "/"
		end

		self.boards_url = "//boards." .. self.index_url
		self.static_url = "//static." .. self.index_url
	else
		self.index_url  = "/"
		self.boards_url = self.index_url  .. "board/"
		self.static_url = self.index_url  .. "static/"
	end

	self.c404_url    = self.index_url  .. "404/"
	self.admin_url   = self.index_url  .. "admin/"
	self.login_url   = self.index_url  .. "login/"
	self.logout_url  = self.index_url  .. "logout/"
	self.styles_url  = self.static_url .. "styles/"
	self.scripts_url = self.static_url .. "scripts/"
end
