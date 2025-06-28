local Nil = require(script.Parent.Nil)

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
		error(`[State] Expected '{expected}' got {typeof(value)}`, 2)
	end
end

function Utils.assign(target, ...)
	for index = 1, select("#", ...) do
		local source = select(index, ...)

		if source ~= nil then
			for key, value in pairs(source) do
				if value == Nil then
					target[key] = nil
				else
					target[key] = value
				end
			end
		end
	end
	return target
end

return Utils
