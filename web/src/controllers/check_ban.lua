local Bans   = require "models.bans"
local Boards = require "models.boards"

return function(self)
	-- MODS = FAGS
	if self.session.admin or
		self.session.mod or
		self.session.janitor or
		self.route_name == "admin" then
		return
	end

	-- Get list of bans by ip
	local bans = Bans:get_bans_by_ip(self.params.ip)

	-- Get current board
	local board
	if self.params.board then
		board = Boards:get_board(self.params.board)
	end
	board = board or {}

	-- If you are banned, gtfo
	for _, ban in ipairs(bans) do
		if ban.board_id == 0 or
			ban.board_id == board.id then

			-- Ban data
			self.ip     = ban.ip
			self.reason = ban.reason or self.i18n("err_ban_reason")
			self.expire = os.date("%Y-%m-%d (%a) %H:%M:%S", ban.time + ban.duration)

			-- Get all board data
			self.boards = Boards:get_boards()

			-- Page title
			self.page_title = self.i18n("ban_title")

			-- Display a theme
			self.board = { theme = "yotsuba_b" }

			self:write({ render = "banned" })
			return
		end
	end
end
