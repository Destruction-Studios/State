return function()
	local noYeild = require(script.Parent.noYield)

	local y = noYeild()

	it("should error if yield", function()
		expect(function()
			y(function(sec)
				task.wait(sec)
			end, 1)
		end).to.throw()
	end)

	it("should run reg functions", function()
		local function add(a, b, c)
			return a + b + c
		end

		expect(function()
			y(add, 1, 2, 3)
		end).to.never.throw()
		expect(y(add, 1, 2, 3)).to.be.ok()
		expect(y(add, 1, 2, 3)).to.equal(6)
	end)
end
