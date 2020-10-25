local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.internal.action_base")
local assert_error = require("lapis.application").assert_error
local assert_valid = require("lapis.validate").assert_valid
local trim_filter  = require("lapis.util").trim_filter
local models       = require "models"
local Boards       = models.boards

function action:GET()

	-- Get Board
	local board = assert_error(Boards:get(self.params.uri_name))
	Boards:format_from_db(board)

	return {
		status = ngx.HTTP_OK,
		json   = board
	}
end

function action:PUT()

	-- Validate parameters
	local params = {
		name              = self.params.name,
		title             = self.params.title,
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

	-- Modify board
	local board = assert_error(Boards:modify(params, self.params.uri_name))
	Boards:format_from_db(board)

	return {
		status = ngx.HTTP_OK,
		json   = board
	}
end

function action:DELETE()

	-- Delete board
	local board = assert_error(Boards:delete(self.params.uri_name))

	return {
		status = ngx.HTTP_OK,
		json   = {
			id         = board.id,
			name = board.name,
			title      = board.title
		}
	}
end

return action
