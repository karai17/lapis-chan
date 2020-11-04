local ngx           = _G.ngx
local action        = setmetatable({}, require "apps.api.internal.action_base")
local assert_error  = require("lapis.application").assert_error
local models        = require "models"
local Announcements = models.announcements

function action:GET()
	local announcement = assert_error(Announcements:get_global())

	return {
		status = ngx.HTTP_OK,
		json   = announcement
	}
end

return action
