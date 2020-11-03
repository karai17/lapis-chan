local ngx    = _G.ngx
local action = setmetatable({}, require "apps.api.internal.action_base")

function action.GET()
	return {
		status = ngx.HTTP_OK,
		json   = {}
	}
end

return action
