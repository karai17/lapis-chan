local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.internal.action_base")
local assert_error = require("lapis.application").assert_error
local role         = require "utils.role"
local models       = require "models"
local Boards       = models.boards
local Posts        = models.posts

function action:GET()

	-- Verify the User's permissions
	assert_error(role.mod(self.api_user))

	-- Get Board
	local board = assert_error(Boards:get(self.params.uri_board))

	-- Get Reported posts
	local posts = Posts:get_board_reports(board.id)
	for _, post in ipairs(posts) do
		Posts:format_from_db(post)
	end

	return {
		status = ngx.HTTP_OK,
		json   = posts
	}
end

return action
