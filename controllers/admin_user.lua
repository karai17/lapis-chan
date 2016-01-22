local Users      = require "models.users"
local Boards     = require "models.boards"
local prep_error = require "utils.prep_error"
local csrf       = require "lapis.csrf"

return {
	before = function(self)
		-- Get all user data
		self.users = Users.get_users()

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
			self.page_title = "Admin Panel - Create User"
			return { render = "admin.create_user" }
		end

		-- Display modification form
		if self.params.action == "modify" then
			self.page_title = "Admin Panel - Modify User"
			self.user = Users.get_user_by_id(self.params.user)
			return { render = "admin.modify_user" }
		end

		-- Delete user
		if self.params.action == "delete" then
			local user = Users.get_user_by_id(self.params.user)

			-- Delete user
			local _, err = Users.delete_user(user)
			if err then return prep_error(self, err) end

			self.action = string.format("deleted user: %s", user.username)
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
			-- Create new user
			if self.params.create_user then
				local sl = string.lower
				-- Verify unique names
				for _, user in ipairs(self.users) do
					if sl(user.username) == sl(self.params.username) then
						prep_error(self, "Username already in use.")
					end
				end

				-- Create user
				local user, err = Users.create_user(self.params)
				if err then return prep_error(self, err) end

				self.action = string.format(
					"created user: %s",
					user.username
				)

				return { render = "admin.success" }
			end

			-- Modify user
			if self.params.modify_user then
				local user = Users.get_user(self.params.username)

				for k, param in pairs(self.params) do
					if user[k] then
						user[k] = param
					end
				end

				-- Modify user
				local _, err = Users.modify_user(user)
				if err then return prep_error(self, err) end

				self.action = string.format(
					"modified user: %s",
					user.username
				)

				return { render = "admin.success" }
			end

			return { redirect_to = self.admin_url }
		end

		return { render = "admin.login" }
	end
}
