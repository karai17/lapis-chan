local Boards     = require "models.boards"
local Pages      = require "models.pages"
local prep_error = require "utils.prep_error"
local csrf       = require "lapis.csrf"

return {
	before = function(self)
		-- Get all board data
		self.boards = Boards.get_boards()

		-- Get all page data
		self.pages = Pages.get_pages()
	end,
	GET = function(self)
		-- Generate CSRF token
		self.csrf_token = csrf.generate_token(self)

		-- Page title
		self.page_title = "Admin Panel"

		-- Verify Authorization
		if self.session.name then
			if not self.session.admin then
				return prep_error(self, "You are not an admin.")
			end
		else
			return { render = "admin.login" }
		end

		-- Display creation form
		if self.params.action == "create" then
			self.page_title = "Admin Panel - Create Page"
			return { render = "admin.create_page" }
		end

		-- Display modification form
		if self.params.action == "modify" then
			self.page_title = "Admin Panel - Modify Page"
			self.page = Pages.get_page(self.params.page)
			return { render = "admin.modify_page" }
		end

		-- Delete page
		if self.params.action == "delete" then
			local page = Pages.get_page(self.params.page)

			-- Delete page
			local _, err = Pages.delete_page(page)
			if err then return prep_error(self, err[1]) end

			self.action = string.format(
				"deleted page: %s - %s",
				page.url,
				page.name
			)
			self.page_title = "Admin Panel - Success"

			return { render = "admin.success" }
		end

		-- Invalid action, gtfo
		return { redirect_to = self.admin_url }
	end,
	POST = function(self)
		-- Page title
		self.page_title = "Admin Panel"

		-- Validate CSRF token
		local _, err = csrf.validate_token(self)

		-- Invalid token
		if err then return prep_error(self, err) end

		-- Must be logged in as an admin!
		if self.session.admin then
			-- Create new page
			if self.params.create_page then
				local sl = string.lower
				-- Verify unique names
				for _, page in ipairs(self.pages) do
					if sl(page.url) == sl(self.params.url) then
						prep_error(self, "Page URL already in use.")
					end
				end

				-- Create page
				local page, err = Pages.create_page(self.params)
				if err then return prep_error(self, err) end

				self.action = string.format(
					"created page: %s - %s",
					page.url,
					page.name
				)

				return { render = "admin.success" }
			end

			-- Modify page
			if self.params.modify_page then
				local page = Pages.get_page(self.params.old)

				for k, param in pairs(self.params) do
					if page[k] then
						page[k] = param
					end
				end

				-- Modify page
				local _, err = Pages.modify_page(page)
				if err then return prep_error(self, err) end

				self.action = string.format(
					"modified page: %s = %s",
					page.url,
					page.name
				)

				return { render = "admin.success" }
			end

			return { redirect_to = self.admin_url }
		end

		return { render = "admin.login" }
	end
}
