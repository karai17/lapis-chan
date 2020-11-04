local lapis   = require "lapis"
local capture = require("lapis.application").capture_errors_json
local r2      = require("lapis.application").respond_to
local handle  = require("utils.error").handle
local app     = lapis.Application()
app.__base    = app
app.name      = "api.boards."
app.path      = "/api/boards"

app:match("boards",         "",                                                        capture({ on_error=handle, r2(require "apps.api.boards.boards")         }))
app:match("board",          "/:uri_board",                                             capture({ on_error=handle, r2(require "apps.api.boards.board")          }))
app:match("announcements",  "/:uri_board/announcements",                               capture({ on_error=handle, r2(require "apps.api.boards.announcements")  }))
app:match("bans",           "/:uri_board/bans",                                        capture({ on_error=handle, r2(require "apps.api.boards.bans")           }))
app:match("reports",        "/:uri_board/reports",                                     capture({ on_error=handle, r2(require "apps.api.boards.reports")        }))
app:match("threads",        "/:uri_board/threads(/pages/:uri_page)",                   capture({ on_error=handle, r2(require "apps.api.boards.threads")        }))
app:match("archived",       "/:uri_board/threads/archived",                            capture({ on_error=handle, r2(require "apps.api.boards.archived")       }))
app:match("thread",         "/:uri_board/threads/:uri_thread",                         capture({ on_error=handle, r2(require "apps.api.boards.thread")         }))
app:match("thread.reports", "/:uri_board/threads/:uri_thread/reports",                 capture({ on_error=handle, r2(require "apps.api.boards.thread_reports") }))
app:match("posts",          "/:uri_board(/threads/:uri_thread)/posts",                 capture({ on_error=handle, r2(require "apps.api.boards.posts")          }))
app:match("post",           "/:uri_board/threads/:uri_thread/posts/:uri_post",         capture({ on_error=handle, r2(require "apps.api.boards.post")           }))
app:match("post.reports",   "/:uri_board/threads/:uri_thread/posts/:uri_post/reports", capture({ on_error=handle, r2(require "apps.api.boards.post_reports")   }))

return app
