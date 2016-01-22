local Users      = require "models.users"
local Boards     = require "models.boards"
local Threads    = require "models.threads"
local Posts      = require "models.posts"
local lfs        = require "lfs"
local prep_error = require "utils.prep_error"
local csrf       = require "lapis.csrf"

return {
	before = function(self)
		-- Get all board data
		self.boards = Boards.get_boards()
	end,
	GET = function(self)
		-- Generate CSRF token
		self.csrf_token = csrf.generate_token(self)

		-- Page title
		self.page_title = "Admin Panel"

		-- Verify Authorization
		if self.session.name then
			if not self.session.admin then
				return prep_error(self, "You are not an admin.")
			end
		else
			return { render = "admin.login" }
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
			self.page_title = "Admin Panel - Create Board"
			return { render = "admin.create_board" }
		end

		-- Display modification form
		if self.params.action == "modify" then
			self.page_title = "Admin Panel - Modify Board"
			self.board = Boards.get_board(self.params.board)
			self.board.archive_time = self.board.archive_time / 24 / 60 / 60
			return { render = "admin.modify_board" }
		end

		-- Delete board
		if self.params.action == "delete" then
			local board   = Boards.get_board(self.params.board)
			local threads = Threads.get_threads(board.id)
			local posts   = Posts.get_posts(board.id)

			-- Delete board
			local _, err = Boards.delete_board(board, threads, posts)
			if err then return prep_error(self, err) end

			self.action = string.format(
				"deleted the board: /%s/ - %s",
				board.short_name,
				board.name
			)
			self.page_title = "Admin Panel - Success"

			return { render = "admin.success" }
		end

		-- Invalid action, gtfo
		return { redirect_to = self.admin_url }
	end,
	POST = function(self)
		-- Page title
		self.page_title = "Admin Panel"

		-- Validate CSRF token
		local _, err = csrf.validate_token(self)

		-- Invalid token
		if err then return prep_error(self, err) end

		-- Must be logged in as an admin!
		if self.session.admin then
			-- Create new board
			if self.params.create_board then
				-- Verify unique names
				for _, board in ipairs(self.boards) do
					if board.name       == self.params.name or
						board.short_name == self.params.short_name then
						prep_error(self, "Board name already in use.")
					end
				end

				-- Convert archive_time to seconds
				if self.params.archive_time ~= "" then
					self.params.archive_time = tonumber(
						self.params.archive_time
					) * 24 * 60 * 60
				end

				-- Create board
				local board, err = Boards.create_board(self.params)
				if err then return prep_error(self, err) end

				self.action = string.format(
					"created the board: /%s/ - %s",
					board.short_name,
					board.name
				)

				return { render = "admin.success" }
			end

			-- Modify board
			if self.params.modify_board then
				local board = Boards.get_board(self.params.board)
				local old_short_name = board.short_name

				for k, param in pairs(self.params) do
					if board[k] then
						board[k] = param
					end
				end

				-- Convert archive_time to seconds
				if board.archive_time ~= "" then
					board.archive_time = tonumber(board.archive_time) * 24 * 60 * 60
				end

				-- Modify board
				local _, err = Boards.modify_board(board, old_short_name)
				if err then return prep_error(self, err) end

				self.action = string.format(
					"modified the board: /%s/ - %s",
					board.short_name,
					board.name
				)

				return { render = "admin.success" }
			end

			return { redirect_to = self.admin_url }
		end

		return { render = "admin.login" }
	end
}
