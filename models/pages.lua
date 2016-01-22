local Model = require("lapis.db.model").Model
local Pages = Model:extend("pages")

local trim  = require("lapis.util").trim_filter
local model = {}

--- Create a new page
-- @tparam table page Page data
-- @treturn boolean success
-- @treturn string error
function model.create_page(page)
	local page, err = Pages:create {
		name    = page.name,
		url     = page.url,
		content = page.content
	}

	if page then
		return page
	else
		return false, err
	end
end

--- Modify a page
-- @tparam table page Page data
-- @treturn boolean success
-- @treturn string error
function model.modify_page(page)
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
function model.delete_page(page)
	return page:delete()
end

--- Get all pages
-- @treturn table pages List of pages
function model.get_pages()
	return Pages:select("order by url asc")
end

--- Get page
-- @tparam string url Page URL
-- @treturn table page
function model.get_page(url)
	return unpack(Pages:select("where url=? limit 1", url))
end

return model
