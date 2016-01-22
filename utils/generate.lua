local encoding = require "lapis.util.encoding"
local sha256   = require "resty.sha256"
local posix    = require "posix"
local salt     = require "secrets.salt"
local token    = require "secrets.token"
local bcrypt   = require "bcrypt"
local sf       = string.format
local ss       = string.sub
local tn       = tonumber
local ts       = tostring

local function get_chunks(str)
	-- Secure trip
	local name, tripcode = str:match("(.-)(##.+)")

	-- Insecure trip
	if not name then
		name, tripcode = str:match("(.-)(#.+)")

		-- Just a name
		if not name then
			return str:match("(.+)")
		end
	end

	return name, tripcode
end

local generate = {}

-- Generate a 6char pseudo random number using a supplied timestamp and the
-- memory location of a supplied table because math.random isn't reliable for
-- this use case.
-- HACK: If you have a better idea, send a PR. I hate this as much as you do.
function generate.random(time, t)
	return sf("%s%s", time, tn("0x" .. ss(ts(t), -6)))
	--return tn(ts(t):match("0x(.+)"), 16) -- bartbes thinks this might be better
end

-- Generate an insecure password
function generate.password(time, t)
	local hasher = sha256:new()
	hasher:update(generate.random(time, t))
	return encoding.encode_base64(hasher:final())
end

-- Generate a secure or insecure tripcode based off the name a user supplies
-- when they make a post. #trip for insecure, ##trip for secure.
-- Secure tripcodes use sha256 + the app's secret token.
-- Insecure tripcodes use standard posix crypt + the app's secret salt.
function generate.tripcode(raw_name)
	local name, tripcode = get_chunks(raw_name)

	if tripcode then
		local pattern = "^([^=]*)"
		tripcode = tripcode:sub(2) -- remove leading '#'

		-- Secure tripcode
		if tripcode:sub(1, 1) == "#" then
			local hasher = sha256:new()
			tripcode     = token .. tripcode:sub(2) -- remove leading '#'
			hasher:update(tripcode)
			local hash = encoding.encode_base64(hasher:final())
			tripcode   = "!!" .. ss(hash:match(pattern), -10)
		-- Insecure tripcode
		else
			local hash = posix.crypt(tripcode, salt)
			tripcode   = "!" .. ss(hash, -10)
		end
	end

	return name, tripcode
end

-- Generate a hash with a 2^12 cost
function generate.hash(password)
	return bcrypt.digest(password, 12)
end

return generate
