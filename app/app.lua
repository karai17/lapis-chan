local lapis = require "lapis"
local app   = lapis.Application()

app:enable "etlua"
app.layout  = require "views.layout"
app.include = function(self, a)
	self.__class.include(self, a, nil, self)
end

-- Installer
local ok, install = pcall(require, "install")
if ok then
	local r2 = require("lapis.application").respond_to
	app:before_filter(require "apps.web.global.config_site")
	app:match("/", r2(install))
	return app
end

app:before_filter(require "apps.web.global.config_site")
app:before_filter(require "apps.web.global.check_auth")
app:before_filter(require "apps.web.global.check_ban")

app:include("apps.web.admin")
app:include("apps.web.pages")
app:include("apps.web.boards")


return app
