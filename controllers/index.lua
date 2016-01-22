local Boards = require "models.boards"

return function(self)
	-- Get all board data
	self.boards = Boards.get_boards()

	-- Page title
	self.page_title = "Index"

	-- Display a theme
	self.board = { theme = "yotsuba_b" }

	return { render = "index" }
end
