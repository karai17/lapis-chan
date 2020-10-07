local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.global.action_base")
local assert_error = require("lapis.application").assert_error
local assert_valid = require("lapis.validate").assert_valid
local trim_filter  = require("lapis.util").trim_filter
local models       = require "models"
local Boards       = models.boards

function action.GET()

	-- Get Boards
	local boards = assert_error(Boards:get_all())
	for _, board in ipairs(boards) do
		Boards:format_from_db(board)
	end

	return {
		status = ngx.HTTP_OK,
		json   = boards
	}
end

function action:POST()

	-- Validate parameters
	local params = {
		short_name        = self.params.short_name,
		name              = self.params.name,
		subtext           = self.params.subtext,
		rules             = self.params.rules,
		anon_name         = self.params.anon_name,
		theme             = self.params.theme,
		total_posts       = self.params.total_posts,
		pages             = self.params.pages,
		threads_per_page  = self.params.threads_per_page,
		text_only         = self.params.text_only,
		filetype_image    = self.params.filetype_image,
		filetype_audio    = self.params.filetype_audio,
		draw              = self.params.draw,
		thread_file       = self.params.thread_file,
		thread_comment    = self.params.thread_comment,
		thread_file_limit = self.params.thread_file_limit,
		post_file         = self.params.post_file,
		post_comment      = self.params.post_comment,
		post_limit        = self.params.post_limit,
		archive           = self.params.archive,
		archive_time      = self.params.archive_time,
		group             = self.params.group
	}
	Boards:format_to_db(params)
	trim_filter(params)
	assert_valid(params, Boards.valid_record)

	-- Verify unique names
	for _, board in ipairs(self.boards) do
		if board.name       == params.name or
			board.short_name == params.short_name then
			assert_error(false, "err_board_used")
		end
	end

	-- Create board
	local board = assert_error(Boards:new(params))
	Boards:format_from_db(board)

	return {
		status = ngx.HTTP_OK,
		json   = board
	}
end

return action
