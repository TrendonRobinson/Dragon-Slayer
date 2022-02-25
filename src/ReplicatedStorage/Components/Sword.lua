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


function Sword:Start()
    while self.Instance do
        self.Instance.CFrame = ( self.Instance.CFrame *  CFrame.fromEulerAnglesXYZ(0, .1, 0) )
        task.wait()
    end
end

function Sword:Stop()
    self._trove:Destroy()
end

return Sword