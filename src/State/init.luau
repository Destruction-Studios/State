local Utils = require(script.Utils)
local Signal = require(script.Parent.Signal)
local Promise = require(script.Parent.Promise)

local NOT_STARTED_MSG = "[State] State has not been started"

local Nil = require(script.Nil)
local Change = require(script.Change)

export type UniqueKey = any

export type Change = {
	OnBind: (self: Change, func: (new: table, old: table) -> nil, shouldConnectToChange: boolean) -> () -> nil,
	OnChange: (self: Change, func: (new: table, old: table) -> nil) -> nil,
}

export type StateObject = {
	Change: Change,

	FormatError: (self: StateObject, err: string) -> string,
	GetState: (self: StateObject) -> any,
	SetState: (self: StateObject, modifer: table | (state: table) -> table) -> nil,
	StartState: (self: StateObject) -> nil,
	Destroy: (self: StateObject) -> nil,
}

export type State = {
	Nil: UniqueKey,
	new: (state: table) -> StateObject,
}

local State = {
	Nil = Nil,
} :: State
local StateObject = {}
StateObject.__index = StateObject

function State.new(defaultValue, traceback): StateObject
	Utils.assertType(defaultValue, "table")

	local self = setmetatable({}, StateObject)

	self._state = Utils.copyTable(defaultValue)
	self._traceback = traceback
	self._changedSignal = Signal.new()

	self.Change = Change.new()

	return self
end

function StateObject:FormatError(message)
	return `\n\n[State] {message}\n\nstate created at\n{self:_getTraceback()}\n\n`
end

function StateObject:_runStateChanged() end

function StateObject:_getTraceback()
	return self._traceback
end

function StateObject:GetState()
	return Utils.copyTable(self._state)
end

function StateObject:SetState(modifer: table | (old: table) -> table)
	assert(self._started, NOT_STARTED_MSG)
	local modified = nil
	if typeof(modifer) == "table" then
		modified = modifer
	elseif typeof(modifer) == "function" then
		local connection = nil
		connection = self._changedSignal:Connect(function()
			warn(self:FormatError(`State Changed while inside :SetState`))
		end)
		local success, value = Promise.try(modifer, self:GetState())
			:catch(function(err)
				warn(self:FormatError(`State Modifer Errored\n{err}`))
			end)
			:await()
		connection:Disconnect()
		connection = nil
		Utils.assertType(value, "table")
		if success and value ~= nil then
			modified = value
		end
	end

	-- local oldState = self._state

	self._state = Utils.assign(self._state, modified)

	self.Change:_fireChange(self:GetState())
end

function StateObject:StartState()
	assert(not self._started, `[State] State has already been started`)

	self._started = true

	self.Change:_fireBind(self:GetState())
end

return State
