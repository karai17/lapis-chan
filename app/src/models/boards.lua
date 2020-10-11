local db     = require "lapis.db"
local giflib = require "giflib"
local lfs    = require "lfs"
local magick = require "magick"
local Model  = require("lapis.db.model").Model
local Boards = Model:extend("boards", {
	relations = {
		{ "announcements", has_many="Announcements" },
		{ "bans",          has_many="Bans" },
		{ "posts",         has_many="Posts" },
		{ "reports",       has_many="Reports" },
		{ "threads",       has_many="Threads", where={ archive=false }, order="sticky desc, last_active desc" },
		{ "archived",       has_many="Threads", where={ archive=true },  order="last_active desc" },
	}
})

Boards.valid_record = {
	{ "short_name",        max_length=255, exists=true },
	{ "name",              max_length=255, exists=true },
	{ "subtext",           max_length=255 },
	{ "ban_message",       max_length=255 },
	{ "anon_name",         max_length=255 },
	{ "theme",             max_length=255 },
	{ "pages",             exists=true },
	{ "threads_per_page",  exists=true },
	{ "thread_file_limit", exists=true },
	{ "post_limit",        exists=true },
	{ "archive_time",      exists=true },
	{ "group",             exists=true }
}

--- Create a board
-- @tparam table params Board parameters
-- @treturn boolean success
-- @treturn string error
function Boards:new(params)
	local board = self:create(params)
	if not board then
		return false, { "err_create_board", { params.short_name, params.name } }
	end

	lfs.mkdir(string.format("./static/%s/", board.short_name))
	return board
end

--- Modify a board
-- @tparam table params Board parameters
-- @tparam old_short_name Board's current short name
-- @treturn boolean success
-- @treturn string error
function Boards:modify(params, old_short_name)
	local board = self:get(old_short_name)
	if not board then
		return false, { "err_create_board", { params.short_name, params.name } } -- FIXME: wrong error message
	end

	local success, err = board:update(params)
	if not success then
		return false, "FIXME: " .. tostring(err)
	end

	if board.short_name ~= old_short_name then
		local old = string.format("./static/%s/", old_short_name)
		local new = string.format("./static/%s/", board.short_name)
		os.rename(old, new)
	end

	return board
end

--- Delete a board
-- @tparam string short_name Board's short name
-- @treturn boolean success
-- @treturn string error
function Boards:delete(short_name)
	local board = self:get(short_name)
	if not board then
		return false, { "err_create_board", { short_name, short_name } } -- FIXME: wrong error message
	end

	local announcements = board:get_announcements()
	local bans          = board:get_bans()
	local posts         = board:get_posts()
	local reports       = board:get_reports()
	local threads       = board:get_threads()
	local dir           = string.format("./static/%s/", board.short_name)

	-- Clear data
	for _, announcement in ipairs(announcements) do announcement:delete() end
	for _, ban          in ipairs(bans)          do ban:delete()          end
	for _, post         in ipairs(posts)         do post:delete()         end
	for _, report       in ipairs(reports)       do report:delete()       end
	for _, thread       in ipairs(threads)       do thread:delete()       end

	-- Clear filesystem
	if lfs.attributes(dir, "mode") == "directory" then
		-- Delete files
		for file in lfs.dir(dir) do
			os.remove(dir .. file)
		end

		-- Delete directory
		lfs.rmdir(dir)
	end

	-- Clear board
	local success = board:delete()
	return success and board or false, { "err_delete_board", { board.short_name, board.name } }
end

--- Get all boards
-- @treturn table boards
function Boards:get_all()
	local boards = self:select("order by boards.group asc, short_name asc")
	return boards and boards or false, "FIXME: ALART!"
end

--- Get board data
-- @tparam string short_name Board's short name
-- @treturn table board
function Boards:get(short_name)
	local board = self:find { short_name=short_name }
	return board and board or false, "FIXME: ALART!"
end

--- Format board paramaters for DB insertion
-- @tparam table params Board parameters
function Boards.format_to_db(_, params)
	-- Convert archive_time from days to seconds
	params.archive_time = (tonumber(params.archive_time) or 0) * 86400
end

--- Format board parameters for User consumption
-- @tparam table params Board parameters
function Boards.format_from_db(_, params)
	-- Convert archive_time from seconds to days
	params.archive_time = tonumber(params.archive_time) / 86400
end

--- Regenerate thumbnails for all posts
-- @treturn none
function Boards.regen_thumbs(_)
	local sql = [[
		select
			boards.short_name as board,
			posts.thread_id,
			posts.file_path,
			posts.file_width,
			posts.file_height,
			posts.file_type
		from posts
		left join boards on
			board_id = boards.id
		where
			file_path   is not null and
			file_width  is not null and
			file_height is not null and
			file_type    = 'image'  and
			file_spoiler = false
		order by
			board_id  asc,
			thread_id asc,
			post_id   asc
	]]
	local dir
	local board
	local thread  = 0
	local results = db.query(sql)

	for _, result in ipairs(results) do
		-- Change board, reset thread counter and image directory
		if result.board ~= board then
			board  = result.board
			thread = 0
			dir    = string.format("./static/%s/", board)
		end

		-- Filesystem paths
		local name, ext = result.file_path:match("^(.+)(%..+)$")
		ext = string.lower(ext)

		local full_path  = dir .. result.file_path
		local thumb_path = dir .. "s" .. result.file_path

		-- Generate a thumbnail
		if ext == ".webm" then
			thumb_path = dir .. "s" .. name .. ".png"

			-- Create screenshot of first frame
			os.execute(string.format("ffmpeg -i %s -ss 00:00:01 -vframes 1 %s -y", full_path, thumb_path))
		end

		-- Save thumbnail
		local w, h
		if result.thread_id > thread then
			thread = result.thread_id
			w = result.file_width  < 250 and result.file_width  or 250
			h = result.file_height < 250 and result.file_height or 250
		else
			w = result.file_width  < 125 and result.file_width  or 125
			h = result.file_height < 125 and result.file_height or 125
		end

		-- Grab first frame from video
		if ext == ".webm" then
			magick.thumb(thumb_path, string.format("%sx%s", w, h), thumb_path)
		elseif ext == ".svg" then
			thumb_path = dir .. "s" .. name .. ".png"
			os.execute(string.format("convert -background none -resize %dx%d %s %s", w, h, full_path, thumb_path))
		elseif ext == ".gif" then
			-- Grab first frame of a gif instead of the last
			local gif, err = giflib.load_gif(full_path)

			if err then
				magick.thumb(full_path, string.format("%sx%s", w, h), thumb_path)
			else
				gif:write_first_frame(thumb_path)
				magick.thumb(thumb_path, string.format("%sx%s", w, h), thumb_path)
			end
		else
			magick.thumb(full_path, string.format("%sx%s", w, h), thumb_path)
		end
	end
end

return Boards
