local assert_error = require("lapis.application").assert_error
local assert_valid = require("lapis.validate").assert_valid
local csrf         = require "lapis.csrf"
local Boards       = require "models.boards"
local Reports      = require "models.reports"

return {
	before = function(self)
		-- Get data
		self.boards  = Boards:get_boards()
		self.reports = Reports:get_reports()

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

		-- Delete report
		if self.params.action == "delete" then
			local report = Reports:get_report_by_id(self.params.report)
			assert_error(Reports:delete_report(report))

			self.page_title = string.format(
				"%s - %s",
				self.i18n("admin_panel"),
				self.i18n("success")
			)
			self.action = self.i18n("deleted_report", { report.id })
			return
		end
	end,
	on_error = function(self)
		local err = self.i18n(unpack(self.errors))
		if err then
			self.errors = { err }
		end

		if not self.session.name then
			return { render = "admin.login" }
		elseif self.params.action == "delete" then
			return { render = "admin.admin" }
		end
	end,
	GET = function(self)
		if not self.session.name then
			return { render = "admin.login" }
		elseif self.params.action == "delete" then
			return { render = "admin.success" }
		end
	end,
	POST = function(self)
		return { redirect_to = self:format_url(self.admin_url) }
	end
}
