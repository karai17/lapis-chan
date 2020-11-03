local assert_error = require("lapis.application").assert_error
local mime         = require "mime"
local models       = require "models"
local Users        = models.users

return function(self)

	if self.req.headers["Authorization"] then

		-- Decode auth info
		local auth = mime.unb64(self.req.headers["Authorization"])
		local username, api_key = auth:match("^Basic (.+)%:(.+)$")

		local params = {
			username = username,
			api_key  = api_key
		}

		-- Get User
		self.api_user          = assert_error(Users:get_api(params))
		self.api_user.api_key  = nil -- This doesn't clear memory in time to be meaningful, but we
		self.api_user.password = nil -- can prevent leaks if we accidentally send this in a response
		return
	end

	-- Set basic User
	self.api_user = {
		id   = -1,
		role = -1
	}

end
