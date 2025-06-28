local Utils = require(script.Utils)
local Event = require(script.Event)
local Promise = require(script.Parent.Promise)
local noYield = require(script.noYield)

local NO_YIELD_MOD = noYield("[State] attempted to yield in modifier function")

local INVALID_MODIFIER_MSG = "[State] %s is not a valid modifier"
local NO_MODIFIERS_MSG = "[State] State does not have modifiers"
local STARTED_MSG = "[State] State has already been started"
local NOT_STARTED_MSG = "[State] State has not been started"

local Nil = require(script.Nil)
local Change = require(script.Change)

export type UniqueKey = any

export type ModifierTable = {
	[any]: (state: StateObject, ...any) -> ...any,
}

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
	SetModifierTable: (self: StateObject, modifierTable: ModifierTable) -> nil,
	RunModifier: (self: StateObject, modifier: string, ...any) -> nil,
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

function State.new(defaultValue): StateObject
	Utils.assertType(defaultValue, "table")

	local self = setmetatable({}, StateObject)

	self._state = Utils.copyTable(defaultValue)
	self._traceback = debug.traceback()
	self._changedSignal = Event.new()
	self._modifierTable = nil

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

function StateObject:SetModifierTable(modiferTable: ModifierTable)
	assert(not self._started, STARTED_MSG)
	self._modifierTable = modiferTable
end

function StateObject:GetState()
	return Utils.copyTable(self._state)
end

function StateObject:RunModifier(modifier: string, ...: any)
	assert(self._modifierTable, NO_MODIFIERS_MSG)

	local func = self._modifierTable[modifier]

	assert(func, INVALID_MODIFIER_MSG:format(modifier))

	self.Change:_fireModifier(modifier, ..., NO_YIELD_MOD(func, self, ...))
end

function StateObject:SetState(modifier: table | (old: table) -> table)
	assert(self._started, NOT_STARTED_MSG)
	local modified = nil
	if typeof(modifier) == "table" then
		modified = modifier
	elseif typeof(modifier) == "function" then
		local connection = nil
		connection = self._changedSignal:Connect(function()
			warn(self:FormatError(`State Changed while inside :SetState`))
		end)
		local success, value = Promise.try(NO_YIELD_MOD, modifier, self:GetState())
			:catch(function(err)
				warn(self:FormatError(`State Modifier Errored\n{err}`))
			end)
			:await()
		self._changedSignal:Disconnect(connection)
		connection = nil
		if success and value ~= nil then
			Utils.assertType(value, "table")
			modified = value
		end
	end

	-- local oldState = self._state

	self._state = Utils.assign(self._state, modified)

	self.Change:_fireChange(self:GetState())
end

function StateObject:StartState()
	assert(not self._started, STARTED_MSG)

	self._started = true

	self.Change:_fireBind(self:GetState())
end

function StateObject:Destroy()
	self.Change:Destroy()
	setmetatable(self, nil)
	table.clear(self)
end

return State :: State
