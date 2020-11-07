local models    = require "models"
local get_error = require "utils.error".get_error
local Users     = models.users
local role      = {}

-- User must be the Owner
function role.owner(user)
	return user.role == Users.role.OWNER and true or nil, get_error.unauthorized_access()
end

-- User must be an Admin or higher
function role.admin(user)
	return user.role >= Users.role.ADMIN and true or nil, get_error.unauthorized_access()
end

-- User must be a Mod or higher
function role.mod(user)
	return user.role >= Users.role.MOD and true or nil, get_error.unauthorized_access()
end

-- User must be a Janitor or higher
function role.janitor(user)
	return user.role >= Users.role.JANITOR and true or nil, get_error.unauthorized_access()
end

-- User must be signed in
function role.user(user)
	return user.role >= Users.role.USER and true or nil, get_error.unauthorized_access()
end

return role
