local Model = require("lapis.db.model").Model
local Bans  = Model:extend("bans")

local db    = require "lapis.db"
local trim  = require("lapis.util").trim_filter
local model = {}

--- Create a new ban
-- @tparam table ban Ban data
-- @treturn boolean success
-- @treturn string err
function model.create_ban(ban)
	-- Trim white space
	trim(ban, {
		"board", "thread", "post_id", "banned",
		"ip", "board_id", "reason", "duration",
	}, nil)

	local ban, err = Bans:create {
		ip       = ban.ip,
		board_id = ban.board_id,
		reason   = ban.reason,
		time     = os.time(),
		duration = (ban.duration and ban.duration or 3) * 24 * 60 * 60
	}

	if ban then
		return ban
	else
		return false, err
	end
end

--- Delete ban
-- @tparam table ban Ban data
-- @treturn boolean success
-- @treturn string err
function model.delete_ban(ban)
	return ban:delete()
end

--- Validate ban
-- @tparam table ban Ban data
-- @treturn boolean valid
function model.validate_ban(ban)
	local time   = os.time()
	local finish = ban.time + ban.duration

	if time >= finish then
		model.delete_ban(ban)
		return false
	end

	return true
end

--- Get all bans
-- @treturn table users List of bans
function model.get_bans()
	local sql  = "order by board_id asc, time + duration desc, ip asc"
	local bans = Bans:select(sql)

	for i=#bans, 1, -1 do
		local ban   = bans[i]
		local valid = model.validate_ban(ban)

		if not valid then
			table.remove(bans, i)
		end
	end

	return bans
end

--- Get ban
-- @tparam string ip IP address
-- @treturn table ban
function model.get_ip_bans(ip)
	local bans = Bans:select("where ip=?", ip)

	for i=#bans, 1, -1 do
		local ban   = bans[i]
		local valid = model.validate_ban(ban)

		if not valid then
			table.remove(bans, i)
		end
	end

	return bans
end

return model
