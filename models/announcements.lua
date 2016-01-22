local Model         = require("lapis.db.model").Model
local Announcements = Model:extend("announcements")

local db    = require "lapis.db"
local trim  = require("lapis.util").trim_filter
local model = {}

--- Create an announcement
-- @tparam table ann Announcement data
-- @treturn boolean success
-- @treturn string error
function model.create_announcement(ann)
	-- Trim white space
	trim(ann, { "board_id", "text" }, db.NULL)

	local ann = Announcements:create {
		board_id = ann.board_id,
		text     = ann.text
	}

	if ann then
		return ann
	end

	return false, "Could not create announcement."
end

--- Modify an announcement
-- @tparam table ann Announcement data
-- @treturn boolean success
-- @treturn string error
function model.modify_announcement(ann)
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
function model.delete_announcement(ann)
	ann:delete()
	return true
end

--- Get all announcements
-- @treturn table announcements
function model.get_announcements()
	return Announcements:select("order by board_id asc")
end

--- Get announcements
-- @tparam number board_id Board ID
-- @treturn table announcements
function model.get_board_announcements(board_id)
	local sql = [[
		where
			board_id = ? or
			board_id = 0
		order by
			board_id asc
	]]
	return Announcements:select(sql, board_id)
end

--- Get announcement
-- @tparam number id Announcement ID
-- @treturn table announcement
function model.get_announcement(id)
	return unpack(Announcements:select("where id=? limit 1", id))
end

return model
