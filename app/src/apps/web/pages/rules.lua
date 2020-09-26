local Boards = require "models.boards"

return function(self)
	-- Get all board data
	self.boards = Boards:get_boards()

	-- Page title
	self.page_title = self.i18n("rules")

	-- Display a theme
	self.board = { theme = "yotsuba_b" }

	for _, board in ipairs(self.boards) do
		board.url = self:url_for("web.boards.board", { board=board.short_name })
		if board.rules then
			board.rules = _G.markdown(board.rules)
		else
			board.rules = ""
		end
	end

	return { render = "rules" }
end
