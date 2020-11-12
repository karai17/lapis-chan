local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.internal.action_base")
local assert_error = require("lapis.application").assert_error
local assert_valid = require("lapis.validate").assert_valid
local trim_filter  = require("lapis.util").trim_filter
local role         = require "utils.role"
local models       = require "models"
local Bans         = models.bans

function action:GET()

	-- Verify the User's permissions
	assert_error(role.mod(self.api_user))

	-- Get all Bans
	local bans = assert_error(Bans:get_all())
	for _, ban in ipairs(bans) do
		Bans:format_from_db(ban)
	end

	return {
		status = ngx.HTTP_OK,
		json   = bans
	}
end

function action:POST()

	-- Verify the User's permissions
	assert_error(role.mod(self.api_user))

	-- Validate parameters
	local params = {
		board_id = tonumber(self.params.board_id),
		ip       = self.params.ip,
		reason   = self.params.reason,
		time     = os.time(),
		duration = tonumber(self.params.duration)
	}
	trim_filter(params)
	Bans:format_to_db(params)
	assert_valid(params, Bans.valid_record)

	-- Create Ban
	local ban = assert_error(Bans:new(params))
	Bans:format_from_db(ban)

	return {
		status = ngx.HTTP_OK,
		json   = ban
	}
end

return action
