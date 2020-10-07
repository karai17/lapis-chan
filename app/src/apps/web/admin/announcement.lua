local assert_error = require("lapis.application").assert_error
local assert_valid = require("lapis.validate").assert_valid
local csrf         = require "lapis.csrf"
local capture      = require "utils.capture"
local generate     = require "utils.generate"

return {
	before = function(self)
		-- Get announcements
		self.announcements = assert_error(capture.get(self:url_for("api.announcements.announcements")))

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
				self.i18n("create_ann")
			)
			self.announcement = self.params
			return
		end

		-- Display modification form
		if self.params.action == "modify" then
			self.announcement = assert_error(capture.get(self:url_for("api.announcements.announcement", { uri_id=self.params.uri_id })))
			self.page_title = string.format(
				"%s - %s",
				self.i18n("admin_panel"),
				self.i18n("modify_ann")
			)
			return
		end

		-- Delete announcement
		if self.params.action == "delete" then
			self.announcement = assert_error(capture.delete(self:url_for("api.announcements.announcement", { uri_id=self.params.uri_id })))
			self.page_title = string.format(
				"%s - %s",
				self.i18n("admin_panel"),
				self.i18n("success")
			)
			self.action = self.i18n("deleted_ann", { self.announcement.text })
			return
		end
	end,

	on_error = function(self)
		self.errors = generate.errors(self.i18n, self.errors)

		if not self.session.name then
			return { render = "admin.login" }
		elseif self.params.action == "create" then
			return { render = "admin.announcement" }
		elseif self.params.action == "modify" then
			return { render = "admin.announcement" }
		elseif self.params.action == "delete" then
			return { render = "admin.admin" }
		end
	end,

	GET = function(self)
		if not self.session.name then
			return { render = "admin.login" }
		elseif self.params.action == "create" then
			return { render = "admin.announcement" }
		elseif self.params.action == "modify" then
			return { render = "admin.announcement" }
		elseif self.params.action == "delete" then
			return { render = "admin.success" }
		end
	end,

	POST = function(self)
		-- Validate CSRF token
		csrf.assert_token(self)

		-- Validate user input
		assert_valid(self.params, {
			{ "text", max_length=255, exists=true }
		})

		-- Create announcement
		if self.params.create_announcement then
			self.announcement = assert_error(capture.post(self:url_for("api.announcements.announcements"), self.params))
			self.page_title = string.format(
				"%s - %s",
				self.i18n("admin_panel"),
				self.i18n("success")
			)
			self.action = self.i18n("created_ann", { self.announcement.text })

			return { render = "admin.success" }
		end

		-- Modify announcement
		if self.params.modify_announcement then
			self.announcement = assert_error(capture.put(self:url_for("api.announcements.announcement", { uri_id=self.params.uri_id }), self.params))
			self.page_title = string.format(
				"%s - %s",
				self.i18n("admin_panel"),
				self.i18n("success")
			)
			self.action = self.i18n("modified_ann", { self.announcement.text })

			return { render = "admin.success" }
		end

		return { redirect_to = self:url_for("web.admin.index") }
	end
}
