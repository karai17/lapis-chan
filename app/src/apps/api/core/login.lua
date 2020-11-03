local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.internal.action_base")
local assert_error = require("lapis.application").assert_error
local models       = require "models"
local Users        = models.users

function action:POST()
	return {
		status = ngx.HTTP_OK,
		json   = {}
	}
end

return action
