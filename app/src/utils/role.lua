local models    = require "models"
local get_error = require "utils.error".get_error
local Users     = models.users
local role      = {}

-- User must be the Owner
function role:owner()
	if self.api_user.role ~= Users.role.OWNER then
		return nil, get_error.unauthorized_access()
	end

	return true
end

-- User must be an Admin or higher
function role:admin()
	if self.api_user.role < Users.role.ADMIN then
		return nil, get_error.unauthorized_access()
	end

	return true
end

-- User must be a Mod or higher
function role:mod()
	if self.api_user.role < Users.role.MOD then
		return nil, get_error.unauthorized_access()
	end

	return true
end

-- User must be a Janitor or higher
function role:janitor()
	if self.api_user.role < Users.role.JANITOR then
		return nil, get_error.unauthorized_access()
	end

	return true
end

-- User must be signed in
function role:user()
	if self.api_user.role < Users.role.USER then
		return nil, get_error.unauthorized_access()
	end

	return true
end

return role
