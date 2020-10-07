local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.global.action_base")
local assert_error = require("lapis.application").assert_error
local models       = require "models"
local Boards       = models.boards

function action:GET()

	-- Get Board
	local board = assert_error(Boards:get(self.params.uri_short_name))

	-- Get Announcements
	local announcements = board:get_announcements()

	return {
		status = ngx.HTTP_OK,
		json   = announcements
	}
end

return action
