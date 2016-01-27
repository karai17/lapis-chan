local config    = require "lapis.config"
local token     = require "secrets.token"
local software  = "Lapis-chan"
local version   = "1.1.1"
local lua_path  = ""
local lua_cpath = ""


config("development", {
	software   = software,
	version    = version,
	subdomains = false,
	site_name  = "Lapis-chan",
	port       = 8080,
	secret     = token,
	postgres   = {
	--mysql      = {
		host     = "127.0.0.1",
		user     = "db_user",
		password = "db_pass",
		database = "db_schema"
	},
	lua_path  = lua_path,
	lua_cpath = lua_cpath,
	body_size = "15m"
})

config("production", {
	software   = software,
	version    = version,
	code_cache = "on",
	subdomains = false,
	site_name  = "Lapis-chan",
	port       = 80,
	secret     = token,
	postgres   = {
	--mysql      = {
		host     = "127.0.0.1",
		user     = "db_user",
		password = "db_pass",
		database = "db_schema"
	},
	lua_path  = lua_path,
	lua_cpath = lua_cpath,
	body_size = "15m"
})

config("test", {
	software   = software,
	version    = version,
	subdomains = false,
	site_name  = "Lapis-chan",
	port       = 80,
	secret     = "test-token",
	postgres   = {
		database = "lapischan_test"
	},
	lua_path  = lua_path,
	lua_cpath = lua_cpath,
	body_size = "15m"
})
