local Boards        = require "models.boards"
local Threads       = require "models.threads"
local Posts         = require "models.posts"
local Announcements = require "models.announcements"
local format        = require "utils.text_formatter"
local csrf          = require "lapis.csrf"

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
		self.form_url    = self.index_url  .. "process"
		self.thread_url  = self.board_url  .. "thread/"
		self.archive_url = self.board_url  .. "archive"
		self.catalog_url = self.board_url  .. "catalog"

		-- Nav links link to sub page if available
		self.sub_page = "catalog"

		-- Flag comments as required or not
		self.comment_flag = self.board.thread_comment

		-- Generate CSRF token
		self.csrf_token = csrf.generate_token(self)

		-- Get threads
		self.threads = Threads.get_threads(self.board.id)

		-- Get stats
		for _, thread in ipairs(self.threads) do
			thread.op      = Posts.get_thread_op(self.board.id, thread.id)
			thread.replies = Posts.count_posts(self.board.id, thread.id) - 1
			thread.files   = Posts.count_files(self.board.id, thread.id)
			thread.url     = self.thread_url .. thread.op.post_id

			-- Get thumbnail URL
			if thread.op.file_path then
				if thread.op.file_spoiler then
					thread.op.thumb = self.static_url .. "post_spoiler.png"
				else
					thread.op.thumb = self.staticb_url .. 's' .. thread.op.file_path
				end

				thread.op.file_path = self.staticb_url .. thread.op.file_path
			end

			-- Process comment
			if thread.op.comment then
				local comment = thread.op.comment
				comment = format.sanitize(comment)
				comment = format.spoiler(comment)
				comment = format.new_lines(comment)

				if #comment > 260 then
					comment = comment:sub(1, 250) .. "..."
				end

				thread.op.comment = comment
			else
				thread.op.comment = ""
			end
		end

		return { render = "catalog" }
	end,
	POST = function(self)
		return { redirect_to = self.index_url }
	end
}
