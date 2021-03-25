local bcrypt = require "bcrypt"
local uuid   = require "resty.jit-uuid"
local config = require("lapis.config").get()
local Model  = require("lapis.db.model").Model
local Users  = Model:extend("users")
local token  = config.secret

Users.role = {
	[-1] = "INVALID",
	[1]  = "USER",
	[6]  = "JANITOR",
	[7]  = "MOD",
	[8]  = "ADMIN",
	[9]  = "OWNER",

	INVALID = -1,
	USER    = 1,
	JANITOR = 6,
	MOD     = 7,
	ADMIN   = 8,
	OWNER   = 9
}

Users.valid_record = {
	{ "username", exists=true },
	{ "role",     exists=true, is_integer=true }
}

Users.default_key = "00000000-0000-0000-0000-000000000000"

--- Create a new user
-- @tparam table user User data
-- @treturn boolean success
-- @treturn string error
function Users:new(params, raw_password)

	-- Check if username is unique
	do
		local unique, err = self:is_unique(params.username)
		if not unique then return nil, err end
	end

	-- Verify password
	do
		local valid, err = self:validate_password(params.password, params.confirm, raw_password)
		if not valid then return nil, err end

		params.confirm  = nil
		params.password = bcrypt.digest(params.username:lower() .. params.password .. token, 12)
	end

	-- Generate unique API key
	do
		local api_key, err = self:generate_api_key()
		if not api_key then return nil, err end

		params.api_key = api_key
	end

	local user = self:create(params)
	return user and user or nil, { "err_create_user", { params.username } }
end

--- Modify a user
-- @tparam table user User data
-- @treturn boolean success
-- @treturn string error
function Users:modify(params, raw_username, raw_password)
	local user = self:get(raw_username)
	if not user then return nil, "FIXME" end

	-- Check if username is unique
	do
		local unique, err, u = self:is_unique(params.username)
		if not unique and user.id ~= u.id then return nil, err end
	end

	-- Verify password
	if params.password then
		local valid, err = self:validate_password(params.password, params.confirm, raw_password)
		if not valid then return nil, err end

		params.confirm  = nil
		params.password = bcrypt.digest(params.username:lower() .. params.password .. token, 12)
	end

	-- Generate unique API key
	if params.api_key then
		local api_key, err = self:generate_api_key()
		if not api_key then return nil, err end

		params.api_key = api_key
	end

	local success, err = user:update(params)
	return success and user or nil, "FIXME: " .. tostring(err)
end

--- Delete user
-- @tparam table user User data
-- @treturn boolean success
-- @treturn string error
function Users:delete(username)
	local user = self:get(username)
	if not user then
		return nil, "FIXME"
	end

	local success = user:delete()
	return success and user or nil, "FIXME"
end

--- Verify user
-- @tparam table params User data
-- @treturn boolean success
-- @treturn string error
function Users:login(params)
	local user = self:get(params.username)
	if not user then return nil, { "err_invalid_user" } end

	local password = user.username .. params.password .. token
	local verified = bcrypt.verify(password, user.password)

	return verified and user or nil, { "err_invalid_user" }
end

--- Get all users
-- @treturn table users List of users
function Users:get_all()
	local users = self:select("order by username asc")
	return users
end

--- Get user
-- @tparam string username Username
-- @treturn table user
function Users:get(username)
	local users = self:select("where lower(username)=? limit 1", username:lower())
	return #users == 1 and users[1] or nil, "FIXME"
end

function Users:get_api(params)
	local user = self:find(params)
	return user and user or nil, "FIXME"
end

function Users:format_to_db(params)
	if not params.role then
		params.role = self.role.INVALID
	end
end

function Users.format_from_db(_, params)
	params.password = nil
	params.api_key  = nil
end

function Users:is_unique(username)
	local user = self:get(username)
	return not user and true or nil, "FIXME", user
end

function Users.validate_password(_, password, confirm, old_password)
	if password ~= confirm or password ~= old_password then
		return nil, "FIXME"
	end

	return true
end

function Users:generate_api_key()
	for _ = 1, 10 do
		local api_key = uuid()
		local user    = self:find { api_key=api_key }
		if not user then return api_key end
	end

	return nil, "FIXME"
end

return Users
