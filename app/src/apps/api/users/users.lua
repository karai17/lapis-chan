local ngx           = _G.ngx
local action        = setmetatable({}, require "apps.api.internal.action_base")
local assert_error  = require("lapis.application").assert_error
local assert_valid  = require("lapis.validate").assert_valid
local trim_filter   = require("lapis.util").trim_filter
local models        = require "models"
local Users         = models.users

function action:GET()

	-- Get all Users
	local users = assert_error(Users:get_all())

	return {
		status = ngx.HTTP_OK,
		json   = users
	}
end

function action:POST()

	-- Validate parameters
	local params = {
		board_id = self.params.board_id,
		text     = self.params.text,
	}
	trim_filter(params)
	assert_valid(params, Users.valid_record)

	-- Create user
	local user = assert_error(Users:new(params))

	return {
		status = ngx.HTTP_OK,
		json   = user
	}
end

return action
