local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.internal.action_base")
local assert_error = require("lapis.application").assert_error
local models       = require "models"
local Boards       = models.boards

function action:GET()

	-- Get Board
	local board = assert_error(Boards:get(self.params.uri_name))

	-- Get Bans
	local bans = board:get_bans()

	return {
		status = ngx.HTTP_OK,
		json   = bans
	}
end

return action
