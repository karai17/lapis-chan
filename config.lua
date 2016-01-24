local config = require "lapis.config"
local token  = require "secrets.token"

config("development", {
	subdomains = false,--true,
	site_name  = "Lapis-chan",
	port       = 8080,
	secret     = token,
	postgres   = {
	--mysql      = {
		host     = "127.0.0.1",
		user     = "db_user",
		password = "db_pass",
		database = "db_schema"
	}
})

config("production", {
	subdomains = false,--true,
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
	code_cache = "on"
})

config("test", {
	subdomains = false,--true,
	site_name  = "Lapis-chan",
	port       = 80,
	secret     = "test-token",
	postgres   = {
		database = "lapischan_test"
	}
})
