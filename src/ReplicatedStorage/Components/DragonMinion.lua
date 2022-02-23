--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)


--// Component
local Tag = "DragonMinion"
local Dragon = Component.new({Tag = Tag})

--// Variables
local Animations = ReplicatedStorage.Animations[Tag]


function Dragon:Construct()
    self._trove = Trove.new()
end

function Dragon:DeathInit()
    local Humanoid = self.Humanoid
    local Connection
    
    self.Instance.HumanoidRootPart.Anchored = true

    Connection = Humanoid.Died:Connect(function()
        local DeathAnim = Humanoid:LoadAnimation(Animations.Death)
        DeathAnim:Play()
        DeathAnim.Stopped:Connect(function()
            DeathAnim:Play()
            DeathAnim.TimePosition = DeathAnim.Length
            DeathAnim:AdjustSpeed(0)
        end)
    end)
end

function Dragon:TrackHealth()
    local Health = self.Instance.HealthGUI
    self.Humanoid:GetPropertyChangedSignal('Health'):Connect(function()
        Health.Frame.Bar.Size = UDim2.fromScale(
            self.Humanoid.Health/self.Humanoid.MaxHealth,
            1
        )
    end)
end

function Dragon:Start()
    self.Humanoid = self.Instance.Humanoid
    self:TrackHealth()
    self:DeathInit()
end

function Dragon:Stop()
    self._trove:Destroy()
end

return Dragon