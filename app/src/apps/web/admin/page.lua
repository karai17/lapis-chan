local assert_error = require("lapis.application").assert_error
local assert_valid = require("lapis.validate").assert_valid
local csrf         = require "lapis.csrf"
local generate     = require "utils.generate"
local Boards       = require "models.boards"
local Pages        = require "models.pages"

return {
	before = function(self)
		-- Get all board data
		self.boards = Boards:get_boards()

		-- Get all page data
		self.pages = Pages:get_pages()

		-- Display a theme
		self.board = { theme = "yotsuba_b" }

		-- Generate CSRF token
		self.csrf_token = csrf.generate_token(self)

		-- Page title
		self.page_title = self.i18n("admin_panel")

		-- Verify Authorization
		if self.session.name then
			if not self.session.admin then
				assert_error(false, "err_not_admin")
			end
		else
			return
		end

		-- Display creation form
		if self.params.action == "create" then
			self.page_title = string.format(
				"%s - %s",
				self.i18n("admin_panel"),
				self.i18n("create_page")
			)
			self.page = self.params
			return
		end

		-- Display modification form
		if self.params.action == "modify" then
			self.page_title = string.format(
				"%s - %s",
				self.i18n("admin_panel"),
				self.i18n("modify_page")
			)
			self.page = Pages:get_page(self.params.page)
			return
		end

		-- Delete page
		if self.params.action == "delete" then
			local page = Pages:get_page(self.params.page)
			assert_error(Pages:delete_page(page))

			self.page_title = string.format(
				"%s - %s",
				self.i18n("admin_panel"),
				self.i18n("success")
			)
			self.action = self.i18n("deleted_page", { page.slug, page.title })
			return
		end
	end,
	on_error = function(self)
		self.errors = generate.errors(self.i18n, self.errors)

		if not self.session.name then
			return { render = "admin.login" }
		elseif self.params.action == "create" then
			return { render = "admin.page" }
		elseif self.params.action == "modify" then
			return { render = "admin.page" }
		elseif self.params.action == "delete" then
			return { render = "admin.admin" }
		end
	end,
	GET = function(self)
		if not self.session.name then
			return { render = "admin.login" }
		elseif self.params.action == "create" then
			return { render = "admin.page" }
		elseif self.params.action == "modify" then
			return { render = "admin.page" }
		elseif self.params.action == "delete" then
			return { render = "admin.success" }
		end
	end,
	POST = function(self)
		-- Validate CSRF token
		csrf.assert_token(self)

		-- Validate user input
		assert_valid(self.params, {
			{ "slug",  max_length=255, exists=true },
			{ "title", max_length=255, exists=true }
		})

		-- Create new page
		if self.params.create_page then
			local sl = string.lower
			-- Verify unique names
			for _, page in ipairs(self.pages) do
				if sl(page.slug) == sl(self.params.slug) then
					assert_error(false, "err_slug_used")
				end
			end

			-- Create page
			local page = assert_error(Pages:create_page(self.params))

			self.page_title = string.format(
				"%s - %s",
				self.i18n("admin_panel"),
				self.i18n("success")
			)
			self.action = self.i18n("created_page", { page.slug, page.title })

			return { render = "admin.success" }
		end

		-- Modify page
		if self.params.modify_page then
			local discard = {
				"page",
				"modify_page",
				"ip",
				"action",
				"csrf_token",
				"old"
			}

			local page = Pages:get_page(self.params.old)

			-- Fill in board with new data
			for k, param in pairs(self.params) do
				page[k] = param
			end

			-- Get rid of form trash
			for _, param in ipairs(discard) do
				page[param] = nil
			end

			assert_error(Pages:modify_page(page))

			self.page_title = string.format(
				"%s - %s",
				self.i18n("admin_panel"),
				self.i18n("success")
			)
			self.action = self.i18n("modified_page", { page.slug, page.title })

			return { render = "admin.success" }
		end

		return { redirect_to = self:url_for("web.admin.index") }
	end
}
