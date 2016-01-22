local Boards        = require "models.boards"
local Threads       = require "models.threads"
local Posts         = require "models.posts"
local Announcements = require "models.announcements"
local format        = require "utils.text_formatter"
local prep_error    = require "utils.prep_error"
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
		if not self.board or
			self.params.page and not tonumber(self.params.page) then
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

		-- Flag comments as required or not
		self.comment_flag = self.board.thread_comment

		-- Generate CSRF token
		self.csrf_token = csrf.generate_token(self)

		-- Current page
		self.params.page = self.params.page or 1

		-- Get threads
		self.threads, self.pages = Threads.get_page_threads(
			self.board.id,
			self.board.threads_per_page,
			self.params.page
		)

		-- Get posts
		for _, thread in ipairs(self.threads) do
			-- Get posts visible on the board index
			thread.posts = Posts.get_index_posts(self.board.id, thread.id)

			-- Get hidden posts
			thread.hidden = Posts.count_hidden_posts(self.board.id, thread.id)

			-- Plurals (or not)
			thread.plural = {
				posts = thread.hidden.posts == 1 and "reply" or "replies",
				files = thread.hidden.files == 1 and "file"  or "files"
			}

			-- Get op
			local op = thread.posts[#thread.posts]
			if not op then
				return prep_error(self, string.format(
					"Thread No.%s has been orphaned.", thread.id
				))
			end

			thread.url = self.board_url .. "thread/" .. op.post_id

			-- Format comments
			for _, post in ipairs(thread.posts) do
				-- OP gets a thread tag
				if post.post_id == op.post_id then
					post.thread = post.post_id
				end

				post.name  = post.name or self.board.anon_name
				post.reply = self.thread_url .. op.post_id .. "#q" .. post.post_id
				post.link  = self.thread_url .. op.post_id .. "#p" .. post.post_id
				post.remix = self.thread_url .. op.post_id .. "#r" .. post.post_id

				post.file_size = math.floor(post.file_size / 1024)
				post.timestamp = os.date("%Y-%m-%d (%a) %H:%M:%S", post.timestamp)

				-- Get thumbnail URL
				if post.file_path then
					if post.file_spoiler then
						if post == thread.posts[#thread.posts] then
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
		end

		return { render = "board" }
	end,
	POST = function(self)
		return { redirect_to = self.index_url }
	end
}
