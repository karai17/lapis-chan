local lapis = require "lapis"
local app   = lapis.Application()
app.__base  = app
app.include = function(self, a)
	self.__class.include(self, a, nil, self)
end

app:before_filter(require "apps.web.global.config_site")
app:before_filter(require "apps.web.global.check_auth")
app:before_filter(require "apps.web.global.check_ban")

app:include("apps.web.admin")
app:include("apps.web.pages")
app:include("apps.web.boards")

return app
