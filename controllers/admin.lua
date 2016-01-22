local Users         = require "models.users"
local Boards        = require "models.boards"
local Posts         = require "models.posts"
local Announcements = require "models.announcements"
local Pages         = require "models.pages"
local Reports       = require "models.reports"
local prep_error    = require "utils.prep_error"
local csrf          = require "lapis.csrf"

return {
	before = function(self)
		-- Get all user data
		self.users = Users.get_users()

		-- Get all board data
		self.boards = Boards.get_boards()

		-- Get all annoucement data
		self.announcements = Announcements.get_announcements()

		-- Get all page data
		self.pages = Pages.get_pages()

		-- Get all report data
		self.reports = Reports.get_reports()

		-- Display a theme
		self.board = { theme = "yotsuba_b" }

		-- Page title
		self.page_title = "Admin Panel"

		-- Create urls
		self.admin_cu_url = self.admin_url .. "create/user"
		self.admin_cb_url = self.admin_url .. "create/board"
		self.admin_ca_url = self.admin_url .. "create/announcement"
		self.admin_cp_url = self.admin_url .. "create/page"

		-- Modify urls
		self.admin_mu_url = self.admin_url .. "modify/user/"
		self.admin_mb_url = self.admin_url .. "modify/board/"
		self.admin_ma_url = self.admin_url .. "modify/announcement/"
		self.admin_mp_url = self.admin_url .. "modify/page/"

		-- Delete urls
		self.admin_du_url = self.admin_url .. "delete/user/"
		self.admin_db_url = self.admin_url .. "delete/board/"
		self.admin_da_url = self.admin_url .. "delete/announcement/"
		self.admin_dp_url = self.admin_url .. "delete/page/"
		self.admin_dr_url = self.admin_url .. "delete/report/"
	end,
	GET = function(self)
		-- Generate CSRF token
		self.csrf_token = csrf.generate_token(self)

		-- Verify Authorization
		if self.session.name then
			if not self.session.admin then
				return prep_error(self, "You are not an admin.")
			end
		else
			return { render = "admin.login" }
		end

		return { render = "admin.admin" }
	end,
	POST = function(self)
		-- Validate CSRF token
		local _, err = csrf.validate_token(self)
		if err then return prep_error(self, err) end

		-- Verify user credentials
		if self.params.login then
			-- Verify user
			local user, err = Users.verify_user(self.params)
			if err then return prep_error(self, err) end

			-- Set username
			self.session.name = user.username

			return { redirect_to = self.admin_url }
		end

		-- Must be logged in as an admin!
		if self.session.admin then
			-- Redirect to modify user page
			if self.params.modify_user then
				return { redirect_to = self.admin_mu_url .. self.params.user }
			end

			-- Redirect to delete user page
			if self.params.delete_user then
				return { redirect_to = self.admin_du_url .. self.params.user }
			end

			-- Redirect to modify board page
			if self.params.modify_board then
				return { redirect_to = self.admin_mb_url .. self.params.board }
			end

			-- Redirect to delete board page
			if self.params.delete_board then
				return { redirect_to = self.admin_db_url .. self.params.board }
			end

			-- Redirect to modify announcement page
			if self.params.modify_announcement then
				return { redirect_to = self.admin_ma_url .. self.params.ann }
			end

			-- Redirect to delete announcement page
			if self.params.delete_announcement then
				return { redirect_to = self.admin_da_url .. self.params.ann }
			end

			-- Redirect to modify page page
			if self.params.modify_page then
				return { redirect_to = self.admin_mp_url .. self.params.page }
			end

			-- Redirect to delete page page
			if self.params.delete_page then
				return { redirect_to = self.admin_dp_url .. self.params.page }
			end

			-- Redirect to reported post
			if self.params.view_report then
				local report = Reports.get_report_by_id(self.params.report)
				local board  = Boards.get_board(report.board_id)
				local post   = Posts.get_post(board.id, report.post_id)
				local op     = Posts.get_thread_op(board.id, report.thread_id)

				local board_url  = self.boards_url .. board.short_name .. "/"
				local thread_url = board_url  .. "thread/"
				local post_url   = thread_url .. op.post_id .. "#p" .. post.post_id

				return { redirect_to = post_url }
			end

			-- Redirect to delete report page
			if self.params.delete_report then
				return { redirect_to = self.admin_dr_url .. self.params.report }
			end

			-- Regenerate thumbnails
			if self.params.regen_thumbs then
				Boards.regen_thumbs()
			end

			return { render = "admin.admin" }
		end

		return { render = "admin.login" }
	end
}
