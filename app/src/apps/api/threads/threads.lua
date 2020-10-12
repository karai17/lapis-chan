local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.internal.action_base")
local assert_error = require("lapis.application").assert_error
local assert_valid = require("lapis.validate").assert_valid
local trim_filter  = require("lapis.util").trim_filter
local models       = require "models"
local Threads      = models.threads

function action:POST()

	-- Validate parameters
	local params = {
		board_id      = tonumber(self.params.board_id),
		last_active   = os.time(),
		sticky        = self.params.sticky,
		lock          = self.params.lock,
		size_override = self.params.size_override,
		save          = self.params.save
	}
	--Threads:format_to_db(params)
	trim_filter(params)
	assert_valid(params, Threads.valid_record)


	-- Create thread
	local thread = assert_error(Threads:new(params))
	--Threads:format_from_db(thread)

	return {
		status = ngx.HTTP_OK,
		json   = thread
	}
end

return action
