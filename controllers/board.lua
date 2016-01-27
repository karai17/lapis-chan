local assert_error  = require("lapis.application").assert_error
local assert_valid  = require("lapis.validate").assert_valid
local csrf          = require "lapis.csrf"
local i18n          = require "i18n"
local format        = require "utils.text_formatter"
local process       = require "utils.request_processor"
local Announcements = require "models.announcements"
local Boards        = require "models.boards"
local Posts         = require "models.posts"
local Threads       = require "models.threads"

return {
	before = function(self)
		-- Set localization
		i18n.setLocale(self.session.locale or "en")
		i18n.loadFile("locale/" .. i18n.getLocale() .. ".lua")
		self.i18n = i18n

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
		if not self.board or
			self.params.page and not tonumber(self.params.page) then
			self:write({ redirect_to = self.index_url })
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

		-- Page URLs
		self.staticb_url = self.static_url .. self.board.short_name .. "/"
		self.board_url   = self.boards_url .. self.board.short_name .. "/"
		self.thread_url  = self.board_url  .. "thread/"
		self.thread_url  = self.board_url  .. "thread/"
		self.archive_url = self.board_url  .. "archive/"
		self.catalog_url = self.board_url  .. "catalog/"
		self.form_url    = self.board_url

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
				assert_error(false, { "err_orphaned", thread.id })
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
	end,
	on_error = function(self)
		self.err = i18n(unpack(self.errors))

		if self.err then
			self.err = "<p>" .. self.err .. "</p>"
		else
			self.err = ""
			for _, e in ipairs(self.errors) do
				self.err = self.err .. "<p>" .. tostring(e) .. "</p>\n"
			end
		end

		return { render = "board"}
	end,
	GET = function(self)
		return { render = "board" }
	end,
	POST = function(self)
		-- Validate CSRF token
		csrf.assert_token(self)

		-- Submit new thread
		if self.params.submit and not self.thread then
			-- Validate user input
			assert_valid(self.params, {
				{ "name",    max_length=255 },
				{ "subject", max_length=255 },
				{ "options", max_length=255 },
				{ "comment", max_length=4096 }
			})

			-- Validate post
			local post = assert_error(process.create_thread(
				self.params, self.session, self.board
			))

			return {
				redirect_to = self.thread_url .. post.post_id .. "#p" .. post.post_id
			}
		end

		-- Delete thread
		if self.params.delete and self.params.thread_id then
			-- Validate user input
			assert_valid(self.params, {
				{ "post_id", exists=true }
			})

			-- Validate deletion
			assert_error(process.delete_thread(
				self.params, self.session, self.board
			))

			return {
				redirect_to = self.board_url
			}
		end

		-- Delete post
		if self.params.delete and not self.params.thread_id then
			-- Validate user input
			assert_valid(self.params, {
				{ "post_id", exists=true }
			})

			-- Validate deletion
			assert_error(process.delete_post(
				self.params, self.session, self.board
			))

			if self.params.thread then
				return {
					redirect_to = self.thread_url .. self.params.thread_id
				}
			else
				return {
					redirect_to = self.board_url
				}
			end
		end

		-- Report post
		if self.params.report then
			-- Validate user input
			assert_valid(self.params, {
				{ "board",   exists=true },
				{ "post_id", exists=true }
			})

			-- Validate report
			local post = assert_error(process.report_post(
				self.params, self.board
			))

			if self.thread then
				local op = Posts:get_thread_op(self.thread.id)
				return {
					redirect_to = self.thread_url .. op.post_id
				}
			else
				return {
					redirect_to = self.board_url
				}
			end
		end

		-- Admin commands
		if self.session.admin or self.session.mod then
			local op = Posts:get_thread_op(self.thread.id)

			-- Sticky thread
			if self.params.sticky then
				assert_error(process.sticky_thread(self.params, self.board))
				return {
					redirect_to = self.thread_url .. op.post_id
				}
			end

			-- Lock thread
			if self.params.lock then
				assert_error(process.lock_thread(self.params, self.board))
				return {
					redirect_to = self.thread_url .. op.post_id
				}
			end

			-- Save thread
			if self.params.save then
				assert_error(process.save_thread(self.params, self.board))
				return {
					redirect_to = self.thread_url .. op.post_id
				}
			end

			-- Override thread
			if self.params.override then
				assert_error(process.override_thread(self.params, self.board))
				return {
					redirect_to = self.thread_url .. op.post_id
				}
			end

			-- Ban user
			if self.params.ban then
				assert_error(process.ban_user(self.params, self.board))
				return {
					redirect_to = self.thread_url .. op.post_id
				}
			end

			return { redirect_to = self.board_url }
		end

		return { redirect_to = self.board_url }
	end
}
