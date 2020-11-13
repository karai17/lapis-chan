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

	-- Verify the User's permissions
	assert_error(role.admin(self.api_user))

	-- Get all Users
	local users = assert_error(Users:get_all())
	for _, user in ipairs(users) do
		Users:format_from_db(user)
	end

	return {
		status = ngx.HTTP_OK,
		json   = users
	}
end

function action:POST()

	-- Verify the User's permissions
	assert_error(role.admin(self.api_user))

	-- Validate parameters
	local params = {
		username = self.params.username,
		password = self.params.password,
		confirm  = self.params.confirm,
		role     = tonumber(self.params.role)
	}
	trim_filter(params)
	Users:format_to_db(params)
	assert_valid(params, Users.valid_record)

	-- DENY if no role was sent
	if params.role == Users.role.INVALID then
		yield_error("FIXME")
	end

	-- Cannot elevate to or above own role
	if self.api_user.role <= params.role then
		yield_error("FIXME")
	end

	-- Create user
	local user = assert_error(Users:new(params, self.params.password))
	Users:format_from_db(user)

	return {
		status = ngx.HTTP_OK,
		json   = user
	}
end

return action
