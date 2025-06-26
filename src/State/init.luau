local Utils = require(script.Utils)
local Signal = require(script.Parent.Signal)
local UniqueKey = require(script.Parent.UniqueKey)
local Promise = require(script.Parent.Promise)

local State = {
	Nil = UniqueKey("Nil"),
}
local StateObject = {}
StateObject.__index = StateObject

function State.new(defaultValue, traceback)
	Utils.assertType(defaultValue, "table")

	local self = setmetatable({}, StateObject)

	self._state = defaultValue
	self._traceback = traceback
	self._changedSignal = Signal.new()

	return self
end

function StateObject:_runStateChanged() end

function StateObject:_runModifer(modifer)
	local new = self:GetState()
	if typeof(modifer) == "table" then
		for k, v in modifer do
			if v == State.Nil then
				new[k] = nil
				continue
			end
			new[k] = v
		end
	elseif typeof(modifer) == "function" then
	end
	return new
end

function StateObject:_getTraceback()
	return self._traceback
end

function StateObject:GetState()
	return Utils.copyTable(self._state)
end

function StateObject:SetState(modifer: table | (old: table) -> table)
	local newState = self:_runModifer(modifer)

	self._value = newState
end

return State
