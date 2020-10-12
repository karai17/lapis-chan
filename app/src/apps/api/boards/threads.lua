local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.internal.action_base")
local assert_error = require("lapis.application").assert_error
local models       = require "models"
local Boards       = models.boards
local Threads      = models.threads

function action:GET()

	local threads, pages
	local board = assert_error(Boards:get(self.params.uri_short_name))

	-- Get Threads
	if self.params.uri_page then
		local paginator = board:get_threads_paginated({ per_page=board.threads_per_page })
		threads = paginator:get_page(self.params.uri_page)
		pages   = paginator:num_pages()
	else
		threads = board:get_threads()
	end

	for _, thread in ipairs(threads) do
		--Threads:format_from_db(thread)
	end

	return {
		status = ngx.HTTP_OK,
		json   = {
			threads = threads,
			pages   = pages
		}
	}
end

return action
