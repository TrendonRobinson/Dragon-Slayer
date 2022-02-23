--// Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--// Knit Controllers
local PlayerController = Knit.CreateController { Name = "PlayerController" }

--// Modules
local Controls = require(script.Controls).new()


function PlayerController:KnitStart()
    -- // Knit Services
    local PlayerService = Knit.GetService("PlayerManagerService")


    --// Client Action
    Controls:init(PlayerService)


end

return PlayerController

