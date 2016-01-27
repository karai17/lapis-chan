local Boards   = require "models.boards"
local Pages    = require "models.pages"
local markdown = require "markdown"

return function(self)
	-- Get all board data
	self.boards = Boards:get_boards()

	-- Get page
	self.page = Pages:get_page(self.params.page)

	if not self.page then
		self:write({ redirect_to = self.c404_url })
		return
	end

	-- Page title
	self.page_title = self.page.name

	-- Markdown
	if self.page.content then
		self.page.content = markdown(self.page.content)
	end

	-- Display a theme
	self.board = { theme = "yotsuba_b" }

	return { render = "page" }
end
