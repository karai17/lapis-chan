local encoding = require "lapis.util.encoding"
local sha256   = require "resty.sha256"
local ffi      = require "ffi"
local posix    = require "posix"
local salt     = require "secrets.salt"
local token    = require "secrets.token"
local bcrypt   = require "bcrypt"
local sf       = string.format
local ss       = string.sub

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

-- math.random isn't reliable for this use case, so instead we're gonna snag
-- some bytes from /dev/urandom, create a uint32, and grab the last 3 digits.
function generate.random()
	-- Read uint32_t from /dev/urandom
	local r = io.open("/dev/urandom", "rb")
	local bytes = r:read(4)
	r:close()

	-- Build number
	local num = ffi.new("unsigned int[1]")
	ffi.copy(num, bytes, 4)

	return sf("%03d", num[0] % 1000)
end

-- Generate an insecure password
function generate.password(time)
	local hasher = sha256:new()
	hasher:update(sf("%s%s", time, generate.random()))
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

function generate.errors(i18n, errors)
	local err = {}

	if #errors > 0 then
		for _, error in ipairs(errors) do
			local e = i18n(unpack(error))
			table.insert(err, e)
		end
	end

	return err
end

return generate
