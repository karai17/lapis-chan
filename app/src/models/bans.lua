local Model = require("lapis.db.model").Model
local Bans  = Model:extend("bans", {
	relations = {
		{ "board", belongs_to="Boards" },
	}
})

Bans.valid_record = {
	{ "ip",   max_length=255, exists=true },
	{ "time", exists=true }
}

--- Create a ban
-- @tparam table params Ban parameters
-- @treturn boolean success
-- @treturn string err
function Bans:new(params)
	local ban = self:create(params)
	return ban and ban or false, { "err_create_ban", { params.ip } }
end

--- Modify a ban
-- @tparam table params Board parameters
-- @treturn boolean success
-- @treturn string error
function Bans:modify(params)
	local ban = self:get(params.id)
	if not ban then
		return false, { "err_create_board", { params.short_name, params.name } } -- FIXME: wrong error message
	end

	local success, err = ban:update(params)
	return success and ban or false, "FIXME: " .. tostring(err)
end

--- Delete a ban
-- @tparam number id Ban's ID
-- @treturn boolean success
-- @treturn string err
function Bans:delete(id)
	local ban = self:get(id)
	if not ban then
		return false, "FIXME"
	end

	local success = ban:delete()
	return success and ban or false, "FIXME"
end

--- Get all bans
-- @treturn table users List of bans
function Bans:get_all()
	local bans = self:select("order by board_id asc, time + duration desc, ip asc")
	if not bans then
		return false, "FIXME"
	end

	for i=#bans, 1, -1 do
		local ban = bans[i]
		if not self:validate_ban(ban) then
			table.remove(bans, i)
		end
	end

	return bans
end

--- Get ban data
-- @tparam number id Ban's ID
-- @treturn table ban
function Bans:get(id)
	local ban = self:find(id)
	return ban and ban or false, "FIXME: ALART!"
end

--- Get bans for specific ip
-- @tparam string ip IP address
-- @treturn table ban
function Bans:get_ip(ip)
	local bans = self:select("where ip=?", ip)
	if not bans then
		return false, "FIXME"
	end

	for i=#bans, 1, -1 do
		local ban = bans[i]
		if not self:validate_ban(ban) then
			table.remove(bans, i)
		end
	end

	return bans
end

--- Validate ban
-- @tparam table ban Ban data
-- @treturn boolean valid
function Bans:validate_ban(ban)
	local time   = os.time()
	local finish = ban.time + ban.duration

	if time >= finish then
		self:delete(ban)
		return false
	end

	return true
end

--- Format ban paramaters for DB insertion
-- @tparam table params Ban parameters
function Bans.format_to_db(_, params)
	-- Convert duration from days to seconds
	params.duration = (tonumber(params.duration) or 0) * 86400
end

--- Format ban parameters for User consumption
-- @tparam table params Ban parameters
function Bans.format_from_db(_, params)
	-- Convert duration from seconds to days
	params.duration = tonumber(params.duration) / 86400
end

return Bans
