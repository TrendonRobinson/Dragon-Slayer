--// Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Knit
local Knit = require(ReplicatedStorage.Packages.Knit)


--// Knit Service
local TestService = Knit.GetService("TestService")

--// Knit Controllers
local TestController = Knit.CreateController { Name = "TestController" }


function TestController:KnitStart()
    TestService.NewRemote:Connect(function()
        print("Server To Client")
    end)
end

return TestController

