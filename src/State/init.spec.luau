return function()
	--selene:allow(unused_variable)
	local State = require(script.Parent)

	local default = {
		Money = 123,
		Name = "Bean",
		Remove = true,
	}

	local state = State.new(default)

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

	describe("State:GetState", function()
		it("should equal default state", function()
			expect(state:GetState().Money).to.equal(default.Money)
		end)

		it("should not be connected to passed", function()
			default.Money += 1
			expect(state:GetState().Money).to.never.be.equal(default.Money)
			default.Money -= 1
		end)
	end)

	describe("State:SetState", function()
		it("should reset money", function()
			state:SetState({
				Money = 0,
			})
			expect(state:GetState().Money).to.equal(0)
		end)

		it("should set remove to nil", function()
			state:SetState({
				Remove = State.Nil,
			})
			expect(state:GetState().Remove).to.equal(nil)
		end)

		it("should work with a function", function()
			state:SetState({
				Money = 123,
			})
			state:SetState(function(old)
				return {
					Money = old.Money + 100,
				}
			end)
			expect(state:GetState().Money).to.equal(223)
		end)

		it("should not be ok to return non table", function()
			expect(function()
				state:SetState(function()
					return "STRING!"
				end)
			end).to.throw()
		end)

		it("should be fine to return nil", function()
			expect(function()
				state:SetState(function()
					return nil
				end)
			end).to.be.ok()
		end)
	end)
end
