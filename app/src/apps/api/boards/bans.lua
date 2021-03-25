local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.internal.action_base")
local assert_error = require("lapis.application").assert_error
local role         = require "utils.role"
local models       = require "models"
local Bans         = models.bans
local Boards       = models.boards

function action:GET()

	-- Verify the User's permissions
	assert_error(role.mod(self.api_user))

	-- Get Board
	local board = assert_error(Boards:get(self.params.uri_board))

	-- Get Bans
	local bans = Bans:get_board(board.id)
	for _, ban in ipairs(bans) do
		Bans:format_from_db(ban)
	end

	return {
		status = ngx.HTTP_OK,
		json   = bans
	}
end

return action
