local Model = require("lapis.db.model").Model
local Posts = Model:extend("posts")

local db        = require "lapis.db"
local trim      = require("lapis.util").trim_filter
local encoding  = require "lapis.util.encoding"
local lfs       = require "lfs"
local giflib    = require "giflib"
local magick    = require "magick"
local md5       = require "md5"
local filetypes = require "utils.file_whitelist"
local generate  = require "utils.generate"
local sf        = string.format
local ss        = string.sub
local model     = {}


function model.prepare_post(params, session, board, thread, posts, files)
	local time = os.time()

	-- Prepare session stuff
	session.password = session.password or generate.password(time, session)

	-- Trim white space
	trim(params, {
		"board", "thread", "sticky", "lock", "size_override", "save",
		"ip", "name",
		"subject", "options", "comment",
		"file", "file_spoiler", "draw"
	}, db.NULL)

	-- Save names on individual boards
	if params.name ~= db.NULL then
		session.names[board.short_name] = params.name
	end

	-- Files take presidence over drawings, but if there is no file, fill in
	-- the file fields with draw data. This shodl avoid ugly code branching
	-- later on in the file.
	params.file = params.file or {
		filename = "",
		content  = ""
	}

	if #params.file.content == 0 and params.draw and params.draw ~= db.NULL then
		local pattern        = ".-,(.+)"
		params.draw          = params.draw:match(pattern)
		params.file.filename = "tegaki.png"
		params.file.content  = encoding.decode_base64(params.draw)
	end

	-- Check board flags
	if thread then
		if thread.lock and not session.admin and not session.mod then
			return false, sf("Thread No.%s is locked.", thread.post_id)
		end

		if board.post_comment and params.comment == db.NULL then
			return false, "Comments are required to post on this board."
		end

		if board.post_file and #params.file.content == 0 then
			return false, "Files are required to post on this board."
		end
	else
		if board.thread_comment and params.comment == db.NULL then
			return false, "Comments are required to post a thread on this board."
		end

		if board.thread_file and #params.file.content == 0 then
			return false, "Files are required to post a thread on this board."
		end
	end

	-- Parse name
	if params.name ~= db.NULL then
		params.name, params.trip = generate.tripcode(params.name)
	end

	-- Set file
	if #params.file.content > 0 then

		-- Reject files in text-only boards
		if board.text_only then
			return false, "Files are not accepted on this board."
		end

		-- Thread limit is already met.
		if thread then
			if files >= board.thread_file_limit and not thread.size_override then
				return false, sf("Thread No.%s is at its file limit.",
					thread.post_id
				)
			end
		end

		local name = sf("%s%s", time, ss(generate.random(time, params), -3))
		local dir  = sf("./static/%s/", board.short_name)
		local ext  = params.file.filename:match("^.+(%..+)$") or ""

		-- Valid filetype
		if not filetypes[ext] then
			return false, sf("Invalid filetype: %s", ext)
		end

		-- Check if valid image
		local image = magick.load_image_from_blob(params.file.content)

		if not image then
			return false, "Invalid image format."
		end

		params.file_name   = params.file.filename
		params.file_path   = name .. ext
		params.file_md5    = md5.sumhexa(params.file.content)
		params.file_size   = #params.file.content
		params.file_width  = image:get_width()
		params.file_height = image:get_height()


		if params.file_spoiler then
			params.file_spoiler = db.TRUE
		else
			params.file_spoiler = db.FALSE
		end

		-- Check if file already exists
		local _, error = model.find_file(board.id, params.file_md5)
		if error then
			return false, error
		end
	else
		params.file_spoiler = db.FALSE
	end

	-- Check contributions
	if params.comment == db.NULL and not params.file_name then
		return false, "You must post either a comment or a file."
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
function model.create_post(params, session, board, thread, op)
	-- Update board
	board.posts = board.posts + 1
	board:update("posts")

	-- Create post
	local post = Posts:create {
		post_id      = board.posts,
		thread_id    = thread.id,
		board_id     = board.id,
		timestamp    = os.time(),
		ip           = params.ip,
		comment      = params.comment,
		name         = params.name,
		trip         = params.trip,
		subject      = params.subject,
		password     = session.password,
		file_name    = params.file_name,
		file_path    = params.file_path,
		file_md5     = params.file_md5,
		file_size    = params.file_size,
		file_width   = params.file_width,
		file_height  = params.file_height,
		file_spoiler = params.file_spoiler
	}

	if post then
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

			if not post.file_spoiler then
				-- Save thumbnail
				local w, h
				if op then
					w = post.file_width  < 250 and post.file_width  or 250
					h = post.file_height < 250 and post.file_height or 250
				else
					w = post.file_width  < 125 and post.file_width  or 125
					h = post.file_height < 125 and post.file_height or 125
				end

				-- Grab first frame of a gif instead of the last
				if ext == ".gif" then
					local gif, err = giflib.load_gif(full_path)

					if err then
						magick.thumb(full_path, sf("%sx%s", w, h), thumb_path)
					else
						gif:write_first_frame(thumb_path)
						magick.thumb(thumb_path, sf("%sx%s", w, h), thumb_path)
					end
				else
					magick.thumb(full_path, sf("%sx%s", w, h), thumb_path)
				end
			end
		end

		return post
	else
		return false, "Unable to submit post."
	end
end

--- Delete post data
-- @tparam table session User session
-- @tparam table board Board data
-- @tparam table post Post data
-- @treturn boolean success
-- @treturn string error
function model.delete_post(session, board, post)
	local function rm_post(short_name)
		if post.file_path then
			local dir = sf("./static/%s/", short_name)
			os.remove(dir .. post.file_path)
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
		return false, sf("Unable to delete post No.%s", post.post_id)
	end
end

--- Get all posts from board
-- @tparam number board_id Board ID
-- @treturn table posts
function model.get_posts(board_id)
	return Posts:select("where board_id=?", board_id)
end

--- Get posts from thread
-- @tparam number board_id Board ID
-- @tparam number thread_id Thread ID
-- @treturn table posts
function model.get_thread_posts(board_id, thread_id)
	local sql = "where board_id=? and thread_id=? order by post_id asc"
	return Posts:select(sql, board_id, thread_id)
end

--- Get op from thread
-- @tparam number board_id Board ID
-- @tparam number thread_id Thread ID
-- @treturn table post
function model.get_thread_op(board_id, thread_id)
	local sql = [[
		where
			board_id = ? and
			thread_id = ?
		order by
			post_id asc
		limit 1
	]]
	return unpack(Posts:select(sql, board_id, thread_id))
end

--- Get op and last 5 posts of a thread to display on board index
-- @tparam number board_id Board ID
-- @tparam number thread_id Thread ID
-- @treturn table posts
function model.get_index_posts(board_id, thread_id)
	local sql = [[
		where
			board_id = ? and
			thread_id = ?
		order by
			post_id desc
		limit 5
	]]
	local posts = Posts:select(sql, board_id, thread_id)

	if model.count_posts(board_id, thread_id) > 5 then
		table.insert(posts, model.get_thread_op(board_id, thread_id))
	end

	return posts
end

--- Get post data
-- @tparam number board_id Board ID
-- @tparam number id Post ID
-- @treturn table post
function model.get_post(board_id, id)
	return unpack(Posts:select("where board_id=? and post_id=?",board_id, id))
end

--- Get post data
-- @tparam number id Post ID
-- @treturn table post
function model.get_post_by_id(id)
	return unpack(Posts:select("where id=?", id))
end

--- Find file in active posts
-- @tparam number board Board ID
-- @tparam string file_md5 Unique hash of file
-- @treturn boolean success
-- @treturn string error
function model.find_file(board_id, file_md5)
	local sql  = "where board_id=? and file_md5=? limit 1"
	local post = unpack(Posts:select(sql, board_id, file_md5))

	if not post then
		return false
	else
		return true, "File already active on this board."
	end
end


--- Count hidden posts in a thread
-- @tparam number board_id Board ID
-- @tparam number thread_id Thread ID
-- @treturn table hidden
function model.count_hidden_posts(board_id, thread_id)
	local posts     = model.get_index_posts(board_id, thread_id)
	local num_posts = model.count_posts(board_id, thread_id)
	local num_files = model.count_files(board_id, thread_id)

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
-- @tparam number board_id Board ID
-- @tparam number thread_id Thread ID
-- @treturn number posts
function model.count_posts(board_id, thread_id)
	local sql = "board_id=? and thread_id=?"
	return Posts:count(sql, board_id, thread_id)
end

--- Count posts with images in a thread
-- @tparam number board_id Board ID
-- @tparam number thread_id Thread ID
-- @treturn number files
function model.count_files(board_id, thread_id)
	local sql = "board_id=? and thread_id=? and file_name is not null"
	return Posts:count(sql, board_id, thread_id)
end

return model
