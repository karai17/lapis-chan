local Bans         = require "models.bans"
local Threads      = require "models.threads"
local Posts        = require "models.posts"
local Reports      = require "models.reports"
local process      = {}

function process.create_thread(params, session, board)
	-- Only admins and mods can flag threads
	if not session.admin or session.mod then
		params.sticky        = nil
		params.lock          = nil
		params.size_override = nil
		params.save          = nil
	end

	-- Prepare data for entry
	local _, err = Posts:prepare_post(params, session, board)
	if err then
		return false, err
	end

	-- Create new thread
	local thread, err = Threads:create_thread(board.id, {
		sticky        = params.sticky,
		lock          = params.lock,
		size_override = params.size_override,
		save          = params.save
	})
	if err then
		return false, err
	end

	-- Archive old threads
	local max_threads = board.threads_per_page * board.pages
	Threads:archive_threads(board.id, max_threads)

	-- Delete old archived threads
	local time    = os.time()
	local threads = Threads:get_archived_threads(board.id)

	for _, t in ipairs(threads) do
		if time - t.last_active > board.archive_time and not t.save then
			local posts = Posts:get_thread_posts(t.id)
			Threads:delete_thread("override", t, posts[1])

			-- Delete all associated posts
			for _, post in ipairs(posts) do
				Posts:delete_post("override", board, post)

				-- Delete associated report
				local report = Reports:get_report(post.id)
				if report then
					Reports:delete_report(report)
				end
			end
		end
	end

	-- Insert post data into database
	local post, err = Posts:create_post(
		params,
		session,
		board,
		thread,
		true
	)
	if err then
		return false, err
	end

	return post
end

function process.create_post(params, session, board, thread)
	local posts = Posts:count_posts(thread.id)
	local files = Posts:count_files(thread.id)

	-- Prepare data for entry
	local _, err = Posts:prepare_post(
		params, session, board, thread, files
	)
	if err then
		return false, err
	end

	-- Insert post data into database
	local post, err = Posts:create_post(
		params,
		session,
		board,
		thread,
		false
	)
	if err then
		return false, err
	end

	posts = posts + 1

	-- Check for [auto]sage
	if params.options ~= "sage" and
	posts <= board.post_limit then
		-- Update thread
		thread.last_active = os.time()
		thread:update("last_active")
	end

	return post
end

function process.delete_thread(params, session, board)
	-- Validate post
	local post = Posts:get_post(board.id, params.thread_id)
	if not post then
		return false, { "err_invalid_post", { params.thread_id } }
	end

	-- Validate thread
	local thread = Threads:get_thread(post.thread_id)
	if not thread then
		return false, { "err_invalid_thread" }
	end

	local posts = Posts:get_posts_by_thread(thread.id)

	-- Delete thread
	local _, err = Threads:delete_thread(session, thread, posts[1])
	if err then
		return false, err
	end

	-- Delete all associated posts
	for _, post in ipairs(posts) do
		Posts:delete_post("override", board, post)

		-- Delete associated report
		local report = Reports:get_report(board.id, post.id)
		if report then
			Reports:delete_report(report)
		end
	end

	return true
end

function process.delete_post(params, session, board)
	-- Validate post
	local post = Posts:get_post(board.id, params.post_id)
	if not post then
		return false, { "err_invalid_post", { params.post_id } }
	end

	-- Validate thread
	local thread = Threads:get_thread(post.thread_id)
	if not thread then
		return false, { "err_invalid_thread" }
	end

	-- Delete post
	local _, err = Posts:delete_post(session, board, post)
	if err then
		return false, err
	end

	-- Update thread
	local posts = Posts:get_posts_by_thread(thread.id)
	thread.last_active = posts[#posts].timestamp
	thread:update("last_active")

	return true
end

function process.report_post(params, board)
	-- Validate post
	local post = Posts:get_post(board.id, params.post_id)
	if not post then
		return false, { "err_invalid_post", { params.thread } }
	end

	local report = Reports:get_report(board.id, post.post_id)

	-- If report exists, update it
	if report then
		report.num_reports = report.num_reports + 1
		local _, err = Reports:modify_report(report)
		if err then
			return false, err
		end
	-- If report is new, create it
	else
		local _, err = Reports:create_report {
			board_id    = board.id,
			thread_id   = post.thread_id,
			post_id     = post.post_id,
			timestamp   = os.time(),
			num_reports = 1
		}
		if err then
			return false, err
		end
	end

	return post
end

-- Sticky thread
function process.sticky_thread(params, board)
	-- Validate post
	local post   = Posts:get_post(board.id, params.post_id)
	if not post then
		return false, { "err_invalid_post", { params.post_id } }
	end

	-- Validate thread
	local thread = Threads:get_thread(post.thread_id)
	if not thread then
		return false, { "err_invalid_thread" }
	end

	thread.sticky = not thread.sticky
	thread:update("sticky")

	return true
end

-- Lock thread
function process.lock_thread(params, board)
	-- Validate post
	local post   = Posts:get_post(board.id, params.post_id)
	if not post then
		return false, { "err_invalid_post", { params.post_id } }
	end

	-- Validate thread
	local thread = Threads:get_thread(post.thread_id)
	if not thread then
		return false, { "err_invalid_thread" }
	end

	thread.lock = not thread.lock
	thread:update("lock")

	return true
end

-- Save thread
function process.save_thread(params, board)
	-- Validate post
	local post   = Posts:get_post(board.id, params.post_id)
	if not post then
		return false, { "err_invalid_post", { params.post_id } }
	end

	-- Validate thread
	local thread = Threads:get_thread(post.thread_id)
	if not thread then
		return false, { "err_invalid_thread" }
	end

	thread.save = not thread.save
	thread:update("save")

	return true
end

-- Override thread
function process.override_thread(params, board)
	-- Validate post
	local post   = Posts:get_post(board.id, params.post_id)
	if not post then
		return false, { "err_invalid_post", { params.post_id } }
	end

	-- Validate thread
	local thread = Threads:get_thread(post.thread_id)
	if not thread then
		return false, { "err_invalid_thread" }
	end

	thread.size_override = not thread.size_override
	thread:update("size_override")

	return true
end

-- Ban user
function process.ban_user(params, board)
	-- Validate post
	local post = Posts:get_post(board.id, params.post_id)
	if not post then
		return false, { "err_invalid_post", { params.post_id } }
	end

	params.ip = post.ip

	-- Convert board name to id if checkbox is set
	if params.board_id then
		params.board_id = board.id
	end

	-- Ban user
	local _, err = Bans:create_ban(params)
	if err then
		return false, err
	end

	-- Flag post
	if params.banned then
		post.banned = true
		post:update("banned")
	end

	return true
end

return process
