local assert_error  = require("lapis.application").assert_error
local assert_valid  = require("lapis.validate").assert_valid
local process       = require "utils.request_processor"
local csrf          = require "lapis.csrf"
local format        = require "utils.text_formatter"
local generate      = require "utils.generate"
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

		-- Get announcements
		self.announcements = Announcements:get_board_announcements(self.board.id)

		-- Page title
		self.page_title = string.format(
		"/%s/ - %s",
		self.board.short_name,
		self.board.name
		)

		-- Nav links link to sub page if available
		self.sub_page = "catalog"

		-- Flag comments as required or not
		self.comment_flag = self.board.thread_comment

		-- Generate CSRF token
		self.csrf_token = csrf.generate_token(self)

		-- Get threads
		self.threads = Threads:get_threads(self.board.id)

		-- Get stats
		for _, thread in ipairs(self.threads) do
			thread.op      = Posts:get_thread_op(thread.id)
			thread.replies = Posts:count_posts(thread.id) - 1
			thread.files   = Posts:count_files(thread.id)
			thread.url     = self:url_for("thread", { board=self.board.short_name, thread=thread.op.post_id })

			if thread.op.file_path then
				local name, ext = thread.op.file_path:match("^(.+)(%..+)$")
				ext = string.lower(ext)

				-- Get thumbnail URL
				if thread.op.file_type == "audio" then
					thread.op.thumb = self:format_url(self.static_url, "post_audio.png")
				elseif thread.op.file_type == "image" then
					if thread.op.file_spoiler then
						thread.op.thumb = self:format_url(self.static_url, "post_spoiler.png")
					else
						if ext == ".webm" or ext == ".svg" then
							thread.op.thumb = self:format_url(self.files_url, self.board.short_name, 's' .. name .. '.png')
						else
							thread.op.thumb = self:format_url(self.files_url, self.board.short_name, 's' .. thread.op.file_path)
						end
					end
				end

				thread.op.file_path = self:format_url(self.files_url, self.board.short_name, thread.op.file_path)
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
	end,
	on_error = function(self)
		self.errors = generate.errors(self.i18n, self.errors)
		return { render = "catalog"}
	end,
	GET = function()
		return { render = "catalog" }
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
				{ "comment", max_length=self.text_size }
			})

			-- Validate post
			local post = assert_error(process.create_thread(self.params, self.session, self.board))
			return { redirect_to = self:url_for("thread", { board=self.board.short_name, thread=post.post_id, anchor="p", id=post.post_id }) }
		end

		return { redirect_to = self:url_for("catalog", { board=self.board.short_name }) }
	end
}
