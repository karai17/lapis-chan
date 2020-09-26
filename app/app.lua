local lapis = require "lapis"
local app   = lapis.Application()

app:enable "etlua"
app.layout  = require "views.layout"
app.include = function(self, a)
	self.__class.include(self, a, nil, self)
end

--[[ -- app:before_filter(require "apps.web.global.install") -- FIXME: set up installer as a simple before filter
do
	local r2 = require("lapis.application").respond_to
	app:before_filter(require "apps.web.global.config_site")
	app:match("/", r2(require "apps.web.global.install"))
	return app
end
--]]

app:before_filter(require "apps.web.global.config_site")
app:before_filter(require "apps.web.global.check_auth")
app:before_filter(require "apps.web.global.check_ban")

app:include("apps.web.admin")
app:include("apps.web.pages")
app:include("apps.web.boards")

return app
