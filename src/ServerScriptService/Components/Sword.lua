--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Tween = require(Knit.Modules.Tween)


--// Knit Services
print(Knit)

--// Component
local Tag = "Sword"
local Sword = Component.new({Tag = Tag})

--// Libraries
local rad = math.rad
local rand = math.random

--// Variables
local Assets = ReplicatedStorage.Assets

local UI = Assets.UI.HealthGUI


function Sword:Construct()
    self._trove = Trove.new()
end

function Sword:PickUp()
    local PickUpPrompt = Instance.new('ProximityPrompt')
    PickUpPrompt.Parent = self.Instance
    PickUpPrompt.ActionText = 'Pick up '..self.Instance.Name..' Sword'

    PickUpPrompt.TriggerEnded:Connect(function(playerWhoTriggered)
        --Pick Up

        self.Instance:Destroy()
        self.Services.PlayerManagerService:AddSwordToInventory(playerWhoTriggered, self.Instance.Name)
        self.Services.PlayerManagerService:EquipSword(playerWhoTriggered, self.Instance.Name)
    end)
end

function Sword:ServicePrep()
	self.Services = {
		PlayerManagerService = Knit.GetService('PlayerManagerService')
	}
end

function Sword:Start()
    self:PickUp()
    Sword:ServicePrep()
end

function Sword:Stop()
    self._trove:Destroy()
end

return Sword