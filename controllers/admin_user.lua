local assert_error = require("lapis.application").assert_error
local assert_valid = require("lapis.validate").assert_valid
local csrf         = require "lapis.csrf"
local i18n         = require "i18n"
local Boards       = require "models.boards"
local Users        = require "models.users"

return {
	before = function(self)
		-- Set localization
		i18n.setLocale(self.session.locale or "en")
		i18n.loadFile("locale/" .. i18n.getLocale() .. ".lua")
		self.i18n = i18n

		-- Get all board data
		self.boards = Boards:get_boards()

		-- Get all user data
		self.users = Users:get_users()

		-- Display a theme
		self.board = { theme = "yotsuba_b" }

		-- Generate CSRF token
		self.csrf_token = csrf.generate_token(self)

		-- Page title
		self.page_title = i18n("admin_panel")

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
				i18n("admin_panel"),
				i18n("create_user")
			)
			self.user = self.params
			return
		end

		-- Display modification form
		if self.params.action == "modify" then
			self.page_title = string.format(
				"%s - %s",
				i18n("admin_panel"),
				i18n("modify_user")
			)
			self.user = Users:get_user_by_id(self.params.user)
			return
		end

		-- Delete user
		if self.params.action == "delete" then
			local user = Users:get_user_by_id(self.params.user)
			assert_error(Users:delete_user(user))

			self.page_title = string.format(
				"%s - %s",
				i18n("admin_panel"),
				i18n("success")
			)
			self.action = i18n("deleted_user", { user.username })
			return
		end
	end,
	on_error = function(self)
		self.err = i18n(unpack(self.errors))

		if self.err then
			self.err = "<p>" .. self.err .. "</p>"
		else
			self.err = ""
			for _, e in ipairs(self.errors) do
				self.err = self.err .. "<p>" .. tostring(e) .. "</p>\n"
			end
		end

		if not self.session.name then
			return { render = "admin.login" }
		elseif self.params.action == "create" then
			return { render = "admin.user" }
		elseif self.params.action == "modify" then
			return { render = "admin.user" }
		elseif self.params.action == "delete" then
			return { render = "admin.admin" }
		end
	end,
	GET = function(self)
		if not self.session.name then
			return { render = "admin.login" }
		elseif self.params.action == "create" then
			return { render = "admin.user" }
		elseif self.params.action == "modify" then
			return { render = "admin.user" }
		elseif self.params.action == "delete" then
			return { render = "admin.success" }
		end
	end,
	POST = function(self)
		-- Validate CSRF token
		csrf.assert_token(self)

		-- Create new user
		if self.params.create_user then
			local sl = string.lower

			-- Validate user input
			assert_valid(self.params, {
				{ "username",        exists=true, max_length=255 },
				{ "new_password",    exists=true, equals=self.params.retype_password },
				{ "retype_password", exists=true }
			})

			self.params.password = self.params.new_password

			-- Verify unique names
			for _, user in ipairs(self.users) do
				if sl(user.username) == sl(self.params.username) then
					assert_error(false, "err_user_used")
				end
			end

			-- Create user
			local user = assert_error(Users:create_user(self.params))

			self.page_title = string.format(
				"%s - %s",
				i18n("admin_panel"),
				i18n("success")
			)
			self.action = i18n("created_user", { user.username })

			return { render = "admin.success" }
		end

		-- Modify user
		if self.params.modify_user then
			-- Validate user input
			assert_valid(self.params, {
				{ "username",        exists=true, max_length=255 },
				{ "new_password",    equals=self.params.retype_password },
				{ "retype_password", }
			})

			local discard = {
				"user",
				"modify_user",
				"ip",
				"action",
				"csrf_token",
				"old_password",
				"new_password",
				"retype_password",
			}

			local user = Users:get_user(self.params.username)

			-- Validate user
			if #self.params.old_password > 0 then
				-- Validate user input
				assert_valid(self.params, {
					{ "new_password",    exists=true },
					{ "retype_password", exists=true }
				})

				-- TODO: verify user's old password in non-admin setting

				self.params.password = self.params.new_password
			end

			-- Fill in board with new data
			for k, param in pairs(self.params) do
				user[k] = param
			end

			-- Get rid of form trash
			for _, param in ipairs(discard) do
				user[param] = nil
			end

			assert_error(Users:modify_user(user))

			self.page_title = string.format(
				"%s - %s",
				i18n("admin_panel"),
				i18n("success")
			)
			self.action = i18n("modified_user", { user.username })

			return { render = "admin.success" }
		end

		return { redirect_to = self.admin_url }
	end
}
