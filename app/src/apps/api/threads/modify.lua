local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.global.action_base")
local assert_error = require("lapis.application").assert_error
local models       = require "models"
local Threads      = models.threads

function action:PUT()

	local params = { id=self.params.uri_id }

	-- Extract flag from URI
	if self.params.uri_value:lower()   == "true" or
		self.params.uri_value:lower()   == "t"    or
		tonumber(self.params.uri_value) == 1      then
		self.params.uri_value = true
	elseif self.params.uri_value:lower() == "false" or
		self.params.uri_value:lower()     == "f"     or
		tonumber(self.params.uri_value)   == 0       then
		self.params.uri_value = false
	else
		return {
			status = ngx.HTTP_BAD_REQUEST,
			json   = {}
		}
	end

	-- Extract variable from URI
	if self.params.uri_action == "sticky" then
		params.sticky = self.params.uri_value
	elseif self.params.uri_action == "lock" then
		params.lock = self.params.uri_value
	elseif self.params.uri_action == "save" then
		params.save = self.params.uri_value
	elseif self.params.uri_action == "size_override" then
		params.size_override = self.params.uri_value
	else
		return {
			status = ngx.HTTP_BAD_REQUEST,
			json   = {}
		}
	end

	-- Modify thread
	local thread = assert_error(Threads:modify(params))
	--Threads:format_from_db(thread)

	return {
		status = ngx.HTTP_OK,
		json   = thread
	}
end

return action
