return function()
	--selene:allow(unused_variable)
	local State = require(script.Parent)

	describe("State.new", function()
		it("should error if not table", function()
			expect(function()
				State.new("123")
			end).to.throw()
		end)

		it("should return table", function()
			expect(State.new({})).to.be.a("table")
		end)
	end)
end
