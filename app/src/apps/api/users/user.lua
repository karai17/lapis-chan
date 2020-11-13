local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.internal.action_base")
local assert_error = require("lapis.application").assert_error
local yield_error  = require("lapis.application").yield_error
local assert_valid = require("lapis.validate").assert_valid
local trim_filter  = require("lapis.util").trim_filter
local role         = require "utils.role"
local models       = require "models"
local Users        = models.users

function action:GET()

	local user = assert_error(Users:get(self.params.uri_user))
	Users:format_from_db(user)

	-- Verify the User's permissions
	local is_admin = role.admin(self.api_user)
	local is_user  = self.api_user.id == user.id
	if not is_admin and not is_user then
		yield_error("FIXME")
	end

	return {
		status = ngx.HTTP_OK,
		json   = user
	}
end

function action:PUT()

	local user = assert_error(Users:get(self.params.uri_user))

	-- Verify the User's permissions
	local is_admin = role.admin(self.api_user)
	local is_user  = self.api_user.id == user.id
	local is_auth  = self.api_user.role > user.role
	if (not is_admin and not is_user) or not is_auth then
		yield_error("FIXME")
	end

	-- Validate parameters
	local params = {
		username = self.params.username,
		password = self.params.password,
		confirm  = self.params.confirm,
		role     = tonumber(self.params.role),
		api_key  = self.params.api_key
	}
	trim_filter(params)
	Users:format_to_db(params)
	assert_valid(params, Users.valid_record)

	-- If no role was sent, don't update it
	-- This is kind of dumb since we're just setting it from nil to -1 and back
	-- to nil, but I want to keep the format_to_db in case of future formatting
	-- concerns.
	if params.role == Users.role.INVALID then
		params.role = nil
	end

	if params.role then

		-- Only admins can change a role
		if not is_admin then
			yield_error("FIXME")
		end

		-- Cannot elevate to or above own role
		if self.api_user.role <= params.role then
			yield_error("FIXME")
		end
	end

	-- Modify User
	user = assert_error(Users:modify(params, self.params.uri_user, self.params.password))
	Users:format_from_db(user)

	return {
		status = ngx.HTTP_OK,
		json   = user
	}
end

function action:DELETE()

	local user = assert_error(Users:get(self.params.uri_user))

	-- Verify the User's permissions
	local is_admin = role.admin(self.api_user)
	local is_user  = self.api_user.id == user.id
	local is_auth  = self.api_user.role > user.role
	if not is_admin and not is_user and not is_auth then
		yield_error("FIXME")
	end

	-- Delete User
	user = assert_error(Users:delete(self.params.uri_user))

	return {
		status = ngx.HTTP_OK,
		json   = {
			id       = user.id,
			username = user.username
		}
	}
end

return action
