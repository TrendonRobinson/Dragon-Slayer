--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)


--// Knit Services
print(Knit)

--// Component
local Tag = "Enemy"
local Enemy = Component.new({Tag = Tag})

--// Variables
local Assets = ReplicatedStorage.Assets

local UI = Assets.UI.HealthGUI


function Enemy:Construct()
    self._trove = Trove.new()
end


function Enemy:TrackHealth()
    local Health = self.GUI
    self.Humanoid:GetPropertyChangedSignal('Health'):Connect(function()
        Health.Frame.Bar.Size = UDim2.fromScale(
            self.Humanoid.Health/self.Humanoid.MaxHealth,
            1
        )
    end)
end

function Enemy:PrepGui()
    self.GUI = UI:Clone()
    self.GUI.Level.Text = 'LV.'..self.Instance:GetAttribute('Level').." "..self.Instance:GetAttribute('Name')
    self.GUI.Adornee = self.Instance.PrimaryPart
    self.GUI.Parent = self.Instance
    self:TrackHealth()
end

function Enemy:Start()
    self.Humanoid = self.Instance.Humanoid
    self:PrepGui()
end

function Enemy:Stop()
    self._trove:Destroy()
end

return Enemy