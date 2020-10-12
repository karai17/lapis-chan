local assert_error = require("lapis.application").assert_error
local capture      = require "utils.capture"

return function(self)
	-- MODS = FAGS
	if self.session.admin         or
		self.session.mod           or
		self.session.janitor       or
		self.route_name == "admin" then
		return
	end

	-- Get list of bans by ip
	local bans = assert_error(capture.get(self:url_for("api.bans.bans_ip", { uri_ip=self.params.ip })))

	-- Get current board
	local board = {}
	if self.params.uri_name then
		board = assert_error(capture.get(self:url_for("api.boards.board", { uri_name=self.params.uri_name })))
	end

	-- If you are banned, gtfo
	for _, ban in ipairs(bans) do
		if ban.board_id == 0 or
			ban.board_id == board.id then

			-- Ban data
			self.ip     = ban.ip
			self.reason = ban.reason or self.i18n("err_ban_reason")
			self.expire = os.date("%Y-%m-%d (%a) %H:%M:%S", ban.time + ban.duration)

			-- Page title
			self.page_title = self.i18n("ban_title")

			-- Display a theme
			self.board = { theme = "yotsuba_b" }

			return self:write({ render = "banned" })
		end
	end
end
