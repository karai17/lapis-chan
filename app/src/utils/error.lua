local ngx       = _G.ngx
local get_error = {}
local status    = {}

--[[ API Error Codes ]]--

-- Authorization

-- email:api_key format in Authorization HTTP header is invalid
function get_error.malformed_authorization()
	return { code=100 }
end

-- email:api_key in Authorization HTTP header does not match any user
-- login credentials do not match any user
function get_error.invalid_authorization()
	return { code=101 }
end

-- Attempting to access endpoint that requires higher priviliges
function get_error.unauthorized_access()
	return { code=102 }
end

-- Data Validation

function get_error.field_not_found(field)
	return { code=200, field=field }
end
function get_error.field_invalid(field)
	return { code=201, field=field }
end
function get_error.field_not_unique(field)
	return { code=202, field=field }
end
function get_error.token_expired(field)
	return { code=203, field=field }
end
function get_error.password_not_match()
	return { code=204 }
end

-- Database I/O

function get_error.database_unresponsive()
	return { code=300 }
end
function get_error.database_create()
	return { code=301 }
end
function get_error.database_modify()
	return { code=302 }
end
function get_error.database_delete()
	return { code=303 }
end
function get_error.database_select()
	return { code=304 }
end

--[[ API -> HTTP Code Map ]]--

-- Authorization
status[100] = ngx.HTTP_BAD_REQUEST
status[101] = ngx.HTTP_FORBIDDEN
status[102] = ngx.HTTP_UNAUTHORIZED

-- Data Validation
status[200] = ngx.HTTP_BAD_REQUEST
status[201] = ngx.HTTP_BAD_REQUEST
status[202] = ngx.HTTP_BAD_REQUEST
status[203] = ngx.HTTP_BAD_REQUEST

-- Database I/O
status[300] = ngx.HTTP_INTERNAL_SERVER_ERROR
status[301] = ngx.HTTP_INTERNAL_SERVER_ERROR
status[302] = ngx.HTTP_INTERNAL_SERVER_ERROR
status[303] = ngx.HTTP_INTERNAL_SERVER_ERROR
status[304] = ngx.HTTP_INTERNAL_SERVER_ERROR

return {
	get_error = get_error,
	handle    = function(self)

		-- Inject localized error messages
		for _, err in ipairs(self.errors) do
			--err.message = self.i18n(err.code)
			if type(err) == "table" then
				for k, v in pairs(err) do
					print(k, ": ", v)
				end
			else
				print(err)
			end
		end

		print(#self.errors)

		return self:write {
			status = 401,--status[self.errors[1].code],
			json   = self.errors
		}
	end
}
