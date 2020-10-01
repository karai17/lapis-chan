local ngx    = _G.ngx
local config = require("lapis.config").get()
local i18n   = require "i18n"
local lfs    = require "lfs"

return function(self)
	-- Set basic information
	self.software  = "Lapis-chan"
	self.version   = "1.2.5"
	self.site_name = config.site_name
	self.text_size = _G.text_size

	-- Prepare internal API
	self.api = {
		boards = require "apps.api.boards.boards",
		board  = require "apps.api.boards.board"
	}

	-- Get localization files
	self.locales = {}
	for file in lfs.dir("src/locale") do
		local name, ext = string.match(file, "^(.+)%.(.+)$")
		if ext == "lua" then
			table.insert(self.locales, name)
		end
	end

	-- Set localization
	if self.params.locale then
		self.session.locale = self.params.locale
	end

	i18n.setLocale(self.session.locale or "en")
	i18n.loadFile("src/locale/en.lua")
	if i18n.getLocale() ~= "en" then
		i18n.loadFile("locale/" .. i18n.getLocale() .. ".lua")
	end
	self.i18n = i18n

	-- Get all boards
	local response = self.api.boards.GET(self)
	self.boards = response.json

	local res = ngx.location.capture(self:url_for("api.boards.boards"))
	--print(res.status)

	-- Static
	self.static_url = "/static/%s"
	self.files_url  = "/files/%s/%s"

	function self:format_url(pattern, ...)
		return self:build_url(string.format(pattern, ...))
	end
end
