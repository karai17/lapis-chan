local assert_error = require("lapis.application").assert_error
local assert_valid = require("lapis.validate").assert_valid
local csrf         = require "lapis.csrf"
local i18n         = require "i18n"
local lfs          = require "lfs"
local Boards       = require "models.boards"
local Posts        = require "models.posts"
local Threads      = require "models.threads"

return {
	before = function(self)
		-- Set localization
		i18n.setLocale(self.session.locale or "en")
		i18n.loadFile("locale/" .. i18n.getLocale() .. ".lua")
		self.i18n = i18n

		-- Get all board data
		self.boards = Boards:get_boards()

		-- Display a theme
		self.board = { theme = "yotsuba_b" }

		-- Generate CSRF token
		self.csrf_token = csrf.generate_token(self)

		-- Page title
		self.page_title = i18n("admin_panel")

		-- Verify Authorization
		if self.session.name then
			if not self.session.admin then
				assert_error(false, "err_not_admin")
			end
		else
			return
		end

		-- Get list of themes
		self.themes = {}
		for file in lfs.dir("."..self.styles_url) do
			local name, ext = string.match(file, "^(.+)(%..+)$")
			if name ~= "reset"  and
			name ~= "posts"  and
			name ~= "style"  and
			name ~= "tegaki" and
			ext  == ".css"   then
				table.insert(self.themes, name)
			end
		end

		-- Display creation form
		if self.params.action == "create" then
			self.page_title = string.format(
				"%s - %s",
				i18n("admin_panel"),
				i18n("create_board")
			)
			self.board = self.params

			if not self.board.theme then
				self.board.theme = "yotsuba_b"
			end

			return
		end

		-- Display modification form
		if self.params.action == "modify" then
			self.page_title = string.format(
				"%s - %s",
				i18n("admin_panel"),
				i18n("modify_board")
			)
			self.board = Boards:get_board(self.params.board)
			self.board.archive_time = self.board.archive_time / 24 / 60 / 60
			return
		end

		-- Delete board
		if self.params.action == "delete" then
			local board   = Boards:get_board(self.params.board)
			local threads = Threads:get_threads(board.id)
			local posts   = Posts:get_posts(board.id)
			assert_error(Boards:delete_board(board, threads, posts))

			self.page_title = string.format(
				"%s - %s",
				i18n("admin_panel"),
				i18n("success")
			)
			self.action = i18n("deleted_board", { board.short_name, board.name })
			return
		end
	end,
	on_error = function(self)
		self.err = i18n(unpack(self.errors))

		if self.err then
			self.err = "<p>" .. self.err .. "</p>"
		else
			self.err = ""
			for _, e in ipairs(self.errors) do
				self.err = self.err .. "<p>" .. tostring(e) .. "</p>\n"
			end
		end

		if not self.session.name then
			return { render = "admin.login" }
		elseif self.params.action == "create" then
			return { render = "admin.board" }
		elseif self.params.action == "modify" then
			return { render = "admin.board" }
		elseif self.params.action == "delete" then
			return { render = "admin.admin" }
		end
	end,
	GET = function(self)
		if not self.session.name then
			return { render = "admin.login" }
		elseif self.params.action == "create" then
			return { render = "admin.board" }
		elseif self.params.action == "modify" then
			return { render = "admin.board" }
		elseif self.params.action == "delete" then
			return { render = "admin.success" }
		end
	end,
	POST = function(self)
		-- Validate CSRF token
		csrf.assert_token(self)

		-- Validate user input
		assert_valid(self.params, {
			{ "short_name",        max_length=255, exists=true },
			{ "name",              max_length=255, exists=true },
			{ "subtext",           max_length=255 },
			{ "ban_message",       max_length=255 },
			{ "anon_name",         max_length=255 },
			{ "theme",             max_length=255 },
			{ "pages",             exists=true },
			{ "threads_per_page",  exists=true },
			{ "thread_file_limit", exists=true },
			{ "post_limit",        exists=true },
			{ "archive_time",      exists=true },
			{ "group",             exists=true }
		})

		-- Create new board
		if self.params.create_board then
			-- Verify unique names
			for _, board in ipairs(self.boards) do
				if board.name       == self.params.name or
					board.short_name == self.params.short_name then
					assert_error(false, "err_board_used")
				end
			end

			-- Convert archive_time to seconds
			if self.params.archive_time ~= "" then
				self.params.archive_time = tonumber(
					self.params.archive_time
				) * 24 * 60 * 60
			end

			-- Create board
			local board = assert_error(Boards:create_board(self.params))

			self.page_title = string.format(
				"%s - %s",
				i18n("admin_panel"),
				i18n("success")
			)
			self.action = i18n("created_board", { board.short_name, board.name })

			return { render = "admin.success" }
		end

		-- Modify board
		if self.params.modify_board then
			local discard = {
				"board",
				"modify_board",
				"ip",
				"action",
				"csrf_token"
			}

			local board = Boards:get_board(self.params.board)
			local old_short_name = board.short_name

			-- Fill in board with new data
			for k, param in pairs(self.params) do
				board[k] = param
			end

			-- Get rid of form trash
			for _, param in ipairs(discard) do
				board[param] = nil
			end

			-- Convert archive_time to seconds
			if board.archive_time ~= "" then
				board.archive_time = tonumber(board.archive_time) * 24 * 60 * 60
			end

			-- Modify board
			assert_error(Boards:modify_board(board, old_short_name))

			self.page_title = string.format(
				"%s - %s",
				i18n("admin_panel"),
				i18n("success")
			)
			self.action = i18n("modified_board", { board.short_name, board.name })

			return { render = "admin.success" }
		end

		return { redirect_to = self.admin_url }
	end
}
