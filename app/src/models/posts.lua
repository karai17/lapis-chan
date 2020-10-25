local encoding  = require "lapis.util.encoding"
local Model     = require("lapis.db.model").Model
local giflib    = require "giflib"
local magick    = require "magick"
local md5       = require "md5"
local filetypes = require "utils.file_whitelist"
local generate  = require "utils.generate"
local Posts     = Model:extend("posts", {
	relations = {
		{ "board",  belongs_to="Boards" },
		{ "thread", belongs_to="Threads" },
	}
})
local sf = string.format

local function get_duration(path)
	local cmd = sf("ffprobe -i %s -show_entries format=duration -v quiet -of csv=\"p=0\" -sexagesimal", path)
	local f = io.popen(cmd, "r")
	local s = f:read("*a")
	f:close()

	local hr, mn, sc = string.match(s, "(%d+):(%d+):(%d+).%d+")
	local d = mn..":"..sc

	if hr ~= "0" then
		d = hr..":"..d
	end

	return d
end

--- Prepare post for insertion
-- @tparam table params Input from the user
-- @tparam table session User session
-- @tparam table board Board data
-- @tparam table thread Thread data
-- @tparam number files Number of files in thread
-- @treturn boolean success
-- @treturn string error
function Posts:prepare_post(params, session, board, thread, files)
	-- FIXME: this whole function should be web-side, not api-side
	local time = os.time()

	-- Prepare session stuff
	session.password = session.password or generate.password(time)

	-- Save names on individual boards
	-- TODO: Put this code elsewhere
	if params.name then
		session.names[board.name] = params.name
	end

	-- Files take presidence over drawings, but if there is no file, fill in
	-- the file fields with draw data. This should avoid ugly code branching
	-- later on in the file.
	-- TODO: send file data through api!
	params.file = params.file or {
		filename = "",
		content  = ""
	}

	if #params.file.content == 0 and params.draw then
		local pattern        = ".-,(.+)"
		params.draw          = params.draw:match(pattern)
		params.file.filename = "tegaki.png"
		params.file.content  = encoding.decode_base64(params.draw)
	end

	-- Check board flags
	if thread then
		if thread.lock and not session.admin and not session.mod then
			return false, { "err_locked_thread", { thread.post_id } }
		end

		if board.post_comment and not params.comment then
			return false, { "err_comment_post" }
		end

		if board.post_file and #params.file.content == 0 then
			return false, { "err_file_post" }
		end
	else
		if board.thread_comment and not params.comment then
			return false, { "err_comment_thread" }
		end

		if board.thread_file and #params.file.content == 0 then
			return false, { "err_file_thread" }
		end
	end

	-- Parse name
	if params.name then
		params.name, params.trip = generate.tripcode(params.name)
	end

	-- Set file
	if #params.file.content > 0 then

		-- Reject files in text-only boards
		if board.text_only then
			return false, { "err_no_files" }
		end

		-- Thread limit is already met.
		if thread then
			if files >= board.thread_file_limit and not thread.size_override then
				return false, { "err_file_limit", { thread.post_id } }
			end
		end

		local name = sf("%s%s", time, generate.random())
		local ext  = params.file.filename:match("^.+(%..+)$")
		ext = string.lower(ext)

		-- Figure out how to deal with the file
		if filetypes.image[ext] and board.filetype_image then
			params.file_type = "image"

			if ext ~= ".webm" then
				-- Check if valid image
				local image = magick.load_image_from_blob(params.file.content)

				if not image then
					return false, { "err_invalid_image" }
				end

				params.file_width  = image:get_width()
				params.file_height = image:get_height()
			end
		elseif filetypes.audio[ext] and board.filetype_audio then
			params.file_type = "audio"
		else
			return false, { "err_invalid_ext", { ext } }
		end

		params.file_name   = params.file.filename
		params.file_path   = name .. ext
		params.file_md5    = md5.sumhexa(params.file.content)
		params.file_size   = #params.file.content

		if params.file_spoiler then
			params.file_spoiler = true
		else
			params.file_spoiler = false
		end

		-- Check if file already exists
		local file = self:find_file(board.id, params.file_md5)
		if file then
			return false, { "err_file_exists" }
		end
	else
		params.file_spoiler = false
	end

	-- Check contributions
	if not params.comment and not params.file_name then
		return false, { "err_contribute" }
	end

	return true
end

--- Create a new post
-- @tparam table params Post parameters
-- @tparam table board Board data
-- @tparam boolean op OP flag
-- @treturn boolean success
-- @treturn string error
function Posts:new(params, board, op)

	-- Create post
	local post = self:create(params)
	if not post then
		return false, { "err_create_post" }
	end

	-- Save file
	if post.file_path then
		local dir       = sf("./static/%s/", board.name)
		local name, ext = post.file_path:match("^(.+)%.(.+)$")
		ext = string.lower(ext)

		-- Filesystem paths
		local full_path  = dir .. post.file_path
		local thumb_path = dir .. "s" .. post.file_path

		-- Save file
		local file = io.open(full_path, "w")
		file:write(params.file_content)
		file:close()

		-- Audio file
		if post.file_type == "audio" then
			post.file_duration = get_duration(full_path)
			post:update("file_duration")
			return post
		end

		-- Image file
		if post.file_type == "image" and not post.file_spoiler then

			-- Save thumbnail
			local w, h
			if op then
				w = post.file_width  < 250 and post.file_width  or 250
				h = post.file_height < 250 and post.file_height or 250
			else
				w = post.file_width  < 125 and post.file_width  or 125
				h = post.file_height < 125 and post.file_height or 125
			end

			-- Generate a thumbnail
			if ext == "webm" then
				thumb_path = dir .. "s" .. name .. ".png"

				-- Create screenshot of first frame
				os.execute(sf("ffmpeg -i %s -ss 00:00:01 -vframes 1 %s -y", full_path, thumb_path))

				-- Update post info
				local image        = magick.load_image(thumb_path)
				post.file_width    = image:get_width()
				post.file_height   = image:get_height()
				post.file_duration = get_duration(full_path)
				post:update("file_width", "file_height", "file_duration")

				-- Resize thumbnail
				magick.thumb(thumb_path, sf("%sx%s", w, h), thumb_path)

			elseif ext == "svg" then
				thumb_path = dir .. "s" .. name .. ".png"
				os.execute(sf("convert -background none -resize %dx%d %s %s", w, h, full_path, thumb_path))

			elseif ext == "gif" then
				local gif, err = giflib.load_gif(full_path)

				if err then
					-- Not animated I presume? TODO: check what err represents
					magick.thumb(full_path, sf("%sx%s", w, h), thumb_path)
				else
					-- Grab first frame of a gif instead of the last
					gif:write_first_frame(thumb_path)

					-- Update post info
					local width, height = gif:dimensions()
					post.file_width     = width
					post.file_height    = height
					post:update("file_width", "file_height")

					-- Resize thumbnail
					magick.thumb(thumb_path, sf("%sx%s", w, h), thumb_path)
				end
			else
				magick.thumb(full_path, sf("%sx%s", w, h), thumb_path)
			end
		end
	end

	-- Update board
	board:update("total_posts")

	return post
end

--- Delete post data
-- @tparam number id Post ID
-- @treturn boolean success
-- @treturn string error
function Posts:delete(id)

	-- Get post
	local post, err = self:get_post_by_id(id)
	if not post then
		return false, err
	end

	-- Delete post
	local success, err = post:delete()
	if not success then
		return false, err--{ "err_delete_post", { post.post_id } }
	end

	-- Delete files
	if post.file_path then
		local board     = post:get_board()
		local dir       = sf("./static/%s/", board.name)
		local name, ext = post.file_path:match("^(.+)%.(.+)$")
		ext = string.lower(ext)
		os.remove(dir .. post.file_path)

		-- Change thumbnail path to png
		if ext == "webm" or ext == "svg" then
			post.file_path = name .. ".png"
		end

		os.remove(dir .. "s" .. post.file_path)
	end

	return post
end

--- Get op and last 5 posts of a thread to display on board index
-- @tparam number thread_id Thread ID
-- @treturn table posts
function Posts:get_index_posts(thread_id)
	local sql = "where thread_id=? order by post_id desc limit 5"
	local posts = self:select(sql, thread_id)

	if self:count_posts(thread_id) > 5 then
		local thread = posts[1]:get_thread()
		local op     = thread:get_op()
		table.insert(posts, op)
	end

	return posts
end

--- Get post data
-- @tparam number board_id Board ID
-- @tparam number post_id Local Post ID
-- @treturn table post
function Posts:get(board_id, post_id)
	local post = self:find {
		board_id = board_id,
		post_id  = post_id
	}
	return post and post or false, "FIXME"
end

--- Get post data
-- @tparam number id Post ID
-- @treturn table post
function Posts:get_post_by_id(id)
	local post = self:find(id)
	return post and post or false, "FIXME"
end

--- Find file in active posts
-- @tparam number board Board ID
-- @tparam string file_md5 Unique hash of file
-- @treturn boolean success
-- @treturn string error
function Posts:find_file(board_id, file_md5)
	local sql  = "where board_id=? and file_md5=? limit 1"
	return unpack(self:select(sql, board_id, file_md5))
end


--- Count hidden posts in a thread
-- @tparam number thread_id Thread ID
-- @treturn table hidden
function Posts:count_hidden_posts(thread_id)
	local posts     = self:get_index_posts(thread_id)
	local num_posts = self:count_posts(thread_id)
	local num_files = self:count_files(thread_id)

	for _, post in ipairs(posts) do
		-- Reduce number of posts hidden
		num_posts = num_posts - 1

		-- Reduce number of files hidden
		if post.file_name then
			num_files = num_files - 1
		end
	end

	return { posts=num_posts, files=num_files }
end

--- Count posts in a thread
-- @tparam number thread_id Thread ID
-- @treturn number posts
function Posts:count_posts(thread_id)
	local sql = "thread_id=?"
	return self:count(sql, thread_id)
end

--- Count posts with images in a thread
-- @tparam number thread_id Thread ID
-- @treturn number files
function Posts:count_files(thread_id)
	local sql = "thread_id=? and file_name is not null"
	return self:count(sql, thread_id)
end

return Posts
