local assert_error  = require("lapis.application").assert_error
local assert_valid  = require("lapis.validate").assert_valid
local csrf          = require "lapis.csrf"
local capture       = require "utils.capture"
local format        = require "utils.text_formatter"
local generate      = require "utils.generate"
local process       = require "utils.request_processor"
local Posts         = require "models.posts"
local Threads       = require "models.threads"

return {
	before = function(self)

		-- Get board
		for _, board in ipairs(self.boards) do
			if board.short_name == self.params.uri_short_name then
				self.board = board
				break
			end
		end

		-- Board not found
		if not self.board or self.params.page and not tonumber(self.params.page) then
			return self:write({ redirect_to = self:url_for("web.pages.index") })
		end

		-- Get announcements
		-- TODO: Consolidate these into a single call
		self.announcements        = assert_error(capture.get(self:url_for("api.announcements.announcement", { uri_id="global" })))
		local board_announcements = assert_error(capture.get(self:url_for("api.boards.announcements", { uri_short_name=self.params.uri_short_name })))
		for _, announcement in ipairs(board_announcements) do
			table.insert(self.announcements, announcement)
		end

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

		-- Current page
		self.params.page = self.params.page or 1

		-- Get threads
		self.threads, self.pages = Threads:get_page_threads(
			self.board.id,
			self.board.threads_per_page,
			self.params.page
		)

		-- Get posts
		for _, thread in ipairs(self.threads) do
			-- Get posts visible on the board index
			thread.posts = Posts:get_index_posts(thread.id)

			-- Get hidden posts
			thread.hidden = Posts:count_hidden_posts(thread.id)

			-- Get op
			local op = thread.posts[#thread.posts]
			if not op then
				assert_error(false, { "err_orphaned", { thread.id } })
			end

			thread.url = self:url_for("web.boards.thread", { uri_short_name=self.board.short_name, thread=op.post_id })

			-- Format comments
			for _, post in ipairs(thread.posts) do
				-- OP gets a thread tag
				if post.post_id == op.post_id then
					post.thread = post.post_id
				end

				post.name            = post.name or self.board.anon_name
				post.reply           = self:url_for("web.boards.thread", { uri_short_name=self.board.short_name, thread=op.post_id, anchor="q", id=post.post_id })
				post.link            = self:url_for("web.boards.thread", { uri_short_name=self.board.short_name, thread=op.post_id, anchor="p", id=post.post_id })
				post.remix           = self:url_for("web.boards.thread", { uri_short_name=self.board.short_name, thread=op.post_id, anchor="r", id=post.post_id })
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
						if post == thread.posts[#thread.posts] then
							post.thumb = self:format_url(self.static_url, "op_audio.png")
						else
							post.thumb = self:format_url(self.static_url, "post_audio.png")
						end
					elseif post.file_type == "image" then
						if post.file_spoiler then
							if post == thread.posts[#thread.posts] then
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
		end
	end,
	on_error = function(self)
		self.errors = generate.errors(self.i18n, self.errors)
		return { render = "board"}
	end,
	GET = function()
		return { render = "board" }
	end,
	POST = function(self)
		-- Validate CSRF token
		csrf.assert_token(self)

		local board_url = self:url_for("web.boards.board", { uri_short_name=self.board.short_name })

		-- Submit new thread
		if self.params.submit then
			-- Validate user input
			assert_valid(self.params, {
				{ "name",    max_length=255 },
				{ "subject", max_length=255 },
				{ "options", max_length=255 },
				{ "comment", max_length=self.text_size }
			})

			-- Validate post
			local post = assert_error(process.create_thread(self.params, self.session, self.board))
			return { redirect_to = self:url_for("web.boards.thread", { uri_short_name=self.board.short_name, thread=post.post_id, anchor="p", id=post.post_id }) }
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
			return { redirect_to = board_url }
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
			return { redirect_to = board_url }
		end

		-- Admin commands
		if self.session.admin or self.session.mod then
			-- Sticky thread
			if self.params.sticky then
				assert_error(process.sticky_thread(self.params, self.board))
				return { redirect_to = board_url }
			end

			-- Lock thread
			if self.params.lock then
				assert_error(process.lock_thread(self.params, self.board))
				return { redirect_to = board_url }
			end

			-- Save thread
			if self.params.save then
				assert_error(process.save_thread(self.params, self.board))
				return { redirect_to = board_url }
			end

			-- Override thread
			if self.params.override then
				assert_error(process.override_thread(self.params, self.board))
				return { redirect_to = board_url }
			end

			-- Ban user
			if self.params.ban then
				assert_error(process.ban_user(self.params, self.board))
				return { redirect_to = board_url }
			end
		end

		return { redirect_to = board_url }
	end
}
