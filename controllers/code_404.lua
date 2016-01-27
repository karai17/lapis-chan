local Boards = require "models.boards"
local i18n   = require "i18n"

return function(self)
	-- Set localization
	i18n.setLocale(self.session.locale or "en")
	i18n.loadFile("locale/" .. i18n.getLocale() .. ".lua")
	self.i18n = i18n

	-- Get all board data
	self.boards = Boards:get_boards()

	-- Page title
	self.page_title = i18n("404")

	-- Display a theme
	self.board = { theme = "yotsuba_b" }

	return { render = "code_404", status = "404" }
end
