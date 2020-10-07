local ngx           = _G.ngx
local action        = setmetatable({}, require "apps.api.global.action_base")
local assert_error  = require("lapis.application").assert_error
local assert_valid  = require("lapis.validate").assert_valid
local trim_filter   = require("lapis.util").trim_filter
local models        = require "models"
local Announcements = models.announcements

function action:GET()

	-- Get all Announcements
	local announcements = assert_error(Announcements:get_all())

	return {
		status = ngx.HTTP_OK,
		json   = announcements
	}
end

function action:POST()

	-- Validate parameters
	local params = {
		board_id = self.params.board_id,
		text     = self.params.text,
	}
	trim_filter(params)
	assert_valid(params, Announcements.valid_record)

	-- Create announcement
	local announcement = assert_error(Announcements:new(params))

	return {
		status = ngx.HTTP_OK,
		json   = announcement
	}
end

return action
