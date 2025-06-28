--#selene:allow(unused_variable)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local State = require(ReplicatedStorage.State)
-- if true then
-- 	return
-- end
local s = State.new({
	Enabled = false,
	Coins = 100,
})

s:SetModifierTable({
	AddCoins = function(state, amount)
		local new = 0
		state:SetState(function(old)
			new = old.Coins + amount
			old.Coins = new
			return old
		end)
		return new
	end,
	RemoveCoins = function(state, amount)
		local new = 0
		state:SetState(function(old)
			new = math.max(old.Coins - amount, 0)
			old.Coins = new
			return old
		end)
		return new
	end,
})

s.Change:OnModifier("AddCoins", function(amount, newBalance)
	print(`Add {amount}: {newBalance}`)
end)

s.Change:OnModifier("RemoveCoins", function(amountToRemove, newBalance)
	print(`Remove {amountToRemove}: {newBalance}`)
end)

s:StartState()

s:RunModifier("AddCoins", 50)
s:RunModifier("RemoveCoins", s:GetState().Coins - 300)

-- s:RunModifier("Error")
