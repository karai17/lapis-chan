local Bans       = require "models.bans"
local Boards     = require "models.boards"
local Threads    = require "models.threads"
local Posts      = require "models.posts"
local Reports    = require "models.reports"
local format     = require "utils.text_formatter"
local prep_error = require "utils.prep_error"
local csrf       = require "lapis.csrf"
local validate   = require("lapis.validate").validate

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

		-- Get current thread data
		if self.params.thread then
			local post  = Posts.get_post(self.board.id, self.params.thread)
			self.thread = Threads.get_thread(post.thread_id)
			self.op     = Posts.get_thread_op(self.board.id, self.thread.id)
		end
	end,
	GET = function(self)
		return { redirect_to = self.index_url }
	end,
	POST = function(self)
		-- Validate CSRF token
		local _, err = csrf.validate_token(self)
		if err then return prep_error(self, err) end

		self.board_url   = self.boards_url .. self.board.short_name .. "/"
		self.thread_url  = self.board_url  .. "thread/"

		if self.params.delete then
			-- Delete thread
			if self.params.thread then
				-- Validate user input
				local err = validate(self.params, {
					{ "csrf_token", exists=true },
					{ "board",      exists=true },
					{ "thread",     exists=true },
					{ "post_id",    exists=true }
				})
				if err then return prep_error(self, err[1]) end

				local post   = Posts.get_post(self.board.id, self.params.post_id)
				local thread = Threads.get_thread(post.thread_id)
				local posts  = Posts.get_thread_posts(self.board.id, thread.id)

				local _, err = Threads.delete_thread(self.session, thread, posts[1])
				if err then return prep_error(self, err) end

				-- Delete all associated posts
				for _, post in ipairs(posts) do
					Posts.delete_post("override", self.board, post)

					-- Delete associated report
					local report = Reports.get_report(post.id)
					if report then
						Reports.delete_report(report)
					end
				end

				return { redirect_to = self.board_url }
			-- Delete post
			else
				-- Validate user input
				local err = validate(self.params, {
					{ "csrf_token", exists=true },
					{ "board",      exists=true },
					{ "post_id",    exists=true }
				})
				if err then return prep_error(self, err[1]) end

				local post = Posts.get_post(self.board.id, self.params.post_id)

				local _, err = Posts.delete_post(self.session, self.board, post)
				if err then return prep_error(self, err) end

				-- Update thread
				local thread = Threads.get_thread(post.thread_id)
				local posts  = Posts.get_thread_posts(self.board.id, thread.id)

				thread.last_active = posts[#posts].timestamp
				thread:update("last_active")

				if self.params.thread then
					return { redirect_to = self.thread_url .. self.params.thread }
				else
					return { redirect_to = self.board_url }
				end
			end
		end

		-- Submit new post
		if self.params.submit then
			-- Validate user input
			local err = validate(self.params, {
				{ "csrf_token", exists=true },
				{ "board",      exists=true },
				{ "name",       max_length=255 },
				{ "subject",    max_length=255 },
				{ "options",    max_length=255 },
				{ "comment",    max_length=4096 }
			})
			if err then return prep_error(self, err[1]) end

			local is_op = true

			-- Get IP from ngx
			self.params.ip = self.req.headers["X-Real-IP"] or self.req.remote_addr

			local thread, posts, files
			if self.thread then
				is_op     = false
				thread = self.thread
				posts  = Posts.count_posts(self.board.id, self.thread.id)
				files  = Posts.count_files(self.board.id, self.thread.id)
			end

			-- Prepare data for entry
			local _, err = Posts.prepare_post(
				self.params, self.session, self.board, thread, posts, files
			)
			if err then return prep_error(self, err) end

			local err
			if not thread then
				-- Only admins and mods can flag threads
				if not self.session.admin or self.session.mod then
					self.params.sticky        = nil
					self.params.lock          = nil
					self.params.size_override = nil
					self.params.save          = nil
				end

				-- Create new thread
				thread, err = Threads.create_thread(self.board.id, {
					sticky        = self.params.sticky,
					lock          = self.params.lock,
					size_override = self.params.size_override,
					save          = self.params.save
				})
				if err then return prep_error(self, err) end

				-- No need to query the db for this
				posts = 0

				-- Archive old threads
				local max_threads = self.board.threads_per_page * self.board.pages
				Threads.archive_threads(self.board.id, max_threads)

				-- Delete old archived threads
				local time    = os.time()
				local threads = Threads.get_archived_threads(self.board.id)

				for _, t in ipairs(threads) do
					if time - t.last_active > self.board.archive_time and not t.save then
						local posts = Posts.get_thread_posts(t.id)
						Threads.delete_thread("override", t, posts)
					end
				end
			end

			-- Insert post data into database
			local post, err = Posts.create_post(
				self.params,
				self.session,
				self.board,
				thread,
				is_op
			)
			if err then return prep_error(self, err) end

			posts = posts + 1

			-- Check for [auto]sage
			if self.params.options ~= "sage" and
			posts <= self.board.post_limit then
				-- Update thread
				thread.last_active = os.time()
				thread:update("last_active")
			end

			local op = Posts.get_thread_op(self.board.id, thread.id)
			return {
				redirect_to = self.thread_url .. op.post_id .. "#p" .. post.post_id
			}
		end

		-- Report post
		if self.params.report then
			local post   = Posts.get_post(self.board.id, self.params.post_id)
			local report = Reports.get_report(self.board.id, post.post_id)

			-- If report exists, update it
			if report then
				report.num_reports = report.num_reports + 1
				local _, err = Reports.modify_report(report)
				if err then return prep_error(self, err) end
			-- If report is new, create it
			else
				local _, err = Reports.create_report {
					board_id    = self.board.id,
					thread_id   = post.thread_id,
					post_id     = post.post_id,
					timestamp   = os.time(),
					num_reports = 1
				}
				if err then return prep_error(self, err) end
			end

			if self.params.thread then
				return { redirect_to = self.thread_url .. self.params.thread }
			else
				return { redirect_to = self.board_url }
			end
		end

		-- Admin commands
		if self.session.admin or self.session.mod then
			-- Sticky thread
			if self.params.sticky then
				local post   = Posts.get_post(self.board.id, self.params.post_id)
				local thread = Threads.get_thread(post.thread_id)
				thread.sticky = not thread.sticky
				thread:update("sticky")
			end

			-- Lock thread
			if self.params.lock then
				local post   = Posts.get_post(self.board.id, self.params.post_id)
				local thread = Threads.get_thread(post.thread_id)
				thread.lock = not thread.lock
				thread:update("lock")
			end

			-- Save thread
			if self.params.save then
				local post   = Posts.get_post(self.board.id, self.params.post_id)
				local thread = Threads.get_thread(post.thread_id)
				thread.save = not thread.save
				thread:update("save")
			end

			-- Override thread
			if self.params.override then
				local post   = Posts.get_post(self.board.id, self.params.post_id)
				local thread = Threads.get_thread(post.thread_id)
				thread.size_override = not thread.size_override
				thread:update("size_override")
			end

			-- Ban user
			if self.params.ban then
				local post = Posts.get_post(self.board.id, self.params.post_id)

				self.params.ip = post.ip

				-- Convert board name to id if checkbox is set
				if self.params.board_id then
					self.params.board_id = self.board.id
				end

				-- gtfo
				local ban, err = Bans.create_ban(self.params)
				if err then prep_error(self, err) end

				if self.params.banned then
					-- Flag post
					post.banned = true
					post:update("banned")
				end
			end

			return { redirect_to = self.board_url }
		end
	end
}
