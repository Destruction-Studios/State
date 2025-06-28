local threads = {}

local Event = {}
Event.__index = Event

function Event.new()
	local self = setmetatable({}, Event)

	return self
end

function Event:Connect(func)
	local connection = { Function = func, _next = self._next, _previous = self }
	if self._next ~= nil then
		self._next._previous = connection
	end
	self._next = connection
	return connection
end

function Event:Disconnect(connection)
	connection._previous._next = connection._next
	if connection._next then
		connection._next._previous = connection._previous
	end
end

local function call(func, ...)
	func(...)
end

local function createThread(func, ...)
	func(...)
	while true do
		table.insert(threads, coroutine.running())

		call(coroutine.yield())
	end
end

function Event:Fire(...)
	local link = self._next

	while link do
		task.spawn(table.remove(threads) or createThread, link.Function, ...)

		link = link._next
	end
end

function Event:DisconnectAll() end

return Event
