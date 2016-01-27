local Boards = require "models.boards"

return function(self)
	-- Get all board data
	self.boards = Boards:get_boards()

	-- Page title
	self.page_title = self.i18n("404")

	-- Display a theme
	self.board = { theme = "yotsuba_b" }

	return { render = "code_404", status = "404" }
end
