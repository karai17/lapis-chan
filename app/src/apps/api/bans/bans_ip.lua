local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.global.action_base")
local assert_error = require("lapis.application").assert_error
local models       = require "models"
local Bans         = models.bans

function action:GET()

	-- Get Bans
	local bans = assert_error(Bans:get_ip(self.params.uri_ip))
	for _, ban in ipairs(bans) do
		Bans:format_from_db(ban)
	end

	return {
		status = ngx.HTTP_OK,
		json   = bans
	}
end

return action
