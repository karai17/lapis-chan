local assert_error = require("lapis.application").assert_error
local yield_error  = require("lapis.application").yield_error
local mime         = require "mime"
local models       = require "models"
local Users        = models.users

return function(self)

	if self.req.headers["Authorization"] then

		-- Decode auth info
		local auth = mime.unb64(self.req.headers["Authorization"]:sub(7))
		local username, api_key = auth:match("^(.+)%:(.+)$")

		-- DENY if Authorization is malformed
		if not username or not api_key then
			yield_error("FIXME: Corrupt auth!")
		end

		-- DENY if a user's key isn't properly set
		if api_key == Users.default_key then
			yield_error("FIXME: Bad auth!")
		end

		local params = {
			username = username,
			api_key  = api_key
		}

		-- Get User
		self.api_user = assert_error(Users:get_api(params))
		Users:format_from_db(self.api_user)
		return
	end

	-- Set basic User
	self.api_user = {
		id   = -1,
		role = -1
	}
end
