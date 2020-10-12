local assert_error = require("lapis.application").assert_error
local csrf         = require "lapis.csrf"
local lfs          = require "lfs"
local capture      = require "utils.capture"
local generate     = require "utils.generate"

return {
	before = function(self)

		-- Display a theme
		self.board = { theme = "yotsuba_b" }

		-- Generate CSRF token
		self.csrf_token = csrf.generate_token(self)

		-- Page title
		self.page_title = self.i18n("admin_panel")

		-- Verify Authorization
		if not self.session.name then return end
		if not self.session.admin then
			assert_error(false, "err_not_admin")
		end

		-- Get list of themes
		self.themes = {}
		for file in lfs.dir("./static/css") do
			local name, ext = string.match(file, "^(.+)%.(.+)$")
			if name ~= "reset"  and
				name ~= "posts"  and
				name ~= "style"  and
				name ~= "tegaki" and
				ext  == "css"    then
				table.insert(self.themes, name)
			end
		end

		-- Display creation form
		if self.params.action == "create" then
			self.page_title = string.format(
				"%s - %s",
				self.i18n("admin_panel"),
				self.i18n("create_board")
			)
			self.board = self.params

			if not self.board.theme then
				self.board.theme = "yotsuba_b"
			end

			return
		end

		-- Display modification form
		if self.params.action == "modify" then
			self.board = assert_error(capture.get(self:url_for("api.boards.board", { uri_name=self.params.uri_name })))
			self.page_title = string.format(
				"%s - %s",
				self.i18n("admin_panel"),
				self.i18n("modify_board")
			)
			return
		end

		-- Delete board
		if self.params.action == "delete" then
			local board = assert_error(capture.delete(self:url_for("api.boards.board", { uri_name=self.params.uri_name })))
			self.page_title = string.format(
				"%s - %s",
				self.i18n("admin_panel"),
				self.i18n("success")
			)
			self.action = self.i18n("deleted_board", { board.name, board.title })
			return
		end
	end,

	on_error = function(self)
		self.errors = generate.errors(self.i18n, self.errors)

		if not self.session.name then
			return { render = "admin.login" }
		elseif self.params.action == "create" then
			return { render = "admin.board" }
		elseif self.params.action == "modify" then
			return { render = "admin.board" }
		elseif self.params.action == "delete" then
			return { render = "admin.admin" }
		end
	end,

	GET = function(self)
		if not self.session.name then
			return { render = "admin.login" }
		elseif self.params.action == "create" then
			return { render = "admin.board" }
		elseif self.params.action == "modify" then
			return { render = "admin.board" }
		elseif self.params.action == "delete" then
			return { render = "admin.success" }
		end
	end,

	POST = function(self)
		-- Validate CSRF token
		csrf.assert_token(self)

		-- Create new board
		if self.params.create_board then
			local board = assert_error(capture.post(self:url_for("api.boards.boards"), self.params))
			self.page_title = string.format(
				"%s - %s",
				self.i18n("admin_panel"),
				self.i18n("success")
			)
			self.action = self.i18n("created_board", { board.name, board.title })

			return { render = "admin.success" }
		end

		-- Modify board
		if self.params.modify_board then
			local board = assert_error(capture.put(self:url_for("api.boards.board", { uri_name=self.params.uri_name }), self.params))
			self.page_title = string.format(
				"%s - %s",
				self.i18n("admin_panel"),
				self.i18n("success")
			)
			self.action = self.i18n("modified_board", { board.name, board.title })

			return { render = "admin.success" }
		end

		return { redirect_to = self:url_for("web.admin.index") }
	end
}
