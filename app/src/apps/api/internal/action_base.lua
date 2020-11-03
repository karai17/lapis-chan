local ngx    = _G.ngx
local action = {}

local function errors()
	return {
		status = ngx.HTTP_NOT_ALLOWED,
		json   = {}
	}
end

action.__index = action
action.GET     = errors
action.POST    = errors
action.PUT     = errors
action.DELETE  = errors

return action
