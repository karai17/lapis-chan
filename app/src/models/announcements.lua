local Model         = require("lapis.db.model").Model
local Announcements = Model:extend("announcements", {
	relations = {
		{ "board", belongs_to="Boards" }
	}
})

Announcements.valid_record = {
	{ "board_id", is_integer=true },
	{ "text",     exists=true }
}

--- Create an announcement
-- @tparam table params Announcement parameters
-- @treturn boolean success
-- @treturn string error
function Announcements:new(params)
	local announcement = self:create(params)
	return announcement and announcement or nil, { "err_create_ann", { params.text } }
end

--- Modify an announcement
-- @tparam table params Announcement parameters
-- @treturn boolean success
-- @treturn string error
function Announcements:modify(params)
	local announcement = self:get(params.id)
	if not announcement then
		return nil, { "err_create_ann", { params.text } } -- FIXME: wrong error
	end

	local success, err = announcement:update(params)
	return success and announcement or nil, "FIXME: " .. tostring(err)
end

--- Delete an announcement
-- @tparam number id Announcement ID
-- @treturn boolean success
-- @treturn string error
function Announcements:delete(id)
	local announcement = self:get(id)
	if not announcement then
		return nil, "FIXME"
	end

	local success = announcement:delete()
	return success and announcement or nil, "FIXME"
end

--- Get all announcements
-- @treturn boolean success
-- @treturn string error
function Announcements:get_all()
	local announcements = self:select("order by board_id asc")
	return announcements and announcements or nil, "FIXME"
end

--- Get announcements
-- @tparam number board_id Board ID
-- @treturn boolean success
-- @treturn string error
function Announcements:get_global()
	local announcements = self:select("where board_id=0")
	return announcements and announcements or nil, "FIXME"
end

--- Get announcement
-- @tparam number id Announcement ID
-- @treturn boolean success
-- @treturn string error
function Announcements:get(id)
	local announcement = self:find(id)
	return announcement and announcement or nil, "FIXME"
end

function Announcements.format_to_db(_, params)
	if not params.board_id then
		params.board_id = 0
	end
end

function Announcements.format_from_db(_, params)
	if params.board_id == 0 then
		params.board_id = nil
	end
end

return Announcements
