local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.internal.action_base")
local assert_error = require("lapis.application").assert_error
local models       = require "models"
local Boards       = models.boards
local Posts        = models.posts

function action:GET()

	local board = assert_error(Boards:get(self.params.uri_name))

	-- Get Post
	local post = assert_error(Posts:get(board.id, self.params.uri_id))
	--Posts:format_from_db(post)

	return {
		status = ngx.HTTP_OK,
		json   = post
	}
end

return action
