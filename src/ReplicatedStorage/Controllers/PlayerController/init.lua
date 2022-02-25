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
    --// Variables
    local Player = game.Players.LocalPlayer
    local Character = Player.Character or Player.CharacterAdded:Wait()
    

    -- // Knit Services
    local PlayerService = Knit.GetService("PlayerManagerService")

    

    --// Client Action
    Controls:init(PlayerService)

    
    
    --// Functions
    local function AddCamera(Character)
        local CameraScript = script.Camera:Clone()
        CameraScript.Parent = Character
        CameraScript.Disabled = false
    end

    local function CharacterAdded(Character)
        AddCamera(Character)
        Controls:init(PlayerService, Character)
    end


    AddCamera(Character)
    Player.CharacterAdded:Connect(CharacterAdded)



end

return PlayerController

