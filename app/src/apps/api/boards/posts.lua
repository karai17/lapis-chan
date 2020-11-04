local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.internal.action_base")
local assert_error = require("lapis.application").assert_error
local assert_valid = require("lapis.validate").assert_valid
local trim_filter  = require("lapis.util").trim_filter
local models       = require "models"
local Boards       = models.boards
local Threads      = models.threads
local Posts        = models.posts

function action:GET()

	local posts

	if self.params.uri_thread then
		local thread = assert_error(Threads:get(self.params.uri_thread))
		posts = thread:get_posts()
	else
		local board = assert_error(Boards:get(self.params.uri_board))
		posts = board:get_posts()
	end

	return {
		status = ngx.HTTP_OK,
		json   = posts
	}
end

function action:POST()
	local now    = os.time()
	local board  = assert_error(Boards:get(self.params.uri_name))
	local thread = Threads:get(self.params.uri_id)
	local op     = thread and false or true

	-- Create a new thread if no thread exists
	if not thread then
		-- Validate parameters
		local params = {
			board_id      = board.id,
			last_active   = now,
			sticky        = self.params.sticky,
			lock          = self.params.lock,
			size_override = self.params.size_override,
			save          = self.params.save
		}

		-- Only admins and mods can flag threads
		-- FIXME: API has no session, need proper auth!
		if not self.session.admin or self.session.mod then
			params.sticky        = nil
			params.lock          = nil
			params.size_override = nil
			params.save          = nil
		end

		--Threads:format_to_db(params)
		trim_filter(params)
		assert_valid(params, Threads.valid_record)

		-- Create thread
		thread = assert_error(Threads:new(params))
		--Threads:format_from_db(thread)
	end

	-- FIXME: there needs to be a better way to do this to avoid race conditions...
	board.total_posts  = board.total_posts + 1

	-- Validate parameters
	local params = {
		post_id       = board.total_posts,
		thread_id     = thread.id,
		board_id      = board.id,
		timestamp     = now,
		ip            = self.params.ip,
		comment       = self.params.comment,
		name          = self.params.name,
		trip          = self.params.trip,
		subject       = self.params.subject,
		password      = self.params.password,
		file_name     = self.params.file_name,
		file_path     = self.params.file_path,
		file_type     = self.params.file_type,
		file_md5      = self.params.file_md5,
		file_size     = self.params.file_size,
		file_width    = self.params.file_width,
		file_height   = self.params.file_height,
		file_duration = self.params.file_duration,
		file_spoiler  = self.params.file_spoiler,
		file_content  = self.params.file_content -- FIXME: we probably want to base64 decode this in format_to_db
	}
	Posts:format_to_db(params)
	trim_filter(params)
	assert_valid(params, Posts.valid_record)

	-- Create post
	local post = assert_error(Posts:new(params, board, op))
	Posts:format_from_db(post)

	return {
		status = ngx.HTTP_OK,
		json   = post
	}
end

return action
