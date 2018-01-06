local trim    = require("lapis.util").trim_filter
local Model   = require("lapis.db.model").Model
local Reports = Model:extend("reports")

--- Create a new report
-- @tparam table report Report data
-- @treturn boolean success
-- @treturn string error
function Reports:create_report(report)
	-- Trim white space
	trim(report, {
		"board_id", "thread_id", "post_id",
		"timestamp", "num_reports"
	}, nil)

	local r = self:create {
		board_id    = report.board_id,
		thread_id   = report.thread_id,
		post_id     = report.post_id,
		timestamp   = report.timestamp,
		num_reports = report.num_reports
	}

	if r then
		return r
	end

	return false, { "err_create_report" }
end

--- Modify a report
-- @tparam table report Report data
-- @treturn boolean success
-- @treturn string error
function Reports:modify_report(report)
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
function Reports:delete_report(report)
	return report:delete()
end

--- Get all reports
-- @treturn table reports List of reports
function Reports:get_reports()
	return self:select("order by timestamp asc")
end

--- Get report
-- @tparam string board_id Board ID
-- @tparam string post_id Post ID
-- @treturn table report
function Reports:get_report(board_id, post_id)
	return unpack(self:select(
		"where board_id=? and post_id=? limit 1",
		board_id, post_id
	))
end

--- Get report
-- @tparam string id Report ID
-- @treturn table report
function Reports:get_report_by_id(id)
	return unpack(self:select("where id=? limit 1", id))
end

return Reports
