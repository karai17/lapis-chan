local ngx           = _G.ngx
local action        = setmetatable({}, require "apps.api.internal.action_base")
local assert_error  = require("lapis.application").assert_error
local models        = require "models"
local Announcements = models.announcements
local Boards        = models.boards

function action:GET()

	-- Get Board
	local board = assert_error(Boards:get(self.params.uri_board))

	-- Get Announcements
	local announcements = Announcements:get_board(board.id)
	for _, announcement in ipairs(announcements) do
		Announcements:format_from_db(announcement)
	end

	return {
		status = ngx.HTTP_OK,
		json   = announcements
	}
end

return action
