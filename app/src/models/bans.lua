local Model = require("lapis.db.model").Model
local Bans  = Model:extend("bans", {
	relations = {
		{ "board", belongs_to="Boards" },
	}
})

Bans.valid_record = {
	{ "board_id", is_integer=true },
	{ "ip",       max_length=255, exists=true },
	{ "time",     exists=true }
}

--- Create a ban
-- @tparam table params Ban parameters
-- @treturn boolean success
-- @treturn string err
function Bans:new(params)
	local ban = self:create(params)
	return ban and ban or nil, { "err_create_ban", { params.ip } }
end

--- Modify a ban
-- @tparam table params Board parameters
-- @treturn boolean success
-- @treturn string error
function Bans:modify(params)
	local ban = self:get(params.id)
	if not ban then
		return nil, { "err_create_board", { params.name, params.title } } -- FIXME: wrong error message
	end

	local success, err = ban:update(params)
	return success and ban or nil, "FIXME: " .. tostring(err)
end

--- Delete a ban
-- @tparam number id Ban's ID
-- @treturn boolean success
-- @treturn string err
function Bans:delete(id)
	local ban = self:get(id)
	if not ban then
		return nil, "FIXME"
	end

	local success = ban:delete()
	return success and ban or nil, "FIXME"
end

--- Get all bans
-- @treturn table users List of bans
function Bans:get_all()
	local bans = self:select("order by board_id asc, time + duration desc, ip asc")

	for i=#bans, 1, -1 do
		local ban = bans[i]
		if not self:validate(ban) then
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
	if not ban then
		return nil, "FIXME: ALART!"
	end

	local valid, err = self:validate(ban)
	if not valid then
		return nil, err
	end

	return ban
end

--- Get bans for specific ip
-- @tparam string ip IP address
-- @treturn table ban
function Bans:get_ip(ip)
	local bans = self:select("where ip=?", ip)

	for i=#bans, 1, -1 do
		local ban = bans[i]
		if not self:validate(ban) then
			table.remove(bans, i)
		end
	end

	return bans
end

--- Validate ban
-- @tparam table ban Ban data
-- @treturn boolean valid
function Bans:validate(ban)
	local time   = os.time()
	local finish = ban.time + ban.duration

	if time >= finish then
		self:delete(ban)
		return nil, "FIXME: ban has exired"
	end

	return true
end

--- Format ban paramaters for DB insertion
-- @tparam table params Ban parameters
function Bans.format_to_db(_, params)
	-- Convert duration from days to seconds
	params.duration = (tonumber(params.duration) or 0) * 86400

	if not params.board_id then
		params.board_id = 0
	end
end

--- Format ban parameters for User consumption
-- @tparam table params Ban parameters
function Bans.format_from_db(_, params)
	-- Convert duration from seconds to days
	params.duration = tonumber(params.duration) / 86400

	if params.board_id == 0 then
		params.board_id = nil
	end
end

return Bans
