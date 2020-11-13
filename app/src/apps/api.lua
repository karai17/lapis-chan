local lapis   = require "lapis"
local capture = require("lapis.application").capture_errors_json
local handle  = require("utils.error").handle
local app     = lapis.Application()
app.__base    = app
app.include   = function(self, a)
	self.__class.include(self, a, nil, self)
end

app:before_filter(capture({ on_error=handle, require "apps.api.internal.before_auth"   }))
-- FIXME: app:before_filter(capture({ on_error=handle, require "apps.api.internal.before_ban"    }))
app:before_filter(capture({ on_error=handle, require "apps.api.internal.before_locale" }))

app:include("apps.api.core")
app:include("apps.api.announcements")
app:include("apps.api.bans")
app:include("apps.api.boards")
app:include("apps.api.pages")
app:include("apps.api.users")

return app
