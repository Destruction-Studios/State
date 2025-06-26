return function()
	local noYeild = require(script.Parent.noYield)

	it("should error if yield", function()
		expect(function()
			noYeild(function(sec)
				task.wait(sec)
			end, 1)
		end).to.throw()
	end)

	it("should run reg functions", function()
		local function add(a, b, c)
			return a + b + c
		end

		expect(function()
			noYeild(add, 1, 2, 3)
		end).to.never.throw()
		expect(noYeild(add, 1, 2, 3)).to.be.ok()
		expect(noYeild(add, 1, 2, 3)).to.equal(6)
	end)
end
