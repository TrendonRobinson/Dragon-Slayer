--// Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--// Knit Controllers
local TestController = Knit.CreateController { Name = "TestController" }


function TestController:KnitStart()
    -- // Knit Services
    local TestService = Knit.GetService("TestService")
end

return TestController

