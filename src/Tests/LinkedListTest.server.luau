local ReplicatedStorage = game:GetService("ReplicatedStorage")
task.wait(2)
if true then
	return
end
local LinkedList = require(ReplicatedStorage.State.Event)

local s = LinkedList.new()

s:Connect(function(m)
	warn(m)
end)

local a = s:Connect(function(m)
	warn("mwamdmawdaw", m)
end)

s:Connect(function(m)
	warn("3", m)
end)

s:Connect(function(...)
	print(...)
end)

s:Fire("fat")

print(s)
s:Disconnect(a)
print(s)
s:Fire("no")
s:Fire(1, 2, 3, 3, 4, 5, 34, 234)
