local assert_error  = require("lapis.application").assert_error
local assert_valid  = require("lapis.validate").assert_valid
local csrf          = require "lapis.csrf"
local format        = require "utils.text_formatter"
local generate      = require "utils.generate"
local process       = require "utils.request_processor"
local Announcements = require "models.announcements"
local Boards        = require "models.boards"
local Posts         = require "models.posts"
local Threads       = require "models.threads"

return {
	before = function(self)
		-- Get all board data
		self.boards = Boards:get_boards()

		-- Get current board data
		for _, board in ipairs(self.boards) do
			if board.short_name == self.params.board then
				self.board = board
				break
			end
		end

		-- Board not found
		if not self.board then
			self:write({ redirect_to = self:url_for("index") })
			return
		end

		-- Get current thread data
		local post  = Posts:get_post(self.board.id, self.params.thread)

		-- Post not found
		if not post then
			self:write({ redirect_to = self:url_for("board", { board=self.board.short_name }) })
			return
		end

		local op = Posts:get_thread_op(post.thread_id)

		if post.post_id ~= op.post_id then
			self:write({ redirect_to = self:url_for("thread", { board=self.board.short_name, thread=op.post_id, anchor="p", id=post.post_id }) })
			return
		end

		self.thread = Threads:get_thread(post.thread_id)

		-- Thread not found
		if not self.thread then
			self:write({ redirect_to = self:url_for("board", { board=self.board.short_name }) })
			return
		end

		-- Get announcements
		self.announcements = Announcements:get_board_announcements(self.board.id)

		-- Page title
		self.page_title = string.format(
			"/%s/ - %s",
			self.board.short_name,
			self.board.name
		)

		-- Flag comments as required or not
		self.comment_flag = self.board.thread_comment

		-- Generate CSRF token
		self.csrf_token = csrf.generate_token(self)

		-- Determine if we allow a user to upload a file
		self.num_files  = Posts:count_files(self.thread.id)

		-- Get posts
		self.posts = Posts:get_posts_by_thread(self.thread.id)

		-- Format comments
		for i, post in ipairs(self.posts) do
			-- OP gets a thread tag
			if i == 1 then
				post.thread = post.post_id
			end

			post.name            = post.name or self.board.anon_name
			post.reply           = self:url_for("thread", { board=self.board.short_name, thread=self.posts[1].post_id, anchor="q", id=post.post_id })
			post.link            = self:url_for("thread", { board=self.board.short_name, thread=self.posts[1].post_id, anchor="p", id=post.post_id })
			post.timestamp       = os.date("%Y-%m-%d (%a) %H:%M:%S", post.timestamp)
			post.file_size       = math.floor(post.file_size / 1024)
			post.file_dimensions = ""

			if post.file_width > 0 and post.file_height > 0 then
				post.file_dimensions = string.format(", %dx%d", post.file_width, post.file_height)
			end

			if not post.file_duration or post.file_duration == "0" then
				post.file_duration = ""
			else
				post.file_duration = string.format(", %s", post.file_duration)
			end

			if post.file_path then
				local name, ext = post.file_path:match("^(.+)(%..+)$")
				ext = string.lower(ext)

				-- Get thumbnail URL
				if post.file_type == "audio" then
					if post == self.posts[1] then
						post.thumb = self:format_url(self.static_url, "op_audio.png")
					else
						post.thumb = self:format_url(self.static_url, "post_audio.png")
					end
				elseif post.file_type == "image" then
					if post.file_spoiler then
						if post == self.posts[1] then
							post.thumb = self:format_url(self.static_url, "op_spoiler.png")
						else
							post.thumb = self:format_url(self.static_url, "post_spoiler.png")
						end
					else
						if ext == ".webm" or ext == ".svg" then
							post.thumb = self:format_url(self.files_url, self.board.short_name, 's' .. name .. '.png')
						else
							post.thumb = self:format_url(self.files_url, self.board.short_name, 's' .. post.file_path)
						end
					end
				end

				post.file_path = self:format_url(self.files_url, self.board.short_name, post.file_path)
			end

			-- Process comment
			if post.comment then
				local comment = post.comment
				comment = format.sanitize(comment)
				comment = format.quote(comment, self, self.board, post)
				comment = format.green_text(comment)
				comment = format.blue_text(comment)
				comment = format.spoiler(comment)
				comment = format.new_lines(comment)
				post.comment = comment
			else
				post.comment = ""
			end
		end
	end,
	on_error = function(self)
		self.errors = generate.errors(self.i18n, self.errors)
		return { render = "thread"}
	end,
	GET = function()
		return { render = "thread" }
	end,
	POST = function(self)
		-- Validate CSRF token
		csrf.assert_token(self)

		local board_url  = self:url_for("board",  { board=self.board.short_name })
		local thread_url = self:url_for("thread", { board=self.board.short_name, thread=self.posts[1].post_id })

		-- Submit new post
		if self.params.submit and self.thread then
			-- Validate user input
			assert_valid(self.params, {
				{ "thread",  exists=true },
				{ "name",    max_length=255 },
				{ "subject", max_length=255 },
				{ "options", max_length=255 },
				{ "comment", max_length=self.text_size }
			})

			-- Validate post
			local post = assert_error(process.create_post(self.params, self.session, self.board, self.thread))
			return { redirect_to = self:url_for("thread", { board=self.board.short_name, thread=self.posts[1].post_id, anchor="p", id=post.post_id }) }
		end

		-- Delete thread
		if self.params.delete and self.params.thread_id then
			-- Validate user input
			assert_valid(self.params, {
				{ "post_id", exists=true }
			})

			-- Validate deletion
			assert_error(process.delete_thread(self.params, self.session, self.board))
			return { redirect_to = board_url }
		end

		-- Delete post
		if self.params.delete and not self.params.thread_id then
			-- Validate user input
			assert_valid(self.params, {
				{ "post_id", exists=true }
			})

			-- Validate deletion
			assert_error(process.delete_post(self.params, self.session, self.board))
			return { redirect_to = thread_url }
		end

		-- Report post
		if self.params.report then
			-- Validate user input
			assert_valid(self.params, {
				{ "board",   exists=true },
				{ "post_id", exists=true }
			})

			-- Validate report
			assert_error(process.report_post(self.params, self.board))
			return { redirect_to = thread_url }
		end

		-- Admin commands
		if self.session.admin or self.session.mod then
			-- Sticky thread
			if self.params.sticky then
				assert_error(process.sticky_thread(self.params, self.board))
				return { redirect_to = thread_url }
			end

			-- Lock thread
			if self.params.lock then
				assert_error(process.lock_thread(self.params, self.board))
				return { redirect_to = thread_url }
			end

			-- Save thread
			if self.params.save then
				assert_error(process.save_thread(self.params, self.board))
				return { redirect_to = thread_url }
			end

			-- Override thread
			if self.params.override then
				assert_error(process.override_thread(self.params, self.board))
				return { redirect_to = thread_url }
			end

			-- Ban user
			if self.params.ban then
				assert_error(process.ban_user(self.params, self.board))
				return { redirect_to = thread_url }
			end

			return { redirect_to = thread_url }
		end

		return { redirect_to = thread_url }
	end
}
