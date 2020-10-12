local db     = require "lapis.db"
local schema = require "lapis.db.schema"
local types  = schema.types

return {
	[100] = function()
		schema.create_table("users", {
			{ "id",       types.serial  { unique=true, primary_key=true }},
			{ "username", types.varchar { unique=true }},
			{ "password", types.varchar },
			{ "admin",    types.boolean { default=false }},
			{ "mod",      types.boolean { default=false }},
			{ "janitor",  types.boolean { default=false }}
		})

		schema.create_table("bans", {
			{ "id",       types.serial  { unique=true, primary_key=true }},
			{ "ip",       types.varchar },
			{ "board_id", types.integer { default=0 }},
			{ "reason",   types.varchar { null=true }},
			{ "time",     types.integer },
			{ "duration", types.integer { default=259200 }}, -- 3 days
		})

		schema.create_table("boards", {
			{ "id",                types.serial  { unique=true, primary_key=true }},
			{ "name",        types.varchar { unique=true }},
			{ "name",              types.varchar { unique=true }},
			{ "subtext",           types.varchar { null=true }},
			{ "rules",             types.text    { null=true }},
			{ "ban_message",       types.varchar { default="USER WAS BANNED FOR THIS POST" }},
			{ "anon_name",         types.varchar { default="Anonymous" }},
			{ "theme",             types.varchar { default="yotsuba_b" }},
			{ "posts",             types.integer { default=0 }},
			{ "pages",             types.integer { default=10 }},
			{ "threads_per_page",  types.integer { default=10 }},
			{ "text_only",         types.boolean { default=false }},
			{ "draw",              types.boolean { default=false }},
			{ "thread_file",       types.boolean { default=true }},
			{ "thread_comment",    types.boolean { default=false }},
			{ "thread_file_limit", types.integer { default=100 }},
			{ "post_file",         types.boolean { default=false }},
			{ "post_comment",      types.boolean { default=false }},
			{ "post_limit",        types.integer { default=250 }},
			{ "archive",           types.boolean { default=true }},
			{ "archive_time",      types.integer { default=2592000 }}, -- 30 days
			{ "group",             types.integer { default=1 }}
		})

		schema.create_table("threads", {
			{ "id",            types.serial  { unique=true, primary_key=true }},
			{ "board_id",      types.integer },
			{ "last_active",   types.integer },
			{ "sticky",        types.boolean { default=false }},
			{ "lock",          types.boolean { default=false }},
			{ "archive",       types.boolean { default=false }},
			{ "size_override", types.boolean { default=false }},
			{ "save",          types.boolean { default=false }}
		})

		schema.create_table("posts", {
			{ "id",           types.serial  { unique=true, primary_key=true }},
			{ "post_id",      types.integer },
			{ "thread_id",    types.integer },
			{ "board_id",     types.integer },
			{ "timestamp",    types.integer },
			{ "ip",           types.varchar },
			{ "comment",      types.text    { null=true }},
			{ "name",         types.varchar { null=true }},
			{ "trip",         types.varchar { null=true }},
			{ "subject",      types.varchar { null=true }},
			{ "password",     types.varchar { null=true }},
			{ "file_name",    types.varchar { null=true }},
			{ "file_path",    types.varchar { null=true }},
			{ "file_md5",     types.varchar { null=true }},
			{ "file_size",    types.integer { null=true }},
			{ "file_width",   types.integer { null=true }},
			{ "file_height",  types.integer { null=true }},
			{ "file_spoiler", types.boolean { null=true }},
			{ "banned",       types.boolean { default=false }}
		})

		schema.create_table("announcements", {
			{ "id",       types.serial  { unique=true, primary_key=true }},
			{ "board_id", types.integer { null=true }},
			{ "text",     types.varchar }
		})

		schema.create_table("reports", {
			{ "id",          types.serial  { unique=true, primary_key=true }},
			{ "board_id",    types.integer },
			{ "thread_id",   types.integer },
			{ "post_id",     types.integer },
			{ "timestamp",   types.integer },
			{ "num_reports", types.integer }
		})

		schema.create_table("pages", {
			{ "id",      types.serial  { unique=true, primary_key=true }},
			{ "url",     types.varchar { unique=true }},
			{ "name",    types.varchar },
			{ "content", types.text }
		})
	end,
	[120] = function()
		schema.add_column("boards", "filetype_image", types.boolean { default=true })
		schema.add_column("boards", "filetype_audio", types.boolean { default=false })
		schema.add_column("posts",  "file_type",      types.varchar { default="image" })
		schema.add_column("posts",  "file_duration",  types.varchar { null=true })
	end,
	-- TODO: COLLAPSE ALL CHANGES FROM HERE FORWARD INTO [200]
	[200] = function()
		schema.rename_column("boards", "posts",      "total_posts")
		schema.rename_column("boards", "name",       "title")
		schema.rename_column("boards", "short_name", "name")
	end,
	[201] = function()
		schema.rename_column("boards", "name",       "title")
		schema.rename_column("boards", "short_name", "name")
	end
}
