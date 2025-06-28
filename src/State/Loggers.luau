local prettyPrint = require(script.Parent.prettyPrint)

local Loggers = {}

local function debug(...)
	print(`[StateLogger] `, ...)
end

function Loggers.defaultLogger(state)
	local changeConnection = state.Change._onChange:Connect(function(new, old)
		debug(`State Bind\nNew: `, prettyPrint(new), `\nOld: `, prettyPrint(old))
	end)
	local bindConnection = state.Change._onBind:Connect(function(new)
		debug(`State Bound\n`, prettyPrint(new))
	end, false)
	local modifierConnection = state.Change._onModifier:Connect(function(modifier, ...)
		debug(`Modifier Ran '{modifier}'\n`, prettyPrint({ ... }))
	end)

	return function()
		state.Change._onChange:Disconnect(changeConnection)
		state.Change._onBind:Disconnect(bindConnection)
		state.Change._onModifier:Disconnect(modifierConnection)
	end
end

return Loggers
