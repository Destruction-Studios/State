--[[
    Based off of Rodux NoYield.luau
    https://github.com/Roblox/rodux/blob/master/src/NoYield.lua
]]

local function handler(thread: thread, success: boolean, ...: any)
	if not success then
		local err = (...)
		if typeof(err) == "string" then
			error(debug.traceback(thread, err), 2)
		else
			error(tostring(err), 2)
		end
	end

	if coroutine.status(thread) ~= "dead" then
		error(debug.traceback(thread, "Attempted to yeild"), 2)
	end

	return ...
end

local function noYeild(callback, ...: any)
	local thread = coroutine.create(callback)

	return handler(thread, coroutine.resume(thread, ...))
end

return noYeild
