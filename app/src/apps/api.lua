local lapis = require "lapis"
local app   = lapis.Application()
app.__base  = app
app.include = function(self, a)
	self.__class.include(self, a, nil, self)
end

app:include("apps.api.announcements")
app:include("apps.api.bans")
app:include("apps.api.boards")
app:include("apps.api.threads")

return app
