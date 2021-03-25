local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.internal.action_base")
local assert_error = require("lapis.application").assert_error
local yield_error  = require("lapis.application").yield_error
local assert_valid = require("lapis.validate").assert_valid
local trim_filter  = require("lapis.util").trim_filter
local role         = require "utils.role"
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

	-- Verify the User's permissions
	assert_error(role.admin(self.api_user))

	-- Validate parameters
	local params = {
		name              = self.params.name,
		title             = self.params.title,
		subtext           = self.params.subtext,
		rules             = self.params.rules,
		ban_message       = self.params.ban_message,
		anon_name         = self.params.anon_name,
		theme             = self.params.theme,
		total_posts       = tonumber(self.params.total_posts),
		pages             = tonumber(self.params.pages),
		threads_per_page  = tonumber(self.params.threads_per_page),
		anon_only         = self.params.anon_only,
		text_only         = self.params.text_only,
		draw              = self.params.draw,
		thread_file       = self.params.thread_file,
		thread_comment    = self.params.thread_comment,
		thread_file_limit = self.params.thread_file_limit,
		post_file         = self.params.post_file,
		post_comment      = self.params.post_comment,
		post_limit        = tonumber(self.params.post_limit),
		archive           = self.params.archive,
		archive_time      = tonumber(self.params.archive_time),
		group             = self.params.group,
		filetype_image    = self.params.filetype_image,
		filetype_audio    = self.params.filetype_audio
	}
	trim_filter(params)
	Boards:format_to_db(params)
	assert_valid(params, Boards.valid_record)

	-- Verify unique name and title
	local boards = Boards:get_all()
	for _, board in ipairs(boards) do
		if board.name == params.name or board.title == params.title then
			yield_error("FIXME")
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
