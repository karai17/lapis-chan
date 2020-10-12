local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.internal.action_base")
local assert_error = require("lapis.application").assert_error
local models       = require "models"
local Threads      = models.threads

function action:GET()

	-- Get Thread
	local thread = assert_error(Threads:get(self.params.uri_id))

	-- Get Posts
	local posts = thread:get_posts()

	return {
		status = ngx.HTTP_OK,
		json   = posts
	}
end

return action
