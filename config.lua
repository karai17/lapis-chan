local config = require "lapis.config"
local token  = require "secrets.token"

-- Use rewrite rules to create 'boards.' and 'static.' subdomains
-- Currently doesn't work, leave this as false!
local subdomains = false

-- Maximum file size (update this in scripts.js too!)
local body_size  = "15m"

-- Maximum comment size (update this in scripts.js too!)
local text_size  = 10000

-- Path to your lua libraries (LuaRocks and OpenResty)
local lua_path   = ""
local lua_cpath  = ""

config("development", {
	site_name  = "Lapis-chan Dev",
	port       = 8080,
	secret     = token,
	subdomains = subdomains,
	body_size  = body_size,
	text_size  = text_size,
	lua_path   = lua_path,
	lua_cpath  = lua_cpath,
	postgres   = {
	--mysql      = {
		host     = "127.0.0.1",
		user     = "db_user",
		password = "db_pass",
		database = "db_schema"
	},
})

config("production", {
	code_cache = "on",
	site_name  = "Lapis-chan Dev",
	port       = 80,
	secret     = token,
	subdomains = subdomains,
	body_size  = body_size,
	text_size  = text_size,
	lua_path   = lua_path,
	lua_cpath  = lua_cpath,
	postgres   = {
	--mysql      = {
		host     = "127.0.0.1",
		user     = "db_user",
		password = "db_pass",
		database = "db_schema"
	},
})

config("test", {
	site_name  = "Lapis-chan Test",
	port       = 80,
	secret     = "test-token",
	subdomains = subdomains,
	body_size  = body_size,
	text_size  = text_size,
	lua_path   = lua_path,
	lua_cpath  = lua_cpath,
	postgres   = {
	--mysql      = {
		host     = "127.0.0.1",
		user     = "db_user",
		password = "db_pass",
		database = "db_schema"
	},
})

