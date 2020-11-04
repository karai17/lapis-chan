local ngx           = _G.ngx
local action        = setmetatable({}, require "apps.api.internal.action_base")
local assert_error  = require("lapis.application").assert_error
local assert_valid  = require("lapis.validate").assert_valid
local trim_filter   = require("lapis.util").trim_filter
local models        = require "models"
local Pages         = models.pages

function action:GET()

	-- Get all Pages
	local pages = assert_error(Pages:get_all())

	return {
		status = ngx.HTTP_OK,
		json   = pages
	}
end

function action:POST()

	-- Validate parameters
	local params = {
		board_id = self.params.board_id,
		text     = self.params.text,
	}
	trim_filter(params)
	assert_valid(params, Pages.valid_record)

	-- Create page
	local page = assert_error(Pages:new(params))

	return {
		status = ngx.HTTP_OK,
		json   = page
	}
end

return action
