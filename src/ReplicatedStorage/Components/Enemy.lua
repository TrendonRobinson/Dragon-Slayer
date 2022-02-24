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
local Tag = "Enemy"
local Enemy = Component.new({Tag = Tag})

--// Libraries
local rad = math.rad
local rand = math.random

--// Variables
local Assets = ReplicatedStorage.Assets

local UI = Assets.UI.HealthGUI


function Enemy:Construct()
    self._trove = Trove.new()
end


function Enemy:TrackHealth()
    if not self.GUI then end
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

function Enemy:DeathInit()
    local Humanoid = self.Humanoid    
    
    self._trove:Connect(Humanoid.Died, function()
        -- self.Instance:FindFirstChild('HealthGUI'):Destroy()
        task.wait(3)
		for _, part in pairs(self.Instance:GetChildren()) do
            if part:IsA"Part" or part:IsA"MeshPart" then
                part.Anchored = true
                
                local action = Tween.new(
                    part, 
                    {
                        Position = part.Position + Vector3.new(0, 5, 0),
                        Transparency = 1,
                        CFrame = part.CFrame * CFrame.Angles(
                        rad(rand(-360, 360)),
                        rad(rand(-360, 360)),
                        rad(rand(-360, 360)))
                    },
                    3
                )
                
                part.CanCollide = false

                action:Play()
            end
        end
        task.wait(3)
        self:Stop()
	end)
end

function Enemy:Start()
    self.Humanoid = self.Instance.Humanoid
    self:PrepGui()
    self:DeathInit()
end

function Enemy:Stop()
    self._trove:Destroy()
    local s, e = pcall(function()
        self.Instance:Destroy()
    end)
end

return Enemy