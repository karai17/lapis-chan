local ngx           = _G.ngx
local action        = setmetatable({}, require "apps.api.internal.action_base")
local assert_error  = require("lapis.application").assert_error
local assert_valid  = require("lapis.validate").assert_valid
local trim_filter   = require("lapis.util").trim_filter
local role          = require "utils.role"
local models        = require "models"
local Announcements = models.announcements

function action:GET()

	-- Verify the User's permissions
	assert_error(role.admin(self.api_user))

	-- Get all Announcements
	local announcements = assert_error(Announcements:get_all())
	for _, announcement in ipairs(announcements) do
		Announcements:format_from_db(announcement)
	end

	return {
		status = ngx.HTTP_OK,
		json   = announcements
	}
end

function action:POST()

	-- Verify the User's permissions
	assert_error(role.admin(self.api_user))

	-- Validate parameters
	local params = {
		board_id = tonumber(self.params.board_id),
		text     = self.params.text,
	}
	trim_filter(params)
	Announcements:format_to_db(params)
	assert_valid(params, Announcements.valid_record)

	-- Create Announcement
	local announcement = assert_error(Announcements:new(params))
	Announcements:format_from_db(announcement)

	return {
		status = ngx.HTTP_OK,
		json   = announcement
	}
end

return action
