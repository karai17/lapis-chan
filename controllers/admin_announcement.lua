local Boards        = require "models.boards"
local Announcements = require "models.announcements"
local prep_error    = require "utils.prep_error"
local csrf          = require "lapis.csrf"

return {
	before = function(self)
		-- Get all announcement data
		self.announcements = Announcements.get_announcements()

		-- Get all board data
		self.boards = Boards.get_boards()
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
			self.page_title = "Admin Panel - Create Announcement"
			return { render = "admin.create_announcement" }
		end

		-- Display modification form
		if self.params.action == "modify" then
			self.page_title = "Admin Panel - Modify Announcement"
			self.announcement = Announcements.get_announcement(self.params.ann)
			return { render = "admin.modify_announcement" }
		end

		-- Delete announcement
		if self.params.action == "delete" then
			local ann = Announcements.get_announcement(self.params.ann)

			-- Delete announcement
			local _, err = Announcements.delete_announcement(ann)
			if err then return prep_error(self, err) end

			self.action = string.format("deleted announcement: %s", ann.text)
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
			-- Create new announcement
			if self.params.create_announcement then
				-- Create announcement
				local ann, err = Announcements.create_announcement(self.params)
				if err then return prep_error(self, err) end

				self.action = string.format(
					"created announcement: %s",
					ann.text
				)

				return { render = "admin.success" }
			end

			-- Modify announcement
			if self.params.modify_announcement then
				local ann = Announcements.get_announcement(self.params.ann)

				for k, param in pairs(self.params) do
					if ann[k] then
						ann[k] = param
					end
				end

				-- Modify user
				local _, err = Announcements.modify_announcement(ann)
				if err then return prep_error(self, err) end

				self.action = string.format(
					"modified user: %s",
					ann.text
				)

				return { render = "admin.success" }
			end

			return { redirect_to = self.admin_url }
		end

		return { render = "admin.login" }
	end
}
