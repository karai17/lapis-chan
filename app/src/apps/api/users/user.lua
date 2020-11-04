local ngx           = _G.ngx
local action        = setmetatable({}, require "apps.api.internal.action_base")
local assert_error  = require("lapis.application").assert_error
local assert_valid  = require("lapis.validate").assert_valid
local trim_filter   = require("lapis.util").trim_filter
local models        = require "models"
local Users         = models.users

function action:GET()
	local user = assert_error(Users:get(self.params.uri_id))

	return {
		status = ngx.HTTP_OK,
		json   = user
	}
end

function action:PUT()

	-- Validate parameters
	local params = {
		id       = tonumber(self.params.uri_id),
		board_id = tonumber(self.params.board_id),
		text     = self.params.text,
	}
	trim_filter(params)
	assert_valid(params, Users.valid_record)

	-- Modify user
	local user = assert_error(Users:modify(params))

	return {
		status = ngx.HTTP_OK,
		json   = user
	}
end

function action:DELETE()

	-- Delete user
	local user = assert_error(Users:delete(self.params.uri_id))

	return {
		status = ngx.HTTP_OK,
		json   = {
			id   = user.id,
			text = user.text
		}
	}
end

return action
