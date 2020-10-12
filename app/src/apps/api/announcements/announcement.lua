local ngx           = _G.ngx
local action        = setmetatable({}, require "apps.api.internal.action_base")
local assert_error  = require("lapis.application").assert_error
local assert_valid  = require("lapis.validate").assert_valid
local trim_filter   = require("lapis.util").trim_filter
local models        = require "models"
local Announcements = models.announcements

function action:GET()
	local announcement

	-- Get global Announcements
	if self.params.uri_id == "global" then
		announcement = assert_error(Announcements:get_global())
	else
		-- Get Announcement
		announcement = assert_error(Announcements:get(self.params.uri_id))
	end

	return {
		status = ngx.HTTP_OK,
		json   = announcement
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
	assert_valid(params, Announcements.valid_record)

	-- Modify announcement
	local announcement = assert_error(Announcements:modify(params))

	return {
		status = ngx.HTTP_OK,
		json   = announcement
	}
end

function action:DELETE()

	-- Delete announcement
	local announcement = assert_error(Announcements:delete(self.params.uri_id))

	return {
		status = ngx.HTTP_OK,
		json   = {
			id   = announcement.id,
			text = announcement.text
		}
	}
end

return action
