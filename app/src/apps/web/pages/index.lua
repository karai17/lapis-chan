return function(self)

	-- Page title
	self.page_title = self.i18n("index")

	-- Display a theme
	self.board = { theme = "yotsuba_b" }

	return { render = "index" }
end
