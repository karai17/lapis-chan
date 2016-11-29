local encoding  = require "lapis.util.encoding"
local trim      = require("lapis.util").trim_filter
local Model     = require("lapis.db.model").Model
local giflib    = require "giflib"
local magick    = require "magick"
local md5       = require "md5"
local filetypes = require "utils.file_whitelist"
local generate  = require "utils.generate"
local Posts     = Model:extend("posts")
local sf        = string.format
local ss        = string.sub

--- Prepare post for insertion
-- @tparam table params Input from the user
-- @tparam table session User session
-- @tparam table board Board data
-- @tparam table thread Thread data
-- @tparam number files Number of files in thread
-- @treturn boolean success
-- @treturn string error
function Posts:prepare_post(params, session, board, thread, files)
	local time = os.time()

	-- Prepare session stuff
	session.password = session.password or generate.password(time, session)

	-- Trim white space
	trim(params, {
		"board", "thread", "sticky", "lock", "size_override", "save",
		"ip", "name",
		"subject", "options", "comment",
		"file", "file_spoiler", "draw"
	}, nil)

	-- Save names on individual boards
	if params.name then
		session.names[board.short_name] = params.name
	end

	-- Files take presidence over drawings, but if there is no file, fill in
	-- the file fields with draw data. This should avoid ugly code branching
	-- later on in the file.
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

		local name = sf("%s%s", time, ss(generate.random(time, params), -3))
		local ext  = params.file.filename:match("^.+(%..+)$") or ""

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
-- @tparam table params Input from the user
-- @tparam table session User session
-- @tparam table board Board data
-- @tparam table thread Thread data
-- @treturn boolean success
-- @treturn string error
function Posts:create_post(params, session, board, thread, op)
	board.posts = board.posts + 1

	-- Create post
	local post = self:create {
		post_id       = board.posts,
		thread_id     = thread.id,
		board_id      = board.id,
		timestamp     = os.time(),
		ip            = params.ip,
		comment       = params.comment,
		name          = params.name,
		trip          = params.trip,
		subject       = params.subject,
		password      = session.password,
		file_name     = params.file_name,
		file_path     = params.file_path,
		file_type     = params.file_type,
		file_md5      = params.file_md5,
		file_size     = params.file_size,
		file_width    = params.file_width,
		file_height   = params.file_height,
		file_duration = params.file_duration,
		file_spoiler  = params.file_spoiler
	}

	if post then
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

		-- Update board
		board:update("posts")

		if post.file_path then
			local ext  = post.file_path:match("^.+(%..+)$") or ""
			local dir  = sf("./static/%s/", board.short_name)

			-- Filesystem paths
			local full_path  = dir .. post.file_path
			local thumb_path = dir .. "s" .. post.file_path

			-- Save file
			local file = io.open(full_path, "w")
			file:write(params.file.content)
			file:close()

			-- Audio file
			if post.file_type == "audio" then
				post.file_duration = get_duration(full_path)
				post:update("file_duration")
				return post
			end

			-- Image file
			if post.file_type == "image" and not post.file_spoiler then
				-- Generate a thumbnail
				if ext == ".webm" then
					thumb_path = ss(thumb_path, 1, -6) .. ".png"

					-- Create screenshot of first frame
					os.execute(sf("ffmpeg -i %s -ss 00:00:01 -vframes 1 %s", full_path, thumb_path))

					local image        = magick.load_image(thumb_path)
					post.file_width    = image:get_width()
					post.file_height   = image:get_height()
					post.file_duration = get_duration(full_path)
					post:update("file_width", "file_height", "file_duration")
				end

				-- Save thumbnail
				local w, h
				if op then
					w = post.file_width  < 250 and post.file_width  or 250
					h = post.file_height < 250 and post.file_height or 250
				else
					w = post.file_width  < 125 and post.file_width  or 125
					h = post.file_height < 125 and post.file_height or 125
				end

				-- Grab first frame from video
				if ext == ".webm" then
					magick.thumb(thumb_path, sf("%sx%s", w, h), thumb_path)
					return post
				end

				-- Grab first frame of a gif instead of the last
				if ext == ".gif" then
					local gif, err = giflib.load_gif(full_path)

					if err then
						magick.thumb(full_path, sf("%sx%s", w, h), thumb_path)
					else
						gif:write_first_frame(thumb_path)
						magick.thumb(thumb_path, sf("%sx%s", w, h), thumb_path)

						-- gifs need to get dimension from the first frame
						local width, height = gif:dimensions()
						post.file_width     = width
						post.file_height    = height
						post:update("file_width", "file_height")
					end
				else
					magick.thumb(full_path, sf("%sx%s", w, h), thumb_path)
				end

				return post
			end
		end

		return post
	else
		return false, { "err_create_post" }
	end
end

--- Delete post data
-- @tparam table session User session
-- @tparam table board Board data
-- @tparam table post Post data
-- @treturn boolean success
-- @treturn string error
function Posts:delete_post(session, board, post)
	local function rm_post(short_name)
		if post.file_path then
			local dir = sf("./static/%s/", short_name)
			os.remove(dir .. post.file_path)

			-- Change path from webm to png
			if ss(post.file_path, -5) == ".webm" then
				post.file_path = ss(post.file_path, 1, -6) .. ".png"
			end

			os.remove(dir .. "s" .. post.file_path)
		end

		post:delete()
	end

	local success = false

	-- MODS = FAGS
	if type(session) == "table" and
		(session.admin or session.mod or session.janitor) then
		rm_post(board.short_name)
		success = true
	-- Override password
	elseif type(session) == "string" and
		session == "override" then
		rm_post(board.short_name)
		success = true
	-- Password has to match!
	elseif post and session.password and
		post.password == session.password then
		rm_post(board.short_name)
		success = true
	end

	if success then
		return success
	else
		return false, { "err_delete_post", { post.post_id } }
	end
end

--- Get all posts from board
-- @tparam number board_id Board ID
-- @treturn table posts
function Posts:get_posts(board_id)
	return self:select("where board_id=?", board_id)
end

--- Get posts from thread
-- @tparam number thread_id Thread ID
-- @treturn table posts
function Posts:get_posts_by_thread(thread_id)
	local sql = "where thread_id=? order by post_id asc"
	return self:select(sql, thread_id)
end

--- Get op from thread
-- @tparam number thread_id Thread ID
-- @treturn table post
function Posts:get_thread_op(thread_id)
	local sql = "where thread_id=? order by post_id asc limit 1"
	return unpack(self:select(sql, thread_id))
end

--- Get op and last 5 posts of a thread to display on board index
-- @tparam number thread_id Thread ID
-- @treturn table posts
function Posts:get_index_posts(thread_id)
	local sql = "where thread_id=? order by post_id desc limit 5"
	local posts = self:select(sql, thread_id)

	if self:count_posts(thread_id) > 5 then
		table.insert(posts, self:get_thread_op(thread_id))
	end

	return posts
end

--- Get post data
-- @tparam number board_id Board ID
-- @tparam number post_id Local Post ID
-- @treturn table post
function Posts:get_post(board_id, post_id)
	return unpack(self:select("where board_id=? and post_id=?", board_id, post_id))
end

--- Get post data
-- @tparam number id Post ID
-- @treturn table post
function Posts:get_post_by_id(id)
	return unpack(self:select("where id=?", id))
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
