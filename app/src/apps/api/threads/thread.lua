local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.internal.action_base")
local assert_error = require("lapis.application").assert_error
local models       = require "models"
local Threads      = models.threads

function action:GET()

	-- Get Thread
	local thread = assert_error(Threads:get(self.params.uri_id))
	--Threads:format_from_db(thread)

	return {
		status = ngx.HTTP_OK,
		json   = thread
	}
end

function action:DELETE()

	-- Delete thread
	local thread = assert_error(Threads:delete(self.params.uri_id))

	return {
		status = ngx.HTTP_OK,
		json   = {
			id = thread.id
		}
	}
end

return action
