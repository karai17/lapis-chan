local trim  = require("lapis.util").trim_filter
local Model = require("lapis.db.model").Model
local Bans  = Model:extend("bans")

--- Create a new ban
-- @tparam table ban Ban data
-- @treturn boolean success
-- @treturn string err
function Bans:create_ban(ban)
	-- Trim white space
	trim(ban, {
		"board", "thread", "post_id", "banned",
		"ip", "board_id", "reason", "duration",
	}, nil)

	local ban = self:create {
		ip       = ban.ip,
		board_id = ban.board_id,
		reason   = ban.reason,
		time     = os.time(),
		duration = (ban.duration and ban.duration or 3) * 24 * 60 * 60
	}

	if ban then
		return ban
	else
		return false, "err_create_ban", { ban.ip }
	end
end

--- Delete ban
-- @tparam table ban Ban data
-- @treturn boolean success
-- @treturn string err
function Bans:delete_ban(ban)
	return ban:delete()
end

--- Validate ban
-- @tparam table ban Ban data
-- @treturn boolean valid
function Bans:validate_ban(ban)
	local time   = os.time()
	local finish = ban.time + ban.duration

	if time >= finish then
		self:delete_ban(ban)
		return false
	end

	return true
end

--- Get all bans
-- @treturn table users List of bans
function Bans:get_bans()
	local sql  = "order by board_id asc, time + duration desc, ip asc"
	local bans = self:select(sql)

	for i=#bans, 1, -1 do
		local ban   = bans[i]
		local valid = self:validate_ban(ban)

		if not valid then
			table.remove(bans, i)
		end
	end

	return bans
end

--- Get ban
-- @tparam string ip IP address
-- @treturn table ban
function Bans:get_bans_by_ip(ip)
	local bans = self:select("where ip=?", ip)

	for i=#bans, 1, -1 do
		local ban   = bans[i]
		local valid = self:validate_ban(ban)

		if not valid then
			table.remove(bans, i)
		end
	end

	return bans
end

return Bans
