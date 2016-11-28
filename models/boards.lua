local db     = require "lapis.db"
local trim   = require("lapis.util").trim_filter
local giflib = require "giflib"
local lfs    = require "lfs"
local magick = require "magick"
local Model  = require("lapis.db.model").Model
local Boards = Model:extend("boards")

--- Create a board
-- @tparam table board Board data
-- @treturn boolean success
-- @treturn string error
function Boards:create_board(board)
	-- Trim white space
	trim(board, {
		"short_name", "name", "subtext", "rules",
		"anon_name", "theme",
		"posts", "pages", "threads_per_page", "text_only", "filetype_image", "filetype_audio", "draw",
		"thread_file", "thread_comment", "thread_file_limit",
		"post_file", "post_comment", "post_limit",
		"archive", "archive_time", "group"
	}, nil)

	local board = self:create {
		short_name        = board.short_name,
		name              = board.name,
		subtext           = board.subtext,
		rules             = board.rules,
		anon_name         = board.anon_name,
		theme             = board.theme,
		posts             = board.posts,
		pages             = board.pages,
		threads_per_page  = board.threads_per_page,
		text_only         = board.text_only,
		filetype_image    = board.filetype_image,
		filetype_audio    = board.filetype_audio,
		draw              = board.draw,
		thread_file       = board.thread_file,
		thread_comment    = board.thread_comment,
		thread_file_limit = board.thread_file_limit,
		post_file         = board.post_file,
		post_comment      = board.post_comment,
		post_limit        = board.post_limit,
		archive           = board.archive,
		archive_time      = board.archive_time,
		group             = board.group
	}

	if board then
		lfs.mkdir(string.format("./static/%s/", board.short_name))
		return board
	end

	return false, "err_create_board", { board.short_name, board.name }
end

--- Modify a board.
-- @tparam table board Board data
-- @treturn boolean success
-- @treturn string error
function Boards:modify_board(board, old_short_name)
	local columns = {}
	for col in pairs(board) do
		table.insert(columns, col)
	end

	if board.short_name ~= old_short_name then
		local old = string.format("./static/%s/", old_short_name)
		local new = string.format("./static/%s/", board.short_name)
		os.rename(old, new)
	end

	return board:update(unpack(columns))
end

--- Delete a board.
-- @tparam table board Board data
-- @tparam table threads List of threads
-- @tparam table posts List of posts
-- @treturn boolean success
-- @treturn string error
function Boards:delete_board(board, threads, posts)
	local dir = string.format("./static/%s/", board.short_name)

	-- Clear posts
	for _, post in ipairs(posts) do
		post:delete()
	end

	-- Clear threads
	for _, thread in ipairs(threads) do
		thread:delete()
	end

	-- Clear board
	board:delete()

	-- Clear filesystem
	if lfs.attributes(dir, "mode") == "directory" then
		-- Delete files
		for file in lfs.dir(dir) do
			os.remove(dir .. file)
		end

		-- Delete directory
		return lfs.rmdir(dir)
	end

	return false, "err_delete_board", { board.short_name, board.name }
end

--- Get all boards
-- @treturn table boards
function Boards:get_boards()
	return self:select("order by boards.group asc, short_name asc")
end

--- Get board data
-- @tparam number id Board ID or Board short name
-- @treturn table board
function Boards:get_board(id)
	if type(id) == "number" then
		return self:find(id)
	else
		return self:find { short_name = id }
	end
end

--- Regenerate thumbnails for all posts
-- @treturn none
function Boards:regen_thumbs()
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
		local ext        = result.file_path:match("^.+(%..+)$")
		local full_path  = dir .. result.file_path
		local thumb_path = dir .. "s" .. result.file_path

		-- Generate a thumbnail
		if ext == ".webm" then
			-- Create screenshot of first frame
			thumb_path = thumb_path:sub(1, -6) .. ".png"
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
		end

		-- Grab first frame of a gif instead of the last
		if ext == ".gif" then
			local gif, err = giflib.load_gif(full_path)

			if err then
				magick.thumb(full_path, string.format("%sx%s", w, h), thumb_path)
			else
				gif:write_first_frame(thumb_path)
				magick.thumb(thumb_path, string.format("%sx%s", w, h), thumb_path)
			end
		elseif ext ~= ".webm" then
			magick.thumb(full_path, string.format("%sx%s", w, h), thumb_path)
		end
	end
end

return Boards
