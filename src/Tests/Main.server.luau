local ReplicatedStorage = game:GetService("ReplicatedStorage")
local State = require(ReplicatedStorage.State)
-- if true then
-- 	return
-- end
local s = State.new({
	Enabled = false,
	Coins = 100,
})

local stop = s.Change:OnBind(function(state)
	print("BOUND with ", state)
end, false)

local stopChange = s.Change:OnChange(function(new, old)
	print("NEW ", new, "OLD ", old)
end)

local stopChange2 = s.Change:OnChange(function()
	warn("change")
end)

-- stop()

s:StartState()

s:SetState({
	Enabled = true,
})

stopChange2()

s:SetState({
	Coins = 10000,
})
