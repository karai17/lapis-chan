local ngx  = _G.ngx
local json = require "cjson"

local function capture(method, uri, body)
	local response = ngx.location.capture(uri, {
		method = method,
		body   = json.encode(body)
	})

	if response.truncated then return end

	if response.status ~= ngx.HTTP_OK then
		return nil, json.decode(response.body)
	end

	return json.decode(response.body)
end

return {
	get = function(...)
		return capture(ngx.HTTP_GET, ...)
	end,

	post = function(...)
		return capture(ngx.HTTP_POST, ...)
	end,

	put = function(...)
		return capture(ngx.HTTP_PUT, ...)
	end,

	delete = function(...)
		return capture(ngx.HTTP_DELETE, ...)
	end,
}
