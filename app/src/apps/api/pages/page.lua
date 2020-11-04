local ngx           = _G.ngx
local action        = setmetatable({}, require "apps.api.internal.action_base")
local assert_error  = require("lapis.application").assert_error
local assert_valid  = require("lapis.validate").assert_valid
local trim_filter   = require("lapis.util").trim_filter
local models        = require "models"
local Pages         = models.pages

function action:GET()
	local page = assert_error(Pages:get(self.params.uri_id))

	return {
		status = ngx.HTTP_OK,
		json   = page
	}
end

function action:PUT()

	-- Validate parameters
	local params = {
		id       = tonumber(self.params.uri_id),
		board_id = tonumber(self.params.board_id),
		text     = self.params.text,
	}
	trim_filter(params)
	assert_valid(params, Pages.valid_record)

	-- Modify page
	local page = assert_error(Pages:modify(params))

	return {
		status = ngx.HTTP_OK,
		json   = page
	}
end

function action:DELETE()

	-- Delete page
	local page = assert_error(Pages:delete(self.params.uri_id))

	return {
		status = ngx.HTTP_OK,
		json   = {
			id   = page.id,
			text = page.text
		}
	}
end

return action
