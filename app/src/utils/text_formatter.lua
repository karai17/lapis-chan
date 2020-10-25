local Posts     = require "models.posts"
local escape    = require("lapis.html").escape
local sf        = string.format
local formatter = {}

--- Sanitize text for HTML safety
-- @tparam string text Raw text
-- @treturn string formatted
function formatter.sanitize(text)
	return escape(text)
end

--- Format new lines to 'br' tags
-- @tparam string text Raw text
-- @treturn string formatted
function formatter.new_lines(text)
	return text:gsub("\n", "<br />\n")
end

--- Format words that begin with '>>'
-- @tparam string text Raw text
-- @tparam table request Request object
-- @tparam table board Board data
-- @tparam table post Post data
-- @treturn string formatted
function formatter.quote(text, request, board, post)
	local function get_url(board, post_id)
		if tonumber(post_id) then
			local p = Posts:get(board.id, post_id)
			if not p then return false end

			local thread = p:get_thread()
			if not thread then return false end

			local op = thread:get_op()
			return
				request:url_for("web.boards.thread", { board=board.name, thread=op.post_id }),
				op
		else
			return request:url_for("web.boards.board", { board=board.name })
		end
	end

	-- >>1234 ur a fag
	-- >>(%d+)
	local match_pattern = "&gt;&gt;(%d+)"
	local sub_pattern   = "&gt;&gt;%s"

	-- Get all the matches and store them in an ordered list
	local posts = {}
	for post_id in text:gmatch(match_pattern) do
		table.insert(posts, { board=board, id=post_id })
	end

	-- Format each match
	for i, p in ipairs(posts) do
		local text    = sf(sub_pattern, p.id)
		local url, op = get_url(p.board, p.id)
		if url then
			if op.thread_id == post.thread_id then
				posts[i] = sf("<a href='%s#p%s' class='quote_link'>%s</a>", url, p.id, text)
			else
				posts[i] = sf("<a href='%s#p%s' class='quote_link'>%s→</a>", url, p.id, text)
			end
		else
			posts[i] = sf("<span class='broken_link'>%s</span>", text)
		end
	end

	-- Substitute each match with the formatted match
	local i = 0
	text = text:gsub(match_pattern, function()
		i = i + 1
		return posts[i]
	end)

	-- >>>/a/1234 check over here
	-- >>>/(%w+)/(%d*)
	match_pattern = "&gt;&gt;&gt;/(%w+)/(%d*)"
	sub_pattern   = "&gt;&gt;&gt;/%s/%s"

	-- Get all the matches and store them in an ordered list
	posts = {}
	for b, post_id in text:gmatch(match_pattern) do
		local response = request.api.boards.GET(request)
		b = response.json or b
		table.insert(posts, { board=b, id=post_id })
	end

	-- Format each match
	for i, p in ipairs(posts) do
		if type(p.board) == "table" then
			local text    = sf(sub_pattern, p.board.name, p.id)
			local url, op = get_url(p.board, p.id)
			if op then
				posts[i] = sf("<a href='%s#p%s' class='quote_link'>%s</a>", url, p.id, text)
			else
				posts[i] = sf("<a href='%s' class='quote_link'>%s</a>", url, text)
			end
		else
			local text = sf(sub_pattern, p.board, p.id)
			posts[i]   = sf("<span class='broken_link'>%s</span>", text)
		end
	end

	-- Substitute each match with the formatted match
	i = 0
	text = text:gsub(match_pattern, function()
		i = i + 1
		return posts[i]
	end)

	return text
end

--- Format lines that begin with '>'
-- @tparam string text Raw text
-- @treturn string formatted
function formatter.green_text(text)
	local formatted = ""

	for line in text:gmatch("[^\n]+") do
		local first  = line:sub(1, 4)

		-- >implying
		if first == "&gt;" then
			line = sf("%s%s%s", "<span class='quote_green'>", line, "</span>")
		end

		formatted = sf("%s%s%s", formatted, line, "\n")
	end

	return formatted
end

--- Format lines that begin with '<'
-- @tparam string text Raw text
-- @treturn string formatted
function formatter.blue_text(text)
	local formatted = ""

	for line in text:gmatch("[^\n]+") do
		local first  = line:sub(1, 4)

		-- <implying
		if first == "&lt;" then
			line = sf("%s%s%s", "<span class='quote_blue'>", line, "</span>")
		end

		formatted = sf("%s%s%s", formatted, line, "\n")
	end

	return formatted
end

function formatter.spoiler(text)
	return text:gsub("(%[spoiler%])(.-)(%[/spoiler%])", "<span class='spoiler'>%2</span>")
end

return formatter
