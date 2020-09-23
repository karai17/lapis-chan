local trim          = require("lapis.util").trim_filter
local Model         = require("lapis.db.model").Model
local Announcements = Model:extend("announcements")

--- Create an announcement
-- @tparam table ann Announcement data
-- @treturn boolean success
-- @treturn string error
function Announcements:create_announcement(ann)
	-- Trim white space
	trim(ann, {
		"board_id", "text"
	}, nil)

	local a = self:create {
		board_id = ann.board_id,
		text     = ann.text
	}

	if a then
		return a
	end

	return false, { "err_create_ann", { ann.text } }
end

--- Modify an announcement
-- @tparam table ann Announcement data
-- @treturn boolean success
-- @treturn string error
function Announcements:modify_announcement(ann)
	local columns = {}
	for col in pairs(ann) do
		table.insert(columns, col)
	end

	return ann:update(unpack(columns))
end

--- Delete an announcement
-- @tparam table ann Announcement data
-- @treturn boolean success
-- @treturn string error
function Announcements:delete_announcement(ann)
	return ann:delete()
end

--- Get all announcements
-- @treturn table announcements
function Announcements:get_announcements()
	return self:select("order by board_id asc")
end

--- Get announcements
-- @tparam number board_id Board ID
-- @treturn table announcements
function Announcements:get_board_announcements(board_id)
	local sql = [[
		where
			board_id = ? or
			board_id = 0
		order by
			board_id asc
	]]
	return self:select(sql, board_id)
end

--- Get announcement
-- @tparam number id Announcement ID
-- @treturn table announcement
function Announcements:get_announcement(id)
	return unpack(self:select("where id=? limit 1", id))
end

return Announcements
