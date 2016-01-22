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

		-- Page urls
		self.board_url  = self.boards_url .. self.board.short_name .. "/"
		self.thread_url = self.board_url  .. "thread/"

		-- Get current thread data
		local post  = Posts.get_post(self.board.id, self.params.thread)

		-- Post not found
		if not post then
			self:write({ redirect_to = self.board_url })
			return
		end

		local op = Posts.get_thread_op(self.board.id, post.thread_id)

		if post.post_id ~= op.post_id then
			self:write({
				redirect_to = self.thread_url .. op.post_id .. "#p" .. post.post_id
			})
			return
		end

		self.thread = Threads.get_thread(post.thread_id)

		-- Thread not found
		if not self.thread then
			self:write({ redirect_to = self.board_url })
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
		self.archive_url = self.board_url  .. "archive"
		self.catalog_url = self.board_url  .. "catalog"

		-- Flag comments as required or not
		self.comment_flag = self.board.thread_comment

		-- Generate CSRF token
		self.csrf_token = csrf.generate_token(self)

		-- Determine if we allow a user to upload a file
		self.num_files  = Posts.count_files(self.board.id, self.thread.id)

		-- Get posts
		self.posts = Posts.get_thread_posts(self.board.id, self.thread.id)

		-- Thread URL
		self.thread_url = self.thread_url .. self.posts[1].post_id

		-- Format comments
		for i, post in ipairs(self.posts) do
			-- OP gets a thread tag
			if i == 1 then
				post.thread = post.post_id
			end

			post.name      = post.name or self.board.anon_name
			post.reply     = "#q" .. post.post_id
			post.link      = "#p" .. post.post_id
			post.timestamp = os.date("%Y-%m-%d (%a) %H:%M:%S", post.timestamp)
			post.file_size = math.floor(post.file_size / 1024)

			-- Get thumbnail URL
			if post.file_path then
				if post.file_spoiler then
					if post == self.posts[1] then
						post.thumb = self.static_url .. "op_spoiler.png"
					else
						post.thumb = self.static_url .. "post_spoiler.png"
					end
				else
					post.thumb = self.staticb_url .. 's' .. post.file_path
				end

				post.file_path = self.staticb_url .. post.file_path
			end

			-- Process comment
			if post.comment then
				local comment = post.comment
				comment = format.sanitize(comment)
				comment = format.quote(comment, self, self.board, post)
				comment = format.green_text(comment)
				comment = format.spoiler(comment)
				comment = format.new_lines(comment)
				post.comment = comment
			else
				post.comment = ""
			end
		end

		return { render = "thread" }
	end,
	POST = function(self)
		return { redirect_to = self.index_url }
	end
}
