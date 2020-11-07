local ngx           = _G.ngx
local action        = setmetatable({}, require "apps.api.internal.action_base")
local assert_error  = require("lapis.application").assert_error
local assert_valid  = require("lapis.validate").assert_valid
local trim_filter   = require("lapis.util").trim_filter
local role          = require "utils.role"
local models        = require "models"
local Announcements = models.announcements

function action:GET()

	-- Get Announcement
	local announcement = assert_error(Announcements:get(self.params.uri_announcement))
	Announcements:format_from_db(announcement)

	return {
		status = ngx.HTTP_OK,
		json   = announcement
	}
end

function action:PUT()

	-- Verify the User's permissions
	assert_error(role.admin(self.api_user))

	-- Validate parameters
	local params = {
		id       = self.params.uri_announcement,
		board_id = tonumber(self.params.board_id),
		text     = self.params.text,
	}
	trim_filter(params)
	Announcements:format_to_db(params)
	assert_valid(params, Announcements.valid_record)

	-- Modify Announcement
	local announcement = assert_error(Announcements:modify(params))
	Announcements:format_from_db(announcement)

	return {
		status = ngx.HTTP_OK,
		json   = announcement
	}
end

function action:DELETE()

	-- Verify the User's permissions
	assert_error(role.admin(self.api_user))

	-- Delete Announcement
	local announcement = assert_error(Announcements:delete(self.params.uri_announcement))

	return {
		status = ngx.HTTP_OK,
		json   = {
			id   = announcement.id,
			text = announcement.text
		}
	}
end

return action
