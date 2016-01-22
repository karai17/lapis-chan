local Model = require("lapis.db.model").Model
local Users = Model:extend("users")

local bcrypt   = require "bcrypt"
local trim     = require("lapis.util").trim_filter
local token    = require "secrets.token"
local generate = require "utils.generate"
local model    = {}

--- Create a new user
-- @tparam table user User data
-- @treturn boolean success
-- @treturn string error
function model.create_user(user)
	local hash = generate.hash(user.username .. user.password .. token)
	user.password = nil

	local user, error = Users:create {
		username = user.username,
		password = hash,
		admin    = user.admin,
		mod      = user.mod,
		janitor  = user.janitor
	}

	if user then
		return user
	else
		return false, error
	end
end

--- Modify a user
-- @tparam table user User data
-- @treturn boolean success
-- @treturn string error
function model.modify_user(user)
	local columns = {}
	for col in pairs(user) do
		table.insert(columns, col)
	end

	return user:update(unpack(columns))
end

--- Delete user
-- @tparam table user User data
-- @treturn boolean success
-- @treturn string error
function model.delete_user(user)
	return user:delete()
end

--- Verify user
-- @tparam table params User data
-- @treturn boolean success
-- @treturn string error
function model.verify_user(params)
	local user = model.get_user(params.username)

	-- No user found with that username
	if not user then
		return false, "Invalid username or password"
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
		return false, "Invalid username or password"
	end
end

--- Get all users
-- @treturn table users List of users
function model.get_users()
	return Users:select("order by username asc")
end

--- Get user
-- @tparam string username Username
-- @treturn table user
function model.get_user(username)
	local username = string.lower(username)
	return unpack(Users:select("where lower(username)=? limit 1", username))
end

--- Get user by ID
-- @tparam number id User ID
-- @treturn table user
function model.get_user_by_id(id)
	return unpack(Users:select("where id=? limit 1", id))
end

return model
