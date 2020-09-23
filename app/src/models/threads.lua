local trim    = require("lapis.util").trim_filter
local Model   = require("lapis.db.model").Model
local Threads = Model:extend("threads")

--- Create thread
-- @tparam number board_id Board ID
-- @tparam table flags List of thread flags
-- @treturn boolean success
-- @treturn string error
function Threads:create_thread(board_id, flags)
	-- Trim white space
	trim(flags, {
		"sticky", "lock",
		"size_override", "save"
	}, false)

	local t = self:create {
		board_id      = board_id,
		last_active   = os.time(),
		sticky        = flags.sticky,
		lock          = flags.lock,
		size_override = flags.size_override,
		save          = flags.save
	}

	if t then
		return t
	end

	return false, { "err_create_thread" }
end

--- Delete entire thread
-- @tparam table session User session
-- @tparam table thread Thread data
-- @tparam table op Post data of op
-- @treturn boolean success
-- @treturn string error
function Threads:delete_thread(session, thread, op)
	local success = false

	-- MODS = FAGS
	if type(session) == "table" and
		(session.admin or session.mod or session.janitor) then
		thread:delete()
		success = true
	-- Override password
	elseif type(session) == "string" and
		session == "override" then
		thread:delete()
		success = true
	-- Password has to match!
	elseif op and session.password and
		op.password == session.password then
		thread:delete()
		success = true
	end

	if success then
		return success
	else
		return false, { "err_delete_post", { op.post_id } }
	end
end

--- Get all threads from board
-- @tparam number board_id Board ID
-- @treturn table threads
function Threads:get_threads(board_id)
	local sql = [[
		where
			board_id = ? and
			archive = false
		order by
			sticky desc,
			last_active desc
	]]
	return self:select(sql, board_id)
end

--- Get thread data
-- @tparam number id Thread ID
-- @treturn table thread
function Threads:get_thread(id)
	return unpack(self:select("where id=?", id))
end

--- Get page of threads
-- @tparam number board_id Board ID
-- @tparam number tpp Threads per page
-- @tparam number page Page to pull from
-- @treturn table threads
-- @treturn number pages
function Threads:get_page_threads(board_id, tpp, page)
	local sql = [[
		where
			board_id = ? and
			archive = false
		order by
			sticky desc,
			last_active desc
	]]
	local pages = self:paginated(sql, board_id,{ per_page = tpp })

	return pages:get_page(page), pages:num_pages()
end

--- Get archived threads
-- @tparam number board_id Board ID
-- @treturn table threads
function Threads:get_archived_threads(board_id)
	local sql = "where board_id=? and archive=true order by last_active desc"
	return self:select(sql, board_id)
end

--- Sticky a thread
-- @tparam table thread Thread data
-- @treturn boolean success
-- @treturn string error
function Threads:sticky_thread(thread)
	thread.sticky = true
	return thread:update("sticky")
end

--- Unsticky a thread
-- @tparam table thread Thread data
-- @treturn boolean success
-- @treturn string error
function Threads:unsticky_thread(thread)
	thread.sticky = false
	return thread:update("sticky")
end

--- Lock a thread
-- @tparam table thread Thread data
-- @treturn boolean success
-- @treturn string error
function Threads:lock_thread(thread)
	thread.lock = true
	return thread:update("lock")
end

--- Unlock a thread
-- @tparam table thread Thread data
-- @treturn boolean success
-- @treturn string error
function Threads:unlock_thread(thread)
	thread.lock = false
	return thread:update("lock")
end

--- Bump threads to archive
-- @tparam number board_id Board ID
-- @tparam number max_threads Maximum number of threads on this board
-- @treturn boolean success
-- @treturn string error
function Threads:archive_threads(board_id, max_threads)
	local threads = self:get_threads(board_id)

	if #threads > max_threads then
		for i=max_threads+1, #threads do
			local _, err = self:archive_thread(threads[i])

			if err then
				return false, err
			end
		end
	end
end

--- Archive a thread
-- @tparam table thread Thread data
-- @treturn boolean success
-- @treturn string error
function Threads:archive_thread(thread)
	thread.sticky      = false
	thread.lock        = true
	thread.archive     = true
	thread.last_active = os.time()
	return thread:update("sticky", "lock", "archive", "last_active")
end

--- Find threads with no posts
-- @treturn table threads
function Threads:find_orphans()
	local sql = "where id not in (select distinct thread_id from posts)"
	return self:select(sql)
end

return Threads
