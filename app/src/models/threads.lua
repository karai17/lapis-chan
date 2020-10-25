local Model   = require("lapis.db.model").Model
local Threads = Model:extend("threads", {
	relations = {
		{ "board", belongs_to="Boards" },
		{ "posts", has_many="Posts" },
		{ "op",    has_one="Posts", order="post_id asc" },
	}
})

Threads.valid_record = {
	{ "board_id", exists=true }
}

--- Create thread
-- @tparam table params Thread parameters
-- @treturn boolean success
-- @treturn string error
function Threads:new(params)
	local thread = self:create(params)
	return thread and thread or false, { "err_create_thread" }
end

--- Modify a thread
-- @tparam table params Thread parameters
-- @treturn boolean success
-- @treturn string error
function Threads:modify(params)
	local thread = self:get(params.id)
	if not thread then
		return false, { "err_create_board" } -- FIXME: wrong error message
	end

	local success, err = thread:update(params)
	return success and thread or false, "FIXME: " .. tostring(err)
end

--- Delete entire thread
-- @tparam number id Thread ID
-- @treturn boolean success
-- @treturn string error
function Threads:delete(id)
	 -- FIXME: API needs to create a user object for better auth checking
	local thread, err = self:get(id)
	if not thread then
		return false, err
	end

	local op      = thread:get_op()
	local success = thread:delete()
	return success and thread or false, { "err_delete_thread", { op.post_id } }
end

--- Get thread data
-- @tparam number id Thread ID
-- @treturn table thread
function Threads:get(id)
	local thread = self:find(id)
	return thread and thread or false, "FIXME"
end

--- Get archived threads
-- @tparam number board_id Board ID
-- @treturn table threads
function Threads:get_archived(board_id)
	local sql = "where board_id=? and archive=true order by last_active desc"
	return self:select(sql, board_id)
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
	return self:select("where id not in (select distinct thread_id from posts)")
end

return Threads
