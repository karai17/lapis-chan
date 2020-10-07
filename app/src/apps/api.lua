local lapis = require "lapis"
local app   = lapis.Application()
app.__base  = app
app.include = function(self, a)
	self.__class.include(self, a, nil, self)
end

app:include("apps.api.announcements")
app:include("apps.api.boards")

return app
