local Boards        = require "models.boards"
local Threads       = require "models.threads"
local Posts         = require "models.posts"
local Announcements = require "models.announcements"
local format        = require "utils.text_formatter"

return {
	before = function(self)
		-- Get all board data
		self.boards = Boards.get_boards()

		-- Get current board data
		for _, board in ipairs(self.boards) do
			if board.short_name == self.params.board then
				self.board = board
				break
			end
		end

		-- Board not found
		if not self.board then
			self:write({ redirect_to = self.index_url })
			return
		end

		-- Get announcements
		self.announcements = Announcements.get_board_announcements(self.board.id)
	end,
	GET = function(self)
		-- Page title
		self.page_title = string.format(
			"/%s/ - %s",
			self.board.short_name,
			self.board.name
		)

		-- Page URLs
		self.staticb_url = self.static_url .. self.board.short_name .. "/"
		self.board_url   = self.boards_url .. self.board.short_name .. "/"
		self.thread_url  = self.board_url  .. "thread/"
		self.catalog_url = self.board_url  .. "catalog/"

		-- Nav links link to sub page if available
		self.sub_page = "archive"

		-- Get threads
		self.threads = Threads.get_archived_threads(self.board.id)

		-- Get time
		self.days = self.board.archive_time / 24 / 60 / 60

		-- Plurals (or not)
		self.plural = {
			threads = #self.threads == 1 and "thread" or "threads",
			days    = self.days     == 1 and "day"    or "days"
		}

		-- Get stats
		for _, thread in ipairs(self.threads) do
			thread.op      = Posts.get_thread_op(self.board.id, thread.id)
			thread.replies = Posts.count_posts(self.board.id, thread.id) - 1
			thread.url     = self.thread_url .. thread.op.post_id

			-- Process name
			thread.op.name = thread.op.name or self.board.anon_name

			-- Process tripcode
			thread.op.trip = thread.op.trip or ""

			-- Process comment
			if thread.op.comment then
				local comment = thread.op.comment
				comment = format.sanitize(comment)
				comment = format.spoiler(comment)

				if #comment > 110 then
					comment = comment:sub(1,100)
					comment = comment .. "..."
				end

				thread.op.comment = comment
			else
				thread.op.comment = ""
			end
		end

		return { render = "archive" }
	end,
	POST = function(self)
		return { redirect_to = self.index_url }
	end
}
