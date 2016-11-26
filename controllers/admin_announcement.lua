local assert_error  = require("lapis.application").assert_error
local assert_valid  = require("lapis.validate").assert_valid
local csrf          = require "lapis.csrf"
local Announcements = require "models.announcements"
local Boards        = require "models.boards"

return {
	before = function(self)
		-- Get all announcement data
		self.announcements = Announcements:get_announcements()

		-- Get all board data
		self.boards = Boards:get_boards()

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
			self.page_title = string.format(
				"%s - %s",
				self.i18n("admin_panel"),
				self.i18n("modify_ann")
			)
			self.announcement = Announcements:get_announcement(self.params.ann)
			return
		end

		-- Delete announcement
		if self.params.action == "delete" then
			local ann = Announcements:get_announcement(self.params.ann)
			assert_error(Announcements:delete_announcement(ann))

			self.page_title = string.format(
				"%s - %s",
				self.i18n("admin_panel"),
				self.i18n("success")
			)
			self.action = self.i18n("deleted_ann", { ann.text })
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
			local ann = assert_error(Announcements:create_announcement(self.params))

			self.page_title = string.format(
				"%s - %s",
				self.i18n("admin_panel"),
				self.i18n("success")
			)
			self.action = self.i18n("created_ann", { ann.text })

			return { render = "admin.success" }
		end

		-- Modify announcement
		if self.params.modify_announcement then
			local discard = {
				"ann",
				"modify_announcement",
				"ip",
				"action",
				"csrf_token"
			}

			local ann = Announcements:get_announcement(self.params.ann)

			-- Fill in board with new data
			for k, param in pairs(self.params) do
				ann[k] = param
			end

			-- Get rid of form trash
			for _, param in ipairs(discard) do
				ann[param] = nil
			end

			assert_error(Announcements:modify_announcement(ann))

			self.page_title = string.format(
				"%s - %s",
				self.i18n("admin_panel"),
				self.i18n("success")
			)
			self.action = self.i18n("modified_ann", { ann.text })

			return { render = "admin.success" }
		end

		return { redirect_to = self:format_url(self.admin_url) }
	end
}
