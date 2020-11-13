local Model = require("lapis.db.model").Model
local Pages = Model:extend("pages")

Pages.valid_record = {
	{ "slug",    exists=true, type="String" },
	{ "title",   exists=true, type="String" },
	{ "content", exists=true, type="String" }
}

--- Create a new page
-- @tparam table page Page data
-- @treturn boolean success
-- @treturn string error
function Pages:new(params)
	local unique, err = self:is_unique(params.slug, params.title)
	if not unique then
		return nil, err
	end

	local page = self:create(params)
	return page and page or nil, { "err_create_page", { page.slug, page.title } }
end

--- Modify a page
-- @tparam table page Page data
-- @treturn boolean success
-- @treturn string error
function Pages:modify(params, slug)
	local page = self:get(slug)
	if not page then
		return nil, "FIXME"
	end

	-- Check to see if the page we are modifying is the one that fails validation.
	-- If it is, that's fine since we're updating the unique values with themselves.
	-- If #pages > 1 then this will always fail since either the new slug or new
	-- title is going to belong to some other page.
	do
		local unique, err, pages = self:is_unique(params.slug, params.title)
		if not unique then
			for _, p in ipairs(pages) do
				if page.id ~= p.id then
					return nil, err
				end
			end
		end
	end

	local success, err = page:update(params)
	return success and page or nil, "FIXME: " .. tostring(err)
end

--- Delete page
-- @tparam table page Page data
-- @treturn boolean success
-- @treturn string error
function Pages:delete(slug)
	local page = self:get(slug)
	if not page then
		return nil, "FIXME"
	end

	local success = page:delete()
	return success and page or nil, "FIXME"
end

--- Get all pages
-- @treturn table pages List of pages
function Pages:get_all()
	return self:select("order by slug asc")
end

--- Get page
-- @tparam string slug Page slug
-- @treturn table page
function Pages:get(slug)
	local page = self:find { slug=slug:lower() }
	return page and page or nil, "FIXME"
end

function Pages:is_unique(slug, title)
	local pages = self:select("where slug=? or lower(title)=?", slug, title:lower())
	return #pages == 0 and true or nil, "FIXME", pages
end

function Pages.format_to_db(_, params)
	params.slug = params.slug:lower()
end

return Pages
