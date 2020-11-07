local ngx           = _G.ngx
local action        = setmetatable({}, require "apps.api.internal.action_base")
local assert_error  = require("lapis.application").assert_error
local models        = require "models"
local Announcements = models.announcements

function action.GET()

	-- Get global Announcements
	local announcements = assert_error(Announcements:get_global())
	for _, announcement in ipairs(announcements) do
		Announcements:format_from_db(announcement)
	end

	return {
		status = ngx.HTTP_OK,
		json   = announcements
	}
end

return action
