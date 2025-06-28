return function()
	local Change = require(script.Parent.Change)

	local change = Change.new()

	local empty = function() end

	describe("Change:OnBind", function()
		it("should return a function", function()
			local stop = change:OnBind(empty, false)

			expect(stop).to.be.a("function")
			stop()
		end)
		it("should error with wrong var", function()
			expect(function()
				change:OnBind(true)
			end).to.throw()
		end)
		it("should fire", function()
			local fired = false
			local stop = change:OnBind(function()
				fired = true
			end, false)

			expect(fired).to.equal(false)

			change:_fireBind()

			expect(fired).to.equal(true)

			stop()
		end)
		it("should not fire when disconnected", function()
			local change2 = Change.new()
			local i = 0
			local stop = change2:OnBind(function()
				i += 1
			end, false)
			expect(i).to.equal(0)
			change2:_fireBind()
			expect(i).to.equal(1)
			stop()
			change2:_fireBind()
			expect(i).to.equal(1)
		end)
	end)
end
