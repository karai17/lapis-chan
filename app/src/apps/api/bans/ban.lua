local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.internal.action_base")
local assert_error = require("lapis.application").assert_error
local assert_valid = require("lapis.validate").assert_valid
local trim_filter  = require("lapis.util").trim_filter
local models       = require "models"
local Bans         = models.bans

function action:GET()

	-- Get Ban
	local ban = assert_error(Bans:get(self.params.uri_id))
	Bans:format_from_db(ban)

	return {
		status = ngx.HTTP_OK,
		json   = ban
	}
end

function action:PUT()

	-- Validate parameters
	local params = {
		id       = tonumber(self.params.uri_id),
		board_id = tonumber(self.params.board_id),
		ip       = self.params.ip,
		reason   = self.params.reason,
		time     = os.time(),
		duration = tonumber(self.params.duration)
	}
	Bans:format_to_db(params)
	trim_filter(params)
	assert_valid(params, Bans.valid_record)

	-- Modify ban
	local ban = assert_error(Bans:modify(params))
	Bans:format_from_db(ban)

	return {
		status = ngx.HTTP_OK,
		json   = ban
	}
end

function action:DELETE()

	-- Delete ban
	local ban = assert_error(Bans:delete(self.params.uri_id))

	return {
		status = ngx.HTTP_OK,
		json   = {
			id = ban.id,
			ip = ban.ip,
		}
	}
end

return action
