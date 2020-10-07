local assert_error = require("lapis.application").assert_error
local capture      = require "utils.capture"
local format       = require "utils.text_formatter"
local Posts        = require "models.posts"
local Threads      = require "models.threads"

return function(self)

	-- Get board
	for _, board in ipairs(self.boards) do
		if board.short_name == self.params.uri_short_name then
			self.board = board
			break
		end
	end

	-- Board not found
	if not self.board then
		return self:write({ redirect_to = self:url_for("web.pages.index") })
	end

	-- Get announcements
	self.announcements = assert_error(capture.get(self:url_for("api.boards.announcements", { uri_short_name=self.params.uri_short_name })))

	-- Page title
	self.page_title = string.format(
		"/%s/ - %s",
		self.board.short_name,
		self.board.name
	)

	-- Nav links link to sub page if available
	self.sub_page = "archive"

	-- Get threads
	self.threads = Threads:get_archived_threads(self.board.id)

	-- Get time
	self.days = math.floor(self.board.archive_time / 24 / 60 / 60)

	-- Get stats
	for _, thread in ipairs(self.threads) do
		thread.op      = Posts:get_thread_op(thread.id)
		thread.replies = Posts:count_posts(thread.id) - 1
		thread.url     = self:url_for("web.boards.thread", { uri_short_name=self.board.short_name, thread=thread.op.post_id })

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
end
