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
	self.page_title = i18n("rules")

	-- Display a theme
	self.board = { theme = "yotsuba_b" }

	for _, board in ipairs(self.boards) do
		board.url   = self.boards_url .. board.short_name .. "/"
		if board.rules then
			board.rules = markdown(board.rules)
		end
	end

	return { render = "rules" }
end
