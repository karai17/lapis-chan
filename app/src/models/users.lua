local bcrypt   = require "bcrypt"
local config   = require("lapis.config").get()
local trim     = require("lapis.util").trim_filter
local Model    = require("lapis.db.model").Model
local Users    = Model:extend("users")
local token    = config.secret

Users.role = {
	[1] = "USER",
	[6] = "JANITOR",
	[7] = "MOD",
	[8] = "ADMIN",
	[9] = "OWNER",

	USER    = 1,
	JANITOR = 6,
	MOD     = 7,
	ADMIN   = 8,
	OWNER   = 9
}

Users.default_key = "00000000-0000-0000-0000-000000000000"

--- Create a new user
-- @tparam table user User data
-- @treturn boolean success
-- @treturn string error
function Users:create_user(user)
	-- Trim white space
	trim(user, {
		"username", "password",
		"admin", "mod", "janitor"
	}, nil)

	-- Generate hash and remove raw password from memory
	local hash = generate.hash(user.username .. user.password .. token)
	user.password = nil

	local u = self:create {
		username = user.username,
		password = hash,
		admin    = user.admin,
		mod      = user.mod,
		janitor  = user.janitor
	}

	if u then
		return u
	end

	return false, { "err_create_user", { user.username } }
end

--- Modify a user
-- @tparam table user User data
-- @treturn boolean success
-- @treturn string error
function Users:modify_user(user)
	local columns = {}
	for col in pairs(user) do
		table.insert(columns, col)
	end

	-- Generate hash
	if user.password then
		user.password = generate.hash(user.username .. user.password .. token)
	end

	return user:update(unpack(columns))
end

--- Delete user
-- @tparam table user User data
-- @treturn boolean success
-- @treturn string error
function Users:delete_user(user)
	return user:delete()
end

--- Verify user
-- @tparam table params User data
-- @treturn boolean success
-- @treturn string error
function Users:verify_user(params)
	local user = self:get_user(params.username)

	-- No user found with that username
	if not user then
		return false, { "err_invalid_user" }
	end

	-- Prepare password and remove raw password from memory
	local password = user.username .. params.password .. token
	params.password = nil

	-- Verify password and remove prepared password from memory
	local verified = bcrypt.verify(password, user.password)
	password = nil

	if verified then
		return user
	else
		return false, { "err_invalid_user" }
	end
end

--- Get all users
-- @treturn table users List of users
function Users:get_all()
	local users = self:select("order by username asc")
	return users and users or nil, "FIXME"
end

--- Get user
-- @tparam string username Username
-- @treturn table user
function Users:get_user(username)
	username = string.lower(username)
	return unpack(self:select("where lower(username)=? limit 1", username))
end

--- Get user by ID
-- @tparam number id User ID
-- @treturn table user
function Users:get_user_by_id(id)
	return unpack(self:select("where id=? limit 1", id))
end

function Users:get_api(params)
	local user = self:find(params)
	return user and user or nil, "FIXME"
end

return Users
