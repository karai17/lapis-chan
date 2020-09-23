local trim  = require("lapis.util").trim_filter
local Model = require("lapis.db.model").Model
local Pages = Model:extend("pages")

--- Create a new page
-- @tparam table page Page data
-- @treturn boolean success
-- @treturn string error
function Pages:create_page(page)
	-- Trim white space
	trim(page, {
		"name", "url", "content"
	}, nil)

	local p = self:create {
		name    = page.name,
		url     = page.url,
		content = page.content
	}

	if p then
		return p
	end

	return false, { "err_create_page", { page.url, page.name } }

end

--- Modify a page
-- @tparam table page Page data
-- @treturn boolean success
-- @treturn string error
function Pages:modify_page(page)
	local columns = {}
	for col in pairs(page) do
		table.insert(columns, col)
	end

	return page:update(unpack(columns))
end

--- Delete page
-- @tparam table page Page data
-- @treturn boolean success
-- @treturn string error
function Pages:delete_page(page)
	return page:delete()
end

--- Get all pages
-- @treturn table pages List of pages
function Pages:get_pages()
	return self:select("order by url asc")
end

--- Get page
-- @tparam string url Page URL
-- @treturn table page
function Pages:get_page(url)
	return unpack(self:select("where url=? limit 1", url))
end

return Pages
