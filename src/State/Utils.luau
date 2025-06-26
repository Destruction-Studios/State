local Utils = {}

function Utils.copyTable(tbl)
	Utils.assertType(tbl, "table")

	local new = {}
	for k, v in tbl do
		if typeof(v) == "table" then
			new[k] = Utils.copyTable(v)
			continue
		end
		new[k] = v
	end
	return new
end

function Utils.assertType(value, expected)
	if typeof(value) ~= expected then
		error(`Expected '{expected}' got {typeof(value)}`, 2)
	end
end

return Utils
