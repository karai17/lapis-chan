local config = require "lapis.config"
local secret = assert(loadfile("../data/secrets/token.lua"))()

-- Use rewrite rules to create 'boards.' and 'static.' subdomains
-- Currently doesn't work, leave this as false!
local subdomains = false

-- Maximum file size (update this in scripts.js too!)
local body_size  = "15m"

-- Maximum comment size (update this in scripts.js too!)
local text_size  = 10000

-- Path to your lua libraries (LuaRocks and OpenResty)
local lua_path  = "/root/.luarocks/share/lua/5.1/?.lua;/root/.luarocks/share/lua/5.1/?/init.lua;/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua;./?.lua;/usr/share/luajit-2.0.4/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua" .. ";/usr/local/openresty/lualib/?.lua" .. ";./src/?.lua;./src/?/init.lua"
local lua_cpath = "/root/.luarocks/lib/lua/5.1/?.so;/usr/lib/lua/5.1/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/lib64/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so" .. ";/usr/lib/?.so;/usr/lib64/?.so;/usr/local/lib/?.so;/usr/local/lib64/?.so"

config("development", {
	site_name  = "[DEVEL] Lapis-chan",
	port       = 80,
	secret     = secret,
	subdomains = subdomains,
	body_size  = body_size,
	text_size  = text_size,
	lua_path   = lua_path,
	lua_cpath  = lua_cpath,
	postgres   = {
		host     = "psql",
		user     = "postgres",
		password = "",
		database = "lapischan"
	},
})

config("production", {
	code_cache = "on",
	site_name  = "Lapis-chan",
	port       = 80,
	secret     = secret,
	subdomains = subdomains,
	body_size  = body_size,
	text_size  = text_size,
	lua_path   = lua_path,
	lua_cpath  = lua_cpath,
	postgres   = {
		host     = "psql",
		user     = "postgres",
		password = "",
		database = "lapischan"
	},
})
