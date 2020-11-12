local ngx          = _G.ngx
local action       = setmetatable({}, require "apps.api.internal.action_base")
local assert_error = require("lapis.application").assert_error
local assert_valid = require("lapis.validate").assert_valid
local trim_filter  = require("lapis.util").trim_filter
local role         = require "utils.role"
local models       = require "models"
local Pages        = models.pages

function action:GET()
	local page = assert_error(Pages:get(self.params.uri_page))

	return {
		status = ngx.HTTP_OK,
		json   = page
	}
end

function action:PUT()

	-- Verify the User's permissions
	assert_error(role.admin(self.api_user))

	-- Validate parameters
	local params = {
		slug    = self.params.slug,
		title   = self.params.title,
		content = self.params.content
	}
	trim_filter(params)
	Pages:format_to_db(params)
	assert_valid(params, Pages.valid_record)

	-- Modify page
	local page = assert_error(Pages:modify(params, self.params.uri_page))

	return {
		status = ngx.HTTP_OK,
		json   = page
	}
end

function action:DELETE()

	-- Verify the User's permissions
	assert_error(role.admin(self.api_user))

	-- Delete Page
	local page = assert_error(Pages:delete(self.params.uri_page))

	return {
		status = ngx.HTTP_OK,
		json   = {
			slug  = page.slug,
			title = page.title
		}
	}
end

return action
