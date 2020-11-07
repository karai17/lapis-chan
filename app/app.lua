local lapis = require "lapis"
local app   = lapis.Application()
app.include = function(self, a)
	self.__class.include(self, a, nil, self)
end

app:enable "etlua"
app.layout = require "views.layout"

do
	function app.handle_404()
		local api = _G.ngx.var.uri:match("^(/api).+$")

		if not api then
			return { render="code_404" }
		else
			return {
				status = 404,
				json   = { "Resource not found!" } -- FIXME: i18n
			}
		end
	end
end

-- NOTE: https://github.com/leafo/lapis/issues/706
do
	local super = app.__index.dispatch
	app.__index.dispatch = function(self, req, res)
		req.parsed_url.path = _G.ngx.var.uri
		super(self, req, res)
	end
end

--[[ -- app:before_filter(require "apps.web.internal.install") -- FIXME: set up installer as a simple before filter
do
	local r2 = require("lapis.application").respond_to
	app:before_filter(require "apps.web.internal.config_site")
	app:match("/", r2(require "apps.web.internal.install"))
	return app
end
--]]

app:include("apps.api")
app:include("apps.web")

return app
