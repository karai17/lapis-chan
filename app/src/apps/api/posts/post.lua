local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.internal.action_base")
local assert_error = require("lapis.application").assert_error
local assert_valid = require("lapis.validate").assert_valid
local trim_filter  = require("lapis.util").trim_filter
local models       = require "models"
local Threads      = models.threads
local Posts        = models.posts

function action:GET()

	-- Get Post
	local post = assert_error(Posts:get_post_by_id(self.params.uri_id))
	--Posts:format_from_db(post)

	return {
		status = ngx.HTTP_OK,
		json   = post
	}
end

function action:PUT()

	-- Validate parameters
	local params = {
		comment      = self.params.comment,
		subject      = self.params.subject,
		file_spoiler = self.params.file_spoiler
	}
	Posts:format_to_db(params)
	trim_filter(params)
	assert_valid(params, Posts.valid_record)

	-- Modify post
	local post = assert_error(Posts:modify(params))
	Posts:format_from_db(post)

	return {
		status = ngx.HTTP_OK,
		json   = post
	}
end

function action:DELETE()

	--[[ FIXME: needs proper auth!
	-- MODS = FAGS
	if type(session) == "table" and
		(session.admin or session.mod or session.janitor) then
		rm_post(board.name)
		success = true
	-- Override password
	elseif type(session) == "string" and
		session == "override" then
		rm_post(board.name)
		success = true
	-- Password has to match!
	elseif post and session.password and
		post.password == session.password then
		rm_post(board.name)
		success = true
	end
	--]]

	-- Delete post
	local post   = assert_error(Posts:get_post_by_id(self.params.uri_id))
	local thread = post:get_thread()
	local op     = thread:get_op()

	if post.id == op.id then
		assert_error(Threads:delete(thread.id))

		local posts = thread:get_posts()
		for _, p in ipairs(posts) do
			assert_error(Posts:delete(p.id))
		end
	else
		assert_error(Posts:delete(post.id))
	end

	return {
		status = ngx.HTTP_OK,
		json   = {
			id = post.id
		}
	}
end

return action
