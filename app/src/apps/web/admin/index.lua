local assert_error  = require("lapis.application").assert_error
local csrf          = require "lapis.csrf"
local generate      = require "utils.generate"
local Announcements = require "models.announcements"
local Boards        = require "models.boards"
local Pages         = require "models.pages"
local Posts         = require "models.posts"
local Reports       = require "models.reports"
local Users         = require "models.users"

return {
	before = function(self)
		-- Get data
		self.announcements = Announcements:get_announcements()
		self.pages         = Pages:get_pages()
		self.reports       = Reports:get_reports()
		self.users         = Users:get_users()

		-- Display a theme
		self.board = { theme = "yotsuba_b" }

		-- Page title
		self.page_title = self.i18n("admin_panel")

		-- Generate CSRF token
		self.csrf_token = csrf.generate_token(self)

		-- Verify Authorization
		if self.session.name then
			if not self.session.admin then
				assert_error(false, "err_not_admin")
			end
		else
			return
		end
	end,
	on_error = function(self)
		self.errors = generate.errors(self.i18n, self.errors)

		if not self.session.name then
			return { render = "admin.login" }
		end

		return { render = "admin.admin" }
	end,
	GET = function(self)
		if not self.session.name then
			return { render = "admin.login" }
		end

		return { render = "admin.admin" }
	end,
	POST = function(self)
		-- Validate CSRF token
		csrf.assert_token(self)

		-- Verify user credentials
		if self.params.login then
			-- Verify user
			local user = assert_error(Users:verify_user(self.params))

			-- Set username
			self.session.name = user.username

			return { redirect_to = self.admin_url }
		end

		-- Must be logged in as an admin!
		if self.session.admin then
			-- Redirect to modify user page
			if self.params.modify_user then
				return { redirect_to = self:url_for("web.admin.users", { action="modify", user=self.params.user }) }
			end

			-- Redirect to delete user page
			if self.params.delete_user then
				return { redirect_to = self:url_for("web.admin.users", { action="delete", user=self.params.user }) }
			end

			-- Redirect to modify board page
			if self.params.modify_board then
				return { redirect_to = self:url_for("web.admin.boards", { action="modify", uri_short_name=self.params.board }) }
			end

			-- Redirect to delete board page
			if self.params.delete_board then
				return { redirect_to = self:url_for("web.admin.boards", { action="delete", uri_short_name=self.params.board }) }
			end

			-- Redirect to modify announcement page
			if self.params.modify_announcement then
				return { redirect_to = self:url_for("web.admin.announcements", { action="modify", ann=self.params.ann }) }
			end

			-- Redirect to delete announcement page
			if self.params.delete_announcement then
				return { redirect_to = self:url_for("web.admin.announcements", { action="delete", ann=self.params.ann }) }
			end

			-- Redirect to modify page page
			if self.params.modify_page then
				return { redirect_to = self:url_for("web.admin.pages", { action="modify", page=self.params.page }) }
			end

			-- Redirect to delete page page
			if self.params.delete_page then
				return { redirect_to = self:url_for("web.admin.pages", { action="delete", page=self.params.page }) }
			end

			-- Redirect to reported post
			if self.params.view_report then
				local report = Reports:get_report_by_id(self.params.report)
				local board  = Boards:get_board(report.board_id)
				local post   = Posts:get_post(board.id, report.post_id)
				local op     = Posts:get_thread_op(report.thread_id)

				return { redirect_to = self:url_for("web.boards.thread", { board=board.short_name, thread=op.post_id, anchor="p", id=post.post_id }) }
			end

			-- Redirect to delete report page
			if self.params.delete_report then
				return { redirect_to = self:url_for("web.admin.reports", { action="delete", report=self.params.report }) }
			end

			-- Regenerate thumbnails
			if self.params.regen_thumbs then
				Boards:regen_thumbs()
			end

			return { render = "admin.admin" }
		end

		return { render = "admin.login" }
	end
}
