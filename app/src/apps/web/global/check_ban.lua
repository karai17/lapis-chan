local Bans = require "models.bans"

return function(self)
	-- MODS = FAGS
	if self.session.admin         or
		self.session.mod           or
		self.session.janitor       or
		self.route_name == "admin" then
		return
	end

	-- Get list of bans by ip
	local bans = Bans:get_bans_by_ip(self.params.ip)

	-- Get current board
	local board = {}
	if self.params.uri_short_name then
		local response = self.api.board.GET(self)
		board = response.json
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
