local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.internal.action_base")
local assert_error = require("lapis.application").assert_error
local yield_error  = require("lapis.application").yield_error
local models       = require "models"
local Users        = models.users

function action:POST()

	local params = {
		username = self.params.username,
		password = self.params.password
	}

	if not params.username or not params.password then
		yield_error("FIXME")
	end

	local user = assert_error(Users:login(params))

	return {
		status = ngx.HTTP_OK,
		json   = {
			id       = user.id,
			username = user.username,
			role     = user.role,
			api_key  = user.api_key
		}
	}
end

return action
