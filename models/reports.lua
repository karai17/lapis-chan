local Model = require("lapis.db.model").Model
local Reports = Model:extend("reports")

local trim  = require("lapis.util").trim_filter
local model = {}

--- Create a new report
-- @tparam table report Report data
-- @treturn boolean success
-- @treturn string error
function model.create_report(report)
	local report, err = Reports:create {
		board_id    = report.board_id,
		thread_id   = report.thread_id,
		post_id     = report.post_id,
		timestamp   = report.timestamp,
		num_reports = report.num_reports
	}

	if report then
		return report
	else
		return false, err
	end
end

--- Modify a report
-- @tparam table report Report data
-- @treturn boolean success
-- @treturn string error
function model.modify_report(report)
	local columns = {}
	for col in pairs(report) do
		table.insert(columns, col)
	end

	return report:update(unpack(columns))
end

--- Delete report
-- @tparam table report Report data
-- @treturn boolean success
-- @treturn string error
function model.delete_report(report)
	return report:delete()
end

--- Get all reports
-- @treturn table reports List of reports
function model.get_reports()
	return Reports:select("order by timestamp asc")
end

--- Get report
-- @tparam string board_id Board ID
-- @tparam string post_id Post ID
-- @treturn table report
function model.get_report(board_id, post_id)
	return unpack(Reports:select(
		"where board_id=? and post_id=? limit 1",
		board_id, post_id
	))
end

--- Get report
-- @tparam string id Report ID
-- @treturn table report
function model.get_report_by_id(id)
	return unpack(Reports:select("where id=? limit 1", id))
end

return model
