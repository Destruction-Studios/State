export type ChangeFunc = (new: table, old: table?) -> nil

local Change = {}
local ChangeMT = {}
ChangeMT.__index = ChangeMT

function Change.new()
	local self = setmetatable({}, ChangeMT)

	self._hasBoundFired = false
	self._lastValue = nil
	self._onChangeConnected = {}
	self._onBindConnected = {}

	return self
end

function ChangeMT:_fireBind(value)
	if self._hasBoundFired then
		return
	end
	self._hasBoundFired = true
	self:_fireTable(self._onBindConnected, value, nil)
	self._lastValue = value
end

function ChangeMT:_fireChange(value)
	self:_fireTable(self._onChangeConnected, value, self._lastValue)
	self._lastValue = value
end

function ChangeMT:OnBind(func: ChangeFunc)
	--add to tbl

	if self._hasBoundFired then
		func(self._lastValue, nil)
	end
end

function ChangeMT:OnChange(func: ChangeFunc) end

return Change
