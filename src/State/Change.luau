export type ChangeFunc = (new: table, old: table?) -> nil

local CONN_DISCONNECT_MSG = `[State] Connection has already been disconnected`

local Event = require(script.Parent.Event)
local Utils = require(script.Parent.Utils)

local Change = {}
local ChangeMT = {}
ChangeMT.__index = ChangeMT

function Change.new()
	local self = setmetatable({}, ChangeMT)

	self._hasBoundFired = false
	self._lastValue = nil
	self._onChange = Event.new()
	self._onBind = Event.new()

	return self
end

function ChangeMT:_fireBind(value)
	if self._hasBoundFired then
		return
	end
	self._hasBoundFired = true
	self._onBind:Fire(value, nil)
	self._lastValue = value
end

function ChangeMT:_fireChange(value)
	self._onChange:Fire(value, self._lastValue)
	self._lastValue = value
end

function ChangeMT:OnBind(func: ChangeFunc, connectToChange: boolean)
	Utils.assertType(func, "function")
	Utils.assertType(connectToChange, "boolean")
	local connection = nil
	local changeConnection = nil

	if self._hasBoundFired then
		func(self._lastValue, nil)
	else
		connection = self._onBind:Connect(func)
	end

	changeConnection = self._onChange:Connect(func)

	return function()
		assert(connection, CONN_DISCONNECT_MSG)
		self._onBind:Disconnect(connection)
		connection = nil

		if changeConnection then
			self._onChange:Disconnect(changeConnection)
			changeConnection = nil
		end
	end
end

function ChangeMT:OnChange(func: ChangeFunc)
	Utils.assertType(func, "function")
	local connection = nil

	connection = self._onChange:Connect(func)

	return function()
		assert(connection, CONN_DISCONNECT_MSG)
		self._onChange:Disconnect(connection)
		connection = nil
	end
end

function ChangeMT:Destroy()
	self._onBind:DisconnectAll()
	self._onChange:DisconnectAll()
end

return Change
