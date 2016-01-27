local assert_error  = require("lapis.application").assert_error
local assert_valid  = require("lapis.validate").assert_valid
local csrf          = require "lapis.csrf"
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
		self.boards        = Boards:get_boards()
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

		-- Create urls
		self.admin_ca_url = self.admin_url .. "create/announcement/"
		self.admin_cb_url = self.admin_url .. "create/board/"
		self.admin_cp_url = self.admin_url .. "create/page/"
		self.admin_cu_url = self.admin_url .. "create/user/"

		-- Modify urls
		self.admin_ma_url = self.admin_url .. "modify/announcement/"
		self.admin_mb_url = self.admin_url .. "modify/board/"
		self.admin_mp_url = self.admin_url .. "modify/page/"
		self.admin_mu_url = self.admin_url .. "modify/user/"

		-- Delete urls
		self.admin_da_url = self.admin_url .. "delete/announcement/"
		self.admin_db_url = self.admin_url .. "delete/board/"
		self.admin_dp_url = self.admin_url .. "delete/page/"
		self.admin_dr_url = self.admin_url .. "delete/report/"
		self.admin_du_url = self.admin_url .. "delete/user/"
	end,
	on_error = function(self)
		local err = self.i18n(unpack(self.errors))
		if err then
			self.errors = { err }
		end

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
				local report = Reports:get_report_by_id(self.params.report)
				local board  = Boards:get_board(report.board_id)
				local post   = Posts:get_post(board.id, report.post_id)
				local op     = Posts:get_thread_op(report.thread_id)

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
				Boards:regen_thumbs()
			end

			return { render = "admin.admin" }
		end

		return { render = "admin.login" }
	end
}
