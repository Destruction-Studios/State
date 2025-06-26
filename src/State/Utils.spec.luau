return function()
	local Utils = require(script.Parent.Utils)

	describe("Utils.copyTable", function()
		local tbl = { 1, 2, 3, {
			Hello = "HAHA",
		} }

		local new = Utils.copyTable(tbl)

		it("should error if not table", function()
			expect(function()
				Utils.copyTable("No")
			end).to.throw()
		end)

		it("should copy", function()
			expect(new[1]).to.equal(tbl[1])
			expect(new[2]).to.equal(tbl[2])
			expect(new[4].Hello).to.equal(tbl[4].Hello)
		end)
	end)

	describe("Utils.assertType", function()
		it("should error", function()
			expect(function()
				Utils.assertType(123, "string")
			end).to.throw()
		end)
		it("should not error", function()
			expect(function()
				Utils.assertType(123, "number")
			end).to.be.ok()
		end)
	end)

	describe("Utils.assign", function()
		local a = { Money = 2 }
		local b = { Name = "Bob" }
		local c = { Money = 5 }

		local new = Utils.assign(a, b, c)

		expect(new.Money).to.equal(c.Money)
		expect(new.Name).to.equal(b.Name)
	end)
end
