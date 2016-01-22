local Boards     = require "models.boards"
local Reports    = require "models.reports"
local prep_error = require "utils.prep_error"
local csrf       = require "lapis.csrf"

return {
	before = function(self)
		-- Get all board data
		self.boards = Boards.get_boards()

		-- Get all report data
		self.reports = Reports.get_reports()
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

		-- Delete report
		if self.params.action == "delete" then
			local report = Reports.get_report_by_id(self.params.report)

			-- Delete report
			local _, err = Reports.delete_report(report)
			if err then return prep_error(self, err[1]) end

			self.action = string.format(
				"deleted report: %s",
				report.id
			)
			self.page_title = "Admin Panel - Success"

			return { render = "admin.success" }
		end

		-- Invalid action, gtfo
		return { redirect_to = self.admin_url }
	end,
	POST = function(self)
		return { redirect_to = self.admin_url }
	end
}
