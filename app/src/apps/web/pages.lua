local lapis = require "lapis"
local app   = lapis.Application()

app.__base     = app
app.name       = "web.pages."
app.handle_404 = require "apps.web.global.code_404"

app:before_filter(require "apps.web.global.config_site")
app:before_filter(require "apps.web.global.check_auth")
app:before_filter(require "apps.web.global.check_ban")

app:match("index",   "/",       require "apps.web.pages.index")
app:match("c404",    "/404",    require "apps.web.global.code_404") -- FIXME: remove this route
app:match("faq",     "/faq",    require "apps.web.pages.rules") -- FIXME: need a faq page
app:match("rules",   "/rules",  require "apps.web.pages.rules")
app:match("logout",  "/logout", require "apps.web.pages.logout")
app:match("page",    "/:page",  require "apps.web.pages.page")

return app
