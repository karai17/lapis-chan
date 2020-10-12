local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.internal.action_base")
local assert_error = require("lapis.application").assert_error
local models       = require "models"
local Boards       = models.boards
local Threads      = models.threads

function action:GET()

	local board = assert_error(Boards:get(self.params.uri_name))

	-- Get Threads
	local threads = board:get_archived()
	for _, thread in ipairs(threads) do
		--Threads:format_from_db(thread)
	end

	return {
		status = ngx.HTTP_OK,
		json   = threads
	}
end

return action
