local i18n = require "i18n"
local lfs  = require "lfs"

return function(self)

	-- Set locale
	self.i18n    = i18n
	local locale = self.req.headers["Content-Language"] or "en"
	i18n.setLocale(locale)
	i18n.loadFile("src/locale/en.lua")

	-- Get locale file
	local path = "src/locale"
	for file in lfs.dir(path) do
		local name, ext = string.match(file, "^(.+)%.(.+)$")
		if name == locale and ext == "lua" then
			i18n.loadFile(string.format("%s/%s.lua", path, name))
		end
	end
end
