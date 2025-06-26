local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TestEZ = require(script.Parent.TestEZ)

TestEZ.TestBootstrap:run({ ReplicatedStorage.State })
