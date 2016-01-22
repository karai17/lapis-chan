local Boards = require "models.boards"

return function(self)
	-- Get all board data
	self.boards = Boards.get_boards()

	-- Page title
	self.page_title = "404 - Page not found"

	-- Base URL
	self.index_url  = self.index_url

	-- Display a theme
	self.board = { theme = "yotsuba_b" }

	return { render = "code_404", status = "404" }
end
